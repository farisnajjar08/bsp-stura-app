# Arbeitsanweisungen für dieses Projekt

Lies zuerst `README.md` — dort steht der fachliche und strategische Stand.
Dieses Dokument regelt, wie in diesem Projekt gearbeitet wird.

## Zusammenarbeit

- **Sprache: Deutsch.**
- Kurz und direkt. Struktur und Zwischenüberschriften, wo sie das Lesen
  beschleunigen. Keine Emojis.
- Abkürzungen beim ersten Auftreten erklären.
- **Der Projektverantwortliche programmiert nicht.** Er versteht Abläufe und
  Architektur gut und trifft die fachlichen Entscheidungen, schreibt aber
  keinen Code. Liefere fertige, lauffähige Dateien — keine Anleitungen zum
  Selbstumsetzen und keine Fragmente, die noch eingebaut werden müssen.
- Widerspricht eine Anforderung der Architektur oder den Rahmenbedingungen,
  sag das direkt und begründe es. Die bisherigen Entscheidungen sind so
  entstanden.

## Unverhandelbare Grundsätze

Diese drei Punkte tragen die gesamte Argumentation gegenüber Hochschule und
Datenschutzbeauftragtem. Sie werden nicht aufgeweicht, um ein Feature zu
ermöglichen:

1. **Keine personenbezogenen Daten.** Kein Login, keine Matrikelnummer, keine
   Namen. Der Server kennt nur Kurse und Kohorten. Die persönliche Auswahl
   bleibt auf dem Gerät.
2. **TraiNex bleibt verbindlich.** Die App ist eine Zustellschicht, kein
   Ersatzsystem. Der Hinweis "Angaben ohne Gewähr, verbindlich ist TraiNex"
   bleibt sichtbar.
3. **Keine erfundenen Daten als echte ausgeben.** Platzhalterinhalte werden in
   der Oberfläche als solche gekennzeichnet. Keine erfundenen Dozentennamen.

## Technische Leitplanken

- **Kein Budget.** Nur kostenlose Angebote. Keine App-Store-Veröffentlichung.
  Web-App, die man über "Zum Startbildschirm hinzufügen" installiert.
- **Wartungsarm bauen.** Der Vorstand wechselt jährlich. Je weniger bewegliche
  Teile, desto eher überlebt das Projekt.
- `index.html` ist bewusst **eine einzige Datei** mit eingebetteten Schriften,
  Logo und Icon. Sie läuft auf jedem Hoster durch Hochladen. Diese Eigenschaft
  nicht ohne Grund aufgeben.
  **Einzige bewusste Ausnahme:** die Reaktionen auf StuRa-Mitteilungen rufen,
  wenn eingerichtet, eine kostenlose Supabase-Schnittstelle auf (siehe unten).
  Das ist die einzige Stelle im Code, die etwas nachlädt. Plan, Hochschule und
  Onboarding funktionieren weiterhin vollständig offline.

## Gestaltung

- Hausfarben der BSP: **#004a98** (Blau) und **#ce0e2d** (Rot).
  Rot ausschließlich für Änderungen, Ausfälle und Warnungen — nie dekorativ.
- Schriften: Archivo (Überschriften), Source Sans 3 (Fließtext),
  IBM Plex Mono (Uhrzeiten und Daten). Als data-URI eingebettet.
- Helles und dunkles Erscheinungsbild werden beide unterstützt; Farben laufen
  über CSS-Variablen.
- Bedienziel: **wenig Scrollen, wenige Klicks.** Nach der Ersteinrichtung
  öffnet die App direkt im Plan des aktuellen Tages.

## Aufbau von `index.html`

Eine Datei, vier Abschnitte:

1. `<style>` — eingebettete Schriften, dann Farbvariablen, dann Komponenten
2. `<script type="application/json" id="stura-news">` — die Mitteilungen des
   StuRa als JSON-Array (`id`, `title`, `body`, `ts`)
3. Markup: `#splash`, `#onboarding`, `#app` (drei Bereiche), `#sheet`
4. `<script>` — die Anwendungslogik

Wichtige Stellen im Skript:

- `PROGRAMS` — Studiengänge mit Beispielmodulen
- `generateCohorts()` — erzeugt die Liste der Startsemester aus dem heutigen
  Datum (Wechsel zum 01.10. und 01.04.), Ergebnis liegt in `COHORTS`. Neue
  Semester tauchen von selbst auf, ohne Codeänderung
- `BLOCKS` — Zeitblöcke (09:00–12:15, 13:00–16:15, 16:30–19:45)
- `buildPlan()` — erzeugt den Wochenplan deterministisch aus Studiengang und
  Kohorte, damit dieselbe Auswahl immer denselben Plan ergibt. Der Offset für
  die Kursrotation hängt an der Position der Kohorte (`cIdx`), nicht an der
  Listenlänge — sonst würde sich der Demo-Plan bestehender Nutzer bei jedem
  neuen Semester unbemerkt verschieben
- `STURA_PASS` — Kennwort für den StuRa-Bereich. **Steht im Quelltext und ist
  kein Sicherheitsmerkmal**, sondern verhindert nur zufälliges Entdecken. Bei
  der produktiven Version durch eine serverseitige Anmeldung ersetzen.
- `SUPABASE_URL` / `SUPABASE_ANON_KEY` — Anbindung für die Reaktionen auf
  StuRa-Mitteilungen (geräteübergreifende Zählung). Leer gelassen läuft die
  App als reine Ein-Datei-Lösung weiter, die Reaktionen zählen dann nur lokal.
  Einrichtung: `README.md`, Abschnitt 7, SQL in `docs/supabase-reaktionen.sql`
- `REACTIONS` — die drei wählbaren Reaktionen (like/heart/meh) mit Emoji
- Auswahl des Studiengangs liegt in `localStorage` (`bsp_prog`, `bsp_cohort`),
  das Erscheinungsbild in `bsp_theme`, der anonyme Geräte-Token in
  `bsp_device_id`, bereits abgegebene Reaktionen in `bsp_reacted_<news-id>`

## Ausbaustufe — was die produktive Version braucht

Erst bauen, wenn die Hochschule zugesagt hat **und** im Vorstand geklärt ist,
wer den Betrieb übernimmt. Vorher entsteht etwas, das niemand in Betrieb nehmen
kann.

- Eigene Adresse statt Hoster-Subdomain
- Datenbank für Mitteilungen, Umfrageergebnisse und anonyme Anliegen
- Web-Push pro Kurs über Topic-Subscriptions (kostenloser Dienst).
  **Zu beachten:** Auf dem iPhone funktionieren Benachrichtigungen nur, wenn
  die App auf dem Startbildschirm liegt. Die Installation ist deshalb nicht
  optional, sondern Teil der Funktion.
- Getrennte Zugänge für StuRa und Verwaltung mit serverseitiger Anmeldung
- Upload der Semesterdatei mit automatischem Einlesen in den Kurskatalog
- Offline-Betrieb über einen Service Worker, damit der Plan auch ohne Empfang
  im Gebäude steht
- Datenschutzerklärung (eine Seite, wegen des Push-Dienstleisters)
