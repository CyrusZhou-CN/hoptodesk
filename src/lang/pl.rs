lazy_static::lazy_static! {
pub static ref T: std::collections::HashMap<&'static str, &'static str> =
    [
        ("Status", "Status"),
        ("Your Desktop", "Twój pulpit"),
        ("desk_tip", "Aby połaczyć się z tym urządzeniem należy użyć tego ID i hasła."),
        ("Password", "Hasło"),
        ("Ready", "Gotowe"),
        ("Established", "Ustanowione"),
		("connecting_status", "Łączenie z siecią HopToDesk..."),
		("connecting_status_short", "Łączenie z siecią HopToDesk..."),		
        ("Enable Service", "Włącz usługę"),
        ("Start Service", "Uruchom usługę"),
        ("Service is running", "Usługa uruchomiona"),
        ("Service is not running", "Usługa nie jest uruchomiona"),
		("not_ready_status", "Brak gotowości"),
		("not_ready_status_short", "Brak gotowości"),				
        ("Control Remote Desktop", "Kontroluj zdalny pulpit"),
        ("Transfer File", "Transfer plików"),
        ("Connect", "Połącz"),
        ("Recent Sessions", "Ostatnie sesje"),
        ("Address Book", "Książka adresowa"),
        ("Confirmation", "Potwierdzenie"),
        ("TCP Tunneling", "Tunelowanie TCP"),
        ("Remove", "Usuń"),
        ("Refresh random password", "Odśwież losowe hasło"),
        ("Set your own password", "Ustaw własne hasło"),
        ("Enable Keyboard/Mouse", "Włącz klawiaturę/mysz"),
        ("Enable Clipboard", "Włącz schowek"),
        ("Enable File Transfer", "Włącz transfer pliku"),
        ("Enable TCP Tunneling", "Włącz tunelowanie TCP"),
        ("IP Whitelisting", "Biała lista IP"),
        ("ID/Relay Server", "Serwer ID/Pośredniczący"),
        ("Stop service", "Zatrzymaj usługę"),
        ("Change ID", "Zmień ID"),
        ("Website", "Strona internetowa"),
        ("About", "O"),
        ("Mute", "Wycisz"),
        ("Audio Input", "Wejście audio"),
        ("Enhancements", "Ulepszenia"),
        ("Hardware Codec", "Kodek sprzętowy"),
        ("Adaptive Bitrate", "Adaptacyjny bitrate"),
        ("ID Server", "Serwer ID"),
        ("Relay Server", "Serwer pośredniczący"),
        ("API Server", "Serwer API"),
        ("invalid_http", "Nieprawidłowy żądanie http"),
        ("Invalid IP", "Nieprawidłowe IP"),
        ("id_change_tip", "Nowy ID może być złożony z małych i dużych liter a-zA-z, cyfry 0-9 oraz _ (podkreślenie). Pierwszym znakiem powinna być litera a-zA-Z, a całe ID powinno składać się z 6 do 16 znaków."),
        ("Invalid format", "Nieprawidłowy format"),
        ("server_not_support", "Serwer nie obsługuje tej funkcji"),
        ("Not available", "Niedostępne"),
        ("Too frequent", "Zbyt często"),
        ("Cancel", "Anuluj"),
        ("Skip", "Pomiń"),
        ("Close", "Zamknij"),
        ("Retry", "Ponów"),
        ("OK", "OK"),
        ("Password Required", "Wymagane jest hasło"),
        ("Please enter your password", "Wpisz proszę twoje hasło"),
        ("Remember password", "Zapamiętaj hasło"),
        ("Wrong Password", "Błędne hasło"),
        ("Do you want to enter again?", "Czy chcesz wprowadzić ponownie?"),
        ("Connection Error", "Błąd połączenia"),
        ("Error", "Błąd"),
        ("Connection lost", "Połączenie zresetowanie przez peer"),
        ("Connecting...", "Łączenie..."),
        ("Connection in progress. Please wait.", "Trwa łączenie. Proszę czekać."),
        ("Please try 1 minute later", "Spróbuj za minutę"),
        ("Login Error", "Błąd logowania"),
        ("Successful", "Sukces"),
        ("Connected, waiting for image...", "Połączono, czekam na obraz..."),
        ("Name", "Nazwa"),
        ("Type", "Typ"),
        ("Modified", "Zmodyfikowany"),
        ("Size", "Rozmiar"),
        ("Show Hidden Files", "Pokaż ukryte pliki"),
        ("Receive", "Odbierz"),
        ("Send", "Wyślij"),
        ("Refresh File", "Odśwież plik"),
        ("Local", "Lokalny"),
        ("Remote", "Zdalny"),
        ("Remote Computer", "Zdalny komputer"),
        ("Local Computer", "Lokalny komputer"),
        ("Confirm Delete", "Potwierdź usunięcie"),
        ("Delete", "Usuń"),
        ("Properties", "Właściwości"),
        ("Multi Select", "Wielokrotny wybór"),
        ("Empty Directory", "Pusty katalog"),
        ("Not an empty directory", "Katalog nie jest pusty"),
        ("Are you sure you want to delete this file?", "Czy na pewno chcesz usunąć ten plik?"),
        ("Are you sure you want to delete this empty directory?", "Czy na pewno chcesz usunać ten pusty katalog?"),
        ("Are you sure you want to delete the file of this directory?", "Czy na pewno chcesz usunąć pliki z tego katalog?"),
        ("Do this for all conflicts", "Zrób to dla wszystkich konfliktów"),
        ("This is irreversible!", "To jest nieodwracalne!"),
        ("Deleting", "Usuwanie"),
        ("files", "pliki"),
        ("Waiting", "Oczekiwanie"),
        ("Finished", "Zakończono"),
        ("Speed", "Prędkość"),
        ("Custom Image Quality", "Niestandardowa jakość obrazu"),
        ("Privacy mode", "Tryb prywatny"),
        ("Block user input", "Blokuj peryferia użytkownika"),
        ("Unblock user input", "Odblokuj peryferia użytkownika"),
        ("Adjust Window", "Dostosuj okno"),
        ("Original", "Oryginalny"),
        ("Shrink", "Zmniejsz"),
        ("Stretch", "Rozciągnij"),
        ("Scrollbar", "Pasek przewijania"),
        ("ScrollAuto", "Przewijanie automatyczne"),
        ("Good image quality", "Dobra jakość obrazu"),
        ("Balanced", "Zrównoważony"),
        ("Optimize reaction time", "Zoptymalizuj czas reakcji"),
        ("Custom", "Niestandardowy"),
        ("Show remote cursor", "Pokazuj zdalny kursor"),
        ("Show quality monitor", "Pokazuj jakość monitora"),
        ("Disable clipboard", "Wyłącz schowek"),
        ("Lock after session end", "Zablokuj po zakończeniu sesji"),
        ("Insert", "Wstaw"),
        ("Insert Lock", "Wstaw blokadę"),
        ("Refresh", "Odśwież"),
        ("ID does not exist", "ID nie istnieje"),
        ("Failed to connect to rendezvous server", "Nie udało się połączyć z serwerem połączeń"),
        ("Please try later", "Spróbuj później"),
        ("Remote desktop is offline", "Zdalny pulpit jest offline"),
        ("Key mismatch", "Niezgodność klucza"),
        ("Timeout", "Przekroczenie czasu"),
        ("Failed to connect to relay server", "Nie udało się połączyć z serwerem pośredniczącym"),
        ("Failed to connect via rendezvous server", "Nie udało się połączyć przez serwer połączeń"),
        ("Failed to connect via relay server", "Nie udało się połączyć przez serwer pośredniczący"),
        ("Failed to make direct connection to remote desktop", "Nie udało się nawiązać bezpośredniego połączenia z pulpitem zdalnym"),
        ("Set Password", "Ustaw hasło"),
        ("OS Password", "Hasło do systemu operacyjnego"),
		("install_tip", "Dla najlepszej wydajności, zainstaluj aplikację."),
        ("Upgrade Now", "Uaktualnij teraz"),
        ("Click to download", "Kliknij, aby pobrać"),
        ("Click to update", "Kliknij, aby zaktualizować"),
        ("Configure", "Konfiguruj"),
		("config_acc", "Włącz uprawnienia \"Dostępność\", aby skorzystać z udostępniania ekranu."),
		("config_screen", "Włącz uprawnienia \"Nagrywanie ekranu\", aby korzystać z funkcji współdzielenia ekranu."),
        ("Installing ...", "Instalowanie..."),
        ("Install", "Zainstaluj"),
        ("Installation", "Instalacja"),
        ("Installation Path", "Ścieżka instalacji"),
        ("Create start menu shortcuts", "Utwórz skróty w menu startowym"),
        ("Create desktop icon", "Utwórz ikonę na pulpicie"),
		("agreement_tip", "Rozpoczynając instalację, wyrażasz zgodę na Warunki świadczenia usług."),
        ("Accept and Install", "Akceptuj i instaluj"),
        ("End-user license agreement", "Umowa licencyjna użytkownika końcowego"),
        ("Generating ...", "Generowanie..."),
        ("A new update is available.", "Dostępna jest nowa aktualizacja."),
        ("Listening ...", "Nasłuchiwanie..."),
        ("Remote Host", "Host zdalny"),
        ("Remote Port", "Port zdalny"),
        ("Action", "Akcja"),
        ("Add", "Dodaj"),
        ("Local Port", "Lokalny port"),
        ("Local Address", "Lokalny adres"),
        ("Change Local Port", "Zmień lokalny port"),
        ("setup_server_tip", "W celu uzyskania szybszego połączenia, skorzystaj z własnego serwera połączeń."),
        ("Too short, at least 6 characters.", "Za krótkie, min. 6 znaków"),
        ("The confirmation is not identical.", "Potwierdzenie nie jest identyczne."),
        ("Permissions", "Uprawnienia"),
        ("Accept", "Akceptuj"),
        ("Dismiss", "Odrzuć"),
        ("Disconnect", "Rozłącz"),
        ("Allow using keyboard and mouse", "Zezwalaj na używanie klawiatury i myszy"),
        ("Allow using clipboard", "Zezwalaj na używanie schowka"),
        ("Allow hearing sound", "Zezwól na transmisję audio"),
        ("Allow file copy and paste", "Zezwalaj na kopiowanie i wklejanie plików"),
        ("Connected", "Połączony"),
        ("Direct and encrypted connection", "Połączenie bezpośrednie i szyfrowane"),
        ("Relayed and encrypted connection", "Połączenie pośrednie i szyfrowane"),
        ("Direct and unencrypted connection", "Połączenie bezpośrednie i nieszyfrowane"),
        ("Relayed and unencrypted connection", "Połączenie pośrednie i nieszyfrowane"),
        ("Enter Remote ID", "Wprowadź zdalne ID"),
        ("Enter your password", "Wprowadź hasło"),
        ("Logging in...", "Trwa logowanie..."),
        ("Enable RDP session sharing", "Włącz udostępnianie sesji RDP"),
        ("Auto Login", "Automatyczne logowanie"),
        ("Enable Direct IP Access", "Włącz Bezpośredni dostęp IP"),
        ("Rename", "Zmień nazwę"),
        ("Space", "Przestrzeń"),
        ("Create Desktop Shortcut", "Utwórz skrót na pulpicie"),
        ("Change Path", "Zmień ścieżkę"),
        ("Create Folder", "Utwórz folder"),
        ("Please enter the folder name", "Wpisz nazwę folderu"),
        ("Fix it", "Napraw to"),
        ("Warning", "Ostrzeżenie"),
        ("Login screen using Wayland is not supported.", "Ekran logowania przy użyciu Wayland nie jest obsługiwany."),
        ("Reboot required", "Wymagany ponowne uruchomienie"),
        ("Unsupported display server ", "Nieobsługiwany serwer wyświetlania "),
        ("x11 expected", "Wymagany jest X11"),
        ("Port", "Port"),
        ("Settings", "Ustawienia"),
        ("Username", "Nazwa użytkownika"),
        ("Invalid port", "Nieprawidłowy port"),
        ("The remote partner has closed the session.", "Zamknięty ręcznie przez peera."),
        ("Enable remote configuration modification", "Włącz zdalną modyfikację konfiguracji"),
        ("Run without install", "Uruchom bez instalacji"),
        ("Always connected via relay", "Zawsze połączony przez przekaźnik"),
		("whitelist_tip", "Dostęp do mnie mają tylko adresy IP z białej listy"),
        ("Always connect via relay", "Zawsze łącz przez przekaźnik"),
        ("Login", "Zaloguj"),
        ("Logout", "Wyloguj"),
        ("Tags", "Tagi"),
        ("Search ID", "Wyszukaj ID"),
        ("Current Wayland display server is not supported.", "Obecny serwer wyświetlania Wayland nie jest obsługiwany."),
        ("whitelist_sep", "Adresy oddzielone przecinkiem"),
		("Add ID", "Dodaj ID"),
        ("Add Tag", "Dodaj tag"),
        ("Unselect all tags", "Odznacz wszystkie tagi"),
        ("Network error", "Błąd sieci"),
        ("Username missed", "Brak nazwy użytkownika"),
        ("Password missed", "Brak hasła"),
        ("Wrong credentials", "Nieprawidłowe dane uwierzytelniające"),
        ("Edit Tag", "Edytuj tag"),
        ("Forget Password", "Nie zapamiętuj hasła"),
        ("Favorites", "Ulubione"),
        ("Add to Favorites", "Dodaj do ulubionych"),
        ("Remove from Favorites", "Usuń z ulubionych"),
        ("Empty", "Pusty"),
        ("Invalid folder name", "Nieprawidłowa nazwa folderu"),
        ("SOCKS5 Proxy", "SOCKS5 Proxy"),
        ("Hostname", "Nazwa hosta"),
        ("Discovered", "Odkryty"),
		("install_daemon_tip", "Do uruchamiania przy starcie, musi zainstalować usługę systemową."),
        ("Remote ID", "Zdalny ID"),
        ("Paste", "Wklej"),
        ("Paste here?", "Wkleić tutaj?"),
        ("Are you sure to close the connection?", "Czy na pewno chcesz zamknąć połączenie?"),
        ("Download new version", "Pobierz nową wersję"),
        ("Touch mode", "Tryb dotykowy"),
        ("Mouse mode", "Tryb myszy"),
        ("One-Finger Tap", "Stuknięcie jednym palcem"),
        ("Left Mouse", "Lewa klik myszy"),
        ("One-Long Tap", "Stuknięcie jednym palcem"),
        ("Two-Finger Tap", "Stuknięcie dwoma palcami"),
        ("Right Mouse", "Prawy klik myszy"),
        ("One-Finger Move", "Przesunięcie jednym palcem"),
        ("Double Tap & Move", "Stuknij dwukrotnie i przesuń"),
        ("Mouse Drag", "Przeciąganie myszą"),
        ("Three-Finger vertically", "Dwa palce w pionie"),
        ("Mouse Wheel", "Kółko myszy"),
        ("Two-Finger Move", "Przesunięcie dwoma palcami"),
        ("Canvas Move", "Przesunięcie płótna"),
        ("Pinch to Zoom", "Uszczypnij, aby powiększyć"),
        ("Canvas Zoom", "Powiększenie płótna"),
        ("Reset canvas", "Zresetuj płótno"),
        ("No permission of file transfer", "Brak zgody na przesyłanie plików"),
        ("Note", "Notatka"),
        ("Connection", "Połączenie"),
        ("Share Screen", "Udostępnij ekran"),
        ("CLOSE", "ZAMKNIJ"),
        ("OPEN", "OTWÓRZ"),
        ("Chat", "Czat"),
        ("Total", "Razem"),
        ("items", "pozycji"),
        ("Selected", "Wybrane"),
        ("Screen Capture", "Zrzut ekranu"),
        ("Input Control", "Kontrola wejścia"),
        ("Audio Capture", "Przechwytywanie dźwięku"),
        ("File Connection", "Transfer pliku"),
        ("Screen Connection", "Połączenie ekranu"),
        ("Do you accept?", "Czy akcetujesz?"),
        ("Open System Setting", "Otwórz ustawienia systemu"),
        ("How to get Android input permission?", "Jak uzyskać uprawnienia do wprowadzania danych w systemie Android?"),
        ("android_input_permission_tip1", "Aby zdalne urządzenie mogło sterować urządzeniem z systemem Android za pomocą myszy lub dotyku, musisz zezwolić HopToDesk na korzystanie z usługi \"Dostępność\"."),
        ("android_input_permission_tip2", "Przejdź do następnej strony ustawień systemu, znajdź i wprowadź [Zainstalowane usługi], włącz usługę [Wprowadzanie HopToDesk]."),
        ("android_new_connection_tip", "Otrzymano nowe żądanie kontroli, chce kontrolować twoje obecne urządzenie."),
        ("android_service_will_start_tip", "Włączenie \"Przechwytywania ekranu\" spowoduje automatyczne uruchomienie usługi, umożliwia innym urządzeniom żądanie połączenia z Twoim urządzeniem."),
        ("android_stop_service_tip", "Zamknięcie usługi spowoduje automatyczne zamknięcie wszystkich nawiązanych połączeń."),
        ("android_version_audio_tip", "Obecna wersja Androida nie obsługuje przechwytywania dźwięku, uaktualnij do Androida 10 lub nowszego."),
        ("android_start_service_tip", "Dotknij [Rozpocznij udostępnianie ekranu], aby zezwolić na udostępnianie ekranu."),
		("minimize_to_tray", "Zminimalizuj do zasobnika podczas zamykania głównego okna"),
        ("Account", "Konto"),
        ("Overwrite", "Nadpisz"),
        ("This file exists, skip or overwrite this file?", "Taki plik już istnieje, czy pominąć lub nadpisać ten plik?"),
        ("Quit", "Zakończ"),
        ("Help", "Pomoc"),
        ("Failed", "Niepowodzenie"),
        ("Succeeded", "Udało się"),
        ("Someone turns on privacy mode, exit", "Ktoś włącza tryb prywatności, wyjdź"),
        ("Unsupported", "Niewspierane"),
        ("Peer denied", "Odmowa dostępu"),
        ("Please install plugins", "Zainstaluj plugin"),
        ("Peer exit", "Wyjście peer"),
        ("Failed to turn off", "Nie udało się wyłączyć"),
        ("Turned off", "Wyłączony"),
        ("In privacy mode", "Uruchom tryb prywatności"),
        ("Out privacy mode", "Opuść tryb prywatności"),
		("Language", "Język (Language)"),
        ("Keep HopToDesk background service", "Zachowaj usługę w tle HopToDesk"),
        ("Ignore Battery Optimizations", "Ignoruj optymalizację baterii"),
        ("android_open_battery_optimizations_tip", "android_open_battery_optimizations_tip"),
        ("Connection not allowed", "Połączenie niedozwolone"),
        ("Legacy mode", "Tryb wstecznej-kompatybilności (legacy)"),
        ("Map mode", "Tryb mapowania"),
        ("Translate mode", "Tryb translacji"),
        ("Use temporary password", "Użyj tymczasowego hasła"),
        ("Use permanent password", "Użyj hasła permanentnego"),
        ("Use both passwords", "Użyj obu haseł"),
        ("Set permanent password", "Ustaw hasło permanentne"),
        ("Set temporary password length", "Ustaw długość hasła tymczasowego"),
        ("Enable Remote Restart", "Włącz Zdalne Restartowanie"),
        ("Allow remote restart", "Zezwól na zdalne restartowanie"),
        ("Restart Remote Device", "Zrestartuje Zdalne Urządzenie"),
        ("Are you sure you want to restart", "Czy na pewno uruchomić ponownie"),
        ("Restarting Remote Device", "Trwa restartowanie Zdalnego Urządzenia"),
        ("remote_restarting_tip", "Trwa ponownie uruchomienie zdalnego urządzenia, zamknij ten komunikat i ponownie nawiąż za chwilę połączenie używając hasła permanentnego"),
        ("Copied", "Skopiowano"),
        ("Exit Fullscreen", "Wyłączyć tryb pełnoekranowy"),
        ("Fullscreen", "Pełny ekran"),
        ("Mobile Actions", "Działania mobilne"),
        ("Select Monitor", "Wybierz Monitor"),
        ("Control Actions", "Działania kontrolne"),
        ("Display Settings", "Ustawienia wyświetlania"),
        ("Ratio", "Proporcje"),
        ("Image Quality", "Jakość obrazu"),
        ("Scroll Style", "Styl przewijania"),
        ("Show Menubar", "Pokaż pasek menu"),
        ("Hide Menubar", "Ukryj pasek menu"),
        ("Direct Connection", "Połącznie Bezpośrednie"),
        ("Relay Connection", "Połączenie Pośrednie"),
        ("Secure Connection", "Połączenie Bezpieczne"),
        ("Insecure Connection", "Połączenie Niebezpieczne"),
        ("Scale original", "Skaluj oryginalnie"),
        ("Scale adaptive", "Skaluj adaptacyjnie"),
        ("General", "Ogólne"),
        ("Security", "Zabezpieczenia"),
        ("Account", "Konto"),
        ("Theme", "Motyw"),
        ("Dark Theme", "Ciemny motyw"),
        ("Dark", "Ciemny"),
        ("Light", "Jasny"),
        ("Follow System", "Zgodne z systemem"),
        ("Enable hardware codec", "Włącz wsparcie sprzętowe dla kodeków"),
        ("Unlock Security Settings", "Odblokuj Ustawienia Zabezpieczeń"),
        ("Enable Audio", "Włącz Dźwięk"),
        ("Temporary Password Length", "Długość hasła tymaczowego"),
        ("Unlock Network Settings", "Odblokuj ustawienia Sieciowe"),
        ("Server", "Serwer"),
        ("Direct IP Access", "Bezpośredni Adres IP"),
        ("Proxy", "Proxy"),
        ("Port", "Port"),
        ("Apply", "Zastosuj"),
        ("Disconnect all devices?", "Czy rozłączyć wszystkie urządzenia?"),
        ("Clear", "Wyczyść"),
        ("Audio Input Device", "Urządzenie wejściowe Audio"),
        ("Deny remote access", "Zabroń dostępu zdalnego"),
        ("Use IP Whitelisting", "Użyj białej listy IP"),
        ("Network", "Sieć"),
        ("Enable RDP", "Włącz RDP"),
        ("Pin menubar", "Przypnij pasek menu"),
        ("Unpin menubar", "Odepnij pasek menu"),
        ("Recording", "Trwa nagrywanie"),
        ("Directory", "Katalog"),
        ("Automatically record incoming sessions", "Automatycznie nagrywaj sesje przychodzące"),
        ("Change", "Zmień"),
        ("Start session recording", "Zacznij nagrywać sesję"),
        ("Stop session recording", "Zatrzymaj nagrywanie sesji"),
        ("Enable Recording Session", "Włącz Nagrywanie Sesji"),
        ("Allow recording session", "Zezwól na nagrywanie sesji"),
        ("Enable LAN Discovery", "Włącz Wykrywanie LAN"),
        ("Deny LAN Discovery", "Zablokuj Wykrywanie LAN"),
        ("Write a message", "Napisz wiadomość"),
        ("Prompt", "Monit"),
        ("elevation_prompt", "Monit o podwyższeniu uprawnień"),
        ("uac_warning", "Ostrzeżenie UAC"),
        ("elevated_foreground_window_warning", "Pierwszoplanowe okno ostrzeżenia o podwyższeniu uprawnień"),
		("Enable Wake On LAN", "Włącz Wake On LAN"),
		("Enable 2FA", "Włącz 2FA"),
		("2FA QR Code", "Kod QR 2FA"),
        ("Scan this QR code with a camera on a secondary device such as a phone to set it up as your 2FA authenticator.", "Zeskanuj ten kod QR za pomocą aparatu na drugim urządzeniu, takim jak telefon, aby skonfigurować go jako uwierzytelnianie 2FA."),
        ("You will need to confirm the 2FA on the secondary device with you when trying to connect to this desktop.", "Podczas próby połączenia z tym pulpitem musisz potwierdzić 2FA na drugim urządzeniu."),		
    ].iter().cloned().collect();
}
