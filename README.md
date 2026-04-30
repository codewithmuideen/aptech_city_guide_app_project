# City Guide Mobile App

A cross-platform Flutter mobile application that lets residents and tourists
discover local attractions, restaurants, hotels and events for a chosen city.
Built as an **Aptech-style eProject** submission.

> Discover your city, one place at a time.

---

## Authors

| Student ID | Full Name                       |
|-----------:|---------------------------------|
| 1599306    | Vincent Biodun Olowokande       |
| 1599738    | Hikmat Adeshewa Raji            |
| 1599290    | Michael Dolapo Obawa            |
| 1424591    | Abdulkhaliq Olayinka Amototo    |

---

## Features

### End-user features
- **Onboarding** — Animated 3-page intro on first launch, never shown again
  after the user taps *Get Started* or *Skip*.
- **Authentication** — Sign up, sign in, forgot password (reset with email +
  new password), secure SHA-256 password hashing, persistent across launches.
- **Personalized Explore screen** — Time-of-day greeting, avatar, quick
  city-switcher pill, a horizontal **Top rated** carousel, category chips
  and a masonry grid of attractions. Shimmer loading skeletons + pull-to-refresh.
- **City selection** — Pick any of the pre-loaded cities; more can be added
  from the admin dashboard. Each city shows a description and hero image.
- **Attraction listings** — Filter by category; sort by rating or name.
- **Premium detail page** — Parallax stretchy hero, floating quick-actions
  card (Route / Call / Website / Review), redesigned info tiles, share to
  clipboard, carousel for multi-image galleries.
- **Maps & directions** — Opens Google Maps (via `url_launcher`) to show a
  pin or route to the attraction from the user's current location.
- **Reviews & ratings** — Bottom-sheet review form with star picker,
  dynamic rating label ("Loved it / Pretty good / ..."), 500-char comment,
  helpful-review likes. Haptic feedback on every interaction.
- **Search** — Keyword search with category filters across the selected city.
- **User profile with stats** — Gradient hero showing avatar + **Reviews /
  Favorites / Cities** counters; view and edit name, email, phone, profile
  photo; manage notifications and dark mode.
- **Favorites** — One-tap heart icon saves an attraction to the user's
  Favorites tab, displayed as a grid with an illustrated empty state.
- **In-app toast notifications** — Custom slide-down toasts respect each
  user's Notifications preference.

### Admin features
- Dedicated **Admin Dashboard** (sign in with the seeded admin account).
- Statistics cards for **users**, **cities**, **attractions** and **reviews**.
- Full CRUD for **Users**:
  create / view / edit / delete; promote or demote admins; reset passwords;
  inspect each user's favorites, notification state, and derived **favorite cities**.
- Full CRUD for **Cities** (with image URL and coordinates).
- Full CRUD for **Attractions** (name, category, description, address,
  phone, website, opening hours, coordinates).
- **Review moderation** — reviews submitted by any signed-in user appear
  in the dashboard stats and in *Manage Reviews* (with reviewer, timestamp,
  stars, helpful count, and a Delete action). Pull down or tap Refresh to
  re-read from storage.

### Non-functional
- Runs offline — all data persisted locally with `shared_preferences`.
- Material 3 theme, Google-Fonts-ready typography, dark / light mode.
- Responsive layout: `MasonryGridView` on wide screens, list on narrow.
- Robust form validation and error messages.

---

## Tech stack

| Layer            | Library                               |
|------------------|---------------------------------------|
| Language         | Dart (Flutter SDK 3.10+)              |
| UI               | Material 3, custom theme              |
| State mgmt       | `provider`                            |
| Local persistence| `shared_preferences` (JSON-encoded)   |
| Images           | `cached_network_image`                |
| Ratings          | `flutter_rating_bar`                  |
| Carousel         | `carousel_slider`                     |
| Grid             | `flutter_staggered_grid_view`         |
| Dates            | `intl`                                |
| Password hashing | `crypto` (SHA-256)                    |
| External links   | `url_launcher` (maps, phone, web)     |

