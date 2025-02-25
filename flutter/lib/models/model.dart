import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/models/ab_model.dart';
import 'package:flutter_hbb/models/chat_model.dart';
import 'package:flutter_hbb/models/cm_file_model.dart';
import 'package:flutter_hbb/models/file_model.dart';
import 'package:flutter_hbb/models/group_model.dart';
import 'package:flutter_hbb/models/peer_tab_model.dart';
import 'package:flutter_hbb/models/server_model.dart';
import 'package:flutter_hbb/models/user_model.dart';
import 'package:flutter_hbb/models/state_model.dart';
import 'package:flutter_hbb/models/desktop_render_texture.dart';
//import 'package:flutter_hbb/plugin/event.dart';
//import 'package:flutter_hbb/plugin/manager.dart';
//import 'package:flutter_hbb/plugin/widgets/desc_ui.dart';
import 'package:flutter_hbb/common/shared_state.dart';
import 'package:flutter_hbb/utils/multi_window_manager.dart';
import 'package:tuple/tuple.dart';
import 'package:image/image.dart' as img2;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';

import '../common.dart';
import '../utils/image.dart' as img;
import '../common/widgets/dialog.dart';
import 'input_model.dart';
import 'platform_model.dart';

import 'package:flutter_hbb/generated_bridge.dart'
    if (dart.library.html) 'package:flutter_hbb/web/bridge.dart';
import 'package:flutter_hbb/native/custom_cursor.dart'
    if (dart.library.html) 'package:flutter_hbb/web/custom_cursor.dart';
    
typedef HandleMsgBox = Function(Map<String, dynamic> evt, String id);
typedef ReconnectHandle = Function(OverlayDialogManager, SessionID, bool);
final _constSessionId = Uuid().v4obj();

class CachedPeerData {
  Map<String, dynamic> updatePrivacyMode = {};
  Map<String, dynamic> peerInfo = {};
  List<Map<String, dynamic>> cursorDataList = [];
  Map<String, dynamic> lastCursorId = {};
  Map<String, bool> permissions = {};
  bool secure = false;
  bool direct = false;

  CachedPeerData();

  @override
  String toString() {
    return jsonEncode({
      'updatePrivacyMode': updatePrivacyMode,
      'peerInfo': peerInfo,
      'cursorDataList': cursorDataList,
      'lastCursorId': lastCursorId,
      'permissions': permissions,
      'secure': secure,
      'direct': direct,
    });
  }

  static CachedPeerData? fromString(String s) {
    try {
      final map = jsonDecode(s);
      final data = CachedPeerData();
      data.updatePrivacyMode = map['updatePrivacyMode'];
      data.peerInfo = map['peerInfo'];
      for (final cursorData in map['cursorDataList']) {
        data.cursorDataList.add(cursorData);
      }
      data.lastCursorId = map['lastCursorId'];
      map['permissions'].forEach((key, value) {
        data.permissions[key] = value;
      });
      data.secure = map['secure'];
      data.direct = map['direct'];
      return data;
    } catch (e) {
      debugPrint('Failed to parse CachedPeerData: $e');
      return null;
    }
  }
}

class FfiModel with ChangeNotifier {
  CachedPeerData cachedPeerData = CachedPeerData();
  PeerInfo _pi = PeerInfo();
  Rect? _rect;

  var _inputBlocked = false;
  final _permissions = <String, bool>{};
  bool? _secure;
  bool? _direct;
  bool _touchMode = false;
  Timer? _timer;
  var _reconnects = 1;
  bool _viewOnly = false;
  WeakReference<FFI> parent;
  late final SessionID sessionId;

  RxBool waitForImageDialogShow = true.obs;
  Timer? waitForImageTimer;
  RxBool waitForFirstImage = true.obs;
  bool isRefreshing = false;

  Rect? get rect => _rect;
  bool get isOriginalResolutionSet =>
      _pi.tryGetDisplayIfNotAllDisplay()?.isOriginalResolutionSet ?? false;
  bool get isVirtualDisplayResolution =>
      _pi.tryGetDisplayIfNotAllDisplay()?.isVirtualDisplayResolution ?? false;
  bool get isOriginalResolution =>
      _pi.tryGetDisplayIfNotAllDisplay()?.isOriginalResolution ?? false;

  Map<String, bool> get permissions => _permissions;
  setPermissions(Map<String, bool> permissions) {
    _permissions.clear();
    _permissions.addAll(permissions);
  }

  bool? get secure => _secure;

  bool? get direct => _direct;

  PeerInfo get pi => _pi;

  bool get inputBlocked => _inputBlocked;

  bool get touchMode => _touchMode;

  bool get isPeerAndroid => _pi.platform == kPeerPlatformAndroid;

  bool get viewOnly => _viewOnly;

  set inputBlocked(v) {
    _inputBlocked = v;
  }

  FfiModel(this.parent) {
    clear();
    sessionId = parent.target!.sessionId;
    cachedPeerData.permissions = _permissions;
  }

  Rect? globalDisplaysRect() => _getDisplaysRect(_pi.displays, true);
  Rect? displaysRect() => _getDisplaysRect(_pi.getCurDisplays(), false);
  Rect? _getDisplaysRect(List<Display> displays, bool useDisplayScale) {
    if (displays.isEmpty) {
      return null;
    }
    int scale(int len, double s) {
      if (useDisplayScale) {
        return len.toDouble() ~/ s;
      } else {
        return len;
      }
    }

    double l = displays[0].x;
    double t = displays[0].y;
    double r = displays[0].x + scale(displays[0].width, displays[0].scale);
    double b = displays[0].y + scale(displays[0].height, displays[0].scale);
    for (var display in displays.sublist(1)) {
      l = min(l, display.x);
      t = min(t, display.y);
      r = max(r, display.x + scale(display.width, display.scale));
      b = max(b, display.y + scale(display.height, display.scale));
    }
    return Rect.fromLTRB(l, t, r, b);
  }
  
  toggleTouchMode() {
    if (!isPeerAndroid) {
      _touchMode = !_touchMode;
      notifyListeners();
    }
  }

  updatePermission(Map<String, dynamic> evt, String id) {
    evt.forEach((k, v) {
      if (k == 'name' || k.isEmpty) return;
      _permissions[k] = v == 'true';
    });
    // Only inited at remote page
    if (desktopType == DesktopType.remote) {
      KeyboardEnabledState.find(id).value = _permissions['keyboard'] != false;
    }
    debugPrint('updatePermission: $_permissions');
    notifyListeners();
  }

  bool get keyboard => _permissions['keyboard'] != false;

  clear() {
    _pi = PeerInfo();
    _secure = null;
    _direct = null;
    _inputBlocked = false;
    _timer?.cancel();
    _timer = null;
    clearPermissions();
    waitForImageTimer?.cancel();
  }

  setConnectionType(String peerId, bool secure, bool direct) {
    cachedPeerData.secure = secure;
    cachedPeerData.direct = direct;
    _secure = secure;
    _direct = direct;
    try {
      var connectionType = ConnectionTypeState.find(peerId);
      connectionType.setSecure(secure);
      connectionType.setDirect(direct);
    } catch (e) {
      //
    }
  }

  Widget? getConnectionImage() {
    if (secure == null || direct == null) {
      return null;
    } else {
      final icon =
          '${secure == true ? 'secure' : 'insecure'}${direct == true ? '' : '_relay'}';
      return SvgPicture.asset('assets/$icon.svg', width: 48, height: 48);
    }
  }

  clearPermissions() {
    _inputBlocked = false;
    _permissions.clear();
  }

  handleCachedPeerData(CachedPeerData data, String peerId) async {
    handleMsgBox({
      'type': 'success',
      'title': 'Successful',
      'text': kMsgboxTextWaitingForImage,
      'link': '',
    }, sessionId, peerId);
    updatePrivacyMode(data.updatePrivacyMode, sessionId, peerId);
    setConnectionType(peerId, data.secure, data.direct);
    await handlePeerInfo(data.peerInfo, peerId, true);
    for (final element in data.cursorDataList) {
      updateLastCursorId(element);
      await handleCursorData(element);
    }
    if (data.lastCursorId.isNotEmpty) {
      updateLastCursorId(data.lastCursorId);
      handleCursorId(data.lastCursorId);
    }
  }
  // todo: why called by two position
  StreamEventHandler startEventListener(SessionID sessionId, String peerId) {
    return (evt) async {
      var name = evt['name'];
      if (name == 'msgbox') {
        handleMsgBox(evt, sessionId, peerId);
      } else if (name == 'set_multiple_windows_session') {
        handleMultipleWindowsSession(evt, sessionId, peerId);
      } else if (name == 'peer_info') {
        handlePeerInfo(evt, peerId, false);
      } else if (name == 'sync_peer_info') {
        handleSyncPeerInfo(evt, sessionId, peerId);
      } else if (name == 'sync_platform_additions') {
        handlePlatformAdditions(evt, sessionId, peerId);
      } else if (name == 'connection_ready') {
        setConnectionType(
            peerId, evt['secure'] == 'true', evt['direct'] == 'true');
      } else if (name == 'switch_display') {
        // switch display is kept for backward compatibility
        handleSwitchDisplay(evt, sessionId, peerId);
      } else if (name == 'cursor_data') {
        updateLastCursorId(evt);
        await handleCursorData(evt);
      } else if (name == 'cursor_id') {
        updateLastCursorId(evt);
        handleCursorId(evt);
      } else if (name == 'cursor_position') {
        await parent.target?.cursorModel.updateCursorPosition(evt, peerId);
      } else if (name == 'clipboard') {
        Clipboard.setData(ClipboardData(text: evt['content']));
      } else if (name == 'permission') {
        updatePermission(evt, peerId);
      } else if (name == 'chat_client_mode') {
        parent.target?.chatModel
            .receive(ChatModel.clientModeID, evt['text'] ?? '');
      } else if (name == 'chat_server_mode') {
        parent.target?.chatModel
            .receive(int.parse(evt['id'] as String), evt['text'] ?? '');
      } else if (name == 'file_dir') {
        parent.target?.fileModel.receiveFileDir(evt);
      } else if (name == 'job_progress') {
        parent.target?.fileModel.jobController.tryUpdateJobProgress(evt);
      } else if (name == 'job_done') {
        parent.target?.fileModel.jobController.jobDone(evt);
        parent.target?.fileModel.refreshAll();
      } else if (name == 'job_error') {
        parent.target?.fileModel.jobController.jobError(evt);
      } else if (name == 'override_file_confirm') {
        parent.target?.fileModel.postOverrideFileConfirm(evt);
      } else if (name == 'load_last_job') {
        parent.target?.fileModel.jobController.loadLastJob(evt);
      } else if (name == 'update_folder_files') {
        parent.target?.fileModel.jobController.updateFolderFiles(evt);
      } else if (name == 'add_connection') {
        parent.target?.serverModel.addConnection(evt);
      } else if (name == 'on_client_remove') {
        parent.target?.serverModel.onClientRemove(evt);
      } else if (name == 'update_quality_status') {
        parent.target?.qualityMonitorModel.updateQualityStatus(evt);
      } else if (name == 'update_block_input_state') {
        updateBlockInputState(evt, peerId);
      } else if (name == 'update_privacy_mode') {
        updatePrivacyMode(evt, sessionId, peerId);
      } else if (name == 'show_elevation') {
        final show = evt['show'].toString() == 'true';
        parent.target?.serverModel.setShowElevation(show);
      } else if (name == 'cancel_msgbox') {
        cancelMsgBox(evt, sessionId);
      } else if (name == 'switch_back') {
        final peer_id = evt['peer_id'].toString();
        await bind.sessionSwitchSides(sessionId: sessionId);
        closeConnection(id: peer_id);
      } else if (name == 'portable_service_running') {
        _handlePortableServiceRunning(peerId, evt);
      //} else if (name == 'on_url_scheme_received') {
        // currently comes from "_url" ipc of mac and dbus of linux
        //onUrlSchemeReceived(evt);
      } else if (name == 'on_voice_call_waiting') {
        // Waiting for the response from the peer.
        parent.target?.chatModel.onVoiceCallWaiting();
      } else if (name == 'on_voice_call_started') {
        // Voice call is connected.
        parent.target?.chatModel.onVoiceCallStarted();
      } else if (name == 'on_voice_call_closed') {
        // Voice call is closed with reason.
        final reason = evt['reason'].toString();
        parent.target?.chatModel.onVoiceCallClosed(reason);
      } else if (name == 'on_voice_call_incoming') {
        // Voice call is requested by the peer.
        parent.target?.chatModel.onVoiceCallIncoming();
      } else if (name == 'update_voice_call_state') {
        parent.target?.serverModel.updateVoiceCallState(evt);
      //} else if (name == 'fingerprint') {
      //  FingerprintState.find(peerId).value = evt['fingerprint'] ?? '';
      //} else if (name == 'plugin_manager') {
      //  pluginManager.handleEvent(evt);
      //} else if (name == 'plugin_event') {
      //  handlePluginEvent(evt,
      //      (Map<String, dynamic> e) => handleMsgBox(e, sessionId, peerId));
      //} else if (name == 'plugin_reload') {
      //  handleReloading(evt);
      //} else if (name == 'plugin_option') {
      //  handleOption(evt);
      } else if (name == "sync_peer_hash_password_to_personal_ab") {
        if (desktopType == DesktopType.main) {
          final id = evt['id'];
          final hash = evt['hash'];
          if (id != null && hash != null) {
            gFFI.abModel
                .changePersonalHashPassword(id.toString(), hash.toString());
          }
        }
      } else if (name == "cm_file_transfer_log") {
        if (isDesktop) {
          gFFI.cmFileModel.onFileTransferLog(evt);
        }
      } else if (name == 'sync_peer_option') {
        _handleSyncPeerOption(evt, peerId);
      } else if (name == 'follow_current_display') {
        handleFollowCurrentDisplay(evt, sessionId, peerId);
      } else if (name == 'use_texture_render') {
        _handleUseTextureRender(evt, sessionId, peerId);
      } else {
        debugPrint('Unknown event name: $name');
      }
    };
  }

