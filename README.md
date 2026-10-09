# BrainSpeed IQ

A Flutter brain-training game with a manga-inspired dark interface, XP/rank progression, timed mini-games, and locally saved progress.

## Included in this first scaffold

- **Reflex Rush** — tap-target reaction challenge
- **Memory Matrix** — memorize and repeat a number sequence
- **Pattern Breaker** — complete an arithmetic sequence
- XP, rank tiers, best-score tracking, and local persistence
- Flutter widget smoke tests and a GitHub Actions CI workflow

## Run locally

Install the Flutter stable SDK, clone this repository, then run:

```bash
flutter create --platforms=android,web --project-name brain_speed_iq .
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

The `flutter create` command generates the Android and web platform folders, which are intentionally not checked into this initial source scaffold.

## Current status

This is an initial playable prototype, not a production release. CI has been configured but must run successfully before treating the code as verified. Build and test on physical Android devices before publishing.

## Important limitations

- Scores are game-performance metrics, **not** a clinically validated IQ assessment.
- Ads and mediation, billing and purchase verification, parental controls, privacy disclosures, and Play Store release configuration are not implemented yet.
- Do not collect children's personal data until the privacy, consent, SDK, and applicable legal requirements have been reviewed.
