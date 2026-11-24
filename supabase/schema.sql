-- Malmö Winter of Love: tables, access rules and realtime.
-- Run once in the Supabase SQL editor, then run seed.sql.

create table if not exists public.places (
  id          text primary key check (char_length(id) <= 60),
  name        text not null check (char_length(name) between 1 and 80),
  cat         text not null check (cat in ('bar','sight','weird','food','outdoors','xmas')),
  descr       text not null default '' check (char_length(descr) <= 600),
  url         text check (url is null or (url ~* '^https://' and char_length(url) <= 300)),
  lat         double precision not null check (lat between 55.545 and 55.645),
  lng         double precision not null check (lng between 12.90 and 13.10),
  by_name     text not null default '' check (char_length(by_name) <= 40),
  created_by  uuid default auth.uid(),
  created_at  timestamptz not null default now()
);

create table if not exists public.activities (
  id          text primary key check (char_length(id) <= 60),
  title       text not null check (char_length(title) between 1 and 90),
  note        text not null default '' check (char_length(note) <= 400),
  place_id    text references public.places(id) on delete set null,
  by_name     text not null default '' check (char_length(by_name) <= 40),
  created_by  uuid default auth.uid(),
  created_at  timestamptz not null default now()
);

-- One row per person per thing they love. item_id is "p:<place id>" or "a:<activity id>".
create table if not exists public.votes (
  user_id     uuid not null default auth.uid(),
  item_id     text not null check (char_length(item_id) <= 64),
  name        text not null default '' check (char_length(name) <= 40),
  created_at  timestamptz not null default now(),
  primary key (user_id, item_id)
);

alter table public.places     enable row level security;
alter table public.activities enable row level security;
alter table public.votes      enable row level security;

-- Everyone can read. Signed-in visitors (anonymous sign-in counts) can add.
-- People can only delete what they added themselves; you delete anything from the dashboard.
create policy "read places"   on public.places for select to anon, authenticated using (true);
create policy "add places"    on public.places for insert to authenticated with check (created_by = auth.uid());
create policy "delete own places" on public.places for delete to authenticated using (created_by = auth.uid());

create policy "read activities" on public.activities for select to anon, authenticated using (true);
create policy "add activities"  on public.activities for insert to authenticated with check (created_by = auth.uid());
create policy "delete own activities" on public.activities for delete to authenticated using (created_by = auth.uid());

create policy "read votes"    on public.votes for select to anon, authenticated using (true);
create policy "cast own vote" on public.votes for insert to authenticated with check (user_id = auth.uid());
create policy "rename own votes" on public.votes for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "remove own vote"  on public.votes for delete to authenticated using (user_id = auth.uid());

-- Live updates for everyone who has the page open.
alter publication supabase_realtime add table public.places, public.activities, public.votes;
