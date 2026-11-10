-- Myfitness Journal schema; execute in Supabase SQL editor.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  calorie_goal integer not null default 2000,
  protein_goal numeric(7,2) not null default 150,
  target_weight_kg numeric(6,2),
  created_at timestamptz not null default now()
);

create table public.exercises (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  unique(user_id, name)
);
create table public.workouts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_date date not null,
  notes text,
  created_at timestamptz not null default now(),
  unique(user_id, workout_date)
);
create table public.workout_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_id uuid not null references public.workouts(id) on delete cascade,
  exercise_id uuid references public.exercises(id) on delete set null,
  exercise_name text not null,
  position integer not null default 0,
  completed boolean not null default false
);
create table public.workout_sets (
  id uuid primary key default gen_random_uuid(),
  workout_exercise_id uuid not null references public.workout_exercises(id) on delete cascade,
  set_number integer not null,
  weight_kg numeric(7,2) not null default 0,
  reps integer not null default 0,
  completed boolean not null default false
);
create table public.foods (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users(id) on delete cascade,
  name text not null,
  kcal_per_100g numeric(8,2) not null,
  protein_per_100g numeric(8,2) not null,
  source text not null default 'custom',
  created_at timestamptz not null default now()
);
create table public.meals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  meal_date date not null,
  name text not null,
  position integer not null default 0
);
create table public.meal_items (
  id uuid primary key default gen_random_uuid(),
  meal_id uuid not null references public.meals(id) on delete cascade,
  food_id uuid references public.foods(id) on delete set null,
  food_name text not null,
  grams numeric(8,2) not null,
  kcal_per_100g_snapshot numeric(8,2) not null,
  protein_per_100g_snapshot numeric(8,2) not null
);
create table public.body_weights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  entry_date date not null,
  weight_kg numeric(6,2) not null,
  created_at timestamptz not null default now(),
  unique(user_id, entry_date)
);

alter table public.profiles enable row level security;
alter table public.exercises enable row level security;
alter table public.workouts enable row level security;
alter table public.workout_exercises enable row level security;
alter table public.workout_sets enable row level security;
alter table public.foods enable row level security;
alter table public.meals enable row level security;
alter table public.meal_items enable row level security;
alter table public.body_weights enable row level security;

create policy "profile own" on public.profiles for all using (id = auth.uid()) with check (id = auth.uid());
create policy "exercises own" on public.exercises for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "workouts own" on public.workouts for all using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "workout exercises via workout" on public.workout_exercises for all
 using (exists(select 1 from public.workouts w where w.id=workout_id and w.user_id=auth.uid()))
 with check (exists(select 1 from public.workouts w where w.id=workout_id and w.user_id=auth.uid()));
create policy "sets via workout exercise" on public.workout_sets for all
 using (exists(select 1 from public.workout_exercises we join public.workouts w on w.id=we.workout_id where we.id=workout_exercise_id and w.user_id=auth.uid()))
 with check (exists(select 1 from public.workout_exercises we join public.workouts w on w.id=we.workout_id where we.id=workout_exercise_id and w.user_id=auth.uid()));
create policy "foods own or global read" on public.foods for select using (user_id is null or user_id=auth.uid());
create policy "foods own write" on public.foods for insert with check (user_id=auth.uid());
create policy "foods own update" on public.foods for update using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "foods own delete" on public.foods for delete using (user_id=auth.uid());
create policy "meals own" on public.meals for all using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "meal items via meal" on public.meal_items for all
 using (exists(select 1 from public.meals m where m.id=meal_id and m.user_id=auth.uid()))
 with check (exists(select 1 from public.meals m where m.id=meal_id and m.user_id=auth.uid()));
create policy "weights own" on public.body_weights for all using (user_id=auth.uid()) with check (user_id=auth.uid());