  _handleUseTextureRender(
      Map<String, dynamic> evt, SessionID sessionId, String peerId) {
    parent.target?.imageModel.setUseTextureRender(evt['v'] == 'Y');
    waitForFirstImage.value = true;
    isRefreshing = true;
    showConnectedWaitingForImage(parent.target!.dialogManager, sessionId,
        'success', 'Successful', kMsgboxTextWaitingForImage);
  }

  _handleSyncPeerOption(Map<String, dynamic> evt, String peer) {
    final k = evt['k'];
    final v = evt['v'];
    if (k == kOptionToggleViewOnly) {
      setViewOnly(peer, v as bool);
    } else if (k == 'keyboard_mode') {
      parent.target?.inputModel.updateKeyboardMode();
    } else if (k == 'input_source') {
      stateGlobal.getInputSource(force: true);
    }
  }

/*
  onUrlSchemeReceived(Map<String, dynamic> evt) {
    final url = evt['url'].toString().trim();
    if (url.startsWith(bind.mainUriPrefixSync()) &&
        handleUriLink(uriString: url)) {
      return;
    }
    switch (url) {
      case kUrlActionClose:
        debugPrint("closing all instances");
        Future.microtask(() async {
          await rustDeskWinManager.closeAllSubWindows();
          windowManager.close();
        });
        break;
      default:
        windowOnTop(null);
        break;
    }
  }
*/
  /// Bind the event listener to receive events from the Rust core.
  updateEventListener(SessionID sessionId, String peerId) {
    platformFFI.setEventCallback(startEventListener(sessionId, peerId));
  }

  _handlePortableServiceRunning(String peerId, Map<String, dynamic> evt) {
    final running = evt['running'] == 'true';
    parent.target?.elevationModel.onPortableServiceRunning(running);
  }

  handleAliasChanged(Map<String, dynamic> evt) {
    if (!(isDesktop || isWebDesktop)) return;
    final String peerId = evt['id'];
    final String alias = evt['alias'];
    String label = getDesktopTabLabel(peerId, alias);
    final rxTabLabel = PeerStringOption.find(evt['id'], 'tabLabel');
    if (rxTabLabel.value != label) {
      rxTabLabel.value = label;
    }
  }
  
  updateCurDisplay(SessionID sessionId, {updateCursorPos = false}) {
    final newRect = displaysRect();
    if (newRect == null) {
      return;
    }
    if (newRect != _rect) {
      if (newRect.left != _rect?.left || newRect.top != _rect?.top) {
        parent.target?.cursorModel.updateDisplayOrigin(
            newRect.left, newRect.top,
            updateCursorPos: updateCursorPos);
      }
      _rect = newRect;
      parent.target?.canvasModel
          .updateViewStyle(refreshMousePos: updateCursorPos);
      _updateSessionWidthHeight(sessionId);
    }
  }

  handleSwitchDisplay(
      Map<String, dynamic> evt, SessionID sessionId, String peerId) {
    final display = int.parse(evt['display']);

    if (_pi.currentDisplay != kAllDisplayValue) {
      if (bind.peerGetDefaultSessionsCount(id: peerId) > 1) {
        if (display != _pi.currentDisplay) {
          return;
        }
      }
      if (!_pi.isSupportMultiUiSession) {
        _pi.currentDisplay = display;
      }
      // If `isSupportMultiUiSession` is true, the switch display message should not be used to update current display.
      // It is only used to update the display info.
    }

    var newDisplay = Display();
    newDisplay.x = double.tryParse(evt['x']) ?? newDisplay.x;
    newDisplay.y = double.tryParse(evt['y']) ?? newDisplay.y;
    newDisplay.width = int.tryParse(evt['width']) ?? newDisplay.width;
    newDisplay.height = int.tryParse(evt['height']) ?? newDisplay.height;
    newDisplay.cursorEmbedded = int.tryParse(evt['cursor_embedded']) == 1;
    newDisplay.originalWidth =
        int.tryParse(evt['original_width']) ?? kInvalidResolutionValue;
    newDisplay.originalHeight =
        int.tryParse(evt['original_height']) ?? kInvalidResolutionValue;
    newDisplay._scale = _pi.scaleOfDisplay(display);
    _pi.displays[display] = newDisplay;

    if (!_pi.isSupportMultiUiSession || _pi.currentDisplay == display) {
      updateCurDisplay(sessionId);
    }

    if (!_pi.isSupportMultiUiSession) {
      try {
        CurrentDisplayState.find(peerId).value = display;
      } catch (e) {
        //
      }
    }

    parent.target?.recordingModel.onSwitchDisplay();
    if (!_pi.isSupportMultiUiSession || _pi.currentDisplay == display) {
      handleResolutions(peerId, evt['resolutions']);
    }
    notifyListeners();
  }

  cancelMsgBox(Map<String, dynamic> evt, SessionID sessionId) {
    if (parent.target == null) return;
    final dialogManager = parent.target!.dialogManager;
    final tag = '$sessionId-${evt['tag']}';
    dialogManager.dismissByTag(tag);
  }

  handleMultipleWindowsSession(
      Map<String, dynamic> evt, SessionID sessionId, String peerId) {
    if (parent.target == null) return;
    final dialogManager = parent.target!.dialogManager;
    final sessions = evt['windows_sessions'];
    final title = translate('Multiple Windows sessions found');
    final text = translate('Please select the session you want to connect to');
    final type = "";

    showWindowsSessionsDialog(
        type, title, text, dialogManager, sessionId, peerId, sessions);
  }
  
  /// Handle the message box event based on [evt] and [id].
  handleMsgBox(Map<String, dynamic> evt, SessionID sessionId, String peerId) {
    if (parent.target == null) return;
    final dialogManager = parent.target!.dialogManager;
    final type = evt['type'];
    final title = evt['title'];
    final text = evt['text'];
    final link = evt['link'];
    if (type == 're-input-password') {
      wrongPasswordDialog(sessionId, dialogManager, type, title, text);
    } else if (type == 'input-2fa') {
      enter2FaDialog(sessionId, dialogManager);
    } else if (type == 'input-password') {
      enterPasswordDialog(sessionId, dialogManager);
    } else if (type == 'session-login' || type == 'session-re-login') {
      enterUserLoginDialog(sessionId, dialogManager);
    } else if (type == 'session-login-password' ||
        type == 'session-login-password') {
      enterUserLoginAndPasswordDialog(sessionId, dialogManager);
    } else if (type == 'restarting') {
      showMsgBox(sessionId, type, title, text, link, false, dialogManager,
          hasCancel: false);
    } else if (type == 'wait-remote-accept-nook') {
      showWaitAcceptDialog(sessionId, type, title, text, dialogManager);
    } else if (type == 'on-uac' || type == 'on-foreground-elevated') {
      showOnBlockDialog(sessionId, type, title, text, dialogManager);
    } else if (type == 'wait-uac') {
      showWaitUacDialog(sessionId, dialogManager, type);
    } else if (type == 'elevation-error') {
      showElevationError(sessionId, type, title, text, dialogManager);
    } else if (type == 'relay-hint' || type == 'relay-hint2') {
      showRelayHintDialog(sessionId, type, title, text, dialogManager, peerId);
    } else if (text == kMsgboxTextWaitingForImage) {
      showConnectedWaitingForImage(dialogManager, sessionId, type, title, text);
    } else if (title == 'Privacy mode') {
      final hasRetry = evt['hasRetry'] == 'true';
      showPrivacyFailedDialog(
          sessionId, type, title, text, link, hasRetry, dialogManager);
    } else {
      final hasRetry = evt['hasRetry'] == 'true';
      showMsgBox(sessionId, type, title, text, link, hasRetry, dialogManager);
    }
  }

  /// Show a message box with [type], [title] and [text].
  showMsgBox(SessionID sessionId, String type, String title, String text,
      String link, bool hasRetry, OverlayDialogManager dialogManager,
      {bool? hasCancel}) {
    msgBox(sessionId, type, title, text, link, dialogManager,
        hasCancel: hasCancel,
        reconnect: reconnect,
        reconnectTimeout: hasRetry ? _reconnects : null);
    _timer?.cancel();
    if (hasRetry) {
      _timer = Timer(Duration(seconds: _reconnects), () {
        reconnect(dialogManager, sessionId, false);
      });
      _reconnects *= 2;
    } else {
      _reconnects = 1;
    }
  }

  void reconnect(OverlayDialogManager dialogManager, SessionID sessionId,
      bool forceRelay) {
    bind.sessionReconnect(sessionId: sessionId, forceRelay: forceRelay);
    clearPermissions();
    dialogManager.dismissAll();
    dialogManager.showLoading(translate('Connecting...'),
        onCancel: closeConnection);
  }

  void showRelayHintDialog(SessionID sessionId, String type, String title,
      String text, OverlayDialogManager dialogManager, String peerId) {
    dialogManager.show(tag: '$sessionId-$type', (setState, close, context) {
      onClose() {
        closeConnection();
        close();
      }

      final style =
          ElevatedButton.styleFrom(backgroundColor: Colors.green[700]);
      var hint = "\n\n${translate('relay_hint_tip')}";
      if (text.contains("10054") || text.contains("104")) {
        hint = "";
      }
      return CustomAlertDialog(
        title: null,
        content: msgboxContent(type, title, "${translate(text)}$hint"),
        actions: [
          dialogButton('Close', onPressed: onClose, isOutline: true),
          if (type == 'relay-hint')
            dialogButton('Connect via relay',
                onPressed: () => reconnect(dialogManager, sessionId, true),
                buttonStyle: style,
                isOutline: true),
          dialogButton('Retry',
              onPressed: () => reconnect(dialogManager, sessionId, false)),
          if (type == 'relay-hint2')
            dialogButton('Connect via relay',
                onPressed: () => reconnect(dialogManager, sessionId, true),
                buttonStyle: style),
        ],
        onCancel: onClose,
      );
    });
  }

  void showConnectedWaitingForImage(OverlayDialogManager dialogManager,
      SessionID sessionId, String type, String title, String text) {
    onClose() {
      closeConnection();
    }

    if (waitForFirstImage.isFalse) return;
    dialogManager.show(
      (setState, close, context) => CustomAlertDialog(
          title: null,
          content: SelectionArea(child: msgboxContent(type, title, text)),
          actions: [
            dialogButton("Cancel", onPressed: onClose, isOutline: true)
          ],
          onCancel: onClose),
      tag: '$sessionId-waiting-for-image',
    );
    waitForImageDialogShow.value = true;
    waitForImageTimer = Timer(Duration(milliseconds: 1500), () {
      if (waitForFirstImage.isTrue && !isRefreshing) {
        bind.sessionInputOsPassword(sessionId: sessionId, value: '');
      }
    });
    bind.sessionOnWaitingForImageDialogShow(sessionId: sessionId);
  }

