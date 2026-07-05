# Smart Travel Planner

A Mobile Cloud Computing group project for ITT632.

Smart Travel Planner is a cross-platform mobile application built with Flutter that helps users plan trips, create day-by-day itineraries, check destination weather, discover tourist attractions, view country information, and track travel budgets. The system integrates multiple cloud services and uses a custom Node.js + Express backend API with a MySQL database.

---

## Project Description


| Component            | Technology                                |
| -------------------- | ----------------------------------------- |
| Mobile Application   | Flutter 3.35.6 (Android / iOS)            |
| In-House Backend API | Node.js v22.14.0 + Express.js             |
| Backend Database     | MySQL 8.x                                 |
| User Authentication  | Firebase Authentication (Free Spark Plan) |
| Cloud Data Storage   | Firebase Firestore (Free Spark Plan)      |
| Weather Forecast     | Open-Meteo API (Free, no key required)    |
| Tourist Attractions  | OpenTripMap API (Free tier)               |
| Country Information  | RestCountries API (Free, no key required) |


---



## Standard Versions

> All team members must use these exact versions for this project to ensure consistency.


| Tool       | Required Version              |
| ---------- | ----------------------------- |
| Flutter    | 3.35.6                        |
| Node.js    | v22.14.0                      |
| Express.js | Locked by `package-lock.json` |
| MySQL      | 8.x                           |


---



## Project Folder Structure

```
smart_travel_planner/
├── mobile_flutter/       # Flutter mobile application
├── backend_express/      # Node.js + Express REST API
├── docs/                 # Project documentation
├── postman/              # Postman API collection
├── README.md
└── .gitignore
```


| Folder             | Contents                                                               |
| ------------------ | ---------------------------------------------------------------------- |
| `mobile_flutter/`  | Flutter app source code, `pubspec.yaml`, `pubspec.lock`                |
| `backend_express/` | Express API source code, `package.json`, `package-lock.json`, `.nvmrc` |
| `docs/`            | System architecture document, API docs, database design, report draft  |
| `postman/`         | Exported Postman collection for API testing                            |


---



## Before Installation: Check Your Versions First

Before installing anything, check what versions you already have.

```bash
flutter --version
node -v
mysql --version
```

- If Flutter is already **3.35.6**, you can skip FVM setup and use Flutter directly.
- If Flutter is a **different version**, use FVM to manage the project version without changing your global Flutter installation.
- If Node.js is already **v22.14.0**, you can skip nvm setup and use Node.js directly.
- If Node.js is a **different version**, use nvm to switch versions without affecting your other projects or FYP.

> **Important:** Do not permanently change your global Flutter or Node.js version. It may break your own Final Year Project. Use FVM and nvm instead.

---



## Flutter Setup



### Option A — If your Flutter version is already 3.35.6

```bash
cd mobile_flutter
flutter pub get
flutter run
```

---



### Option B — If your Flutter version is NOT 3.35.6

Use **FVM (Flutter Version Manager)** to run Flutter 3.35.6 for this project only without changing your global version.

**Step 1: Install FVM**

```bash
dart pub global activate fvm
```

**Step 2: Set up Flutter 3.35.6 for this project**

```bash
cd mobile_flutter
fvm install 3.35.6
fvm use 3.35.6
```

**Step 3: Install Flutter packages**

```bash
fvm flutter pub get
```

**Step 4: Run the app**

```bash
fvm flutter run
```

**Step 5: Verify the Flutter version used**

```bash
fvm flutter --version
```

> **IDE Note:** If you use VS Code or Android Studio, point the Flutter SDK path to:
>
> ```
> mobile_flutter/.fvm/flutter_sdk
> ```
>
> This ensures the IDE uses Flutter 3.35.6 for this project instead of your global version.

---



## Node.js + Express Backend Setup



### Option A — If your Node.js version is already v22.14.0

```bash
cd backend_express
npm install
npm run dev
```

---



### Option B — If your Node.js version is NOT v22.14.0

Use **nvm (Node Version Manager)** to run Node.js v22.14.0 for this project only without changing your global version.

The `backend_express/` folder includes a `.nvmrc` file containing `22.14.0`. Running `nvm use` inside the folder will automatically switch to the correct version.

---



#### Windows (nvm-windows)

Download and install nvm-windows from:

