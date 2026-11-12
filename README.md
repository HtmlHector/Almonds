# Almonds

A food-scanner app in the spirit of Yuka and Oasis. Scan a product's barcode
(or search by name) and see a 0–100 health score, which additives are worth
worrying about and why, healthier alternatives, and whether it fits your diet.
Keep a history and talk about it with the community.

Built with **Flutter** (native iOS look, including the iOS 26 Liquid Glass tab
bar) and **Supabase** (Postgres, Auth, row-level security). Product data comes
from [Open Food Facts](https://world.openfoodfacts.org).

## Features

**Scanning and results**
- Barcode scanning (EAN/UPC) with torch; manual entry and **search by name**
  for devices without a camera
- Transparent score with a breakdown (nutrition, additives, organic) so users
  see *why* a product scored the way it did
- 46 curated additives with severity, category and plain-language
  explanations, matched by name, alias or E-number
- Nutrition traffic lights per 100 g, Nutri-Score and NOVA badges, allergens
- **Healthier alternatives**: better-scoring products from the same category
- **Compare** two products side by side
- **Share** a score card as an image
- Recently viewed products open **offline** from a local cache

**Personalisation**
- **Dietary preferences**: vegan, vegetarian, palm-oil free, and 10 allergens.
  Every product shows a clear *fits / conflicts / can't confirm* banner

**Account and community**
- Email sign-up and sign-in, editable username, in-app account deletion
- History and favourites synced per account
- Community posts (optionally attached to a product), votes, comments
- **Report and block** for user-generated content

**Polish**
- Native iOS widgets throughout: large titles, grouped lists, sheets, action
  sheets, SF Symbols, dark mode, haptics
- Onboarding, app icon, branded launch screen, empty/loading/error states

## How the score works

| Part | Points | Source |
| --- | --- | --- |
| Nutrition | 0–60 | Nutri-Score (2017) points from energy, sugars, saturated fat, sodium, fibre and protein |
| Additives | 0–30 | Starts at 30; −3 / −8 / −15 per low / moderate / high-risk additive |
| Organic | 0–10 | Organic label present |

A product containing a high-risk additive is capped at 49. If a product has no
nutrition facts, the score is rescaled from the remaining parts and the UI says
so. Ratings: Excellent ≥ 75, Good ≥ 50, Mediocre ≥ 25, Poor below.

The engine is a pure Dart class (`lib/data/services/scoring_engine.dart`) with
unit tests. Beverages use the same thresholds as foods, a known simplification.

## Architecture

```
lib/
  core/        config, theme, shared widgets
  data/
    models/        Product, Nutriments, ScoreResult, Diet, Post, ...
    services/      Open Food Facts client, scoring engine, additive catalog,
                   product service (cache + search + alternatives)
    repositories/  Supabase access (auth, history, community, diet)
  state/       ChangeNotifier controllers (provider)
  features/    auth, onboarding, scanner, search, product, compare,
               history, community, profile, shell
supabase/migrations/   schema + RLS policies
assets/data/additives.json
```

Repositories are the only code that talks to Supabase; screens talk to
controllers; the scoring engine and diet matching have no Flutter or network
dependencies.

## Running it

Prerequisites: Flutter, Docker and the
[Supabase CLI](https://supabase.com/docs/guides/local-development).

```bash
supabase start          # local Postgres + Auth + REST, applies supabase/migrations
flutter pub get
flutter run             # iOS simulator reaches the stack at 127.0.0.1
```

No secrets are committed; the default key is the public local-stack key. The
iOS simulator has no camera, so use **Search** or **Enter Barcode**.

### Hosted backend

To run without a local stack, create a free project at supabase.com, then:

```bash
supabase login
supabase link --project-ref <ref>
supabase db push        # applies everything in supabase/migrations
flutter run \
  --dart-define=SUPABASE_URL=https://<ref>.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=<publishable key>
```

For email sign-up in a hosted project, either configure SMTP or turn off
"Confirm email" under Authentication → Providers while developing.

On an Android emulator use `SUPABASE_URL=http://10.0.2.2:54321` for the local
stack. Note the UI is built for iOS.

## Tests and CI

```bash
flutter analyze
flutter test
```

Covers scoring, additive matching (word boundaries, E-numbers, aliases),
nutrient parsing, the Open Food Facts client (found, not found, malformed
barcode, server error, offline), the offline cache, search, healthier
alternatives, diet matching and compare logic. GitHub Actions runs analyze and
tests on every push and does an unsigned iOS build.

## Data and disclaimer

Open Food Facts data is community-maintained and may be incomplete (ODbL).
Scores are informational and not medical advice. Allergen and diet banners rely
on that data, so check the package if an allergy is serious.
