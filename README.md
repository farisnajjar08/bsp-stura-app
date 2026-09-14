# BSP StuRa — App für Stundenplan und Mitteilungen

Projekt des StuRa-Vorstands der BSP Business & Law School Berlin.
Stand: September 2026.

---

## 1. Ausgangsproblem

Die Kommunikation von Hochschule und StuRa erreicht die Studierenden nicht.
Nachrichten und Anfragen werden ignoriert. Die Ursache liegt nach Einschätzung
des Vorstands nicht in den Inhalten, sondern davor: Es fehlt die Verbundenheit
zur Hochschule, ohne die niemand Grund hat zuzuhören.

Beobachtungen, die das stützen:

- Nach den Vorlesungen verlässt praktisch jeder sofort den Campus. Die Gebäude
  sind auf Repräsentation ausgelegt, nicht auf Aufenthalt.
- Veranstaltungen und Workshops gibt es, sie sind aber durchgängig
  kostenpflichtig (Veranstaltungen ca. 55 Euro Eintritt, Workshops ca. 30 Euro
  pro Session). Das erzeugt eine Kundenbeziehung statt Zugehörigkeit.
- Die Hochschule ist stark auf Wirtschaftlichkeit ausgerichtet. Zugeständnisse
  sind möglich, brauchen aber eine betriebswirtschaftliche Begründung, keine
  moralische.

## 2. Strategische Entscheidung

Statt die Kommunikation zu verbessern, wird zuerst ein Kanal gebaut, den die
Studierenden aus eigenem Interesse öffnen.

**Der Hebel ist Push statt Pull.** Das Campus-Management-System TraiNex ist ein
Hol-System: Man muss aktiv nachsehen. Genau das tut niemand. Tagesaktuelle
Raumänderungen und Ausfälle stehen heute nur auf einer schwer nutzbaren Website
oder hängen vor Ort aus.

**Der Stundenplan ist der Köder, die Mitteilungen sind der Zweck.** Studierende
installieren die App wegen des Plans. Einmal installiert, erreichen Hochschule
und StuRa sie über zwei getrennte Kanäle.

**Zwei Absender, ein Ort.** Die Trennung in "Hochschule" und "StuRa" ist das
stärkste Argument gegenüber der Hochschulleitung: Der StuRa bittet nicht um
etwas, sondern bietet der Verwaltung einen Zustellweg für ihre eigenen
Mitteilungen an.

## 3. Recherchestand zu TraiNex

Geprüft im September 2026 anhand der Herstellerdokumentation:

- TraiNex hat bereits eine mobile WebApp (Aufruf über die Hochschuladresse im
  Handy-Browser) mit Stundenplan, Lernmaterialien, Nachrichten und News-Feed.
- **Nicht dokumentiert sind:** Push-Benachrichtigungen, eine API, ein
  iCal-/ICS-Export. Die vorhandenen Schnittstellenmodule betreffen Zoom/Teams,
  Statistisches Landesamt und Krankenkassen.
- Noten und Prüfungsanmeldung sind mobil bewusst gesperrt.

Konsequenz: Es gibt nichts, worauf sich technisch aufsetzen lässt. Der einzige
realistische Weg zu den Plandaten ist eine Datei, die die Verwaltung ohnehin
erzeugt.

Quellen: TraiNexWiki (WebApp), campus-management-system.de (Module).

## 4. Architektur — und warum sie so aussieht

Die zentrale Entwurfsentscheidung: **Die App verarbeitet keine
personenbezogenen Daten.** Nicht aus Vorsicht, sondern weil sie technisch
keine bekommt.

- Der Server kennt nur **Kurse und Kohorten**, keine Personen.
- Der Student wählt einmal Studiengang und Startsemester. Die Auswahl und
  spätere Abweichungen (einzelne Kurse an- oder abwählen) bleiben **auf dem
  Gerät**.
- Push läuft später über **Topic-Subscriptions**: Das Gerät meldet sich beim
  Push-Dienst für ein Thema an (etwa "IBA-Sem5-Marketing"). Der StuRa sendet an
  das Thema, nicht an Personen, und erfährt nie, wer zuhört.