1. [https://github.com/coreybutler/nvm-windows/releases](https://github.com/coreybutler/nvm-windows/releases)
2. Assets ---> nvm-setup.exe

Then run:

```bash
cd backend_express
nvm install 22.14.0
nvm use 22.14.0
node -v
npm install
npm run dev
```

---



#### macOS / Linux (nvm)

Install nvm if not already installed:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

Restart your terminal, then run:

```bash
cd backend_express
nvm install 22.14.0
nvm use 22.14.0
node -v
npm install
npm run dev
```

---



## MySQL Setup

The Express backend uses MySQL 8.x as its database.

**Step 1: Start your local MySQL server**

Make sure MySQL 8.x is running on your machine.

**Step 2: Create the database**

Open MySQL and run:

```sql
CREATE DATABASE smart_travel_planner;
```

**Step 3: Run migrations**

Navigate to `backend_express/database/migrations/` and run the SQL files in order against your `smart_travel_planner` database:

```
001_create_users_table.sql
002_create_destinations_table.sql
003_create_trips_table.sql
004_create_itineraries_table.sql
005_create_itinerary_items_table.sql
006_create_expenses_table.sql
007_create_admin_logs_table.sql
```

**Step 4: Update your** `.env` **file with your MySQL credentials**

See the [Backend Environment File](#backend_environment-file) section below.

---



## Backend Environment File

Copy the example environment file and fill in your local values:

**macOS / Linux:**

```bash
cd backend_express
cp .env.example .env
```

**Windows PowerShell:**

```powershell
cd backend_express
Copy-Item .env.example .env
```

Open `.env` and update the values:

```env
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_NAME=smart_travel_planner
DB_USER=root
DB_PASSWORD=
FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=
OPENTRIPMAP_API_KEY=
```

> **Do not commit your** `.env` **file.** It is listed in `.gitignore`. Never put real credentials in `README.md` or any committed file.

---



## Running the Backend

```bash
cd backend_express
npm run dev
```

The server will start at:

```
http://localhost:3000
```

API base URL:

```
http://localhost:3000/api
```

---



## Connecting Flutter to the Local Backend

The Flutter app needs to know the backend URL. Update `mobile_flutter/lib/config/app_config.dart` with the correct address.

**Android Emulator:**

```
http://10.0.2.2:3000/api
```

The Android emulator uses `10.0.2.2` to reach `localhost` on the host machine.

**Real Android Phone:**

Your phone and your laptop must both be connected to the **same Wi-Fi network**.

Find your laptop's local IP address:

- **Windows:** Run `ipconfig` in Command Prompt. Look for `IPv4 Address`.
- **macOS / Linux:** Run `ifconfig` in Terminal. Look for `inet` under your Wi-Fi adapter.

Then use:

```
http://192.168.x.x:3000/api
```

Replace `192.168.x.x` with your actual laptop IP address.

> **Make sure the Express server is listening on** `0.0.0.0` **in** `app.js`**:**
>
> ```javascript
> app.listen(3000, '0.0.0.0', () => {
>   console.log('Server running on port 3000');
> });
> ```

---



## Firebase Setup

1. Go to [https://console.firebase.google.com](https://console.firebase.google.com) and create a new project.
2. Enable **Firebase Authentication** and turn on the **Email/Password** sign-in method.
3. Enable **Firestore Database** if you are using it for profile metadata.
4. Add your Flutter app to the Firebase project (Android and/or iOS).
5. Download `google-services.json` (Android) and place it in `mobile_flutter/android/app/`.
6. Run FlutterFire CLI to generate `firebase_options.dart`:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

1. For the Express backend, generate a **Firebase Admin SDK private key** from Project Settings → Service Accounts. Save the values in `backend_express/.env`.

> **Do not commit any Firebase private keys or** `google-services.json` **to the repository.**

---



## External API Setup


| API           | Key Required | Where to Configure                                                                                 |
| ------------- | ------------ | -------------------------------------------------------------------------------------------------- |
| Open-Meteo    | No           | No setup required                                                                                  |
| RestCountries | No           | No setup required                                                                                  |
| OpenTripMap   | Yes (Free)   | Register at [https://opentripmap.io](https://opentripmap.io) and add key to `backend_express/.env` |


---



## Useful Commands



### Flutter

```bash
# Check Flutter version
flutter --version

# Install packages
flutter pub get

# Run the app
flutter run

# Build Android APK
flutter build apk --release
```

**With FVM:**

```bash
fvm flutter --version
fvm flutter pub get
fvm flutter run
fvm flutter build apk --release
```

---



### Node.js + Express

```bash
# Check Node.js version
node -v

# Install packages
npm install

# Run in development mode (with auto-restart)
npm run dev

# Run in production mode
npm start
```

---



### MySQL

```bash
# Check MySQL version
mysql --version

# Log in to MySQL
mysql -u root -p
```

---



## Git Branch Strategy



### Main Branches


| Branch    | Purpose                                                                |
| --------- | ---------------------------------------------------------------------- |
| `main`    | Stable final submission. Only merge here when the project is complete. |
| `develop` | Active development. All feature branches merge into this.              |




### Feature Branches


| Branch                    | Owner      |
| ------------------------- | ---------- |
| `feature/flutter-ui`      | Member 1   |
| `feature/trip-planner-ui` | Member 1   |
| `feature/itinerary-ui`    | Member 1   |
| `feature/express-api`     | Member 2   |
| `feature/trip-crud-api`   | Member 2   |
| `feature/budget-api`      | Member 2   |
| `feature/admin-api`       | Member 2   |
| `feature/firebase-auth`   | Member 3   |
| `feature/weather-api`     | Member 3   |
| `feature/attraction-api`  | Member 3   |
| `feature/country-api`     | Member 3   |
| `feature/mysql-database`  | Member 4   |
| `feature/testing`         | Member 4   |
| `feature/deployment`      | Member 4   |
| `fix/bug-name`            | Any member |




### Branch Rules

- Always create feature branches from `develop`, not `main`.
- Commit regularly with clear and descriptive commit messages.
- Open a pull request into `develop` when a feature is ready.
- Have at least one other member review the pull request before merging.
- Only merge into `main` for the final stable submission.

---



## Team Member Responsibilities

> All team members are assigned coding tasks.


| Member       | Responsibilities                                                                                              |
| ------------ | ------------------------------------------------------------------------------------------------------------- |
| **Member 1** | Flutter UI, home screen, trip list, create trip screen, itinerary screen, navigation, reusable widgets        |
| **Member 2** | Express API setup, trip CRUD, itinerary API, expense/budget API, admin API, middleware, validation            |
| **Member 3** | Firebase Authentication in Flutter, Firestore service, Open-Meteo API, OpenTripMap API, RestCountries API     |
| **Member 4** | MySQL migrations, seeders, model query functions, Postman testing, environment setup, bug fixing, screenshots |


---



## Troubleshooting



### Flutter version is different from 3.35.6

Use FVM. See [Flutter Setup — Option B](#option-b--if-your-flutter-version-is-not-3356) above.

---



### Node.js version is different from v22.14.0

Use nvm or nvm-windows. See [Node.js + Express Backend Setup — Option B](#option-b--if-your-nodejs-version-is-not-v221400) above.

---



### `npm install` fails or throws errors

1. Check your Node.js version:

```bash
node -v
```

It must be `v22.14.0`. If not, switch using nvm.

1. Delete `node_modules` and reinstall:

```bash
rm -rf node_modules
npm install
```

> **Warning:** Do not delete `package-lock.json` unless the whole team agrees to update dependencies. It is committed to the repository to lock versions for all members.

---



### Flutter app cannot connect to the Express backend

Go through this checklist:

- Is the Express server running? Check your terminal for `Server running on port 3000`.
- Are you using `http://10.0.2.2:3000/api` for the **Android emulator**?
- Are you using the correct **laptop IP address** for a real device?
- Are your phone and laptop connected to the **same Wi-Fi**?
- Is `app.js` listening on `0.0.0.0` instead of `127.0.0.1`?
- Is your **firewall** blocking port 3000? Try temporarily disabling it or adding a rule to allow port 3000.

---



### MySQL connection error in Express

Go through this checklist:

- Is the MySQL service running on your machine?
- Are `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, and `DB_NAME` correct in your `.env` file?
- Does the `smart_travel_planner` database exist? Run `SHOW DATABASES;` in MySQL to check.
- Have you run the SQL migration files to create the tables?

---



### `fvm` command not found after installing

After installing FVM with `dart pub global activate fvm`, you may need to add the Dart pub global bin to your system PATH.

**Windows:** Add `%APPDATA%\Pub\Cache\bin` to your system PATH environment variable.

**macOS / Linux:** Add the following to your shell profile (`.bashrc`, `.zshrc`, etc.):

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

Then restart your terminal.

---



## Important Notes


| Rule                                                  | Detail                                                                                               |
| ----------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| **Do NOT commit** `.env`                              | The `.env` file contains secrets. It is in `.gitignore`.                                             |
| **Do NOT commit API keys in code**                    | Store all API keys in `.env` only.                                                                   |
| **DO commit** `pubspec.lock`                          | This locks Flutter package versions for the whole team.                                              |
| **DO commit** `package-lock.json`                     | This locks Node.js package versions for the whole team.                                              |
| **Do NOT change standard versions without agreement** | Changing Flutter or Node.js versions without team consensus may break the project for other members. |
| **Use FVM and nvm**                                   | Protect each member's FYP environment by managing project-specific versions with FVM and nvm.        |


---

*Smart Travel Planner — ITT632 Mobile Cloud Computing Group Project*