  void showPrivacyFailedDialog(
      SessionID sessionId,
      String type,
      String title,
      String text,
      String link,
      bool hasRetry,
      OverlayDialogManager dialogManager) {
    if (text == 'no_need_privacy_mode_no_physical_displays_tip' ||
        text == 'Enter privacy mode') {
      // There are display changes on the remote side,
      // which will cause some messages to refresh the canvas and dismiss dialogs.
      // So we add a delay here to ensure the dialog is displayed.
      Future.delayed(Duration(milliseconds: 3000), () {
        showMsgBox(sessionId, type, title, text, link, hasRetry, dialogManager);
      });
    } else {
      showMsgBox(sessionId, type, title, text, link, hasRetry, dialogManager);
    }
  }

  _updateSessionWidthHeight(SessionID sessionId) {
    if (_rect == null) return;
    if (_rect!.width <= 0 || _rect!.height <= 0) {
      debugPrintStack(
          label: 'invalid display size (${_rect!.width},${_rect!.height})');
    } else {
      final displays = _pi.getCurDisplays();
      if (displays.length == 1) {
        bind.sessionSetSize(
          sessionId: sessionId,
          display:
              pi.currentDisplay == kAllDisplayValue ? 0 : pi.currentDisplay,
          width: _rect!.width.toInt(),
          height: _rect!.height.toInt(),
        );
      } else {
        for (int i = 0; i < displays.length; ++i) {
          bind.sessionSetSize(
            sessionId: sessionId,
            display: i,
            width: displays[i].width.toInt(),
            height: displays[i].height.toInt(),
          );
        }
      }
    }
  }

  /// Handle the peer info event based on [evt].
  handlePeerInfo(Map<String, dynamic> evt, String peerId, bool isCache) async {
    // This call is to ensuer the keyboard mode is updated depending on the peer version.
    parent.target?.inputModel.updateKeyboardMode();
    
    // Map clone is required here, otherwise "evt" may be changed by other threads through the reference.
    // Because this function is asynchronous, there's an "await" in this function.
    cachedPeerData.peerInfo = {...evt};
    // Do not cache resolutions, because a new display connection have different resolutions.
    cachedPeerData.peerInfo.remove('resolutions');

    // Recent peer is updated by handle_peer_info(ui_session_interface.rs) --> handle_peer_info(client.rs) --> save_config(client.rs)
    bind.mainLoadRecentPeers();

    parent.target?.dialogManager.dismissAll();
    _pi.version = evt['version'];
    _pi.isSupportMultiUiSession =
        bind.isSupportMultiUiSession(version: _pi.version);
    _pi.username = evt['username'];
    _pi.hostname = evt['hostname'];
    _pi.platform = evt['platform'];
    _pi.sasEnabled = evt['sas_enabled'] == 'true';
    final currentDisplay = int.parse(evt['current_display']);
    if (_pi.primaryDisplay == kInvalidDisplayIndex) {
      _pi.primaryDisplay = currentDisplay;
    }

    if (bind.peerGetDefaultSessionsCount(id: peerId) <= 1) {
      _pi.currentDisplay = currentDisplay;
    }

    try {
      CurrentDisplayState.find(peerId).value = _pi.currentDisplay;
    } catch (e) {
      //
    }

    final connType = parent.target?.connType;
    if (isPeerAndroid) {
      _touchMode = true;
    } else {
      _touchMode = await bind.sessionGetOption(
              sessionId: sessionId, arg: kOptionTouchMode) !=
          '';
    }
    if (connType == ConnType.fileTransfer) {
      parent.target?.fileModel.onReady();
    } else if (connType == ConnType.defaultConn) {
      List<Display> newDisplays = [];
      List<dynamic> displays = json.decode(evt['displays']);
      for (int i = 0; i < displays.length; ++i) {
        newDisplays.add(evtToDisplay(displays[i]));
      }
      _pi.displays.value = newDisplays;
      _pi.displaysCount.value = _pi.displays.length;
      if (_pi.currentDisplay < _pi.displays.length) {
        // now replaced to _updateCurDisplay
        updateCurDisplay(sessionId);
      }
      if (displays.isNotEmpty) {
        _reconnects = 1;
        waitForFirstImage.value = true;
        isRefreshing = false;
      }
      Map<String, dynamic> features = json.decode(evt['features']);
      _pi.features.privacyMode = features['privacy_mode'] == 1;
      if (!isCache) {
        handleResolutions(peerId, evt["resolutions"]);
      }
      parent.target?.elevationModel.onPeerInfo(_pi);
    }
    if (connType == ConnType.defaultConn) {
      setViewOnly(
          peerId,
          bind.sessionGetToggleOptionSync(
              sessionId: sessionId, arg: kOptionToggleViewOnly));
    }
    if (connType == ConnType.defaultConn) {
      final platformAdditions = evt['platform_additions'];
      if (platformAdditions != null && platformAdditions != '') {
        try {
          _pi.platformAdditions = json.decode(platformAdditions);
        } catch (e) {
          debugPrint('Failed to decode platformAdditions $e');
        }
      }
    }

    _pi.isSet.value = true;
    stateGlobal.resetLastResolutionGroupValues(peerId);

    if (isDesktop || isWebDesktop) {
      checkDesktopKeyboardMode();
    }

    notifyListeners();

    if (!isCache) {
      tryUseAllMyDisplaysForTheRemoteSession(peerId);
    }
  }

  checkDesktopKeyboardMode() async {
    if (isInputSourceFlutter) {
      // Local side, flutter keyboard input source
      // Currently only map mode is supported, legacy mode is used for compatibility.
      for (final mode in [kKeyMapMode, kKeyLegacyMode]) {
        if (bind.sessionIsKeyboardModeSupported(
            sessionId: sessionId, mode: mode)) {
          bind.sessionSetKeyboardMode(sessionId: sessionId, value: mode);
          break;
        }
      }
    } else {
      final curMode = await bind.sessionGetKeyboardMode(sessionId: sessionId);
      if (curMode != null) {
        if (bind.sessionIsKeyboardModeSupported(
            sessionId: sessionId, mode: curMode)) {
          return;
        }
      }

      // If current keyboard mode is not supported, change to another one.
      for (final mode in [kKeyMapMode, kKeyTranslateMode, kKeyLegacyMode]) {
        if (bind.sessionIsKeyboardModeSupported(
            sessionId: sessionId, mode: mode)) {
          bind.sessionSetKeyboardMode(sessionId: sessionId, value: mode);
          break;
        }
      }
    }
  }

  tryUseAllMyDisplaysForTheRemoteSession(String peerId) async {
    if (bind.sessionGetUseAllMyDisplaysForTheRemoteSession(
            sessionId: sessionId) !=
        'Y') {
      return;
    }

    if (!_pi.isSupportMultiDisplay || _pi.displays.length <= 1) {
      return;
    }

    final screenRectList = await getScreenRectList();
    if (screenRectList.length <= 1) {
      return;
    }

    // to-do: peer currentDisplay is the primary display, but the primary display may not be the first display.
    // local primary display also may not be the first display.
    //
    // 0 is assumed to be the primary display here, for now.

    // move to the first display and set fullscreen
    bind.sessionSwitchDisplay(
      isDesktop: isDesktop,
      sessionId: sessionId,
      value: Int32List.fromList([0]),
    );
    _pi.currentDisplay = 0;
    try {
      CurrentDisplayState.find(peerId).value = _pi.currentDisplay;
    } catch (e) {
      //
    }
    await tryMoveToScreenAndSetFullscreen(screenRectList[0]);

    final length = _pi.displays.length < screenRectList.length
        ? _pi.displays.length
        : screenRectList.length;
    for (var i = 1; i < length; i++) {
      openMonitorInNewTabOrWindow(i, peerId, _pi,
          screenRect: screenRectList[i]);
    }
  }

  tryShowAndroidActionsOverlay({int delayMSecs = 10}) {
    if (isPeerAndroid) {
      if (parent.target?.connType == ConnType.defaultConn &&
          parent.target != null &&
          parent.target!.ffiModel.permissions['keyboard'] != false) {
        Timer(Duration(milliseconds: delayMSecs), () {
          if (parent.target!.dialogManager.mobileActionsOverlayVisible.isTrue) {
            parent.target!.dialogManager
                .showMobileActionsOverlay(ffi: parent.target!);
          }
        });
      }
    }
  }

  handleResolutions(String id, dynamic resolutions) {
    try {
      final resolutionsObj = json.decode(resolutions as String);
      late List<dynamic> dynamicArray;
      if (resolutionsObj is Map) {
        // The web version
        dynamicArray = (resolutionsObj as Map<String, dynamic>)['resolutions']
            as List<dynamic>;
      } else {
        // The rust version
        dynamicArray = resolutionsObj as List<dynamic>;
      }
      List<Resolution> arr = List.empty(growable: true);
      for (int i = 0; i < dynamicArray.length; i++) {
        var width = dynamicArray[i]["width"];
        var height = dynamicArray[i]["height"];
        if (width is int && width > 0 && height is int && height > 0) {
          arr.add(Resolution(width, height));
        }
      }
      arr.sort((a, b) {
        if (b.width != a.width) {
          return b.width - a.width;
        } else {
          return b.height - a.height;
        }
      });
      _pi.resolutions = arr;
    } catch (e) {
      debugPrint("Failed to parse resolutions:$e");
    }
  }

  Display evtToDisplay(Map<String, dynamic> evt) {
    var d = Display();
    d.x = evt['x']?.toDouble() ?? d.x;
    d.y = evt['y']?.toDouble() ?? d.y;
    d.width = evt['width'] ?? d.width;
    d.height = evt['height'] ?? d.height;
    d.cursorEmbedded = evt['cursor_embedded'] == 1;
    d.originalWidth = evt['original_width'] ?? kInvalidResolutionValue;
    d.originalHeight = evt['original_height'] ?? kInvalidResolutionValue;
    double v = (evt['scale']?.toDouble() ?? 100.0) / 100;
    d._scale = v > 1.0 ? v : 1.0;
    return d;
  }

  updateLastCursorId(Map<String, dynamic> evt) {
    // int.parse(evt['id']) may cause FormatException
    // Unhandled Exception: FormatException: Positive input exceeds the limit of integer 18446744071749110741
    parent.target?.cursorModel.id = evt['id'];
  }

  handleCursorId(Map<String, dynamic> evt) {
    cachedPeerData.lastCursorId = evt;
    parent.target?.cursorModel.updateCursorId(evt);
  }

  handleCursorData(Map<String, dynamic> evt) async {
    cachedPeerData.cursorDataList.add(evt);
    await parent.target?.cursorModel.updateCursorData(evt);
  }

  /// Handle the peer info synchronization event based on [evt].
  handleSyncPeerInfo(
      Map<String, dynamic> evt, SessionID sessionId, String peerId) async {
    if (evt['displays'] != null) {
      cachedPeerData.peerInfo['displays'] = evt['displays'];
      List<dynamic> displays = json.decode(evt['displays']);
      List<Display> newDisplays = [];
      for (int i = 0; i < displays.length; ++i) {
        newDisplays.add(evtToDisplay(displays[i]));
      }
      _pi.displays.value = newDisplays;
      _pi.displaysCount.value = _pi.displays.length;

      if (_pi.currentDisplay == kAllDisplayValue) {
        updateCurDisplay(sessionId);
        // to-do: What if the displays are changed?
      } else {
        if (_pi.currentDisplay >= 0 &&
            _pi.currentDisplay < _pi.displays.length) {
          updateCurDisplay(sessionId);
        } else {
          if (_pi.displays.isNotEmpty) {
            // Notify to switch display
            msgBox(sessionId, 'custom-nook-nocancel-hasclose-info', 'Prompt',
                'display_is_plugged_out_msg', '', parent.target!.dialogManager);
            final newDisplay = pi.primaryDisplay == kInvalidDisplayIndex
                ? 0
                : pi.primaryDisplay;
            final displays = newDisplay;
            bind.sessionSwitchDisplay(
              isDesktop: isDesktop,
              sessionId: sessionId,
              value: Int32List.fromList([displays]),
            );

            if (_pi.isSupportMultiUiSession) {
              // If the peer supports multi-ui-session, no switch display message will be send back.
              // We need to update the display manually.
              switchToNewDisplay(newDisplay, sessionId, peerId);
            }
          } else {
            msgBox(sessionId, 'nocancel-error', 'Prompt', 'No Displays', '',
                parent.target!.dialogManager);
          }
        }
      }
    }
    parent.target!.canvasModel
        .tryUpdateScrollStyle(Duration(milliseconds: 300), null);
    notifyListeners();
  }