---

## Folder structure

```
city_guide_app/
├── android/ ios/ web/         # platform folders (bootstrapped by `flutter create`)
├── assets/
│   ├── icons/app_logo.svg     # brand mark
│   └── images/
├── docs/
│   ├── PROJECT_REPORT.md
│   ├── INSTALLATION.md
│   └── USER_GUIDE.md
├── lib/
│   ├── main.dart              # App entry, MultiProvider setup, theming
│   ├── data/
│   │   └── sample_data.dart   # Seed cities, attractions, admin user
│   ├── models/                # AppUser, City, Attraction, Review
│   ├── providers/             # AuthProvider, CityProvider, ThemeProvider
│   ├── services/              # AuthService, StorageService
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── auth/              # login, register, forgot_password
│   │   ├── home/              # home_screen (tabs), city_selection
│   │   ├── attractions/       # attraction_list, attraction_detail
│   │   ├── search/            # search_screen
│   │   ├── profile/           # profile, edit_profile
│   │   ├── map/               # map_screen (opens external maps)
│   │   └── admin/             # dashboard, manage_cities, manage_attractions, manage_reviews
│   ├── utils/                 # app_theme, constants, validators
│   └── widgets/               # app_logo, attraction_card, city_card, review_tile, custom_text_field
├── pubspec.yaml
└── README.md
```

---

## Running the app

### 1. Install Flutter
Requires Flutter **3.10 or newer**. Install from <https://docs.flutter.dev/get-started/install>.
Verify:
```bash
flutter --version
flutter doctor
```

### 2. Bootstrap platform folders
(The repo only ships the `lib/`, `assets/`, `docs/` and `pubspec.yaml` —
platform folders are created on your machine.)
```bash
cd city_guide_app
flutter create . --project-name city_guide_app --org com.eproject.cityguide
```

### 3. Install dependencies
```bash
flutter pub get
```

### 4. Run

**Android / iOS / Desktop:**
```bash
flutter run
```

**Web (recommended for quick evaluation):**
```bash
flutter run -d chrome --web-port=8080
```
> **Always pass `--web-port=8080`** (or any fixed port) when running on
> Chrome. Browser localStorage is scoped by origin, so a random port on
> each run creates a fresh, empty bucket - accounts and reviews appear to
> "disappear" between sessions. A fixed port keeps all your data across
> launches.

### 5. Demo accounts

| Role  | Email                   | Password   |
|-------|-------------------------|------------|
| Admin | `admin@cityguide.com`   | `Admin@123`|
| User  | create via **Sign Up**  | -          |

---

## Documentation

Every doc ships in both Markdown and Word (.docx) form:

| Document            | Markdown                                           | Word                                                 |
|---------------------|----------------------------------------------------|------------------------------------------------------|
| Project report      | [PROJECT_REPORT.md](docs/PROJECT_REPORT.md)        | [PROJECT_REPORT.docx](docs/PROJECT_REPORT.docx)      |
| Installation guide  | [INSTALLATION.md](docs/INSTALLATION.md)            | [INSTALLATION.docx](docs/INSTALLATION.docx)          |
| User guide          | [USER_GUIDE.md](docs/USER_GUIDE.md)                | [USER_GUIDE.docx](docs/USER_GUIDE.docx)              |
| README              | [README.md](README.md)                             | [docs/README.docx](docs/README.docx)                 |

### Regenerating the Word docs after you edit markdown
```bash
pip install python-docx
python tool/generate_docs.py
```

### Regenerating launcher icons from the in-app logo
```bash
flutter run -d windows --target=tool/generate_icons.dart   # writes assets/icons/app_logo.png
dart run flutter_launcher_icons                            # Android / iOS / web / Windows
```

---

## License

Academic eProject submission - not for commercial distribution.
