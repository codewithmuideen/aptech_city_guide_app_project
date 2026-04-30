# City Guide Mobile Application
## eProject Report

---

### Cover Page

| | |
|---|---|
| **Project title** | City Guide Mobile Application |
| **Platform** | Android / iOS (Flutter, Dart) |
| **Project type** | Aptech-style eProject submission |
| **Version** | 1.0.0 |
| **Academic year** | 2025 / 2026 |

### Team Members

| Student ID | Full Name                       | Role                                  |
|-----------:|---------------------------------|---------------------------------------|
| 1599306    | Vincent Biodun Olowokande       | Team Lead, Architecture, Admin module |
| 1599738    | Hikmat Adeshewa Raji            | UI / UX Design, Authentication module |
| 1599290    | Michael Dolapo Obawa            | Attractions, Reviews, Search module   |
| 1424591    | Abdulkhaliq Olayinka Amototo    | Data layer, Documentation, Testing    |

---

## 1. Acknowledgement
We thank the Aptech eProjects team for the opportunity to apply our
classroom knowledge of Dart and Flutter to a real-world mobile application.
We are grateful to our faculty mentors for guidance on architecture,
usability and documentation, and to all testers who provided feedback on
the beta builds.

## 2. Abstract
City Guide is a cross-platform Flutter mobile application that serves as an
all-in-one digital travel companion for residents and tourists. It provides
quick access to a curated catalogue of attractions, restaurants, hotels and
events in a selected city, together with ratings, reviews, rich imagery,
contact information and directions. An administrator role allows content to
be maintained through an in-app dashboard. The app is fully offline-capable,
storing all data on the device, and ships with a clean Material 3 interface
that supports both light and dark themes.

## 3. Objectives
The project was undertaken to:

1. Build a production-quality Flutter mobile application that demonstrates
   mastery of Dart, Flutter widgets, state management and local persistence.
2. Deliver the functional and non-functional requirements specified in the
   eProject brief (authentication, city browsing, attractions, detailed
   information, maps, reviews, search, profile, admin dashboard).
3. Produce complete technical documentation — README, project report,
   installation guide and user guide — suitable for evaluation.
4. Apply SDLC best practices: requirements analysis, modular design,
   implementation, testing and documentation.

## 4. Problem Statement
Tourists and even long-time residents often struggle to discover the best
attractions, restaurants and events in a city. Printed guides are out of
date, web pages fragmented, and mobile solutions are typically city- or
country-specific. There is a need for a lightweight, extensible mobile
application that:

- groups attractions by city,
- surfaces ratings and reviews from real users,
- offers directions without requiring heavy external apps,
- and can be maintained by a non-technical administrator from within the
  product itself.

## 5. Scope
### In-scope
- Android and iOS phones (Flutter target).
- Regular-user flows: registration, login, exploration, search, reviews,
  favorites, profile.
- Admin flows: city / attraction / review CRUD.
- Offline-first data layer seeded with 4 cities and 9 attractions.

### Out-of-scope
- Online payments or booking integrations.
- Multi-language / RTL localization (only English).
- Server-side backend (the app uses on-device storage; swapping in a REST
  backend is a documented future extension).

## 6. Software Requirements Specification (SRS)

### 6.1 Functional requirements (traceability matrix)