  handlePlatformAdditions(
      Map<String, dynamic> evt, SessionID sessionId, String peerId) async {
    final updateData = evt['platform_additions'] as String?;
    if (updateData == null) {
      return;
    }

    if (updateData.isEmpty) {
      _pi.platformAdditions.remove(kPlatformAdditionsRustDeskVirtualDisplays);
      _pi.platformAdditions.remove(kPlatformAdditionsAmyuniVirtualDisplays);
    } else {
      try {
        final updateJson = json.decode(updateData) as Map<String, dynamic>;
        for (final key in updateJson.keys) {
          _pi.platformAdditions[key] = updateJson[key];
        }
        if (!updateJson
            .containsKey(kPlatformAdditionsRustDeskVirtualDisplays)) {
          _pi.platformAdditions
              .remove(kPlatformAdditionsRustDeskVirtualDisplays);
        }
        if (!updateJson.containsKey(kPlatformAdditionsAmyuniVirtualDisplays)) {
          _pi.platformAdditions.remove(kPlatformAdditionsAmyuniVirtualDisplays);
        }
      } catch (e) {
        debugPrint('Failed to decode platformAdditions $e');
      }
    }

    cachedPeerData.peerInfo['platform_additions'] =
        json.encode(_pi.platformAdditions);
  }

  handleFollowCurrentDisplay(
      Map<String, dynamic> evt, SessionID sessionId, String peerId) async {
    if (evt['display_idx'] != null) {
      if (pi.currentDisplay == kAllDisplayValue) {
        return;
      }
      _pi.currentDisplay = int.parse(evt['display_idx']);
      try {
        CurrentDisplayState.find(peerId).value = _pi.currentDisplay;
      } catch (e) {
        //
      }
      bind.sessionSwitchDisplay(
        isDesktop: isDesktop,
        sessionId: sessionId,
        value: Int32List.fromList([_pi.currentDisplay]),
      );
    }
    notifyListeners();
  }

  // Directly switch to the new display without waiting for the response.
  switchToNewDisplay(int display, SessionID sessionId, String peerId,
      {bool updateCursorPos = false}) {
    // VideoHandler creation is upon when video frames are received, so either caching commands(don't know next width/height) or stopping recording when switching displays.
    parent.target?.recordingModel.onClose();
    // no need to wait for the response
    pi.currentDisplay = display;
    updateCurDisplay(sessionId, updateCursorPos: updateCursorPos);
    try {
      CurrentDisplayState.find(peerId).value = display;
    } catch (e) {
      //
    }
  }


  updateBlockInputState(Map<String, dynamic> evt, String peerId) {
    _inputBlocked = evt['input_state'] == 'on';
    notifyListeners();
    try {
      BlockInputState.find(peerId).value = evt['input_state'] == 'on';
    } catch (e) {
      //
    }
  }

  updatePrivacyMode(
      Map<String, dynamic> evt, SessionID sessionId, String peerId) async {
    notifyListeners();
    try {
      final isOn = bind.sessionGetToggleOptionSync(
          sessionId: sessionId, arg: 'privacy-mode');
      if (isOn) {
        var privacyModeImpl = await bind.sessionGetOption(
            sessionId: sessionId, arg: 'privacy-mode-impl-key');
        // For compatibility, version < 1.2.4, the default value is 'privacy_mode_impl_mag'.
        final initDefaultPrivacyMode = 'privacy_mode_impl_mag';
        PrivacyModeState.find(peerId).value =
            privacyModeImpl ?? initDefaultPrivacyMode;
      } else {
        PrivacyModeState.find(peerId).value = '';
      }
    } catch (e) {
      //
    }
  }

  void setViewOnly(String id, bool value) {
    if (versionCmp(_pi.version, '1.40.5') < 0) return;
    // tmp fix for https://github.com/rustdesk/rustdesk/pull/3706#issuecomment-1481242389
    // because below rx not used in mobile version, so not initialized, below code will cause crash
    // current our flutter code quality is fucking shit now. !!!!!!!!!!!!!!!!
    try {
      if (value) {
        ShowRemoteCursorState.find(id).value = value;
      } else {
        ShowRemoteCursorState.find(id).value = bind.sessionGetToggleOptionSync(
            sessionId: sessionId, arg: 'show-remote-cursor');
      }
    } catch (e) {
      //
    }
    if (_viewOnly != value) {
      _viewOnly = value;
      notifyListeners();
    }
  }
}

class ImageModel with ChangeNotifier {
  ui.Image? _image;

  ui.Image? get image => _image;

  String id = '';

  late final SessionID sessionId;

  bool _useTextureRender = false;

  WeakReference<FFI> parent;

  final List<Function(String)> callbacksOnFirstImage = [];

  ImageModel(this.parent) {
    sessionId = parent.target!.sessionId;
  }

  get useTextureRender => _useTextureRender;

  addCallbackOnFirstImage(Function(String) cb) => callbacksOnFirstImage.add(cb);

  onRgba(int display, Uint8List rgba) {
    final pid = parent.target?.id;
    final rect = parent.target?.ffiModel.pi.getDisplayRect(display);
    img.decodeImageFromPixels(
        rgba,
        rect?.width.toInt() ?? 0,
        rect?.height.toInt() ?? 0,
        isWeb ? ui.PixelFormat.rgba8888 : ui.PixelFormat.bgra8888,
        onPixelsCopied: () {
      // Unlock the rgba memory from rust codes.
      platformFFI.nextRgba(sessionId, display);
    }).then((image) {
      if (parent.target?.id != pid) return;
      try {
        // my throw exception, because the listener maybe already dispose
        update(image);
      } catch (e) {
        debugPrint('update image: $e');
      }
    });
  }

  update(ui.Image? image) async {
    if (_image == null && image != null) {
      if (isDesktop || isWebDesktop) {
        await parent.target?.canvasModel.updateViewStyle();
        await parent.target?.canvasModel.updateScrollStyle();
      } else {
        final size = MediaQueryData.fromWindow(ui.window).size;
        final canvasWidth = size.width;
        final canvasHeight = size.height;
        final xscale = canvasWidth / image.width;
        final yscale = canvasHeight / image.height;
        parent.target?.canvasModel.scale = min(xscale, yscale);
      }
      if (parent.target != null) {
        await initializeCursorAndCanvas(parent.target!);
      }
    }
    _image?.dispose();
    _image = image;
    if (image != null) notifyListeners();
  }

  // mobile only
  // for desktop, height should minus tabbar height
  double get maxScale {
    if (_image == null) return 1.5;
    final size = MediaQueryData.fromWindow(ui.window).size;
    final xscale = size.width / _image!.width;
    final yscale = size.height / _image!.height;
    return max(1.5, max(xscale, yscale));
  }

  // mobile only
  // for desktop, height should minus tabbar height
  double get minScale {
    if (_image == null) return 1.5;
    final size = MediaQueryData.fromWindow(ui.window).size;
    final xscale = size.width / _image!.width;
    final yscale = size.height / _image!.height;
    return min(xscale, yscale) / 1.5;
  }

  updateUserTextureRender() {
    final preValue = _useTextureRender;
    _useTextureRender = isDesktop && bind.mainGetUseTextureRender();
    if (preValue != _useTextureRender) {
      notifyListeners();
    }
  }

  setUseTextureRender(bool value) {
    _useTextureRender = value;
    notifyListeners();
  }

  void disposeImage() {
    _image?.dispose();
    _image = null;
  }
}

enum ScrollStyle {
  scrollbar,
  scrollauto,
}

class ViewStyle {
  final String style;
  final double width;
  final double height;
  final int displayWidth;
  final int displayHeight;
  ViewStyle({
    required this.style,
    required this.width,
    required this.height,
    required this.displayWidth,
    required this.displayHeight,
  });

  static defaultViewStyle() {
    final desktop = (isDesktop || isWebDesktop);
    final w =
        desktop ? kDesktopDefaultDisplayWidth : kMobileDefaultDisplayWidth;
    final h =
        desktop ? kDesktopDefaultDisplayHeight : kMobileDefaultDisplayHeight;
    return ViewStyle(
      style: '',
      width: w.toDouble(),
      height: h.toDouble(),
      displayWidth: w,
      displayHeight: h,
    );
  }

  static int _double2Int(double v) => (v * 100).round().toInt();

  @override
  bool operator ==(Object other) =>
      other is ViewStyle &&
      other.runtimeType == runtimeType &&
      _innerEqual(other);

  bool _innerEqual(ViewStyle other) {
    return style == other.style &&
        ViewStyle._double2Int(other.width) == ViewStyle._double2Int(width) &&
        ViewStyle._double2Int(other.height) == ViewStyle._double2Int(height) &&
        other.displayWidth == displayWidth &&
        other.displayHeight == displayHeight;
  }

  @override
  int get hashCode => Object.hash(
        style,
        ViewStyle._double2Int(width),
        ViewStyle._double2Int(height),
        displayWidth,
        displayHeight,
      ).hashCode;

  double get scale {
    double s = 1.0;
    if (style == kRemoteViewStyleAdaptive) {
      if (width != 0 &&
          height != 0 &&
          displayWidth != 0 &&
          displayHeight != 0) {
        final s1 = width / displayWidth;
        final s2 = height / displayHeight;
        s = s1 < s2 ? s1 : s2;
      }
    }
    return s;
  }
}

class CanvasModel with ChangeNotifier {
  // image offset of canvas
  double _x = 0;
  // image offset of canvas
  double _y = 0;
  // image scale
  double _scale = 1.0;
  double _devicePixelRatio = 1.0;
  Size _size = Size.zero;
  // the tabbar over the image
  // double tabBarHeight = 0.0;
  // the window border's width
  // double windowBorderWidth = 0.0;
  // remote id
  String id = '';
  late final SessionID sessionId;
  // scroll offset x percent
  double _scrollX = 0.0;
  // scroll offset y percent
  double _scrollY = 0.0;
  ScrollStyle _scrollStyle = ScrollStyle.scrollauto;
  ViewStyle _lastViewStyle = ViewStyle.defaultViewStyle();

  final ScrollController _horizontal = ScrollController();
  final ScrollController _vertical = ScrollController();
  
  final _imageOverflow = false.obs;

  WeakReference<FFI> parent;

  CanvasModel(this.parent) {
    sessionId = parent.target!.sessionId;
  }

  double get x => _x;
  double get y => _y;
  double get scale => _scale;
  double get devicePixelRatio => _devicePixelRatio;
  Size get size => _size;
  ScrollStyle get scrollStyle => _scrollStyle;
  ViewStyle get viewStyle => _lastViewStyle;
  RxBool get imageOverflow => _imageOverflow;

  _resetScroll() => setScrollPercent(0.0, 0.0);

  setScrollPercent(double x, double y) {
    _scrollX = x;
    _scrollY = y;
  }

  ScrollController get scrollHorizontal => _horizontal;
  ScrollController get scrollVertical => _vertical;
  double get scrollX => _scrollX;
  double get scrollY => _scrollY;

  static double get leftToEdge =>
      isDesktop ? windowBorderWidth + kDragToResizeAreaPadding.left : 0;
  static double get rightToEdge =>
      isDesktop ? windowBorderWidth + kDragToResizeAreaPadding.right : 0;
  static double get topToEdge => isDesktop
      ? tabBarHeight + windowBorderWidth + kDragToResizeAreaPadding.top
      : 0;
  static double get bottomToEdge =>
      isDesktop ? windowBorderWidth + kDragToResizeAreaPadding.bottom : 0;

  updateViewStyle({refreshMousePos = true}) async {
    Size getSize() {
      final size = MediaQueryData.fromWindow(ui.window).size;
      // If minimized, w or h may be negative here.
      double w = size.width - leftToEdge - rightToEdge;
      double h = size.height - topToEdge - bottomToEdge;
      return Size(w < 0 ? 0 : w, h < 0 ? 0 : h);
    }

    final style = await bind.sessionGetViewStyle(sessionId: sessionId);
    if (style == null) {
      return;
    }

    _size = getSize();
    final displayWidth = getDisplayWidth();
    final displayHeight = getDisplayHeight();
    final viewStyle = ViewStyle(
      style: style,
      width: size.width,
      height: size.height,
      displayWidth: displayWidth,
      displayHeight: displayHeight,
    );
    if (_lastViewStyle == viewStyle) {
      return;
    }
    if (_lastViewStyle.style != viewStyle.style) {
      _resetScroll();
    }
    _lastViewStyle = viewStyle;
    _scale = viewStyle.scale;

    _devicePixelRatio = ui.window.devicePixelRatio;
    if (kIgnoreDpi && style == kRemoteViewStyleOriginal) {
      _scale = 1.0 / _devicePixelRatio;
    }
    _x = (size.width - displayWidth * _scale) / 2;
    _y = (size.height - displayHeight * _scale) / 2;
    _imageOverflow.value = _x < 0 || y < 0;
    notifyListeners();
    if (refreshMousePos) {
      parent.target?.inputModel.refreshMousePos();
    }
    tryUpdateScrollStyle(Duration.zero, style);
  }

