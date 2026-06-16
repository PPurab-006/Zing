# Zing

> An open only you place. Zing only gives, never takes.

A daily quote app built around creators, athletes, and public figures who shaped you. No signup. No data collection. Fully local.

---

## Philosophy

- **Resonance over inspiration** — quotes from people you actually love
- **Zero data collection** — everything lives on your device
- **Zing only gives, never takes**

---

## Project Structure

```
lib/
  core/
    services/
      database_service.dart     ← Hive init, all box management
      quote_service.dart        ← Quote scheduling & refresh logic
    constants/                  ← App-wide constants
    utils/                      ← Helper functions
  data/
    models/
      creator_model.dart        ← Creator Hive model
      quote_model.dart          ← Quote + QuoteSource Hive models
      preferences_model.dart    ← UserPreferences Hive model
    repositories/               ← Repository pattern (future)
  presentation/
    screens/
      onboarding/               ← Creator selection flow
      home/                     ← Main quote screen
      settings/                 ← Frequency, notifications etc
    widgets/                    ← Shared UI components
    theme/
      zing_theme.dart           ← Black & white theme

assets/
  data/
    creators.json               ← Master creator index
    quotes/
      markiplier.json           ← Per-creator quote files
      technoblade.json
      xqc.json
      ...
  fonts/                        ← ZingDisplay font files
  images/
    creators/                   ← Creator avatar images
```

---

## Data Architecture

**Isolation principle:** Each creator has their own Hive box (`quotes_markiplier`, `quotes_xqc` etc). One creator's data never touches another's. Adding a new creator = dropping a new JSON file. Zero structural changes.

**Loading strategy:**
1. App launches → reads `creators.json` into `creators_box`
2. User selects creators during onboarding
3. Only selected creators' JSON files are parsed and stored in Hive
4. All subsequent reads from Hive — fast, offline, forever

**Quote schema:**
```json
{
  "id": "mark_001",
  "text": "Quote text here",
  "tags": ["funny", "iconic"],
  "language": "en",
  "source": {
    "video_title": "Video name",
    "youtube_url": "https://youtube.com/watch?v=..."
  }
}
```

---

## Quote Dataset Targets

- **Dev dataset:** 10 creators × 20 quotes = 200 quotes
- **Launch dataset:** 10 creators × 500 quotes = 5,000 quotes
- **Scale target:** 50 creators × 500 quotes = 25,000 quotes (~5MB)

At max frequency (5 quotes/day), 500 quotes = 100 days before any repeat per creator. With randomisation across multiple selected creators, effectively years of fresh content.

---

## Setup

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

> Note: Run build_runner to generate Hive adapters (*.g.dart files) before running the app.

---

## Hive Type IDs

| Model | TypeId |
|-------|--------|
| Creator | 0 |
| QuoteSource | 1 |
| Quote | 2 |
| UserPreferences | 3 |

---

## Adding a New Creator

1. Add entry to `assets/data/creators.json`
2. Create `assets/data/quotes/{creator_id}.json` with quote array
3. Add avatar image to `assets/images/creators/`
4. Register new asset path in `pubspec.yaml` if needed
5. Ship app update — zero code changes required

---

*Built with Flutter. No backend. No accounts. No data collected.*
