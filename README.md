# Myfitness Journal

Flutter + Supabase fitness journal starter.

## Features in this starter
- Teal/charcoal Material 3 UI
- Dashboard, Workout, Meals, Weight tabs
- Local demo workout, food and weight journaling
- Exercise/set completion toggles
- Meals with custom foods, grams, kcal/100g and protein/100g
- Daily weight entries
- Local persistence is not yet wired (demo state resets on app restart)

## Run
1. Install Flutter stable and Android Studio.
2. Create a Flutter app: `flutter create myfitness_journal`
3. Replace its `lib/` directory with this project's `lib/`.
4. Add dependencies from `pubspec.yaml` (merge into generated file).
5. `flutter pub get && flutter run`

## Supabase next
- Create a Supabase project.
- Add `supabase/migrations/001_initial.sql` in SQL Editor.
- Configure Google provider in Supabase Auth and Google Cloud OAuth.
- Add `supabase_flutter` and initialize with project URL + anon key.
- Keep the anon key in app config; never embed service-role keys.
- Apply RLS policies; each user's records are isolated by `auth.uid()`.

## Free tier note
Supabase/Vercel/Google provider and Open Food Facts have free options, but quotas, availability and terms can change. Google OAuth setup requires configuring credentials.