  tryUpdateScrollStyle(Duration duration, String? style) async {
    if (_scrollStyle != ScrollStyle.scrollbar) return;
    style ??= await bind.sessionGetViewStyle(sessionId: sessionId);
    if (style != kRemoteViewStyleOriginal) {
      return;
    }

    _resetScroll();
    Future.delayed(duration, () async {
      updateScrollPercent();
    });
  }

  updateScrollStyle() async {
    final style = await bind.sessionGetScrollStyle(sessionId: sessionId);
    if (style == kRemoteScrollStyleBar) {
      _scrollStyle = ScrollStyle.scrollbar;
      _resetScroll();
    } else {
      _scrollStyle = ScrollStyle.scrollauto;
    }
    notifyListeners();
  }

  update(double x, double y, double scale) {
    _x = x;
    _y = y;
    _scale = scale;
    notifyListeners();
  }

  bool get cursorEmbedded =>
      parent.target?.ffiModel._pi.cursorEmbedded ?? false;

  int getDisplayWidth() {
    final defaultWidth = (isDesktop || isWebDesktop)
        ? kDesktopDefaultDisplayWidth
        : kMobileDefaultDisplayWidth;
    return parent.target?.ffiModel.rect?.width.toInt() ?? defaultWidth;
  }

  int getDisplayHeight() {
    final defaultHeight = (isDesktop || isWebDesktop)
        ? kDesktopDefaultDisplayHeight
        : kMobileDefaultDisplayHeight;
    return parent.target?.ffiModel.rect?.height.toInt() ?? defaultHeight;
  }

  static double get windowBorderWidth => stateGlobal.windowBorderWidth.value;
  static double get tabBarHeight => stateGlobal.tabBarHeight;

  moveDesktopMouse(double x, double y) {
    if (size.width == 0 || size.height == 0) {
      return;
    }

    // On mobile platforms, move the canvas with the cursor.
    final dw = getDisplayWidth() * _scale;
    final dh = getDisplayHeight() * _scale;
    var dxOffset = 0;
    var dyOffset = 0;
    try {
      if (dw > size.width) {
        dxOffset = (x - dw * (x / size.width) - _x).toInt();
      }
      if (dh > size.height) {
        dyOffset = (y - dh * (y / size.height) - _y).toInt();
      }
    } catch (e) {
      debugPrintStack(
          label:
              '(x,y) ($x,$y), (_x,_y) ($_x,$_y), _scale $_scale, display size (${getDisplayWidth()},${getDisplayHeight()}), size $size, , $e');
      return;
    }

    _x += dxOffset;
    _y += dyOffset;
    if (dxOffset != 0 || dyOffset != 0) {
      notifyListeners();
    }

    // If keyboard is not permitted, do not move cursor when mouse is moving.
    if (parent.target != null && parent.target!.ffiModel.keyboard) {
      // Draw cursor if is not desktop.
      if (!(isDesktop || isWebDesktop)) {
        parent.target!.cursorModel.moveLocal(x, y);
      } else {
        try {
          RemoteCursorMovedState.find(id).value = false;
        } catch (e) {
          //
        }
      }
    }
  }

  set scale(v) {
    _scale = v;
    notifyListeners();
  }

  panX(double dx) {
    _x += dx;
    notifyListeners();
  }

  resetOffset() {
    if (isWebDesktop) {
      updateViewStyle();
    } else {
      _x = (size.width - getDisplayWidth() * _scale) / 2;
      _y = (size.height - getDisplayHeight() * _scale) / 2;
    }
    notifyListeners();
  }

  panY(double dy) {
    _y += dy;
    notifyListeners();
  }

  updateScale(double v, Offset focalPoint) {
    if (parent.target?.imageModel.image == null) return;
    final s = _scale;
    _scale *= v;
    final maxs = parent.target?.imageModel.maxScale ?? 1;
    final mins = parent.target?.imageModel.minScale ?? 1;
    if (_scale > maxs) _scale = maxs;
    if (_scale < mins) _scale = mins;
    // (focalPoint.dx - _x_1) / s1 + displayOriginX = (focalPoint.dx - _x_2) / s2 + displayOriginX
    // _x_2 = focalPoint.dx - (focalPoint.dx - _x_1) / s1 * s2
    _x = focalPoint.dx - (focalPoint.dx - _x) / s * _scale;
    final adjustForKeyboard =
        parent.target?.cursorModel.adjustForKeyboard() ?? 0.0;
    // (focalPoint.dy - _y_1 + adjust) / s1 + displayOriginY = (focalPoint.dy - _y_2 + adjust) / s2 + displayOriginY
    // _y_2 = focalPoint.dy + adjust - (focalPoint.dy - _y_1 + adjust) / s1 * s2
    _y = focalPoint.dy +
        adjustForKeyboard -
        (focalPoint.dy - _y + adjustForKeyboard) / s * _scale;
    notifyListeners();
  }

  clear([bool notify = false]) {
    _x = 0;
    _y = 0;
    _scale = 1.0;
    if (notify) notifyListeners();
  }

  updateScrollPercent() {
    final percentX = _horizontal.hasClients
        ? _horizontal.position.extentBefore /
            (_horizontal.position.extentBefore +
                _horizontal.position.extentInside +
                _horizontal.position.extentAfter)
        : 0.0;
    final percentY = _vertical.hasClients
        ? _vertical.position.extentBefore /
            (_vertical.position.extentBefore +
                _vertical.position.extentInside +
                _vertical.position.extentAfter)
        : 0.0;
    setScrollPercent(percentX, percentY);
  }
}

// data for cursor
class CursorData {
  final String peerId;
  final String id;
  final img2.Image image;
  double scale;
  Uint8List? data;
  final double hotxOrigin;
  final double hotyOrigin;
  double hotx;
  double hoty;
  final int width;
  final int height;

  CursorData({
    required this.peerId,
    required this.id,
    required this.image,
    required this.scale,
    required this.data,
    required this.hotxOrigin,
    required this.hotyOrigin,
    required this.width,
    required this.height,
  })  : hotx = hotxOrigin * scale,
        hoty = hotxOrigin * scale;

  int _doubleToInt(double v) => (v * 10e6).round().toInt();

  double _checkUpdateScale(double scale) {
    double oldScale = this.scale;
    if (scale != 1.0) {
      // Update data if scale changed.
      final tgtWidth = (width * scale).toInt();
      final tgtHeight = (width * scale).toInt();
      if (tgtWidth < kMinCursorSize || tgtHeight < kMinCursorSize) {
        double sw = kMinCursorSize.toDouble() / width;
        double sh = kMinCursorSize.toDouble() / height;
        scale = sw < sh ? sh : sw;
      }
    }

    if (_doubleToInt(oldScale) != _doubleToInt(scale)) {
      if (isWindows) {
        data = img2
            .copyResize(
              image,
              width: (width * scale).toInt(),
              height: (height * scale).toInt(),
              interpolation: img2.Interpolation.average,
            )
            .getBytes(order: img2.ChannelOrder.bgra);
      } else {
        data = Uint8List.fromList(
          img2.encodePng(
            img2.copyResize(
              image,
              width: (width * scale).toInt(),
              height: (height * scale).toInt(),
              interpolation: img2.Interpolation.average,
            ),
          ),
        );
      }
    }

    this.scale = scale;
    hotx = hotxOrigin * scale;
    hoty = hotyOrigin * scale;
    return scale;
  }

  String updateGetKey(double scale) {
    scale = _checkUpdateScale(scale);
    return '${peerId}_${id}_${_doubleToInt(width * scale)}_${_doubleToInt(height * scale)}';
  }
}

const _forbiddenCursorPng =
    'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAAXNSR0IB2cksfwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAkZQTFRFAAAA2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4G2B4GWAwCAAAAAAAA2B4GAAAAMTExAAAAAAAA2B4G2B4G2B4GAAAAmZmZkZGRAQEBAAAA2B4G2B4G2B4G////oKCgAwMDag8D2B4G2B4G2B4Gra2tBgYGbg8D2B4G2B4Gubm5CQkJTwsCVgwC2B4GxcXFDg4OAAAAAAAA2B4G2B4Gz8/PFBQUAAAAAAAA2B4G2B4G2B4G2B4G2B4G2B4G2B4GDgIA2NjYGxsbAAAAAAAA2B4GFwMB4eHhIyMjAAAAAAAA2B4G6OjoLCwsAAAAAAAA2B4G2B4G2B4G2B4G2B4GCQEA4ODgv7+/iYmJY2NjAgICAAAA9PT0Ojo6AAAAAAAAAAAA+/v7SkpKhYWFr6+vAAAAAAAA8/PzOTk5ERER9fX1KCgoAAAAgYGBKioqAAAAAAAApqamlpaWAAAAAAAAAAAAAAAAAAAAAAAALi4u/v7+GRkZAAAAAAAAAAAAAAAAAAAAfn5+AAAAAAAAV1dXkJCQAAAAAAAAAQEBAAAAAAAAAAAA7Hz6BAAAAMJ0Uk5TAAIWEwEynNz6//fVkCAatP2fDUHs6cDD8d0mPfT5fiEskiIR584A0gejr3AZ+P4plfALf5ZiTL85a4ziD6697fzN3UYE4v/4TwrNHuT///tdRKZh///+1U/ZBv///yjb///eAVL//50Cocv//6oFBbPvpGZCbfT//7cIhv///8INM///zBEcWYSZmO7//////1P////ts/////8vBv//////gv//R/z///QQz9sevP///2waXhNO/+fc//8mev/5gAe2r90MAAAByUlEQVR4nGNggANGJmYWBpyAlY2dg5OTi5uHF6s0H78AJxRwCAphyguLgKRExcQlQLSkFLq8tAwnp6ycPNABjAqKQKNElVDllVU4OVVhVquJA81Q10BRoAkUUYbJa4Edoo0sr6PLqaePLG/AyWlohKTAmJPTBFnelAFoixmSAnNOTgsUeQZLTk4rJAXWnJw2EHlbiDyDPCenHZICe04HFrh+RydnBgYWPU5uJAWinJwucPNd3dw9GDw5Ob2QFHBzcnrD7ffx9fMPCOTkDEINhmC4+3x8Q0LDwlEDIoKTMzIKKg9SEBIdE8sZh6SAJZ6Tkx0qD1YQkpCYlIwclCng0AXLQxSEpKalZyCryATKZwkhKQjJzsnNQ1KQXwBUUVhUXBJYWgZREFJeUVmFpMKlWg+anmqgCkJq6+obkG1pLEBTENLU3NKKrIKhrb2js8u4G6Kgpze0r3/CRAZMAHbkpJDJU6ZMmTqtFbuC6TNmhsyaMnsOFlmwgrnzpsxfELJwEXZ5Bp/FS3yWLlsesmLlKuwKVk9Ys5Zh3foN0zduwq5g85atDAzbpqSGbN9RhV0FGOzctWH3lD14FOzdt3H/gQw8Cg4u2gQPAwBYDXXdIH+wqAAAAABJRU5ErkJggg==';
const _defaultCursorPng =
    'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARzQklUCAgICHwIZIgAAAFmSURBVFiF7dWxSlxREMbx34QFDRowYBchZSxSCWlMCOwD5FGEFHap06UI7KPsAyyEEIQFqxRaCqYTsqCJFsKkuAeRXb17wrqV918dztw55zszc2fo6Oh47MR/e3zO1/iAHWmznHKGQwx9ip/LEbCfazbsoY8j/JLOhcC6sCW9wsjEwJf483AC9nPNc1+lFRwI13d+l3rYFS799rFGxJMqARv2pBXh+72XQ7gWvklPS7TmMl9Ak/M+DqrENvxAv/guKKApuKPWl0/TROK4+LbSqzhuB+OZ3fRSeFPWY+Fkyn56Y29hfgTSpnQ+s98cvorVey66uPlNFxKwZOYLCGfCs5n9NMYVrsp6mvXSoFqpqYFDvMBkStgJJe93dZOwVXxbqUnBENulydSReqUrDhcX0PT2EXarBYS3GNXMhboinBgIl9K71kg0L3+PvyYGdVpruT2MwrF0iotiXfIwus0Dj+OOjo6Of+e7ab74RkpgAAAAAElFTkSuQmCC';

const kPreForbiddenCursorId = "-2";
final preForbiddenCursor = PredefinedCursor(
  png: _forbiddenCursorPng,
  id: kPreForbiddenCursorId,
);
const kPreDefaultCursorId = "-1";
final preDefaultCursor = PredefinedCursor(
  png: _defaultCursorPng,
  id: kPreDefaultCursorId,
  hotxGetter: (double w) => w / 2,
  hotyGetter: (double h) => h / 2,
);

