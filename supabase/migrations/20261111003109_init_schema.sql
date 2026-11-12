-- Almonds schema: profiles, scan history, community (posts, votes, comments).
-- Every table has row-level security; users can only write their own rows.

-- ===== Profiles =====
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null unique check (char_length(username) between 3 and 24),
  avatar_url text,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles are viewable by signed-in users"
  on public.profiles for select to authenticated using (true);
create policy "users update own profile"
  on public.profiles for update to authenticated
  using (auth.uid() = id) with check (auth.uid() = id);

-- Create a profile automatically when a user signs up.
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id, username)
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'username', ''),
      'user_' || substr(replace(new.id::text, '-', ''), 1, 8)
    )
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ===== Scan history =====
create table public.scan_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  barcode text not null,
  name text not null,
  brand text not null default '',
  image_url text,
  score int not null check (score between 0 and 100),
  product jsonb not null default '{}'::jsonb, -- full product snapshot for offline detail view
  is_favorite boolean not null default false,
  scanned_at timestamptz not null default now(),
  unique (user_id, barcode)
);

create index scan_history_user_time on public.scan_history (user_id, scanned_at desc);

alter table public.scan_history enable row level security;

create policy "users read own history"
  on public.scan_history for select to authenticated using (auth.uid() = user_id);
create policy "users insert own history"
  on public.scan_history for insert to authenticated with check (auth.uid() = user_id);
create policy "users update own history"
  on public.scan_history for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users delete own history"
  on public.scan_history for delete to authenticated using (auth.uid() = user_id);

-- ===== Community =====
create table public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade default auth.uid(),
  title text not null check (char_length(title) between 1 and 120),
  body text not null default '' check (char_length(body) <= 2000),
  product_barcode text,
  product_name text,
  created_at timestamptz not null default now()
);

create index posts_created on public.posts (created_at desc);

create table public.post_votes (
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade default auth.uid(),
  value smallint not null check (value in (-1, 1)),
  primary key (post_id, user_id)
);

create table public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade default auth.uid(),
  body text not null check (char_length(body) between 1 and 1000),
  created_at timestamptz not null default now()
);

create index comments_post on public.comments (post_id, created_at);

alter table public.posts enable row level security;
alter table public.post_votes enable row level security;
alter table public.comments enable row level security;

create policy "posts readable by signed-in users"
  on public.posts for select to authenticated using (true);
create policy "users create own posts"
  on public.posts for insert to authenticated with check (auth.uid() = user_id);
create policy "users edit own posts"
  on public.posts for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users delete own posts"
  on public.posts for delete to authenticated using (auth.uid() = user_id);

create policy "votes readable by signed-in users"
  on public.post_votes for select to authenticated using (true);
create policy "users cast own votes"
  on public.post_votes for insert to authenticated with check (auth.uid() = user_id);
create policy "users change own votes"
  on public.post_votes for update to authenticated
  using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "users remove own votes"
  on public.post_votes for delete to authenticated using (auth.uid() = user_id);

create policy "comments readable by signed-in users"
  on public.comments for select to authenticated using (true);
create policy "users create own comments"
  on public.comments for insert to authenticated with check (auth.uid() = user_id);
create policy "users delete own comments"
  on public.comments for delete to authenticated using (auth.uid() = user_id);

-- Feed view: posts with author, vote total, the caller's vote, and comment count.
create view public.post_feed with (security_invoker = true) as
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
join public.profiles pr on pr.id = p.user_id;

grant select on public.post_feed to authenticated;

-- Account deletion: lets a signed-in user delete their own account (cascades to all their data).
create function public.delete_my_account() returns void
language plpgsql security definer set search_path = '' as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
