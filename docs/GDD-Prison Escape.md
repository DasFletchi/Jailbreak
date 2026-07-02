# FriendslopEZPZ – Game Design Document

> **Working Title:** FriendslopEZPZ  
> **Engine:** Godot 4.7+ (Forward Plus)  
> **Genre:** Co-op Prison Escape (Action + Chaos)  
> **Players:** 2–6  
> **Networking:** easy-peasy-multiplayer 2.0 (ENet, kein Steam nötig)  
> **Target Price:** $5–8 Launch  
> **Inspiration:** rekrap-style gameplay (freestyle, bullet points, clip-worthy)

---

## Vision

Ein chaotisches Co-op Prison Escape Game wo jede Runde anders läuft.  
Kein scripted Ablauf – Systeme knallen aufeinander und produzieren Geschichten.  
Proximity Voice + Emergent Gameplay = Clip-Maschine für YouTube.

---

## Core Pillars

- **Action + Chaos** – schnelle Runden, laute Momente, scheitern ist lustig
- **Proximity Voice** – nah redet man normal, weiter weg leiser, Wachen hören mit
- **Wiederspielbarkeit** – procedural generiertes Gefängnis, random Events, verschiedene Persönlichkeiten pro Wache
- **Clip-worthy** – jedes Spiel produziert 1-2 Momente die man ausschneiden und hochladen will

---

## Game Flow

1. **Lobby** – Host erstellen / IP joinen, Name setzen, Spielerliste
2. **Runden-Start** – Gefängnis wird procedural generiert (mit Seed)
3. **Playing** – Spieler spawnen im Cellblock, müssen Items sammeln und Ausgang finden
4. **Flucht** – Alle Requirements erfüllt → Exit-Raum freigeschaltet → alle raus = Win
5. **Runden-Ende** – 5s Recap, zurück zur Lobby, nächste Runde

---

## Room-System

### Room-Templates (aktuell 12)

| Raum | Kategorie | Security | Spawns | Besonderheit |
|------|-----------|----------|--------|--------------|
| Cellblock | CELLBLOCK | 0 | niedrig | Startraum, immer da |
| Cafeteria | CAFETERIA | 0 | niedrig | Viel Platz, oft mehrere Türen |
| Guard Office | GUARD_OFFICE | 2 | niedrig | Alarm-Button, high-security |
| Yard | YARD | 0 | niedrig | Offen, Wachen haben freie Sicht |
| Infirmary | INFIRMARY | 1 | medium | Medkits, Skalpelle |
| Storage | STORAGE | 1 | medium | Zufälliger Loot, dunkel |
| Vent Shaft | VENT_SHAFT | 1 | keiner | Geheimgang zwischen Etagen |
| Armory | ARMORY | 2 | hoch | Waffen + Keycards, stark bewacht |
| Laundry | LAUNDRY | 0 | niedrig | Uniformen, Versteck-Möglichkeit |
| Shower | SHOWER | 0 | niedrig | Offen, wenig Deckung |
| Library | LIBRARY | 0 | niedrig | Ruhig, Wachen ignorieren oft |
| Exit | EXIT | 2 | keiner | Flucht-Endpunkt, immer da |

### Prozedurale Generierung

- **Graph-basiert**: Räume werden als Nodes mit `door_points` verbunden
- **Pro Floor**: 6 Räume pro Etage, 2 Etagen Standard
- **Seed-basiert**: Gleicher Seed = gleiches Gefängnis (für Replays/Sharing)
- **Required Rooms**: Cellblock + Exit sind Pflicht
- **Restricted Rooms**: Manche Räume nur 1x pro Map (Armory, Guard Office, etc.)
- **Weighted Selection**: Räume haben Gewichtung – Storage kommt öfter als Armory
- **Extra Connections**: Lüftungsschächte als Random-Verbindungen zwischen nicht-benachbarten Räumen

### Layout-Algorithmus

1. Required Rooms platzieren (Cellblock, Exit)
2. Restliche Räume per Weighted Random füllen
3. Grid-Layout (x = Raumposition, y = Etage)
4. Connections: benachbarte Räume = Türen, übereinander = Treppen
5. Extra: Random-Vents für alternative Routen
6. Loot pro Raum spawnen basierend auf Security-Level

---

## Emergent Gameplay Systeme