class PredefinedCursor {
  ui.Image? _image;
  img2.Image? _image2;
  CursorData? _cache;
  String png;
  String id;
  double Function(double)? hotxGetter;
  double Function(double)? hotyGetter;

  PredefinedCursor(
      {required this.png, required this.id, this.hotxGetter, this.hotyGetter}) {
    init();
  }

  ui.Image? get image => _image;
  CursorData? get cache => _cache;

  init() {
    _image2 = img2.decodePng(base64Decode(png));
    if (_image2 != null) {
      // The png type of forbidden cursor image is `PngColorType.indexed`.
      if (isWindows && id == kPreForbiddenCursorId) {
        _image2 = _image2!.convert(format: img2.Format.uint8, numChannels: 4);
      }

      () async {
        final defaultImg = _image2!;
        // This function is called only one time, no need to care about the performance.
        Uint8List data = defaultImg.getBytes(order: img2.ChannelOrder.rgba);
        _image?.dispose();
        _image = await img.decodeImageFromPixels(
            data, defaultImg.width, defaultImg.height, ui.PixelFormat.rgba8888);
        if (_image == null) {
          print("decodeImageFromPixels failed, pre-defined cursor $id");
          return;
        }
        double scale = 1.0;
        if (isWindows) {
          data = _image2!.getBytes(order: img2.ChannelOrder.bgra);
        } else {
          data = Uint8List.fromList(img2.encodePng(_image2!));
        }

        _cache = CursorData(
          peerId: '',
          id: id,
          image: _image2!.clone(),
          scale: scale,
          data: data,
          hotxOrigin:
              hotxGetter != null ? hotxGetter!(_image2!.width.toDouble()) : 0,
          hotyOrigin:
              hotyGetter != null ? hotyGetter!(_image2!.height.toDouble()) : 0,
          width: _image2!.width,
          height: _image2!.height,
        );
      }();
    }
  }
}

class CursorModel with ChangeNotifier {
  ui.Image? _image;
  final _images = <String, Tuple3<ui.Image, double, double>>{};
  CursorData? _cache;
  final _cacheMap = <String, CursorData>{};
  final _cacheKeys = <String>{};
  double _x = -10000;
  double _y = -10000;
  // int.parse(evt['id']) may cause FormatException
  // So we use String here.
  String _id = "-1";
  double _hotx = 0;
  double _hoty = 0;
  double _displayOriginX = 0;
  double _displayOriginY = 0;
  DateTime? _firstUpdateMouseTime;
  Rect? _windowRect;
  List<RemoteWindowCoords> _remoteWindowCoords = [];
  bool gotMouseControl = true;
  DateTime _lastPeerMouse = DateTime.now()
      .subtract(Duration(milliseconds: 3000 * kMouseControlTimeoutMSec));
  String peerId = '';
  WeakReference<FFI> parent;

  // Only for mobile, touch mode
  // To block touch event above the KeyHelpTools
  //
  // A better way is to not listen events from the KeyHelpTools.
  // But we're now using a Container(child: Stack(...)) to wrap the KeyHelpTools,
  // and the listener is on the Container.
  Rect? _keyHelpToolsRect;
  // `lastIsBlocked` is only used in common/widgets/remote_input.dart -> _RawTouchGestureDetectorRegionState -> onDoubleTap()
  // Because onDoubleTap() doesn't have the `event` parameter, we can't get the touch event's position.
  bool _lastIsBlocked = false;
  double _yForKeyboardAdjust = 0;

  keyHelpToolsVisibilityChanged(Rect? r) {
    _keyHelpToolsRect = r;
    if (r == null) {
      _lastIsBlocked = false;
    } else {
      // Block the touch event is safe here.
      // `lastIsBlocked` is only used in onDoubleTap() to block the touch event from the KeyHelpTools.
      // `lastIsBlocked` will be set when the cursor is moving or touch somewhere else.
      _lastIsBlocked = true;
    }
    _yForKeyboardAdjust = _y;
  }

  get lastIsBlocked => _lastIsBlocked;
  
  ui.Image? get image => _image;
  CursorData? get cache => _cache;

  double get x => _x - _displayOriginX;
  double get y => _y - _displayOriginY;

  double get devicePixelRatio => parent.target!.canvasModel.devicePixelRatio;
  
  Offset get offset => Offset(_x, _y);

  double get hotx => _hotx;
  double get hoty => _hoty;

  set id(String id) => _id = id;
  
  bool get isPeerControlProtected =>
      DateTime.now().difference(_lastPeerMouse).inMilliseconds <
      kMouseControlTimeoutMSec;

  bool isConnIn2Secs() {
    if (_firstUpdateMouseTime == null) {
      _firstUpdateMouseTime = DateTime.now();
      return true;
    } else {
      return DateTime.now().difference(_firstUpdateMouseTime!).inSeconds < 2;
    }
  }

  CursorModel(this.parent);

  Set<String> get cachedKeys => _cacheKeys;
  addKey(String key) => _cacheKeys.add(key);

  // remote physical display coordinate
  Rect getVisibleRect() {
    final size = MediaQueryData.fromWindow(ui.window).size;
    final xoffset = parent.target?.canvasModel.x ?? 0;
    final yoffset = parent.target?.canvasModel.y ?? 0;
    final scale = parent.target?.canvasModel.scale ?? 1;
    final x0 = _displayOriginX - xoffset / scale;
    final y0 = _displayOriginY - yoffset / scale;
    return Rect.fromLTWH(x0, y0, size.width / scale, size.height / scale);
  }

  get keyboardHeight => MediaQueryData.fromWindow(ui.window).viewInsets.bottom;
  get scale => parent.target?.canvasModel.scale ?? 1.0;

  double adjustForKeyboard() {
    if (keyboardHeight < 100) {
      return 0.0;
    }

    final m = MediaQueryData.fromWindow(ui.window);
    final size = m.size;
    final thresh = (size.height - keyboardHeight) / 2;
    final h = (_yForKeyboardAdjust - getVisibleRect().top) *
        scale; // local physical display height
    return h - thresh;
  }

  // mobile Soft keyboard, block touch event from the KeyHelpTools
  shouldBlock(double x, double y) {
    if (!(parent.target?.ffiModel.touchMode ?? false)) {
      return false;
    }
    if (_keyHelpToolsRect == null) {
      return false;
    }
    if (isPointInRect(Offset(x, y), _keyHelpToolsRect!)) {
      return true;
    }
    return false;
  }

  move(double x, double y) {
    if (shouldBlock(x, y)) {
      _lastIsBlocked = true;
      return false;
    }
    _lastIsBlocked = false;
    moveLocal(x, y, adjust: adjustForKeyboard());
    parent.target?.inputModel.moveMouse(_x, _y);
    return true;
  }

  moveLocal(double x, double y, {double adjust = 0}) {
    final xoffset = parent.target?.canvasModel.x ?? 0;
    final yoffset = parent.target?.canvasModel.y ?? 0;
    _x = (x - xoffset) / scale + _displayOriginX;
    _y = (y - yoffset + adjust) / scale + _displayOriginY;
    notifyListeners();
  }

  reset() {
    _x = _displayOriginX;
    _y = _displayOriginY;
    parent.target?.inputModel.moveMouse(_x, _y);
    parent.target?.canvasModel.clear(true);
    notifyListeners();
  }

  updatePan(Offset delta, Offset localPosition, bool touchMode) {
    if (touchMode) {
      _handleTouchMode(delta, localPosition);
      return;
    }
    double dx = delta.dx;
    double dy = delta.dy;
    if (parent.target?.imageModel.image == null) return;
    final scale = parent.target?.canvasModel.scale ?? 1.0;
    dx /= scale;
    dy /= scale;
    final r = getVisibleRect();
    var cx = r.center.dx;
    var cy = r.center.dy;
    var tryMoveCanvasX = false;
    if (dx > 0) {
      final maxCanvasCanMove = _displayOriginX +
          (parent.target?.imageModel.image!.width ?? 1280) -
          r.right.roundToDouble();
      tryMoveCanvasX = _x + dx > cx && maxCanvasCanMove > 0;
      if (tryMoveCanvasX) {
        dx = min(dx, maxCanvasCanMove);
      } else {
        final maxCursorCanMove = r.right - _x;
        dx = min(dx, maxCursorCanMove);
      }
    } else if (dx < 0) {
      final maxCanvasCanMove = _displayOriginX - r.left.roundToDouble();
      tryMoveCanvasX = _x + dx < cx && maxCanvasCanMove < 0;
      if (tryMoveCanvasX) {
        dx = max(dx, maxCanvasCanMove);
      } else {
        final maxCursorCanMove = r.left - _x;
        dx = max(dx, maxCursorCanMove);
      }
    }
    var tryMoveCanvasY = false;
    if (dy > 0) {
      final mayCanvasCanMove = _displayOriginY +
          (parent.target?.imageModel.image!.height ?? 720) -
          r.bottom.roundToDouble();
      tryMoveCanvasY = _y + dy > cy && mayCanvasCanMove > 0;
      if (tryMoveCanvasY) {
        dy = min(dy, mayCanvasCanMove);
      } else {
        final mayCursorCanMove = r.bottom - _y;
        dy = min(dy, mayCursorCanMove);
      }
    } else if (dy < 0) {
      final mayCanvasCanMove = _displayOriginY - r.top.roundToDouble();
      tryMoveCanvasY = _y + dy < cy && mayCanvasCanMove < 0;
      if (tryMoveCanvasY) {
        dy = max(dy, mayCanvasCanMove);
      } else {
        final mayCursorCanMove = r.top - _y;
        dy = max(dy, mayCursorCanMove);
      }
    }

    if (dx == 0 && dy == 0) return;
    _x += dx;
    _y += dy;
    if (tryMoveCanvasX && dx != 0) {
      parent.target?.canvasModel.panX(-dx);
    }
    if (tryMoveCanvasY && dy != 0) {
      parent.target?.canvasModel.panY(-dy);
    }

    parent.target?.inputModel.moveMouse(_x, _y);
    notifyListeners();
  }

  bool _isInCurrentWindow(double x, double y) {
    final w = _windowRect!.width / devicePixelRatio;
    final h = _windowRect!.width / devicePixelRatio;
    return x >= 0 && y >= 0 && x <= w && y <= h;
  }

  _handleTouchMode(Offset delta, Offset localPosition) {
    bool isMoved = false;
    if (_remoteWindowCoords.isNotEmpty &&
        _windowRect != null &&
        !_isInCurrentWindow(localPosition.dx, localPosition.dy)) {
      final coords = InputModel.findRemoteCoords(localPosition.dx,
          localPosition.dy, _remoteWindowCoords, devicePixelRatio);
      if (coords != null) {
        double x2 =
            (localPosition.dx - coords.relativeOffset.dx / devicePixelRatio) /
                coords.canvas.scale;
        double y2 =
            (localPosition.dy - coords.relativeOffset.dy / devicePixelRatio) /
                coords.canvas.scale;
        x2 += coords.cursor.offset.dx;
        y2 += coords.cursor.offset.dy;
        parent.target?.inputModel.moveMouse(x2, y2);
        isMoved = true;
      }
    }
    if (!isMoved) {
      final scale = parent.target?.canvasModel.scale ?? 1.0;
      _x += delta.dx / scale;
      _y += delta.dy / scale;
      parent.target?.inputModel.moveMouse(_x, _y);
    }
    notifyListeners();
  }

  disposeImages() {
    _images.forEach((_, v) => v.item1.dispose());
    _images.clear();
  }
  updateCursorData(Map<String, dynamic> evt) async {
    final id = evt['id'];
    final hotx = double.parse(evt['hotx']);
    final hoty = double.parse(evt['hoty']);
    final width = int.parse(evt['width']);
    final height = int.parse(evt['height']);
    List<dynamic> colors = json.decode(evt['colors']);
    final rgba = Uint8List.fromList(colors.map((s) => s as int).toList());
    final image = await img.decodeImageFromPixels(
        rgba, width, height, ui.PixelFormat.rgba8888);
    if (image == null) {
      return;
    }
    if (await _updateCache(rgba, image, id, hotx, hoty, width, height)) {
      _images[id]?.item1.dispose();
      _images[id] = Tuple3(image, hotx, hoty);
    }

    // Update last cursor data.
    // Do not use the previous `image` and `id`, because `_id` may be changed.
    _updateCurData();
  }

