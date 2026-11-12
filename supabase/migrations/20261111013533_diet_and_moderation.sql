-- Dietary preferences + community moderation (report / block).

-- ===== Dietary preferences (stored on the profile) =====
alter table public.profiles
  add column diets text[] not null default '{}',
  add column avoid_allergens text[] not null default '{}';

-- ===== Blocking =====
create table public.blocked_users (
  blocker_id uuid not null references public.profiles (id) on delete cascade default auth.uid(),
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

alter table public.blocked_users enable row level security;

create policy "users read own blocks"
  on public.blocked_users for select to authenticated using (auth.uid() = blocker_id);
create policy "users block others"
  on public.blocked_users for insert to authenticated with check (auth.uid() = blocker_id);
create policy "users unblock"
  on public.blocked_users for delete to authenticated using (auth.uid() = blocker_id);

-- ===== Reports =====
create table public.post_reports (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  reporter_id uuid not null references public.profiles (id) on delete cascade default auth.uid(),
  reason text not null check (char_length(reason) between 1 and 200),
  created_at timestamptz not null default now(),
  unique (post_id, reporter_id)
);

alter table public.post_reports enable row level security;

create policy "users file own reports"
  on public.post_reports for insert to authenticated with check (auth.uid() = reporter_id);
create policy "users read own reports"
  on public.post_reports for select to authenticated using (auth.uid() = reporter_id);

-- ===== Feed hides posts from users you blocked =====
create or replace view public.post_feed with (security_invoker = true) as
select
  p.id,
  p.title,
  p.body,
  p.product_barcode,
  p.product_name,
  p.created_at,
  p.user_id,
  pr.username as author,
  coalesce((select sum(v.value) from public.post_votes v where v.post_id = p.id), 0)::int as votes,
  (select v.value from public.post_votes v
     where v.post_id = p.id and v.user_id = auth.uid()) as my_vote,
  (select count(*) from public.comments c where c.post_id = p.id)::int as comment_count
from public.posts p
join public.profiles pr on pr.id = p.user_id
where not exists (
  select 1 from public.blocked_users b
  where b.blocker_id = auth.uid() and b.blocked_id = p.user_id
);
