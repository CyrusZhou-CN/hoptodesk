lazy_static::lazy_static! {
pub static ref T: std::collections::HashMap<&'static str, &'static str> =
    [
        ("Status", "Stato"),
        ("Your Desktop", "Questo desktop"),
        ("desk_tip", "Puoi accedere al tuo desktop usando l'ID e la password riportati qui."),
        ("Password", "Password"),
        ("Ready", "Pronto"),
        ("Established", "Stabilita"),
        ("connecting_status", "Connessione alla rete HopToDesk in corso..."),
        ("connecting_status_short", "Connessione..."),				
        ("Enable Service", "Abilita servizio"),
        ("Start Service", "Avvia servizio"),
        ("Service is running", "Il servizio è in esecuzione"),
        ("Service is not running", "Il servizio non è in esecuzione"),
        ("not_ready_status", "Non pronto. Verifica la tua connessione"),
		("not_ready_status_short", "Non pronto"),
        ("Control Remote Desktop", "Controlla desktop remoto"),
        ("Transfer File", "Trasferisci file"),
        ("Connect", "Connetti"),
        ("Recent Sessions", "Sessioni recenti"),
        ("Address Book", "Rubrica"),
        ("Confirmation", "Conferma"),
        ("TCP Tunneling", "Tunnel TCP"),
        ("Remove", "Rimuovi"),
        ("Refresh random password", "Nuova password casuale"),
        ("Set your own password", "Imposta la password"),
        ("Enable Keyboard/Mouse", "Abilita tastiera/mouse"),
        ("Enable Clipboard", "Abilita appunti"),
        ("Enable File Transfer", "Abilita trasferimento file"),
        ("Enable TCP Tunneling", "Abilita tunnel TCP"),
        ("IP Whitelisting", "IP autorizzati"),
        ("ID/Relay Server", "Server ID/Relay"),
        ("Import Server Config", "Importa configurazione server dagli appunti"),
        ("Export Server Config", "Esporta configurazione server negli appunti"),
        ("Import server configuration successfully", "Configurazione server importata completata"),
        ("Export server configuration successfully", "Configurazione Server esportata completata"),
        ("Invalid server configuration", "Configurazione server non valida"),
        ("Clipboard is empty", "Gli appunti sono vuoti"),
        ("Stop service", "Arresta servizio"),
        ("Change ID", "Cambia ID"),
        ("Your new ID", "Il nuovo ID"),
        ("length %min% to %max%", "lunghezza da %min% a %max%"),
        ("starts with a letter", "inizia con una lettera"),
        ("allowed characters", "caratteri consentiti"),
        ("id_change_tip", "Puoi usare solo i caratteri a-z, A-Z, 0-9 e _ (sottolineato).\nIl primo carattere deve essere a-z o A-Z.\nLa lunghezza deve essere fra 6 e 16 caratteri."),
        ("Website", "Sito web programma"),
        ("About", "Info programma"),
        ("Slogan_tip", "Realizzato con il cuore in questo mondo caotico!"),
        ("Privacy Statement", "Informativa sulla privacy"),
        ("Mute", "Audio off"),
        ("Build Date", "Data build"),
        ("Version", "Versione"),
        ("Home", "Home"),
        ("Audio Input", "Ingresso audio"),
        ("Enhancements", "Miglioramenti"),
        ("Hardware Codec", "Codec hardware"),
        ("Adaptive Bitrate", "Bitrate adattivo"),
        ("ID Server", "ID server"),
        ("Relay Server", "Server relay"),
        ("API Server", "Server API"),
        ("invalid_http", "deve iniziare con http:// o https://"),
        ("Invalid IP", "Indirizzo IP non valido"),
        ("Invalid format", "Formato non valido"),
        ("server_not_support", "Non ancora supportato dal server"),
        ("Not available", "Non disponibile"),
        ("Too frequent", "Troppo frequente"),
        ("Cancel", "Annulla"),
        ("Skip", "Ignora"),
        ("Close", "Chiudi"),
        ("Retry", "Riprova"),
        ("OK", "OK"),
        ("Password Required", "Password richiesta"),
        ("Please enter your password", "Inserisci la password"),
        ("Remember password", "Ricorda password"),
        ("Wrong Password", "Password errata"),
        ("Do you want to enter again?", "Vuoi riprovare?"),
        ("Connection Error", "Errore di connessione"),
        ("Error", "Errore"),
        ("Connection lost", "Reimpostata dal peer"),
        ("Connecting...", "Connessione..."),
        ("Connection in progress. Please wait.", "Connessione in corso..."),
        ("Please try 1 minute later", "Riprova fra 1 minuto"),
        ("Login Error", "Errore accesso"),
        ("Successful", "Completato"),
        ("Connected, waiting for image...", "Connesso, in attesa dell'immagine..."),
        ("Name", "Nome"),
        ("Type", "Tipo"),
        ("Modified", "Modificato"),
        ("Size", "Dimensione"),
        ("Show Hidden Files", "Visualizza file nascosti"),
        ("Receive", "Ricevi"),
        ("Send", "Invia"),
        ("Refresh File", "Aggiorna file"),
        ("Local", "Locale"),
        ("Remote", "Remoto"),
        ("Remote Computer", "Computer remoto"),
        ("Local Computer", "Computer locale"),
        ("Confirm Delete", "Conferma eliminazione"),
        ("Delete", "Elimina"),
        ("Properties", "Proprietà"),
        ("Multi Select", "Selezione multipla"),
        ("Select All", "Seleziona tutto"),
        ("Unselect All", "Deseleziona tutto"),
        ("Empty Directory", "Cartella vuota"),
        ("Not an empty directory", "Non è una cartella vuota"),
        ("Are you sure you want to delete this file?", "Sei sicuro di voler eliminare questo file?"),
        ("Are you sure you want to delete this empty directory?", "Sei sicuro di voler eliminare questa cartella vuota?"),
        ("Are you sure you want to delete the file of this directory?", "Sei sicuro di voler eliminare il file di questa cartella?"),
        ("Do this for all conflicts", "Ricorca questa scelta per tutti i conflitti"),
        ("This is irreversible!", "Questo è irreversibile!"),
        ("Deleting", "Eliminazione di"),
        ("files", "file"),
        ("Waiting", "In attesa"),
        ("Finished", "Completato"),
        ("Speed", "Velocità"),
        ("Custom Image Quality", "Qualità immagine personalizzata"),
        ("Privacy mode", "Modalità privacy"),
        ("Block user input", "Blocca input utente"),
        ("Unblock user input", "Sblocca input utente"),
        ("Adjust Window", "Adatta finestra"),
        ("Original", "Originale"),
        ("Shrink", "Restringi"),
        ("Stretch", "Allarga"),
        ("Scrollbar", "Barra scorrimento"),
        ("ScrollAuto", "Scorri automaticamente"),
        ("Good image quality", "Qualità immagine buona"),
        ("Balanced", "Bilanciata qualità/velocità"),
        ("Optimize reaction time", "Ottimizza tempo reazione"),
        ("Custom", "Profilo personalizzato"),
        ("Show remote cursor", "Visualizza cursore remoto"),
        ("Show quality monitor", "Visualizza qualità video"),
        ("Disable clipboard", "Disabilita appunti"),
        ("Lock after session end", "Blocca al termine della sessione"),
        ("Insert", "Inserisci"),
        ("Insert Lock", "Blocco inserimento"),
        ("Refresh", "Aggiorna"),
        ("ID does not exist", "L'ID non esiste"),
        ("Failed to connect to signal server", "Errore di connessione al server rendezvous"),
        ("Please try later", "Riprova più tardi"),
        ("Remote desktop is offline", "Il desktop remoto è offline"),
        ("Key mismatch", "La chiave non corrisponde"),
        ("Timeout", "Timeout"),
        ("Unable to connect to the remote partner.", "Impossibile connettersi al partner remoto."),
        ("Failed to connect via relay server", "Errore di connessione tramite il server relay"),
        ("Failed to make direct connection to remote desktop", "Impossibile connettersi direttamente al desktop remoto"),
        ("Set Password", "Imposta password"),
        ("OS Password", "Password sistema operativo"),
        ("install_tip", "Si consiglia un'installazione completa."),
        ("Upgrade Now", "Fai click per aggiornare"),
        ("Click to upgrade", "Aggiorna"),
        ("Click to download", "Download"),
        ("Click to update", "Aggiorna"),
        ("Configure", "Configura"),
        ("config_acc", "Per controllare il desktop dall'esterno, devi fornire a HopToDesk il permesso 'Accessibilità'."),
        ("config_screen", "Per controllare il desktop dall'esterno, devi fornire a HopToDesk il permesso 'Registrazione schermo'."),
        ("Installing ...", "Installazione ..."),
        ("Install", "Installa"),
        ("Installation", "Installazione"),
        ("Installation Path", "Percorso installazione"),
        ("Create start menu shortcuts", "Crea i collegamenti nel menu Start"),
        ("Create desktop icon", "Crea un'icona sul desktop"),
        ("agreement_tip", "Avviando l'installazione, accetti i termini del contratto di licenza."),
        ("Accept and Install", "Accetta e installa"),
        ("End-user license agreement", "Contratto di licenza con l'utente finale"),
        ("Generating ...", "Generazione ..."),
        ("A new update is available.", "La tua installazione non è aggiornata."),
        ("not_close_tcp_tip", "Non chiudere questa finestra mentre stai usando il tunnel"),
        ("Listening ...", "In ascolto ..."),
        ("Remote Host", "Host remoto"),
        ("Remote Port", "Porta remota"),
        ("Action", "Azione"),
        ("Add", "Aggiungi"),
        ("Local Port", "Porta locale"),
        ("Local Address", "Indirizzo locale"),
        ("Change Local Port", "Cambia porta locale"),
        ("setup_server_tip", "Per una connessione più veloce, configura uno specifico server"),
        ("Too short, at least 6 characters.", "Troppo corta, almeno 6 caratteri"),
        ("The confirmation is not identical.", "La password di conferma non corrisponde"),
        ("Permissions", "Permessi"),
        ("Accept", "Accetta"),
        ("Dismiss", "Rifiuta"),
        ("Disconnect", "Disconnetti"),
        ("Allow using keyboard and mouse", "Consenti l'uso di tastiera e mouse"),
        ("Allow using clipboard", "Consenti l'uso degli appunti"),
        ("Allow hearing sound", "Consenti la riproduzione dell'audio"),
        ("Allow file copy and paste", "Consenti copia e incolla di file"),
        ("Connected", "Connesso"),
        ("Direct and encrypted connection", "Connessione diretta e cifrata"),
        ("Relayed and encrypted connection", "Connessione tramite relay e cifrata"),
        ("Direct and unencrypted connection", "Connessione diretta e non cifrata"),
        ("Relayed and unencrypted connection", "Connessione tramite relay e non cifrata"),
        ("Enter Remote ID", "Inserisci l'ID remoto"),
        ("Enter your password", "Inserisci la password"),
        ("Logging in...", "Autenticazione..."),
        ("Enable RDP session sharing", "Abilita condivisione sessione RDP"),
        ("Auto Login", "Accesso automatico"),
        ("Enable Direct IP Access", "Abilita l'accesso diretto tramite IP"),
        ("Rename", "Rinomina"),
        ("Space", "Spazio"),
        ("Create Desktop Shortcut", "Crea collegamento sul desktop"),
        ("Change Path", "Modifica percorso"),
        ("Create Folder", "Crea cartella"),
        ("Please enter the folder name", "Inserisci il nome della cartella"),
        ("Disable Wayland", "Risolvi"),
        ("Warning", "Avviso"),
        ("Login screen using Wayland is not supported.", "La schermata di accesso non è supportata usando Wayland"),
        ("Reboot required", "Riavvio necessario"),
        ("Unsupported display server", "Display server non supportato"),
        ("x11 expected", "necessario xll"),
        ("Port", "Porta"),
        ("Settings", "Impostazioni"),
        ("Username", "Nome utente"),
        ("Invalid port", "Numero porta non valido"),
        ("The remote partner has closed the session.", "Chiuso manualmente dal peer."),
        ("Enable remote configuration modification", "Abilita la modifica remota della configurazione"),
        ("Run without install", "Avvia senza installare"),
        ("Connect via relay", "Collegati tramite relay"),
        ("Always connect via relay", "Collegati sempre tramite relay"),
        ("whitelist_tip", "Possono connettersi a questo desktop solo gli indirizzi IP autorizzati"),
        ("Login", "Accedi"),
        ("Verify", "Verifica"),
        ("Remember me", "Ricordami"),
        ("Trust this device", "Registra questo dispositivo come attendibile"),
        ("Verification code", "Codice di verifica"),
        ("verification_tip", "È stato inviato un codice di verifica all'indirizzo email registrato, per accedere inserisci il codice di verifica."),
        ("Logout", "Esci"),
        ("Tags", "Etichette"),
        ("Search ID", "Cerca ID"),
        ("Current Wayland display server is not supported.", "Questo display server Wayland non è supportato"),
		("Change Display", "Cambia visualizzazione"),		
        ("whitelist_sep", "Separati da virgola, punto e virgola, spazio o a capo"),
        ("Add ID", "Aggiungi ID"),
        ("Add Tag", "Aggiungi etichetta"),
        ("Unselect all tags", "Deseleziona tutte le etichette"),
        ("Network error", "Errore di rete"),
        ("Username missed", "Nome utente mancante"),
        ("Password missed", "Password mancante"),
        ("Wrong credentials", "Credenziali errate"),
        ("The verification code is incorrect or has expired", "Il codice di verifica non è corretto o è scaduto"),
        ("Edit Tag", "Modifica etichetta"),
        ("Forget Password", "Dimentica password"),
        ("Favorites", "Preferiti"),
        ("Add to Favorites", "Aggiungi ai preferiti"),
        ("Remove from Favorites", "Rimuovi dai preferiti"),
        ("Empty", "Vuoto"),
        ("Invalid folder name", "Nome della cartella non valido"),
        ("SOCKS5 Proxy", "SOCKS5 Proxy"),
        ("Hostname", "Nome host"),
        ("Discovered", "Rilevate"),
        ("install_daemon_tip", "Per avviare il programma all'accensione, è necessario installarlo come servizio di sistema."),
        ("Remote ID", "ID remoto"),
        ("Paste", "Incolla"),
        ("Paste here?", "Incollare qui?"),
        ("Are you sure to close the connection?", "Sei sicuro di voler chiudere la connessione?"),
        ("Download new version", "Scarica nuova versione"),
        ("Touch mode", "Modalità tocco"),
        ("Mouse mode", "Modalità mouse"),
        ("One-Finger Tap", "Tocca con un dito"),
        ("Left Mouse", "Mouse sinistro"),
        ("One-Long Tap", "Tocco lungo con un dito"),
        ("Two-Finger Tap", "Tocca con due dita"),
        ("Right Mouse", "Mouse destro"),
        ("One-Finger Move", "Movimento con un dito"),
        ("Double Tap & Move", "Tocca due volte e sposta"),
        ("Mouse Drag", "Trascina il mouse"),
        ("Three-Finger vertically", "Tre dita in verticale"),
        ("Mouse Wheel", "Rotellina del mouse"),
        ("Two-Finger Move", "Movimento con due dita"),
        ("Canvas Move", "Sposta tela"),
        ("Pinch to Zoom", "Pizzica per zoomare"),
        ("Canvas Zoom", "Zoom tela"),
        ("Reset canvas", "Ripristina tela"),
        ("No permission of file transfer", "Nessun permesso per il trasferimento file"),
        ("Note", "Nota"),
        ("Connection", "Connessione"),
        ("Share Screen", "Condividi schermo"),
        ("Chat", "Chat"),
        ("Total", "Totale"),
        ("items", "Oggetti"),
        ("Selected", "Selezionato"),
        ("Screen Capture", "Cattura schermo"),
        ("Input Control", "Controllo input"),
        ("Audio Capture", "Acquisizione audio"),
        ("File Connection", "Connessione file"),
        ("Screen Connection", "Connessione schermo"),
        ("Do you accept?", "Accetti?"),
        ("Open System Setting", "Apri impostazioni di sistema"),
        ("How to get Android input permission?", "Come ottenere l'autorizzazione input in Android?"),
        ("android_input_permission_tip1", "Affinché un dispositivo remoto possa controllare un dispositivo Android tramite mouse o tocco, devi consentire a HopToDesk di usare il servizio 'Accessibilità'."),
        ("android_input_permission_tip2", "Vai nella pagina delle impostazioni di sistema che si aprirà di seguito, trova e accedi a [Servizi installati], attiva il servizio [HopToDesk Input]."),
        ("android_new_connection_tip", "È stata ricevuta una nuova richiesta di controllo per il dispositivo attuale."),
        ("android_service_will_start_tip", "L'attivazione di Cattura schermo avvierà automaticamente il servizio, consentendo ad altri dispositivi di richiedere una connessione da questo dispositivo."),
        ("android_stop_service_tip", "La chiusura del servizio chiuderà automaticamente tutte le connessioni stabilite."),
        ("android_version_audio_tip", "L'attuale versione di Android non supporta l'acquisizione audio, esegui l'aggiornamento ad Android 10 o versioni successive."),
        ("android_start_service_tip", "Per avviare il servizio di condivisione dello schermo seleziona [Avvia servizio] o abilita l'autorizzazione [Cattura schermo]."),
        ("android_permission_may_not_change_tip", "Le autorizzazioni per le connessioni stabilite non possono essere modificate istantaneamente fino alla riconnessione."),
        ("Account", "Account"),
        ("Overwrite", "Sovrascrivi"),
        ("This file exists, skip or overwrite this file?", "Questo file esiste, vuoi ignorarlo o sovrascrivere questo file?"),
        ("Quit", "Esci"),
        ("doc_mac_permission", ""),
        ("Help", "Aiuto"),
        ("Failed", "Fallito"),
        ("Succeeded", "Completato"),
        ("Someone turned on privacy mode, exiting.", "Qualcuno attiva la modalità privacy, esci"),
        ("Unsupported", "Non supportato"),
        ("Peer denied", "Acvesso negato al dispositivo remoto"),
        ("Please install plugins", "Installa i plugin"),
        ("Peer exit", "Uscita dal dispostivo remoto"),
        ("Failed to turn off", "Impossibile spegnere"),
        ("Turned off", "Spegni"),
        ("In privacy mode", "In modalità privacy"),
        ("Out privacy mode", "Uscita dalla modalità privacy"),
		("Language", "Lingua"),
        ("Keep HopToDesk background service", "Mantieni il servizio di HopToDesk in background"),
        ("Ignore Battery Optimizations", "Ignora le ottimizzazioni della batteria"),
        ("android_open_battery_optimizations_tip", "Se vuoi disabilitare questa funzione, vai nelle impostazioni dell'applicazione HopToDesk, apri la sezione 'Batteria' e deseleziona 'Senza restrizioni'."),
        ("Start on Boot", "Avvia all'accensione"),
        ("Start the screen sharing service on boot, requires special permissions", "L'avvio del servizio di condivisione dello schermo all'accensione richiede autorizzazioni speciali"),
        ("Connection not allowed", "Connessione non consentita"),
        ("Legacy mode", "Modalità legacy"),
        ("Map mode", "Modalità mappa"),
        ("Translate mode", "Modalità traduzione"),
        ("Use permanent password", "Usa password permanente"),
        ("Use both passwords", "Usa password monouso e permanente"),
        ("Set permanent password", "Imposta password permanente"),
        ("Enable Remote Restart", "Abilita riavvio da remoto"),
        ("Allow remote restart", "Consenti riavvio da remoto"),
        ("Restart Remote Device", "Riavvia dispositivo remoto"),
        ("Are you sure you want to restart", "Sei sicuro di voler riavviare?"),
        ("Restarting Remote Device", "Il dispositivo remoto si sta riavviando"),
        ("remote_restarting_tip", "Riavvia il dispositivo remoto"),
        ("Copied", "Copiato"),
        ("Exit Fullscreen", "Esci dalla modalità schermo intero"),
        ("Fullscreen", "A schermo intero"),
        ("Mobile Actions", "Azioni mobili"),
        ("Select Monitor", "Seleziona schermo"),
        ("Control Actions", "Azioni controllo"),
        ("Display Settings", "Impostazioni visualizzazione"),
        ("Ratio", "Rapporto"),
        ("Image Quality", "Qualità immagine"),
        ("Scroll Style", "Stile scorrimento"),
        ("Show Toolbar", "Visualizza barra strumenti"),
        ("Hide Toolbar", "Nascondi barra strumenti"),
        ("Direct Connection", "Connessione diretta"),
        ("Relay Connection", "Connessione relay"),
        ("Secure Connection", "Connessione sicura"),
        ("Insecure Connection", "Connessione non sicura"),
        ("Scale original", "Scala originale"),
        ("Scale adaptive", "Scala adattiva"),
        ("General", "Generale"),
        ("Security", "Sicurezza"),
        ("Theme", "Tema"),
        ("Dark Theme", "Tema scuro"),
        ("Light Theme", "Tema chiaro"),
        ("Dark", "Scuro"),
        ("Light", "Chiaro"),
        ("Follow System", "Sistema"),
        ("Enable hardware codec", "Abilita codec hardware"),
        ("Unlock Security Settings", "Sblocca impostazioni sicurezza"),
        ("Enable Audio", "Abilita audio"),
        ("Unlock Network Settings", "Sblocca impostazioni di rete"),
        ("Server", "Server"),
        ("Direct IP Access", "Accesso IP diretto"),
        ("Proxy", "Proxy"),
        ("Apply", "Applica"),
        ("Disconnect all devices?", "Vuoi disconnettere tutti i dispositivi?"),
        ("Clear", "Azzera"),
        ("Audio Input Device", "Dispositivo ingresso audio"),
        ("Deny remote access", "Nega accesso remoto"),
        ("Use IP Whitelisting", "Usa elenco IP autorizzati"),
        ("Network", "Rete"),
        ("Enable RDP", "Abilita RDP"),
        ("Pin Toolbar", "Blocca barra strumenti"),
        ("Unpin Toolbar", "Sblocca barra strumenti"),
        ("Recording", "Registrazione"),
        ("Directory", "Cartella"),
        ("Automatically record incoming sessions", "Registra automaticamente le sessioni in entrata"),
        ("Change", "Modifica"),
        ("Start session recording", "Inizia registrazione sessione"),
        ("Stop session recording", "Ferma registrazione sessione"),
        ("Enable Recording Session", "Abilita registrazione sessione"),
        ("Allow recording session", "Permetti registrazione sessione"),
        ("Enable LAN Discovery", "Abilita rilevamento LAN"),
        ("Deny LAN Discovery", "Nega rilevamento LAN"),
        ("Write a message", "Scrivi un messaggio"),
        ("Prompt", "Richiedi"),
        ("Please wait for confirmation of UAC...", "Attendi la conferma dell'UAC..."),
        ("elevated_foreground_window_tip", "La finestra attuale del desktop remoto richiede per funzionare privilegi più elevati, quindi non è possibile usare temporaneamente il mouse e la tastiera.\nÈ possibile chiedere all'utente remoto di ridurre a icona la finestra attuale o di selezionare il pulsante di elevazione nella finestra di gestione della connessione.\nPer evitare questo problema, ti consigliamo di installare il software nel dispositivo remoto."),
        ("Disconnected", "Disconnesso"),
        ("Other", "Altro"),
        ("Confirm before closing multiple tabs", "Conferma prima di chiudere più schede"),
        ("Keyboard Settings", "Impostazioni tastiera"),
        ("Full Access", "Accesso completo"),
        ("Screen Share", "Condivisione schermo"),
        ("Wayland requires Ubuntu 21.04 or higher version.", "Wayland richiede Ubuntu 21.04 o versione successiva."),
        ("Wayland requires higher version of linux distro. Please try X11 desktop or change your OS.", "Wayland richiede una versione superiore della distribuzione Linux.\nProva X11 desktop o cambia il sistema operativo."),
        ("JumpLink", "Vai a"),
        ("Please Select the screen to be shared(Operate on the peer side).", "Seleziona lo schermo da condividere (opera sul lato peer)."),
        ("Show HopToDesk", "Visualizza HopToDesk"),
        ("This PC", "Questo PC"),
        ("or", "O"),
        ("Continue with", "Continua con"),
        ("Elevate", "Eleva"),
        ("Zoom cursor", "Cursore zoom"),
        ("Accept sessions via password", "Accetta sessioni via password"),
        ("Accept sessions via click", "Accetta sessioni via clic"),
        ("Accept sessions via both", "Accetta sessioni con entrambe le password"),
        ("Please wait for the remote side to accept your session request...", "Attendi che il dispositivo remoto accetti la richiesta di sessione..."),
        ("One-time Password", "Password monouso"),
        ("Use one-time password", "Usa password monouso"),
        ("One-time password length", "Lunghezza password monouso"),
        ("Request access to your device", "Richiedi l'accesso al dispositivo"),
        ("Hide connection management window", "Nascondi la finestra di gestione delle connessioni"),
        ("hide_cm_tip", "Permetti di nascondere solo se si accettano sessioni con password permanente"),
        ("wayland_experiment_tip", "Il supporto Wayland è in fase sperimentale, se vuoi un accesso stabile usa X11."),
        ("Right click to select tabs", "Clic con il tasto destro per selezionare le schede"),
        ("Skipped", "Saltato"),
        ("Add to Address Book", "Aggiungi alla rubrica"),
        ("Group", "Gruppo"),
        ("Search", "Cerca"),
        ("Closed manually by web console", "Chiudi manualmente dalla console web"),
        ("Local keyboard type", "Tipo tastiera locale"),
        ("Select local keyboard type", "Seleziona il tipo di tastiera locale"),
        ("software_render_tip", "Se nel computer con Linux è presente una scheda grafica Nvidia e la finestra remota si chiude immediatamente dopo la connessione, installa il nuovo driver open source e usa il rendering software.\nPotrebbe essere necessario un riavvio del programma."),
        ("Always use software rendering", "Usa sempre il render software"),
        ("config_input", "Per controllare il desktop remoto con la tastiera, è necessario concedere le autorizzazioni a HopToDesk 'Monitoraggio input'."),
        ("config_microphone", "Per poter chiamare, è necessario concedere l'autorizzazione a HopToDesk 'Registra audio'."),
        ("request_elevation_tip", "Se c'è qualcuno nel lato remoto è possibile richiedere l'elevazione."),
        ("Wait", "Attendi"),
        ("Elevation Error", "Errore durante l'elevazione dei diritti"),
        ("Ask the remote user for authentication", "Chiedi l'autenticazione all'utente remoto"),
        ("Choose this if the remote account is administrator", "Scegli questa opzione se l'account remoto è amministratore"),
        ("Transmit the username and password of administrator", "Trasmetti il nome utente e la password dell'amministratore"),
        ("still_click_uac_tip", "Richiedi ancora che l'utente remoto faccia clic su OK nella finestra UAC dell'esecuzione di HopToDesk."),
        ("Request Elevation", "Richiedi elevazione dei diritti"),
        ("wait_accept_uac_tip", "Attendi che l'utente remoto accetti la finestra di dialogo UAC."),
        ("Elevate successfully", "Elevazione dei diritti effettuata correttamente"),
        ("uppercase", "Maiuscola"),
        ("lowercase", "Minuscola"),
        ("digit", "Numero"),
        ("special character", "Carattere speciale"),
        ("length>=8", "Lunghezza >= 8"),
        ("Weak", "Debole"),
        ("Medium", "Media"),
        ("Strong", "Forte"),
        ("Switch Sides", "Cambia lato"),
        ("Please confirm if you want to share your desktop?", "Vuoi condividere il desktop?"),
        ("Display", "Visualizzazione"),
        ("Default View Style", "Stile visualizzazione predefinito"),
        ("Default Scroll Style", "Stile scorrimento predefinito"),
        ("Default Image Quality", "Qualità immagine predefinita"),
        ("Default Codec", "Codec predefinito"),
        ("Bitrate", "Bitrate"),
        ("FPS", "FPS"),
        ("Auto", "Automatico"),
        ("Other Default Options", "Altre opzioni predefinite"),
        ("Voice call", "Chiamata vocale"),
        ("Text chat", "Chat testuale"),
        ("Stop voice call", "Interrompi chiamata vocale"),
        ("relay_hint_tip", "Se non è possibile connettersi direttamente, puoi provare a farlo tramite relay.\nInoltre, se si vuoi usare il relay al primo tentativo, è possibile aggiungere all'ID il suffisso '/r\' o selezionare nella scheda peer l'opzione 'Collegati sempre tramite relay'."),
        ("Reconnect", "Riconnetti"),
        ("Codec", "Codec"),
        ("Resolution", "Risoluzione"),
        ("No transfers in progress", "Nessun trasferimento in corso"),
        ("Set one-time password length", "Imposta lunghezza password monouso"),
        ("install_cert_tip", "Installa certificato HopToDesk"),
        ("comfirm_install_cert_tip", "Questo è un certificato di test HopToDesk, che può essere considerato attendibile.\nIl certificato verrà usato per certifarsi ed installare i driver HopToDesk quando richiesto."),
        ("RDP Settings", "Impostazioni RDP"),
        ("Sort by", "Ordina per"),
        ("New Connection", "Nuova connessione"),
        ("Restore", "Ripristina"),
        ("Minimize", "Minimizza"),
        ("Maximize", "Massimizza"),
        ("Your Device", "Questo dispositivo"),
        ("empty_recent_tip", "Le sessioni recenti verranno visualizzate qui."),
        ("empty_favorite_tip", "I colleghi preferiti verranno visualizzati qui."),
        ("empty_lan_tip", "I peer scoperti verranno visualizzati qui."),
        ("empty_address_book_tip", "Sembra che per ora nella rubrica non ci siano connessioni."),
        ("eg: admin", "es: admin"),
        ("Empty Username", "Nome utente vuoto"),
        ("Empty Password", "Password vuota"),
        ("Me", "Io"),
        ("identical_file_tip", "Questo file è identico a quello del peer."),
        ("show_monitors_tip", "Visualizza schermi nella barra strumenti"),
        ("View Mode", "Modalità visualizzazione"),
        ("login_linux_tip", "Accedi all'account Linux remoto"),
        ("verify_rustdesk_password_tip", "Conferma password HopToDesk"),
        ("remember_account_tip", "Ricorda questo account"),
        ("os_account_desk_tip", "Questo account viene usato per accedere al sistema operativo remoto e attivare la sessione desktop in modalità non presidiata."),
        ("OS Account", "Account sistema operativo"),
        ("another_user_login_title_tip", "È già loggato un altro utente."),
        ("another_user_login_text_tip", "Separato"),
        ("xorg_not_found_title_tip", "Xorg non trovato."),
        ("xorg_not_found_text_tip", "Installa Xorg."),
        ("no_desktop_title_tip", "Non c'è nessun desktop disponibile."),
        ("no_desktop_text_tip", "Installa il desktop GNOME."),
        ("No need to elevate", "Elevazione dei privilegi non richiesta"),
        ("System Sound", "Dispositivo audio sistema"),
        ("Default", "Predefinita"),
        ("New RDP", "Nuovo RDP"),
        ("Fingerprint", "Firma digitale"),
        ("Copy Fingerprint", "Copia firma digitale"),
        ("no fingerprints", "Nessuna firma digitale"),
        ("Select a peer", "Seleziona un peer"),
        ("Select peers", "Seleziona peer"),
        ("Plugins", "Plugin"),
        ("Uninstall", "Disinstalla"),
        ("Update", "Aggiorna"),
        ("Enable", "Abilita"),
        ("Disable", "Disabilita"),
        ("Options", "Opzioni"),
        ("resolution_original_tip", "Risoluzione originale"),
        ("resolution_fit_local_tip", "Adatta risoluzione locale"),
        ("resolution_custom_tip", "Risoluzione personalizzata"),
        ("Collapse toolbar", "Comprimi barra strumenti"),
        ("Accept and Elevate", "Accetta ed eleva"),
        ("accept_and_elevate_btn_tooltip", "Accetta la connessione ed eleva le autorizzazioni UAC."),                                
        ("clipboard_wait_response_timeout_tip", "Timeout attesa risposta della copia."),
        ("Incoming connection", "Connessioni in entrata"),
        ("Outgoing connection", "Connessioni in uscita"),
        ("Exit", "Esci da HopToDesk"),
        ("Open", "Apri HopToDesk"),
        ("logout_tip", "Sei sicuro di voler uscire?"),
        ("Service", "Servizio"),
        ("Start", "Avvia"),
        ("Stop", "Ferma"),
        ("exceed_max_devices", "Hai raggiunto il numero massimo di dispositivi gestibili."),
        ("Sync with recent sessions", "Sincronizza con le sessioni recenti"),
        ("Sort tags", "Ordina etichette"),
        ("Open connection in new tab", "Apri connessione in una nuova scheda"),
        ("Move tab to new window", "Sposta scheda nella finestra successiva"),
        ("Can not be empty", "Non può essere vuoto"),
        ("Already exists", "Esiste già"),
        ("Change Password", "Modifica password"),
        ("Refresh Password", "Aggiorna password"),
        ("ID", "ID"),
        ("Grid View", "Vista griglia"),
        ("List View", "Vista elenco"),
        ("Select", "Seleziona"),
        ("Toggle Tags", "Attiva/disattiva tag"),
        ("pull_ab_failed_tip", "Impossibile aggiornare la rubrica"),
        ("push_ab_failed_tip", "Impossibile sincronizzare la rubrica con il server"),
        ("synced_peer_readded_tip", "I dispositivi presenti nelle sessioni recenti saranno sincronizzati di nuovo nella rubrica."),
        ("Change Color", "Modifica colore"),
        ("Primary Color", "Colore primario"),
        ("HSV Color", "Colore HSV"),
        ("Installation Successful!", "Installazione completata"),
        ("Installation failed!", "Installazione fallita"),
        ("Reverse mouse wheel", "Rotella mouse inversa"),
        ("{} sessions", "{} sessioni"),
        ("scam_title", "Potresti essere stato TRUFFATO!"),
        ("scam_text1", "Se sei al telefono con qualcuno che NON conosci NON DI TUA FIDUCIA che ti ha chiesto di usare RustDesk e di avviare il servizio, non procedere e riattacca subito."),
        ("scam_text2", "Probabilmente è un truffatore che cerca di rubare i tuoi soldi o altre informazioni private."),
        ("Don't show again", "Non visualizzare più"),
        ("I Agree", "Accetto"),
        ("Decline", "Non accetto"),
        ("Timeout in minutes", "Timeout in minuti"),
        ("auto_disconnect_option_tip", ""),
        ("Connection failed due to inactivity", "Connessione non riuscita a causa di inattività"),
        ("Check for software update on startup", "All'avvio verifica presenza aggiornamenti programma"),
        ("upgrade_rustdesk_server_pro_to_{}_tip", "Aggiorna RustDesk Server Pro alla versione {} o successiva!"),
        ("pull_group_failed_tip", "Impossibile aggiornare il gruppo"),        
		("Enable 2FA", "Abilita 2FA"),
        ("Enable 2FA Auto Accept", "Abilita l'accettazione automatica 2FA"),				
		("Enable Wake On LAN", "Abilita Wake On LAN"),
        ("Scan this QR code with a camera on a secondary device such as a phone to set it up as your 2FA authenticator.", "Scansiona questo codice QR con una fotocamera su un dispositivo secondario come un telefono per configurarlo come autenticatore 2FA."),
        ("You will need to confirm the 2FA on the secondary device with you when trying to connect to this desktop.", "Dovrai confermare con te la 2FA sul dispositivo secondario quando tenti di connetterti a questo desktop."),		
        ("Choose Network", "Scegli Rete"),		
		("Unattended Access", "Accesso non Presidiato"),				
    ].iter().cloned().collect();
}