### Wachen-Verhalten (5 Persönlichkeiten)

| Typ | Vision | Hearing | Alert-Speed | Verhalten |
|-----|--------|---------|-------------|-----------|
| STRICT | 1.2x | 1.2x | schnell | Hört jeden Lärm |
| LAZY | 0.6x | 0.5x | langsam | Ignoriert vieles |
| CORRUPT | 0.8x | 0.7x | sehr langsam | Lässt sich von Items ablenken |
| PARANOID | 1.1x | 1.3x | extrem schnell | Schlägt sofort Alarm |
| CARELESS | 0.5x | 0.6x | langsam | Übersieht Spieler leicht |

### Guard States

- **PATROL** – normale Route, 4-8 zufällige Punkte
- **SUSPICIOUS** – hat was gehört/gesehen, geht Richtung Quelle
- **ALERT** – verfolgt Spieler, sprintet
- **SEARCHING** – sucht nach Verlust (8s Timer)
- **CALLING** – ruft Verstärkung (dauert je nach Persönlichkeit)

### Sound-Propagation

- Lärm breitet sich realistisch aus
- Umgeworfener Stuhl in Raum A zieht nächste Wache an
- Wache in Raum B bleibt ahnungslos
- Spieler lernen Sound als Werkzeug zu nutzen

### System-Interaktionen

- Essensausgabe + Lüftungsschacht = Essen durch Schacht bugsieren, Wache ablenken
- Stromkreise überlasten (viele Geräte an) → Sicherung fliegt raus → Dunkelheit → Fluchtchance
- Feueralarm auslösen → Chaos → alle sprinten
- Wachen bestechen (Corrupt-Trait) mit Items

**Faustregel:** Nie "der Spieler kann X tun" programmieren.  
Systeme programmieren (Licht, Sound, Autorität, Hunger, Aufmerksamkeit) und aufeinander knallen lassen.

---

## Items & Loot

### Item-Typen

- **Tool** – crowbar, keycard, wire_cutters, uniform (Flucht-Requirements)
- **Weapon** – Schraubenschlüssel, Skalpell, Brechstange (auch als Waffe nutzbar)
- **Food** – heilt, macht Lärm beim Essen
- **Key** – spezifische Türen öffnen
- **Misc** – Zahnbürste (spitzen = Waffe / Dietrich / ablenken)

### Loot-Tables pro Raum

- **Armory** → Schraubenschlüssel, Waffen, Keycards
- **Infirmary** → Skalpelle, Medkits
- **Kitchen/Cafeteria** → Messer, Essen
- **Storage** → Zufall, meist nützlicher Kram
- **Laundry** → Uniform (Verkleidung)
- **Guard Office** → Keycards, Funkgerät

### Item-System (Resource-basiert)

- `ItemData` Resource mit: name, description, type, tool_type, weight, stackable, effect_value
- Items haben Side-Effects: Zahnbürste kann spitzen (Waffe), Dietrich, oder Ablenkung
- Flucht-Requirements: 3 von 5 Items werden pro Runde zufällig als "gebraucht" markiert

---

## Multiplayer & Networking

### easy-peasy-multiplayer 2.0

- **Kein Steam nötig** – reines ENet, IP-basiert
- Host/Join über IP (+ evtl. Lobby-Code später)
- 2-6 Spieler
- RPC-basiert für Aktionen (collect_requirement, movement, etc.)

### Architektur

- **NetworkManager** (Autoload) – verwaltet Peer-Connections, Spielerliste
- **GameManager** (Autoload) – Rundenlogik, State-Machine, Escape-Conditions
- **PrisonGenerator** (Autoload) – generiert Gefängnis auf Server, teilt via RPC

### Multiplayer-Synergien

- Spieler A hält Wache ab (chatten, ablenken), Spieler B schleicht vorbei
- Spieler C löst Feueralarm aus, im Chaos fliehen alle
- Proximity Voice: nah = laut (Wachen hören), weit weg = leise

---

## UI Struktur

### Main Menu (title_screen.tscn)

- Host Button
- Join Button + IP Input
- Player Name Input
- Start Button (nur Host)
- Player List + Ready-Check

### HUD

- Inventar (max 4 Slots)
- Flucht-Requirements (3 Items als Checkliste)
- Health
- Runden-Timer

### Debug (Dev)

