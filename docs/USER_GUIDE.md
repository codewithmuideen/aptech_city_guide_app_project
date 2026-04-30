# City Guide - User Guide

A feature-by-feature walk-through of the City Guide mobile application for
both end users and administrators.

---

## 1. Getting started

1. Launch the app. The splash screen displays the City Guide logo.
2. **First launch**: three intro screens appear (*Discover / Eat-Stay-Explore
   / Share*). Swipe through, then tap **Get Started** (or **Skip** on any
   page). You won't see these again.
3. You are taken to **Login**.
4. First time here? Tap **Sign Up** to create an account.
5. Already registered? Enter your email and password and tap **Login**.

### Demo accounts
| Role  | Email                   | Password    |
|-------|-------------------------|-------------|
| Admin | `admin@cityguide.com`   | `Admin@123` |
| User  | Any account you sign up | -           |

---

## 2. Creating an account

1. From the login screen tap **Sign Up**.
2. Enter **Full Name**, **Email**, **Phone**, **Password** and
   **Confirm Password**.
3. Tap **Sign Up**. On success, you land on the Home tab.

> Passwords must be at least 6 characters. Emails must be unique across the app.

---

## 3. Forgot password

1. From login, tap **Forgot Password?**.
2. Enter the email you registered with plus a new password.
3. Tap **Reset Password**. You'll be returned to login to sign in with the new password.

---

## 4. Choosing a city

- The first time you log in, the **Select a City** sheet opens automatically.
- Tap any city card to choose it. The app remembers your selection.
- Change city any time via the *city* icon in the Explore app bar.

---

## 5. Exploring attractions

### Explore tab
- **Greeting header**: avatar + time-of-day greeting (*Good morning / afternoon
  / evening*) + current-city pill (tap it to switch cities).
- **Top rated carousel**: horizontal row of the highest-rated attractions
  in the current city (tap *View on map* to see them all on the map).
- Category chips: **All / Attraction / Restaurant / Hotel / Event**.
- Sort menu: **Rating** or **Name**.
- Masonry grid of all places in the city.
- **Pull down** to refresh.

### Attraction detail (redesigned)
- **Parallax hero** image at the top that stretches when pulled.
- Rounded glass **Favorite** and **Share** icons (share copies info to clipboard).
- Floating **Quick actions** card right under the hero:
  - **Route** - opens Google Maps for directions
  - **Call** - dials the attraction's phone
  - **Website** - opens in the browser
  - **Review** - opens a bottom sheet to post a review
- **About** section with full description.
- **Info** section with colored icon tiles (Address, Phone, Hours, Website).
- **Reviews** list with avatars, star rating, helpful-count and a
  "Write a review" button.

### Writing a review (bottom sheet)
1. Tap **Review** (quick-action or the "Write a review" button).
2. A bottom sheet slides up with a large star picker and a dynamic label
   (*Loved it / Pretty good / It was okay / Disappointing / Awful*).
3. Write up to 500 characters, tap **Post review**.
4. A slide-down toast confirms it was saved.

---

## 6. Map & directions

- From any attraction list, tap the map icon in the app bar to see a
  numbered list of all locations.
- Tap the pin icon on a row to **view on Google Maps**.
- Tap the directions icon to **start turn-by-turn directions** in Google
  Maps from your current position.

---

## 7. Writing a review

1. Open an attraction's detail page.
2. Tap **Review**.
3. Pick a star rating (half-stars supported).
4. Enter a comment.
5. Tap **Submit**. Your review appears at the top of the list.

### Liking helpful reviews
- Tap the thumbs-up on any review to mark it helpful.

---

## 8. Search

- Go to the **Search** tab.
- Type at least one character to filter matching names, descriptions and addresses.
- Combine with a category chip to narrow results.
- Tap any card to open the attraction's detail page.

---

## 9. Favorites

- Tap the heart icon on any attraction card (or detail page) to add it to your favorites.
- Open the **Favorites** tab to see all saved attractions.
- Tap the filled heart in the list to remove an item.

---

## 10. Profile

The Profile tab opens with a **gradient hero** showing your avatar, name,
email, admin badge (if any), and a stats row:

- **Reviews** you've posted
- **Favorites** you've saved
- **Cities** you've explored (derived from favorite attractions)

Below the hero:

| Action                     | How                                      |
|----------------------------|-------------------------------------------|
| Edit your name / email / phone / photo | *Profile > Edit Profile*      |
| Toggle notifications       | *Profile > Notifications*                 |
| Toggle dark mode           | *Profile > Dark Mode*                     |
| View app info / credits    | *Profile > About*                         |
| Sign out                   | *Profile > Sign out*                      |

