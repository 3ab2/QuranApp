# Quran Noor — Google Play production release

This document is the **release engineering baseline** for Android (AAB), signing, policy alignment, and operational checklist.

---

## 1. Release signing (mandatory before Play upload)

### Generate the upload keystore (once)

- **Windows:** run `android\generate_upload_keystore.ps1` from the repo root, or use `keytool` manually (see `android/key.properties.template`).
- **Never** commit `android/key.properties` or `*.jks` / `*.keystore` (already in `android/.gitignore`).

### Configure Gradle

- Copy `android/key.properties.template` → `android/key.properties`.
- Set `storePassword`, `keyPassword`, `keyAlias`, `storeFile` (path relative to `android/`, e.g. `upload-keystore.jks`).

### Build production AAB

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`.

### Verify signing

- **jarsigner:** `jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab` (expect `jar verified`).
- **Play Console:** first upload registers the **upload key**; Google Play App Signing holds the **app signing key**.

### Backup (critical)

- Store **keystore file + all passwords + key alias** in a password manager and an **offline encrypted backup**.
- Losing the upload key complicates updates; follow [Google Play key loss policy](https://support.google.com/googleplay/android-developer/answer/9842757).

---

## 2. Build hardening (current Gradle state)

| Item | Status |
|------|--------|
| `isMinifyEnabled` / R8 | `true` (release) |
| `isShrinkResources` | `true` (release) |
| ProGuard rules | `android/app/proguard-rules.pro` (Flutter + Gson + `audio_service`) |
| `isDebuggable` | `false` (release) |
| `compileSdk` / `targetSdk` | From Flutter SDK (`flutter.compileSdkVersion` / `flutter.targetSdkVersion`) |
| `applicationId` | `com.qurannoor.app` (not `com.example.*`) |
| Multidex | Rely on Flutter / `minSdk` ≥ 21 default; enable multidex only if build reports limit errors |
| ABI splits | Prefer **AAB** without manual ABI splits; Play serves optimized APKs |

**Versioning:** bump `version:` in `pubspec.yaml` as `major.minor.patch+versionCode` — **increment `versionCode` (+N)** for every Play upload.

---

## 3. Security & privacy (audit summary)

### Permissions (`AndroidManifest.xml`)

| Permission | Rationale |
|------------|-----------|
| `INTERNET` | Prayer API, streaming, tafsir |
| `ACCESS_FINE/COARSE_LOCATION` | Prayer times / Qibla |
| `POST_NOTIFICATIONS` | Android 13+ notifications |
| `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` | Prayer / Adhan alarms — **declare exact alarm use on Play** and complete **Data safety** |
| `RECEIVE_BOOT_COMPLETED` | Reschedule after reboot |
| `WAKE_LOCK` | Notifications / audio |
| `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | Background tilawat (`audio_service`) |

### Exported components

- `MainActivity`: `exported=true` (launcher) — expected.
- `AudioService` / `MediaButtonReceiver`: `exported=true` with media intents — required for media integration; keep `tools:ignore` only where needed for lint.

### Sensitive logging

- API URLs and response bodies in `PrayerService` are gated with `kDebugMode` to reduce production log exposure.

### Play policy tasks (manual)

- **Privacy policy URL** (host a page describing location, notifications, third-party APIs, audio).
- **Data safety form** (location, approximate/precise, alarm APIs).
- **Exact alarms declaration** if required for your target SDK / policy category.
- **Foreground service type** declaration for media playback.

---

## 4. Battery / background / OEM notes

**Validated in code (not a substitute for device QA):**

- Exact alarm scheduling with permission checks and inexact fallback in `PrayerService`.
- Boot receiver entries for `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, and common OEM quick-boot actions.
- Notification channels for pre-alert, Adhan, snooze, tilawat.

**OEM guidance (Honor, Xiaomi, Samsung, Oppo, Huawei):**

- Users may need to **disable battery optimization** / allow **autostart** / **lock app in recents** for reliable Adhan.
- Document this in-app (Help) and optionally in Play listing **“may require disabling battery restrictions for alarms.”**

**Android 13 / 14 / 15:**

- Runtime **notification** permission.
- **Exact alarm** restrictions: handle `canScheduleExactAlarms` / settings intent where applicable.

---

## 5. Crash & stability

- Prefer **no `assert` in production paths**; several `assert(() { debugPrint(...) })` patterns only log in debug — OK.
- Watch **disposed** `ScrollController` / audio after navigation pop.
- Test **notification tap** races when app is killed vs background.

---

## 6. Performance (release checklist)

- Profile **cold start** and **Quran scroll** on a **mid-range** device.
- Monitor **RAM** during background audio + prayer reschedule.
- Avoid unnecessary **rebuilds** (const widgets, provider scope).

---

## 7. Play Store listing (Quran Noor)

| Asset | Guidance |
|-------|------------|
| App name | **Quran Noor** (aligned with `strings.xml` / l10n) |
| Short description | ~80 chars: prayer times, Quran, Adhan, duas, calm UI |
| Full description | Features, languages, **privacy link**, **offline** scope, **alarm disclaimer** |
| Icon | 512×512 + adaptive icon (verify safe zone / monochrome if needed) |
| Feature graphic | 1024×500, brand + tagline |
| Screenshots | Phone + 7" tablet; show Adhan, Quran, settings, notifications |
| Content rating | Religious content, no user-generated public content |
| **Privacy policy** | Required before production |

**Keywords / SEO:** Quran, prayer times, Adhan, Azan, Muslim, Coran, dua, Qibla (locale-specific store listings).

---

## 8. AAB validation command set

```bash
flutter clean
flutter pub get
flutter build appbundle --release
dir build\app\outputs\bundle\release\
jarsigner -verify -verbose -certs build\app\outputs\bundle\release\app-release.aab
```

Internal testing: upload AAB to **internal testing** track, install via Play, verify signing and upgrades.

---

## 9. Remaining risks & recommendations

| Risk | Mitigation |
|------|------------|
| OEM kills alarms | In-app battery guidance; optional full-screen intent for Adhan if policy allows |
| Lost keystore | Offline backups; Play App Signing |
| R8 / plugin regressions | Smoke-test release after each dependency bump |
| `USE_EXACT_ALARM` policy | Ensure Play declaration matches real behavior |

**Future:** Crashlytics / Play pre-launch reports; staged rollout (5% → 100%).

---

## 10. Play Console upload (short)

1. Create app with package **com.qurannoor.app**.
2. Complete **store listing**, **Data safety**, **content rating**, **privacy policy**.
3. Upload **AAB** to internal testing → closed → open production.
4. Enable **Play App Signing** (default for new apps).
5. Increment **versionCode** each release.
