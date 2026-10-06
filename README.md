# School Management System — Starter v0.1

This is a **starter project**, not the complete 15-phase system yet. It includes:
- Flutter Android app foundation
- Five role choices on the login screen
- Supabase Flutter package and optional initialization
- GitHub Actions workflow that builds and uploads a release APK

## Important
The login screen currently implements Supabase email/password sign-in for **Super Admin only**. School Access Code login, role-based dashboards, database tables, RLS policies, offline sync, and the remaining modules are not implemented yet. Do not use this starter with real student data until authorization and Row Level Security are implemented and tested.

## Set up Supabase
1. Create a Supabase project.
2. Copy the Project URL and the **publishable/anon client key** (never use the `service_role` key in the app).
3. In GitHub, open your repository: Settings → Secrets and variables → Actions → New repository secret.
4. Add:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

## Build APK on GitHub
1. Upload/extract this project into a GitHub repository, ensuring `pubspec.yaml`, `lib/`, and `.github/workflows/main.yml` are at the repository root.
2. Push to the `main` branch, or open Actions → Build Android APK → Run workflow.
3. Open the completed workflow run and download the `school-management-apk` artifact.
4. Extract the downloaded artifact ZIP to find `app-release.apk`.

## Local build (optional)
Install Flutter and Android tooling, then run:
```bash
flutter pub get
flutter run
```

## Project layout
- `lib/main.dart` — app entry point and starter login UI
- `pubspec.yaml` — Flutter dependencies
- `.github/workflows/main.yml` — automated Android APK build