Verworfene Alternativen und der Grund:

- **Login mit Matrikelnummer und Passwort:** Macht den StuRa
  datenschutzrechtlich verantwortlich, provoziert Passwort-Wiederverwendung mit
  TraiNex, lässt sich nicht verifizieren (die Matrikelnummernliste liegt nicht
  vor) und erzeugt Moderationsaufwand.
- **Stundenplan aus TraiNex auslesen (Scraping):** Serverseitig verlangt es die
  Zugangsdaten der Studierenden — Ausschlusskriterium. Geräteseitig verbietet
  der Browser aus Sicherheitsgründen den Zugriff auf fremde Seiten.
- **Kommentarfunktion:** Ersetzt durch Umfragen und ein anonymes
  Anliegen-Formular. Umfrageergebnisse sind für den StuRa als
  Verhandlungsargument wertvoller als ein Kommentarverlauf, anonyme
  Rückmeldungen sind ehrlicher, und beides erzeugt keinen Moderationsaufwand.

## 5. Was die Hochschule liefern muss

Genau eine Sache: **einmal pro Semester die Datei, aus der die Stundenpläne
erzeugt werden** (Excel, CSV, PDF — was vorliegt). Kein Systemzugriff, keine
Schnittstelle, keine Kosten.

Bewusst **nicht** verlangt wird ein Zugang, in den die IT Kurse eintippt.
Doppelerfassung ist die Aufgabe, die in jeder IT-Abteilung als Erstes
liegenbleibt. Wer die Daten pflegt, haftet außerdem für Fehler — das würde die
IT entweder ablehnen oder mit einem Anspruch auf Kontrolle über die gesamte App
beantworten.

Deshalb trägt die App sichtbar den Hinweis: *Angaben ohne Gewähr, verbindlich
ist TraiNex.*

Offen ist, ob die IT überhaupt zuständig ist. An vielen Hochschulen erstellt die
Studiengangskoordination die Pläne, während die IT nur das System betreibt.

## 6. Aktueller Stand

`index.html` ist eine lauffähige Demo-App in einer einzigen Datei. Schriften,
Logo und App-Icon sind eingebettet, es wird nichts nachgeladen.

**Funktioniert:**

- Startbildschirm: Logo wächst auf, hält eine Sekunde, blendet aus
- Erstauswahl Studiengang (Jura, Wirtschaftspsychologie, International Business
  Administration), dann Startsemester. Die Liste der Startsemester erzeugt sich
  aus dem heutigen Datum (Wechsel jeweils zum 01.10. und 01.04.) und wächst von
  selbst — kein manuelles Nachtragen nötig
- Auswahl wird gespeichert; beim zweiten Öffnen geht es direkt in den Plan.
  Korrigierbar über die blaue Leiste oben im Plan ("ändern") oder über das
  Zahnrad-Symbol (Einstellungen) auf jedem der drei Bereiche
- Einstellungen: Erscheinungsbild manuell auf Hell/Dunkel/System stellen
  (überschreibt die automatische Systemeinstellung), Studiengang & Semester
  ändern
- Drei Bereiche: Plan, Hochschule, StuRa
- Wochenplan Mo–Fr mit Raumänderung und Ausfall als Demonstration; Tage mit
  Änderungen tragen einen roten Punkt
- Reaktionen (Daumen hoch, Herz, unzufrieden) auf StuRa-Mitteilungen. Pro Gerät
  ist nur eine Reaktion pro Mitteilung möglich, die Zählung ist über alle
  Geräte hinweg sichtbar, sobald das kostenlose Supabase-Projekt eingerichtet
  ist (siehe Abschnitt 7). Ohne diese Einrichtung zählen die Buttons nur lokal
  auf dem eigenen Gerät
- Installation über "Zum Startbildschirm hinzufügen" mit BSP-Icon und
  Vollbildstart

**Funktioniert noch nicht:**

- Das anonyme Anliegen-Formular zeigt den Ablauf, überträgt aber nichts
- Push-Benachrichtigungen
- Offline-Betrieb
- Mitteilungen veröffentlichen: Das ging nur in der früheren, auf claude.ai
  gehosteten Fassung. In dieser eigenständigen Datei sind die Mitteilungen
  fest eingebaut