| ID   | Requirement                                                     | Implemented in                                 |
|------|-----------------------------------------------------------------|------------------------------------------------|
| FR-1 | Users can create an account                                     | `screens/auth/register_screen.dart`            |
| FR-2 | Users can log in securely                                       | `screens/auth/login_screen.dart` + SHA-256 hash |
| FR-3 | Password reset                                                  | `screens/auth/forgot_password_screen.dart`     |
| FR-4 | Browse and select a city                                        | `screens/home/city_selection_screen.dart`      |
| FR-5 | City details (name, description, image)                         | `widgets/city_card.dart` + sample data         |
| FR-6 | Attraction listings (name, image, description, phone, hours)    | `screens/attractions/attraction_list_screen.dart` |
| FR-7 | Filter / sort by category and rating                            | `CityProvider.filterSort`                      |
| FR-8 | Detailed attraction view with gallery and website link          | `screens/attractions/attraction_detail_screen.dart` |
| FR-9 | Integrated map and directions                                   | `screens/map/map_screen.dart` (external Google Maps) |
| FR-10| Leave reviews and ratings                                       | `_showReviewDialog` in attraction detail       |
| FR-11| Like helpful reviews                                            | `CityProvider.toggleLikeReview`                |
| FR-12| Keyword search with filters                                     | `screens/search/search_screen.dart`            |
| FR-13| Edit profile; manage notifications & favorites                  | `screens/profile/*`                            |
| FR-14| Admin dashboard — CRUD attractions, events, reviews             | `screens/admin/*`                              |
| FR-15| Admin CRUD for users (add / view / edit / delete / admin flag)  | `screens/admin/manage_users.dart`              |
| FR-16| Admin can see each user's favorite cities (derived)             | `_favoriteCities()` in `manage_users.dart`     |

### 6.2 Non-functional requirements

| ID    | Requirement            | How satisfied                                                                 |
|-------|------------------------|-------------------------------------------------------------------------------|
| NFR-1 | Responsiveness (1-2 s) | `provider`-driven reactive UI, cached images, no blocking operations on UI.   |
| NFR-2 | Loading time           | No remote fetch on startup; local JSON store.                                 |
| NFR-3 | User interface         | Material 3, consistent card shapes, rounded corners, accessible contrast.     |
| NFR-4 | Accessibility          | Native Flutter semantics, scalable type, high-contrast colors.                |
| NFR-5 | User friendliness      | Bottom-nav, floating action buttons, clear error messages, empty-state copy.  |
| NFR-6 | Operability / reliability | All I/O wrapped in async + await; form validators on every input.          |
| NFR-7 | Error handling         | Validators, SnackBar error feedback, defensive null checks.                   |
| NFR-8 | Scalability            | Layered architecture (provider / service / storage) allows swap to REST API.  |
| NFR-9 | Security               | SHA-256 password hashing, admin-gated screens, auth-required features.        |
| NFR-10| Documentation          | README, project report, installation, user guide.                             |
| NFR-11| Video                  | Recorded demo to be submitted alongside report.                               |

### 6.3 Use-case summary
- **UC-01 Register** - new visitor creates an account.
- **UC-02 Login / Logout** - existing user authenticates.
- **UC-03 Reset password** - user provides email + new password.
- **UC-04 Select city** - user chooses any of the available cities.
- **UC-05 Browse attractions** - user filters and sorts listings.
- **UC-06 View details** - user reads full info, opens map or website.
- **UC-07 Submit review** - user rates & comments on an attraction.
- **UC-08 Search** - user looks for a specific place.
- **UC-09 Admin: CRUD city** - admin adds / edits / removes cities.
- **UC-10 Admin: CRUD attraction** - admin maintains catalogue.
- **UC-11 Admin: moderate reviews** - admin removes offensive content.
- **UC-12 Admin: CRUD users** - admin creates, updates, promotes, or deletes user accounts.
- **UC-13 Admin: audit user activity** - admin reviews each user's favorites and derived favorite cities.

## 7. System Design

### 7.1 High-level architecture
```
          +-------------+      +------------------+
 Widgets  |  Screens    | ---> |  Providers       |  (ChangeNotifier + provider pkg)
          +-------------+      +------------------+
                                      |
                                      v
                              +------------------+
                              |  Services        |  (AuthService, StorageService)
                              +------------------+
                                      |
                                      v
                              +------------------+
                              |  shared_preferences (JSON persistence) |
                              +------------------+
```

The layered design keeps UI code free of persistence concerns and allows
the data source to be swapped (e.g. to a REST backend) without touching
screens.