- Label3D mit Generierungs-Info
- Room-Übersicht

---

## Technical Architecture

### Projekt-Struktur

```
addons/easy_peasy_multiplayer/   # Plugin (unverändert)
ai/
  GuardAI.gd                     # Wachen-State-Machine
autoload/
  GameManager.gd                 # Zentrale Spiel-Logik
  NetworkManager.gd              # Multiplayer-Wrapper
  PrisonGenerator.gd             # Prozedurale Generierung
items/
  ItemData.gd                    # Item-Resource
rooms/
  CellBlock.tscn, Cafeteria.tscn # 12 Room-Szenen
  ...
scenes/
  title_screen.tscn              # Main Menu
  Game.tscn                      # Hauptspiel-Szene
  Player.tscn                    # Spieler-Controller
  Guard.tscn                     # Wachen-Instanz
  Item.tscn                      # Item-Instanz im Raum
scripts/
  RoomBase.gd                    # Basis-Klasse für Räume
  PlayerController.gd            # Movement + Interaktion
  GuardAI.gd                     # (siehe ai/)
  ItemBase.gd                    # Item-Verhalten im Raum
  GameWorld.gd                   # Baut Gefängnis aus Generierung
  Door.gd                        # Tür-Logik (öffnen/schließen/aufbrechen)
  MainMenu.gd                    # UI-Logik
docs/
  GDD-Prison Escape.md           # Dieses Dokument
```

### Dependencies

- Godot 4.7+
- easy-peasy-multiplayer Plugin (ENet, kein Steam)
- Jolt Physics (bereits aktiviert)
- Forward Plus Renderer
- Keine externen Abhängigkeiten

---

## Events & Wiederspielbarkeit

### Random Events (pro Runde 1-2)

- **Inspektion heute** – mehr Wachen, höhere Alertness
- **Ausgang gesperrt** – bestimmte Route dicht
- **Mitgefangener hilft dir** – extra Item oder Info
- **Wache krank** – weniger Personal
- **Hund patrouilliert** – extre Gefahr im Hof
- **Stromausfall** – Dunkelheit, Fluchtchance

### Routen-Variation

- Mal ist Hofweg offen, mal nicht
- Mal patrouilliert ein Hund, mal nicht
- Mal sind bestimmte Türen verschlossen, mal offen
- Item-Platzierungen variieren pro Runde

---

## Dev Roadmap (Vorschlag)

1. **Core Setup** – Projekt-Struktur, easy-peasy integriert, Player-Controller, Movement
2. **Rooms** – Alle 12 Räume bauen mit Door-Points und Item-Spawns
3. **Generator** – Graph-basiertes Layout, Connections, Seeds
4. **Guard AI** – State-Machine, Persönlichkeiten, Sight/Hearing
5. **Items** – Item-Resources, Loot-Tables, Inventar
6. **Multiplayer** – Lobby, RPCs, Sync, Game-Manager
7. **Emergent Systems** – Sound-Propagation, Events, Interaktionen
8. **Proximity Voice** – Discord-integration oder Ingame-Voice
9. **UI/UX** – Main Menu, HUD, Feedback
10. **Polish** – Juice, VFX, SFX, Maps, Balancing

---

## Monetization

- **Launch Price:** $5-8
- **Platform:** PC (Steam oder Itch.io)
- **Warum?** Niedrige Einstieghürde, viral-potential durch Clips, Friendslop-Markt
- **Kein P2W** – keine Mikrotransaktionen, einmal kaufen und friendsloppen

---

## Namensvorschläge (als Entscheidungshilfe)

1. **The Slammer** – kurz, catchy, sofort verständlich
2. **Block Party** – Zellenblock + Party, Friendslop-Vibe
3. **BreakOUT** – doppeldeutig, leicht zu merken
4. **Jailbreak** – klassisch aber solide
5. **Hoosegow** – alter Slang, klingt mysteriös (rekrap-Style)
6. **The Ditch** – "We're ditching this place"
7. **Out** – ein Wort, minimalistisch
8. **FriendslopEZPZ** – aktueller Dev-Name, beschreibt was es ist

---
*GDD erstellt aus Chat-Verlauf + bestehender Codebase (prison_escape_friendslop).  
Nächstes Ziel: Code aus prison_escape_friendslop ins friendslop-ezpz Repo portieren.*