  Future<bool> _updateCache(
    Uint8List rgba,
    ui.Image image,
    String id,
    double hotx,
    double hoty,
    int w,
    int h,
  ) async {
    Uint8List? data;
    img2.Image imgOrigin = img2.Image.fromBytes(
        width: w, height: h, bytes: rgba.buffer, order: img2.ChannelOrder.rgba);
    if (isWindows) {
      data = imgOrigin.getBytes(order: img2.ChannelOrder.bgra);
    } else {
      ByteData? imgBytes =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (imgBytes == null) {
        return false;
      }
      data = imgBytes.buffer.asUint8List();
    }
    final cache = CursorData(
      peerId: peerId,
      id: id,
      image: imgOrigin,
      scale: 1.0,
      data: data,
      hotxOrigin: hotx,
      hotyOrigin: hoty,
      width: w,
      height: h,
    );
    _cacheMap[id] = cache;
    return true;
  }

  bool _updateCurData() {
    _cache = _cacheMap[_id];
    final tmp = _images[_id];
    if (tmp != null) {
      _image = tmp.item1;
      _hotx = tmp.item2;
      _hoty = tmp.item3;
      try {
        // may throw exception, because the listener maybe already dispose
        notifyListeners();
      } catch (e) {
        debugPrint(
            'WARNING: updateCursorId $_id, without notifyListeners(). $e');
      }
      return true;
    } else {
      return false;
    }
  }

  updateCursorId(Map<String, dynamic> evt) {
    if (!_updateCurData()) {
      debugPrint(
          'WARNING: updateCursorId $_id, cache is ${_cache == null ? "null" : "not null"}. without notifyListeners()');
    }
  }

  /// Update the cursor position.
  updateCursorPosition(Map<String, dynamic> evt, String id) async {
    if (!isConnIn2Secs()) {
      gotMouseControl = false;
      _lastPeerMouse = DateTime.now();
    }
    _x = double.parse(evt['x']);
    _y = double.parse(evt['y']);
    try {
      RemoteCursorMovedState.find(id).value = true;
    } catch (e) {
      //
    }
    notifyListeners();
  }

  updateDisplayOrigin(double x, double y, {updateCursorPos = true}) {
    _displayOriginX = x;
    _displayOriginY = y;
    if (updateCursorPos) {
      _x = x + 1;
      _y = y + 1;
      parent.target?.inputModel.moveMouse(x, y);
    }
    parent.target?.canvasModel.resetOffset();
    notifyListeners();
  }

  updateDisplayOriginWithCursor(
      double x, double y, double xCursor, double yCursor) {
    _displayOriginX = x;
    _displayOriginY = y;
    _x = xCursor;
    _y = yCursor;
    parent.target?.inputModel.moveMouse(x, y);
    notifyListeners();
  }

  clear() {
    _x = -10000;
    _x = -10000;
    _image = null;
    disposeImages();

    _clearCache();
    _cache = null;
    _cacheMap.clear();
  }

  _clearCache() {
    final keys = {...cachedKeys};
    for (var k in keys) {
      debugPrint("deleting cursor with key $k");
      deleteCustomCursor(k);
    }
  }

  trySetRemoteWindowCoords() {
    Future.delayed(Duration.zero, () async {
      _windowRect =
          await InputModel.fillRemoteCoordsAndGetCurFrame(_remoteWindowCoords);
    });
  }

  clearRemoteWindowCoords() {
    _windowRect = null;
    _remoteWindowCoords.clear();
  }
}

class QualityMonitorData {
  String? speed;
  String? fps;
  String? delay;
  String? targetBitrate;
  String? codecFormat;
}

class QualityMonitorModel with ChangeNotifier {
  WeakReference<FFI> parent;

  QualityMonitorModel(this.parent);
  var _show = false;
  final _data = QualityMonitorData();

  bool get show => _show;
  QualityMonitorData get data => _data;

  checkShowQualityMonitor(SessionID sessionId) async {
    final show = await bind.sessionGetToggleOption(
            sessionId: sessionId, arg: 'show-quality-monitor') ==
        true;
    if (_show != show) {
      _show = show;
      notifyListeners();
    }
  }

  updateQualityStatus(Map<String, dynamic> evt) {
    try {
      if ((evt['speed'] as String).isNotEmpty) _data.speed = evt['speed'];
      if ((evt['fps'] as String).isNotEmpty) {
        final fps = jsonDecode(evt['fps']) as Map<String, dynamic>;
        final pi = parent.target?.ffiModel.pi;
        if (pi != null) {
          final currentDisplay = pi.currentDisplay;
          if (currentDisplay != kAllDisplayValue) {
            final fps2 = fps[currentDisplay.toString()];
            if (fps2 != null) {
              _data.fps = fps2.toString();
            }
          } else if (fps.isNotEmpty) {
            final fpsList = [];
            for (var i = 0; i < pi.displays.length; i++) {
              fpsList.add((fps[i.toString()] ?? 0).toString());
            }
            _data.fps = fpsList.join(' ');
          }
        } else {
          _data.fps = null;
        }
      }
      if ((evt['delay'] as String).isNotEmpty) _data.delay = evt['delay'];
      if ((evt['target_bitrate'] as String).isNotEmpty) {
        _data.targetBitrate = evt['target_bitrate'];
      }
      if ((evt['codec_format'] as String).isNotEmpty) {
        _data.codecFormat = evt['codec_format'];
      }
      notifyListeners();
    } catch (e) {
      //
    }
  }
}

class RecordingModel with ChangeNotifier {
  WeakReference<FFI> parent;
  RecordingModel(this.parent);
  bool _start = false;
  get start => _start;

  onSwitchDisplay() {
    if (isIOS || !_start) return;
    final sessionId = parent.target?.sessionId;
    int? width = parent.target?.canvasModel.getDisplayWidth();
    int? height = parent.target?.canvasModel.getDisplayHeight();
    if (sessionId == null || width == null || height == null) return;
    final pi = parent.target?.ffiModel.pi;
    if (pi == null) return;
    final currentDisplay = pi.currentDisplay;
    if (currentDisplay == kAllDisplayValue) return;
    bind.sessionRecordScreen(
        sessionId: sessionId,
        start: true,
        display: currentDisplay,
        width: width,
        height: height);
  }

  toggle() async {
    if (isIOS) return;
    final sessionId = parent.target?.sessionId;
    if (sessionId == null) return;
    final pi = parent.target?.ffiModel.pi;
    if (pi == null) return;
    final currentDisplay = pi.currentDisplay;
    if (currentDisplay == kAllDisplayValue) return;
    _start = !_start;
    notifyListeners();
    await _sendStatusMessage(sessionId, pi, _start);
    if (_start) {
      sessionRefreshVideo(sessionId, pi);
      if (versionCmp(pi.version, '1.2.4') >= 0) {
        // will not receive SwitchDisplay since 1.2.4
        onSwitchDisplay();
      }
    } else {
      bind.sessionRecordScreen(
          sessionId: sessionId,
          start: false,
          display: currentDisplay,
          width: 0,
          height: 0);
    }
  }

  onClose() async {
    if (isIOS) return;
    final sessionId = parent.target?.sessionId;
    if (sessionId == null) return;
    if (!_start) return;
    _start = false;
    final pi = parent.target?.ffiModel.pi;
    if (pi == null) return;
    final currentDisplay = pi.currentDisplay;
    if (currentDisplay == kAllDisplayValue) return;
    await _sendStatusMessage(sessionId, pi, false);
    bind.sessionRecordScreen(
        sessionId: sessionId,
        start: false,
        display: currentDisplay,
        width: 0,
        height: 0);
  }

  _sendStatusMessage(SessionID sessionId, PeerInfo pi, bool status) async {
    await bind.sessionRecordStatus(sessionId: sessionId, status: status);
  }
}

class ElevationModel with ChangeNotifier {
  WeakReference<FFI> parent;
  ElevationModel(this.parent);
  bool _running = false;
  bool _canElevate = false;
  bool get showRequestMenu => _canElevate && !_running;
  onPeerInfo(PeerInfo pi) {
    _canElevate = pi.platform == kPeerPlatformWindows && pi.sasEnabled == false;
    _running = false;
  }

  onPortableServiceRunning(bool running) => _running = running;
}

enum ConnType { defaultConn, fileTransfer, portForward, rdp }

/// Flutter state manager and data communication with the Rust core.
class FFI {
  var id = '';
  var version = '';
  var connType = ConnType.defaultConn;
  var closed = false;
  var auditNote = '';

  /// dialogManager use late to ensure init after main page binding [globalKey]
  late final dialogManager = OverlayDialogManager();

  late final SessionID sessionId;
  late final ImageModel imageModel; // session
  late final FfiModel ffiModel; // session
  late final CursorModel cursorModel; // session
  late final CanvasModel canvasModel; // session
  late final ServerModel serverModel; // global
  late final ChatModel chatModel; // session
  late final FileModel fileModel; // session
  late final AbModel abModel; // global
  late final GroupModel groupModel; // global
  late final UserModel userModel; // global
  late final PeerTabModel peerTabModel; // global
  late final QualityMonitorModel qualityMonitorModel; // session
  late final RecordingModel recordingModel; // session
  late final InputModel inputModel; // session
  late final ElevationModel elevationModel; // session
  late final CmFileModel cmFileModel; // cm
  late final TextureModel textureModel; //session

  FFI(SessionID? sId) {
    sessionId = sId ?? (isDesktop ? Uuid().v4obj() : _constSessionId);
    imageModel = ImageModel(WeakReference(this));
    ffiModel = FfiModel(WeakReference(this));
    cursorModel = CursorModel(WeakReference(this));
    canvasModel = CanvasModel(WeakReference(this));
    serverModel = ServerModel(WeakReference(this));
    chatModel = ChatModel(WeakReference(this));
    fileModel = FileModel(WeakReference(this));
    userModel = UserModel(WeakReference(this));
    peerTabModel = PeerTabModel(WeakReference(this));
    abModel = AbModel(WeakReference(this));
    groupModel = GroupModel(WeakReference(this));
    qualityMonitorModel = QualityMonitorModel(WeakReference(this));
    recordingModel = RecordingModel(WeakReference(this));
    inputModel = InputModel(WeakReference(this));
    elevationModel = ElevationModel(WeakReference(this));
    cmFileModel = CmFileModel(WeakReference(this));
    textureModel = TextureModel(WeakReference(this));
  }

  /// Mobile reuse FFI
  void mobileReset() {
    ffiModel.waitForFirstImage.value = true;
    ffiModel.isRefreshing = false;
    ffiModel.waitForImageDialogShow.value = true;
    ffiModel.waitForImageTimer?.cancel();
    ffiModel.waitForImageTimer = null;
  }

