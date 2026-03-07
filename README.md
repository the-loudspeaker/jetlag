# JetLag: Namma Ooru Edition

An app to play hide & seek across Bengaluru (Blr).

## Features
- **Real-time Tracking**: Seekers and Hiders can see each other's locations (with appropriate delays/logic).
- **Interactive Map**: Displays Bengaluru Metro lines, stations, malls, lakes, bus stops, and major landmarks.
- **Configurable Gameplay**: Constants like metro station radius are configurable via Supabase.
- **Role-based Experience**: Dedicated home screens for Hiders and Seekers.

## Project Structure

The project follows SOLID principles and a layered architecture for better maintainability:

```text
lib/
├── data/           # Static coordinate lists and map definitions
├── models/         # Type-safe data structures (Metro, Landmark, etc.)
├── services/       # Business logic & side-effects (GPS, Supabase, Storage)
├── widgets/        # Reusable UI components and map overlays
├── screens/        # Feature-specific stateful screens
│   ├── hiders/     # Hider-specific views
│   ├── seekers/    # Seeker-specific views
│   └── shared/     # Shared screens like Role Selection
├── themes/         # App styling and map tile configuration
└── main.dart       # App entry point and initialization
```

## Getting Started

1.  **Prerequisites**:
    - Flutter SDK (Stable)
    - Java 21 (for Android builds)
    - A Supabase project for real-time data syncing.

2.  **Setup**:
    - Run `flutter pub get` to install dependencies.
    - Create a `.env` file in the root directory. Use `example.env` as a template:
      ```bash
      cp example.env .env
      ```
    - Fill in your `SUPABASE_URL` and `SUPABASE_ANON_KEY` in the `.env` file.
    - Ensure your `configs` table is set up in Supabase (see implementation notes).

3.  **Build**:
    - Build for Android: `flutter build apk --release --target-platform android-arm64`

## Metro data
Metro line and station assets live in `assets/metro/*.geojson`. Run `python3 scripts/build_metro_assets.py` to refresh them from OpenStreetMap/Overpass; the script falls back to the bundled sample data if fetching fails.

## CI/CD
This project includes GitHub Actions to automatically build release APKs on every push to the `main` branch. 

**Note**: To enable the build, you must add the following secrets to your GitHub repository:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Artifacts are kept for the last 5 runs.

## License
This project is licensed under the **GNU General Public License v3.0 (GPLv3)**. See the [LICENSE](LICENSE) file for details.

## TODO 
- Balance the deck & print it.
- Do a trial run.
- Add bottom nav bar layout for Matching, Measuring & Photos type questions & views. 
- Temperature & Radar will be done manually.