**Beispieldaten:** Kurse, Räume und Beiträge sind Platzhalter und in der App als
solche gekennzeichnet. Fächer sind typische Module der drei Studiengänge, Räume
001–028 in der Siemensvilla. Dozentennamen wurden bewusst weggelassen, um keine
Personen zu erfinden. Echte Stundenplandaten liegen noch nicht vor.

## 7. Einrichtung der Reaktionen (optional)

Die Daumen-hoch/Herz/unzufrieden-Buttons unter StuRa-Mitteilungen zählen ohne
weitere Einrichtung nur lokal auf dem eigenen Gerät. Damit sie über alle Geräte
hinweg zählen, braucht es ein kleines, kostenloses Backend:

1. Kostenloses Projekt auf [supabase.com](https://supabase.com) anlegen (keine
   Kreditkarte nötig).
2. Im SQL-Editor das Skript `docs/supabase-reaktionen.sql` ausführen.
3. Unter „Project Settings“ → „API“ die `Project URL` und den `anon public
   key` kopieren.
4. Beide Werte in `index.html` eintragen — Suche im Text nach
   `SUPABASE_URL` (zwei Zeilen, direkt darunter `SUPABASE_ANON_KEY`).
5. Datei neu hochladen. Fertig.

Der anon-Schlüssel ist bewusst zur Verwendung im Browser gedacht — der Schutz
läuft über die Row-Level-Security-Regeln im SQL-Skript, nicht über Geheimhaltung
des Schlüssels. Gespeichert wird pro Reaktion nur die Mitteilungs-ID, ein
zufälliger Geräte-Token (kein Login, keine Person) und die gewählte Reaktion.

## 8. Nächste Schritte

1. **Demo bei der Hochschule.** Sie hat ein Beispiel verlangt, bevor sie etwas
   genehmigt. `docs/konzept-entwurf.pdf` ist die Begleitunterlage.
2. **Anfrage an die richtige Stelle.** Drei Auskünfte, nicht sofort die Datei:
   In welchem Format werden die Semesterpläne erzeugt? Wer ist intern
   zuständig — IT oder Studiengangskoordination? Spricht grundsätzlich etwas
   dagegen, sie dem StuRa einmal pro Semester zu überlassen?
3. **Betrieb klären, bevor die echte Version gebaut wird.** Wer aktualisiert den
   Kurskatalog jedes Semester? Wer betreut die App, wenn der Vorstand wechselt?
   Ohne Antwort darauf hat das Projekt ein eingebautes Ablaufdatum.
4. **Produktive Version** — siehe `CLAUDE.md`, Abschnitt "Ausbaustufe".

## 9. Rahmenbedingungen

- **Kein Budget.** Kein App Store (Apple 99 Euro im Jahr, Google 25 Euro
  einmalig), kein Freelancer, keine laufenden Serverkosten. Nur kostenlose
  Angebote.
- **Kein Entwickler im Vorstand.** Der Projektverantwortliche versteht Abläufe
  und Architektur, schreibt aber keinen Code. Code muss fertig und lauffähig
  geliefert werden.
- **Zeitliche Einschränkung.** Der Projektverantwortliche ist bis Ende Dezember
  2026 im Ausland. Konzept, Anfragen und Business Case gehen aus der Ferne,
  alles mit Präsenzbedarf ab Januar.
- **Wechselnde Besetzung.** Der StuRa-Vorstand wechselt. Was nur eine Person
  betreuen kann, überlebt den Wechsel nicht.

## 10. Inhalt dieses Ordners

```
index.html                      Die App — eine Datei, direkt hochladbar
CLAUDE.md                       Arbeitsanweisungen für Claude-Code-Sitzungen
README.md                       Dieses Dokument
assets/bsp-logo.jpg             Offizielles BSP-Logo (Original des Vorstands)
docs/konzept-entwurf.pdf        Zweiseitige Unterlage für Gespräche
docs/mockup.html                Statische Ansicht der vier Screens
docs/supabase-reaktionen.sql    Einrichtung für geräteübergreifende Reaktionen
```