  /// Start with the given [id]. Only transfer file if [isFileTransfer], only port forward if [isPortForward].
  void start(
    String id, {
    bool isFileTransfer = false,
    bool isPortForward = false,
    bool isRdp = false,
    String? switchUuid,
    String? password,
    bool? isSharedPassword,
    bool? forceRelay,
    int? tabWindowId,
    int? display,
    List<int>? displays,
  }) {
    closed = false;
    auditNote = '';
    if (isMobile) mobileReset();
    assert(!(isFileTransfer && isPortForward), 'more than one connect type');
    if (isFileTransfer) {
      connType = ConnType.fileTransfer;
    } else if (isPortForward) {
      connType = ConnType.portForward;
    } else {
      chatModel.resetClientMode();
      connType = ConnType.defaultConn;
      canvasModel.id = id;
      imageModel.id = id;
      cursorModel.peerId = id;
    }

    final isNewPeer = tabWindowId == null;
    // If tabWindowId != null, this session is a "tab -> window" one.
    // Else this session is a new one.
    if (isNewPeer) {
      // ignore: unused_local_variable
      final addRes = bind.sessionAddSync(
        sessionId: sessionId,
        id: id,
        isFileTransfer: isFileTransfer,
        isPortForward: isPortForward,
        isRdp: isRdp,
        switchUuid: switchUuid ?? '',
        forceRelay: forceRelay ?? false,
        password: password ?? '',
        isSharedPassword: isSharedPassword ?? false,
      );
    } else if (display != null) {
      if (displays == null) {
        debugPrint(
            'Unreachable, failed to add existed session to $id, the displays is null while display is $display');
        return;
      }
      final addRes = bind.sessionAddExistedSync(
          id: id, sessionId: sessionId, displays: Int32List.fromList(displays));
      if (addRes != '') {
        debugPrint(
            'Unreachable, failed to add existed session to $id, $addRes');
        return;
      }
      ffiModel.pi.currentDisplay = display;
    }
    if (isDesktop && connType == ConnType.defaultConn) {
      textureModel.updateCurrentDisplay(display ?? 0);
    }

    // CAUTION: `sessionStart()` and `sessionStartWithDisplays()` are an async functions.
    // Though the stream is returned immediately, the stream may not be ready.
    // Any operations that depend on the stream should be carefully handled.
    late final Stream<EventToUI> stream;
    if (isNewPeer || display == null || displays == null) {
      stream = bind.sessionStart(sessionId: sessionId, id: id);
    } else {
      // We have to put displays in `sessionStart()` to make sure the stream is ready
      // and then the displays' capturing requests can be sent.
      stream = bind.sessionStartWithDisplays(
          sessionId: sessionId, id: id, displays: Int32List.fromList(displays));
    }

    if (isWeb) {
      platformFFI.setRgbaCallback((int display, Uint8List data) {
        onEvent2UIRgba();
        imageModel.onRgba(display, data);
      });
      return;
    }
    
    final cb = ffiModel.startEventListener(sessionId, id);

    imageModel.updateUserTextureRender();
    final hasGpuTextureRender = bind.mainHasGpuTextureRender();

    final SimpleWrapper<bool> isToNewWindowNotified = SimpleWrapper(false);
    // Preserved for the rgba data.
    stream.listen((message) {
      if (closed) return;
      if (tabWindowId != null && !isToNewWindowNotified.value) {
        // Session is read to be moved to a new window.
        // Get the cached data and handle the cached data.
        Future.delayed(Duration.zero, () async {
          final args = jsonEncode({'id': id, 'close': display == null});
          final cachedData = await DesktopMultiWindow.invokeMethod(
              tabWindowId, kWindowEventGetCachedSessionData, args);
          if (cachedData == null) {
            // unreachable
            debugPrint('Unreachable, the cached data is empty.');
            return;
          }
          final data = CachedPeerData.fromString(cachedData);
          if (data == null) {
            debugPrint('Unreachable, the cached data cannot be decoded.');
            return;
          }
          ffiModel.setPermissions(data.permissions);
          await ffiModel.handleCachedPeerData(data, id);
          await sessionRefreshVideo(sessionId, ffiModel.pi);
          await bind.sessionRequestNewDisplayInitMsgs(
              sessionId: sessionId, display: ffiModel.pi.currentDisplay);
        });
        isToNewWindowNotified.value = true;
      }
      () async {
        if (message is EventToUI_Event) {
          if (message.field0 == "close") {
            closed = true;
            debugPrint('Exit session event loop');
            return;
          }

          Map<String, dynamic>? event;
          try {
            event = json.decode(message.field0);
          } catch (e) {
            debugPrint('json.decode fail1(): $e, ${message.field0}');
          }
          if (event != null) {
            await cb(event);
          }
        } else if (message is EventToUI_Rgba) {
          final display = message.field0;
          if (imageModel.useTextureRender || ffiModel.pi.forceTextureRender) {
            //debugPrint("EventToUI_Rgba display:$display");
            textureModel.setTextureType(display: display, gpuTexture: false);
            onEvent2UIRgba();
          } else {
            // Fetch the image buffer from rust codes.
            final sz = platformFFI.getRgbaSize(sessionId, display);
            if (sz == 0) {
              platformFFI.nextRgba(sessionId, display);
              return;
            }
            final rgba = platformFFI.getRgba(sessionId, display, sz);
            if (rgba != null) {
              onEvent2UIRgba();
              imageModel.onRgba(display, rgba);
            } else {
              platformFFI.nextRgba(sessionId, display);
            }
          }
        } else if (message is EventToUI_Texture) {
          final display = message.field0;
          debugPrint("EventToUI_Texture display:$display");
          if (hasGpuTextureRender) {
            textureModel.setTextureType(display: display, gpuTexture: true);
            onEvent2UIRgba();
          }
        }
      }();
    });
    // every instance will bind a stream
    this.id = id;
  }

  void onEvent2UIRgba() async {
    if (ffiModel.waitForImageDialogShow.isTrue) {
      ffiModel.waitForImageDialogShow.value = false;
      ffiModel.waitForImageTimer?.cancel();
      clearWaitingForImage(dialogManager, sessionId);
    }
    if (ffiModel.waitForFirstImage.value == true) {
      ffiModel.waitForFirstImage.value = false;
      dialogManager.dismissAll();
      await canvasModel.updateViewStyle();
      await canvasModel.updateScrollStyle();
      for (final cb in imageModel.callbacksOnFirstImage) {
        cb(id);
      }
    }
  }
  
  /// Login with [password], choose if the client should [remember] it.
  void login(String osUsername, String osPassword, SessionID sessionId,
      String password, bool remember) {
    bind.sessionLogin(
        sessionId: sessionId,
        osUsername: osUsername,
        osPassword: osPassword,
        password: password,
        remember: remember);
  }

  void send2FA(SessionID sessionId, String code, bool trustThisDevice) {
    bind.sessionSend2Fa(
        sessionId: sessionId, code: code, trustThisDevice: trustThisDevice);
  }
  
  /// Close the remote session.
  Future<void> close({bool closeSession = true}) async {
    closed = true;
    chatModel.close();
    if (imageModel.image != null && !isWebDesktop) {
      await setCanvasConfig(
          sessionId,
          cursorModel.x,
          cursorModel.y,
          canvasModel.x,
          canvasModel.y,
          canvasModel.scale,
          ffiModel.pi.currentDisplay);
    }
    imageModel.update(null);
    cursorModel.clear();
    ffiModel.clear();
    canvasModel.clear();
    inputModel.resetModifiers();
    if (closeSession) {
      await bind.sessionClose(sessionId: sessionId);
    }
    debugPrint('model $id closed');
    id = '';
  }

  void setMethodCallHandler(FMethod callback) {
    platformFFI.setMethodCallHandler(callback);
  }

  Future<bool> invokeMethod(String method, [dynamic arguments]) async {
    return await platformFFI.invokeMethod(method, arguments);
  }
}

const kInvalidResolutionValue = -1;
const kVirtualDisplayResolutionValue = 0;

class Display {
  double x = 0;
  double y = 0;
  int width = 0;
  int height = 0;
  bool cursorEmbedded = false;
  int originalWidth = kInvalidResolutionValue;
  int originalHeight = kInvalidResolutionValue;
  double _scale = 1.0;
  double get scale => _scale > 1.0 ? _scale : 1.0;

  Display() {
    width = (isDesktop || isWebDesktop)
        ? kDesktopDefaultDisplayWidth
        : kMobileDefaultDisplayWidth;
    height = (isDesktop || isWebDesktop)
        ? kDesktopDefaultDisplayHeight
        : kMobileDefaultDisplayHeight;
  }

  @override
  bool operator ==(Object other) =>
      other is Display &&
      other.runtimeType == runtimeType &&
      _innerEqual(other);

  bool _innerEqual(Display other) =>
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height &&
      other.cursorEmbedded == cursorEmbedded;

  bool get isOriginalResolutionSet =>
      originalWidth != kInvalidResolutionValue &&
      originalHeight != kInvalidResolutionValue;
  bool get isVirtualDisplayResolution =>
      originalWidth == kVirtualDisplayResolutionValue &&
      originalHeight == kVirtualDisplayResolutionValue;
  bool get isOriginalResolution =>
      width == originalWidth && height == originalHeight;
}

class Resolution {
  int width = 0;
  int height = 0;
  Resolution(this.width, this.height);

  @override
  String toString() {
    return 'Resolution($width,$height)';
  }
}

class Features {
  bool privacyMode = false;
}

const kInvalidDisplayIndex = -1;

class PeerInfo with ChangeNotifier {
  String version = '';
  String username = '';
  String hostname = '';
  String platform = '';
  bool sasEnabled = false;
  bool isSupportMultiUiSession = false;
  int currentDisplay = 0;
  int primaryDisplay = kInvalidDisplayIndex;
  RxList<Display> displays = <Display>[].obs;
  Features features = Features();
  List<Resolution> resolutions = [];
  Map<String, dynamic> platformAdditions = {};

  RxInt displaysCount = 0.obs;
  RxBool isSet = false.obs;

  bool get isWayland => platformAdditions[kPlatformAdditionsIsWayland] == true;
  bool get isHeadless => platformAdditions[kPlatformAdditionsHeadless] == true;
  bool get isInstalled =>
      platform != kPeerPlatformWindows ||
      platformAdditions[kPlatformAdditionsIsInstalled] == true;
  List<int> get RustDeskVirtualDisplays => List<int>.from(
      platformAdditions[kPlatformAdditionsRustDeskVirtualDisplays] ?? []);
  int get amyuniVirtualDisplayCount =>
      platformAdditions[kPlatformAdditionsAmyuniVirtualDisplays] ?? 0;

  bool get isSupportMultiDisplay =>
      (isDesktop || isWebDesktop) && isSupportMultiUiSession;
  bool get forceTextureRender => currentDisplay == kAllDisplayValue;

  bool get cursorEmbedded => tryGetDisplay()?.cursorEmbedded ?? false;

  bool get isRustDeskIdd =>
      platformAdditions[kPlatformAdditionsIddImpl] == 'rustdesk_idd';
  bool get isAmyuniIdd =>
      platformAdditions[kPlatformAdditionsIddImpl] == 'amyuni_idd';

  Display? tryGetDisplay({int? display}) {
    if (displays.isEmpty) {
      return null;
    }
    display ??= currentDisplay;
    if (display == kAllDisplayValue) {
      return displays[0];
    } else {
      if (display > 0 && display < displays.length) {
        return displays[display];
      } else {
        return displays[0];
      }
    }
  }

  Display? tryGetDisplayIfNotAllDisplay({int? display}) {
    if (displays.isEmpty) {
      return null;
    }
    display ??= currentDisplay;
    if (display == kAllDisplayValue) {
      return null;
    }
    if (display >= 0 && display < displays.length) {
      return displays[display];
    } else {
      return null;
    }
  }

  List<Display> getCurDisplays() {
    if (currentDisplay == kAllDisplayValue) {
      return displays;
    } else {
      if (currentDisplay >= 0 && currentDisplay < displays.length) {
        return [displays[currentDisplay]];
      } else {
        return [];
      }
    }
  }

  double scaleOfDisplay(int display) {
    if (display >= 0 && display < displays.length) {
      return displays[display].scale;
    }
    return 1.0;
  }

  Rect? getDisplayRect(int display) {
    final d = tryGetDisplayIfNotAllDisplay(display: display);
    if (d == null) return null;
    return Rect.fromLTWH(d.x, d.y, d.width.toDouble(), d.height.toDouble());
  }
}


const canvasKey = 'canvas';

Future<void> setCanvasConfig(
    SessionID sessionId,
    double xCursor,
    double yCursor,
    double xCanvas,
    double yCanvas,
    double scale,
    int currentDisplay) async {
  final p = <String, dynamic>{};
  p['xCursor'] = xCursor;
  p['yCursor'] = yCursor;
  p['xCanvas'] = xCanvas;
  p['yCanvas'] = yCanvas;
  p['scale'] = scale;
  p['currentDisplay'] = currentDisplay;
  await bind.sessionSetFlutterOption(
      sessionId: sessionId, k: canvasKey, v: jsonEncode(p));
}

Future<Map<String, dynamic>?> getCanvasConfig(SessionID sessionId) async {
  if (!isWebDesktop) return null;
  var p =
      await bind.sessionGetFlutterOption(sessionId: sessionId, k: canvasKey);
  if (p == null || p.isEmpty) return null;
  try {
    Map<String, dynamic> m = json.decode(p);
    return m;
  } catch (e) {
    return null;
  }
}

Future<void> initializeCursorAndCanvas(FFI ffi) async {
  var p = await getCanvasConfig(ffi.sessionId);
  int currentDisplay = 0;
  if (p != null) {
    currentDisplay = p['currentDisplay'];
  }
  if (p == null || currentDisplay != ffi.ffiModel.pi.currentDisplay) {
    ffi.cursorModel.updateDisplayOrigin(
        ffi.ffiModel.rect?.left ?? 0, ffi.ffiModel.rect?.top ?? 0);
    return;
  }
  double xCursor = p['xCursor'];
  double yCursor = p['yCursor'];
  double xCanvas = p['xCanvas'];
  double yCanvas = p['yCanvas'];
  double scale = p['scale'];
  ffi.cursorModel.updateDisplayOriginWithCursor(ffi.ffiModel.rect?.left ?? 0,
      ffi.ffiModel.rect?.top ?? 0, xCursor, yCursor);
  ffi.canvasModel.update(xCanvas, yCanvas, scale);
}

clearWaitingForImage(OverlayDialogManager? dialogManager, SessionID sessionId) {
  dialogManager?.dismissByTag('$sessionId-waiting-for-image');
}