### Profile photo
Tap **Edit Profile**, then tap the camera badge over the avatar. Pick an
image from your gallery; it's saved (as base64) right next to your other
profile data.

---

## 11. Administrator workflows

Log in as `admin@cityguide.com` / `Admin@123` to reach the **Admin Dashboard**.

### 11.1 Dashboard at a glance
- **Gradient hero header** showing the admin avatar, name, and four
  *glass* stat tiles: **Users / Cities / Places / Reviews**.
- Three round buttons in the header:
  - **Dark / Light mode** toggle (switches the whole admin theme)
  - **Refresh** (re-reads stats from storage)
  - **Sign out** (always opens a confirmation dialog - "Sign out? You
    will need to log in again." with Cancel / Sign out)
- Below the hero: **Management** section with four colored tiles.
- **Pull down** anywhere on the dashboard to refresh.

### 11.2 Manage Users
1. **View**: each row shows the user's avatar, name, email, phone, badges
   (ADMIN / YOU), number of favorites, notification state, and derived
   **favorite cities** (cities in which the user has at least one favorite
   attraction).
2. **Add**: tap **+ Add User** (bottom-right or app bar). Fill name, email,
   phone, password, and flip the Administrator switch if needed.
3. **Edit**: open the popup menu on any row and pick **Edit user** - you
   can also set a new password here (leave blank to keep the current one).
4. **Promote / demote**: popup menu > **Make admin** / **Revoke admin**.
   You cannot change your own admin status.
5. **Delete**: popup menu > **Delete user**. You cannot delete yourself.

### 11.3 Manage Cities
1. **Add**: tap **+ Add City** (bottom-right FAB or `+` icon in the app bar).
2. Fill name, country, description, coordinates.
3. **Image**: tap the dashed image area to **pick a photo from your
   device** (gallery on phone, file dialog on web/desktop). Or paste an
   image URL in the text field below. The image preview updates instantly,
   with **Change** and **Remove** buttons overlaid on the photo.
4. Save.
5. **Edit**: tap the pencil on any row.
6. **Delete**: tap the trash icon. This also removes the city's attractions.

### 11.4 Manage Attractions
1. **Add**: tap **+ Add Attraction** (FAB or app-bar icon).
2. Pick a **City** and a **Category**, fill in details, coordinates.
3. **Image**: same picker as cities - tap to choose a file from your
   device, or paste a URL.
4. Save.
5. **Edit**: tap the pencil on any row.
6. **Delete**: tap the trash. This also removes the attraction's reviews.

> Photos picked from a device are stored as base64 data URLs inside the
> same `imageUrl` field, so the rest of the app (cards, hero, detail page)
> renders them transparently.

### 11.5 Manage Reviews
- Full list of reviews, newest first. Each entry shows the reviewer's
  avatar, name, the attraction reviewed, date/time, stars, comment, and
  helpful count.
- Pull down or tap the refresh icon to re-read from storage.
- Tap **Delete** under any review to remove offensive or inappropriate content.

### 11.6 Logging out
Tap the **Sign out** circle in the top-right of the gradient hero. A
confirmation dialog asks *"Sign out? You will need to log in again to
access the admin dashboard."* with **Cancel** and **Sign out** buttons.
The same confirmation now appears for regular users when they sign out
from the Profile tab.

### 11.7 Where the data lives
All data is persisted on-device via `shared_preferences` (JSON). When
someone signs up or submits a review on **this** device and browser, admin
sees it in the next refresh. The app has no backend, so there is no
cross-device syncing out of the box.

Seeding is **additive**: the app never overwrites existing users, reviews
or favorites. Seed records are only filled in for any `id` that is missing.

### 11.8 Web-specific persistence note
On Chrome the data lives in **localStorage**, which is keyed by the exact
origin (scheme + host + port). Flutter picks a random port by default, so
always launch the app with a fixed port:

```bash
flutter run -d chrome --web-port=8080
```

This keeps every run pointing at the same storage bucket.

---

## 12. Tips & troubleshooting

| Issue                                   | Tip                                                          |
|-----------------------------------------|--------------------------------------------------------------|
| Images don't load                       | Check your internet connection - images come from Unsplash.  |
| Directions do not open                  | Make sure Google Maps or a browser is installed.             |
| Can't find an attraction                | Change the city from the Explore app bar.                    |
| Want to test as a fresh user            | Use the Sign Up flow with a different email.                 |
| Forgot admin credentials                | See `lib/utils/constants.dart`.                              |

---

## 13. Authors

| Student ID | Full Name                    |
|-----------:|------------------------------|
| 1599306    | Vincent Biodun Olowokande    |
| 1599738    | Hikmat Adeshewa Raji         |
| 1599290    | Michael Dolapo Obawa         |
| 1424591    | Abdulkhaliq Olayinka Amototo |
