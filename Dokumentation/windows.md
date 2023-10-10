<!--- Comments are Fun --->

# Server und so...

<!-- TOC -->
- [Server und so...](#server-und-so)
  - [Domain](#domain)
    - [Richtlinienergebnissatz (prüfen, ob Gruppenrichtlinien greifen)](#richtlinienergebnissatz-prüfen-ob-gruppenrichtlinien-greifen)
    - [Zurücksetzen aller Verzeichnisberechtigungen](#zurücksetzen-aller-verzeichnisberechtigungen)
  - [Registry](#registry)
      - [Öffnen von `HKCU` anderer lokaler User](#öffnen-von-hkcu-anderer-lokaler-user)
      - [Netzwerkumgebung ausblenden](#netzwerkumgebung-ausblenden)
  - [Rechner im Netzwerk verstecken (funktioniert nicht)](#rechner-im-netzwerk-verstecken-funktioniert-nicht)
  - [Nova von extern starten](#nova-von-extern-starten)
  - [Airbus Datenbank](#airbus-datenbank)
  - [Verzeichnisse und Dateien mit Berechtigungen kopieren](#verzeichnisse-und-dateien-mit-berechtigungen-kopieren)
  - [Verzeichnisse synchronisieren / spiegeln (in eine Richtung)](#verzeichnisse-synchronisieren--spiegeln-in-eine-richtung)
  - [virtuelle Festplatte mounten](#virtuelle-festplatte-mounten)
  - [Powershell](#powershell)
  - [STLB](#stlb)
  - [Serverübersicht](#serverübersicht)
<!-- /TOC -->

## Domain

### Richtlinienergebnissatz (prüfen, ob Gruppenrichtlinien greifen)

`rsop.msc`

### Zurücksetzen aller Verzeichnisberechtigungen

`ICACLS c:\freigabe\* /T /L /Q /C /RESET`

## Registry

#### Öffnen von `HKCU` anderer lokaler User

- Registry Editor mit Adminrechten öffnen
- `HKEY_USERS` auswählen
- `Datei` - `Struktur laden`
- Namen frei vergeben
- der `HKCU` Baum des User ist jetzt unter `HKEY_USERS` zu sehen

#### Netzwerkumgebung ausblenden

Pfad `HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\NonEnum`

Falls `NonEnum` nicht existiert, einfach erstellen.

folgenden DWORD-Schlüssel erstellen
`{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}`

hierbei den HEX-Wert auf 1 setzen

## Rechner im Netzwerk verstecken (funktioniert nicht)

`net config server /hidden:yes`

## Nova von extern starten

- Netextender runterladen und installieren 
- https://www.sonicwall.com/de-de/products/remote-access/vpn-clients/ 
- IP mit angefügtem Port `91.249.215.146:4433`
- User `cadagentur1` und `cadagentur2`
- Domäne `kec` 

Cloudzugang für die Prerequisites

> https://cloud.kirchner-ingenieure.de/s/TkPegcTRnS5NKnk  
> cad#-agenTUR-25  

## Airbus Datenbank

Port: 41456
PW: airbussql#

## Verzeichnisse und Dateien mit Berechtigungen kopieren

`robocopy \\Quellserver\Quellverzeichnis D:\Zielverzeichnis /MIR /B /R:1 /W:1 /COPYALL`

`robocopy \\Quellserver\Quellverzeichnis D:\\Zielverzeichnis /MIR /B /R:1 /W:1 /COPYALL`

## Verzeichnisse synchronisieren / spiegeln (in eine Richtung)

`robocopy`

## virtuelle Festplatte mounten

Am Besten über die Datenträgerverwaltung einbinden.

## Powershell

```
winget install JanDeDobbeleer.OhMyPosh -s winget
(Get-Command oh-my-posh).Source
oh-my-posh get shell
notepad $PROFILE
New-Item -Path $PROFILE -Type File -Force
oh-my-posh init pwsh | Invoke-Expression
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/jandedobbeleer.omp.json" | Invoke-Expression
install-module -name terminal-icons -repository psgallery
import
-module -name terminal-icons
install-module psreadline

Update:
winget upgrade JanDeDobbeleer.OhMyPosh -s winget
```

## Domänenuser und Scripts anzeigen
```
dsquery * domainroot -filter "(&(objectCategory=Person)(objectClass=User))" -limit 0 -attr sAMAccountName sn givenName scriptpath distinguishedName > C:\Loginscript.txt
```


## STLB

Setzen Sie den Haken vor „EasyLogin unterstützt“ und Schließen Sie das Freigabecenter. 
Anschließend muss im Internet Informationsdienste Manager der Anwendungspool 
„SBAPI.AppPool“ einmal beendet und neu gestartet werden. 
Danach ist in Ihrem STLB-Bau Server die „Easy Login“ Funktion aktiviert und kan
n von der AVA Software verwendet 
werden.
Das Aktivieren der „Easy Login“ Funktion sorgt technisch dafür, dass 
bei einer Anmeldung 
am STLB
-
Bau mit eine
m unbekannten Nutzernamen, dieser Nutzer autom
a
tisch durch 
STLB
-
Bau als neuer Nutzer angelegt wird und anschließend im STLB
-
Bau arbeiten kann
.

## Remotedesktop auf TCP umstellen

```
Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client
```

Hier muss ein weiterer Registry-Wert mit dem Namen `fClientDisableUDP` angelegt werden. Diesem neuen DWORD 32-Bit Wert „fClientDisableUDP“ müsst Ihr dann noch den Wert „1“ zuweisen.

## Proxy anzeigen

`netsh winhttp show proxy`


## Serverübersicht

```mermaid
graph TD;
    kgt-mi-hv([Hyper-V Host <br> kgt-mi-sql]) --> kgt-mi-sql(SQL Server <br> kgt-mi-sql);
    kgt-mi-hv --> kgt-mi-app("Application Server <br> File Server <br> kgt-mi-app");
    kgt-mi-hv --> kgt-minden-dc("Domain Controller <br> kgt-minden-dc");
    kgt-mi-hv --> kgt-mi-abacus["Abacus WebServer <br> kgt-abacus"];
    kgt-mi-hv --> kgt-mi-rp["Reverse Proxy <br> debian-rp"];
    kgt-mi-sql --> novadb[(Nova KGT)];
    kgt-mi-sql --> airbusdb[(Nova Airbus)];
    kgt-mi-sql --> tricdb[(Tric)];
    kgt-mi-sql --> calidb[(California)];
```


<!---
$${\small \text{Font size is small, eg. $\sum{x_i = 10}$}}$$

inline $\LARGE \text{Hello!}$

$\small Hello!$

$\text{\.{V}=10}$

Der Volumentstrom $\small \text{\.{V}}$ beträgt 200m³/h ${m^3}

$\Huge Hello!$
$\huge Hello!$
$\LARGE Hello!$
$\Large Hello!$
$\large Hello!$
$\normalsize Hello!$
$\small Hello!$
$\scriptsize Hello!$
$\tiny Hello!$
--->


<!---
test $\ \.{V}=10$

$\sqrt{3x-1}+(1+x)^2$  
$$\sqrt{3x-1}+(1+x)^2$$
--->

<!--- <br> für Zeilenumbruch. \n geht auch, sollte man aber nicht nutzen --->