### 7.2 Entity-relationship diagram
```
AppUser (id, name, email, passwordHash, phone, isAdmin, favorites[], notifications)
  |
  | 1 - *
  v
Review (id, attractionId, userId, userName, rating, comment, createdAt, likedBy[])
  ^
  | * - 1
  |
Attraction (id, cityId, name, category, description, image, gallery[],
            address, phone, website, hours, lat, lng)
  |
  | * - 1
  v
City (id, name, country, description, image, lat, lng)
```

### 7.3 Screen navigation
```
SplashScreen
   |
   +--> LoginScreen ---(register)---> RegisterScreen
   |        |
   |        +--(forgot)--> ForgotPasswordScreen
   |
   +--> HomeScreen (tabs: Explore | Search | Favorites | Profile)
   |        |
   |        +--> CitySelectionScreen
   |        +--> AttractionListScreen --> AttractionDetailScreen
   |        |                                      |
   |        |                                      +--> MapScreen (list + external maps)
   |        +--> SearchScreen
   |        +--> ProfileScreen --> EditProfileScreen
   |
   +--> AdminDashboard (admin role)
            |
            +--> ManageCitiesScreen
            +--> ManageAttractionsScreen
            +--> ManageReviewsScreen
```

## 8. Implementation Highlights
- **Provider-based state** keeps UI declarative and easy to test.
- **Seeded offline data** means the reviewer can run the app immediately
  with 4 cities and 9 curated attractions.
- **Custom `AppLogo` painter** renders the brand mark natively in Flutter
  without any SVG dependency, and a matching `app_logo.svg` is included for
  store-listing assets.
- **SHA-256 password hashing** via `crypto`.
- **External maps integration** uses `url_launcher` to hand-off to Google
  Maps for pins and directions - no Google Maps API key required, which
  simplifies evaluator setup.

## 9. Testing

### 9.1 Strategy
Manual black-box testing covering every functional requirement, plus
targeted form-level validation checks. Flutter's built-in widget test
harness can be extended; the included smoke test in `test/` verifies the
app boots and renders the splash screen.

### 9.2 Sample test cases

| # | Test case                        | Steps                                       | Expected                          | Result |
|---|----------------------------------|---------------------------------------------|-----------------------------------|--------|
| 1 | Register with existing email     | Enter an email that already exists          | Error "account exists"            | Pass   |
| 2 | Login with wrong password        | Enter a valid email but wrong password      | Error "Invalid email or password" | Pass   |
| 3 | Category filter                  | Choose "Restaurant"                         | Only restaurants shown            | Pass   |
| 4 | Sort by name                     | Sort menu > Name                            | List ordered A-Z                  | Pass   |
| 5 | Leave review                     | Rate, type comment, submit                  | Appears at top of reviews list    | Pass   |
| 6 | Like review                      | Tap thumbs-up                               | Count increments, icon filled     | Pass   |
| 7 | Toggle favorite                  | Tap heart                                   | Shows in Favorites tab            | Pass   |
| 8 | Admin delete city                | Admin > Manage Cities > delete              | City and its attractions removed  | Pass   |
| 9 | Dark mode                        | Profile > Dark Mode on                      | Dark theme applied app-wide       | Pass   |
| 10| Directions                       | Attraction > Directions                     | External Google Maps opens        | Pass   |

## 10. Future Enhancements
- Replace local store with a Firebase / REST backend for real-time sync.
- Add Google Sign-In and social login.
- Internationalisation (i18n) for English, French, Spanish, Yoruba.
- Push notifications for nearby events using `firebase_messaging`.
- Booking integrations (hotels, tickets) via partner APIs.
- In-app camera upload for review photos.

## 11. Conclusion
The City Guide eProject successfully delivers every functional and
non-functional requirement specified in the brief. It applies sound mobile
design principles, a clean layered architecture, and a complete admin /
user experience — demonstrating the team's practical command of Dart and
Flutter.

---

### Appendix A - Directory Listing
See `README.md` > *Folder structure* section.

### Appendix B - Demo Credentials
| Role  | Email                 | Password   |
|-------|-----------------------|------------|
| Admin | `admin@cityguide.com` | `Admin@123`|
| User  | create via **Sign Up**| -          |
