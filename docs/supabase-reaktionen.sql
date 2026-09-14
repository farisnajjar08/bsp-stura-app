-- Einrichtung der Reaktionen (Daumen/Smileys) auf StuRa-Mitteilungen.
-- Einmal im SQL-Editor eines kostenlosen Supabase-Projekts ausführen:
-- https://supabase.com  ->  New Project (kostenlos, keine Kreditkarte nötig)
-- ->  SQL Editor  ->  dieses Skript einfügen  ->  Run
--
-- Danach unter "Project Settings" -> "API" die Werte
--   Project URL        ->  SUPABASE_URL
--   anon public key     ->  SUPABASE_ANON_KEY
-- in index.html eintragen (Suche nach "SUPABASE_URL").
-- Beide Werte sind zur öffentlichen Verwendung im Browser gedacht,
-- der Schutz läuft über die Row-Level-Security-Regeln unten.

create table if not exists reactions (
  news_id     text not null,
  device_id   uuid not null,
  reaction    text not null check (reaction in ('like','heart','meh')),
  created_at  timestamptz not null default now(),
  primary key (news_id, device_id)
);

-- Ein Gerät kann pro Mitteilung nur eine Zeile anlegen (siehe Primary Key oben).
-- Ein zweiter Versuch vom selben Gerät scheitert am Primary Key und wird
-- von der App stillschweigend als "schon abgestimmt" behandelt.

alter table reactions enable row level security;

-- Jeder darf eine eigene Reaktion einfügen, aber weder die Rohdaten lesen
-- noch fremde Zeilen ändern oder löschen. So bleibt device_id (ein
-- zufälliger, nicht mit einer Person verknüpfter Token) nach außen unsichtbar.
create policy "anon kann eigene Reaktion einfügen"
  on reactions for insert
  to anon
  with check (true);

grant insert on reactions to anon;

-- Aggregierte, anonyme Zählung pro Mitteilung und Reaktionstyp.
-- Nur diese View ist lesbar, nicht die Tabelle "reactions" selbst.
create or replace view reaction_counts as
  select news_id, reaction, count(*)::int as n
  from reactions
  group by news_id, reaction;

grant select on reaction_counts to anon;
