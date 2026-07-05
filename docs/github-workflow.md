# GitHub Workflow Guide — Smart Travel Planner

This guide covers every Git and GitHub command the team needs.
Follow this workflow every time you work on the project.

---

## Table of Contents

1. [First Time Setup — Clone the Repository](#1-first-time-setup--clone-the-repository)
2. [Understand the Branch Structure](#2-understand-the-branch-structure)
3. [Correct Full Workflow — Every Session](#3-correct-full-workflow--every-session)
4. [Step-by-Step Commands Reference](#4-step-by-step-commands-reference)
5. [Opening a Pull Request on GitHub](#5-opening-a-pull-request-on-github)
6. [After Pull Request is Merged](#6-after-pull-request-is-merged)
7. [How to Update Your Branch If develop Changed](#7-how-to-update-your-branch-if-develop-changed)
8. [Handling Merge Conflicts](#8-handling-merge-conflicts)
9. [Common Mistakes to Avoid](#9-common-mistakes-to-avoid)
10. [Quick Command Cheat Sheet](#10-quick-command-cheat-sheet)
11. [Complete Example Walkthrough](#11-complete-example-walkthrough)

---



## 1. First Time Setup — Clone the Repository

> Do this **once only** when you first join the project.
> After this you never clone again unless you lose your local copy.

```bash
# Clone the repository to your local machine
git clone https://github.com/taiga2921/ICT632_smart_travel_planner.git

# Go into the project folder
cd smart-travel-planner

# Check that remote is connected
git remote -v
```

Expected output:

```
origin  https://github.com/taiga2921/ICT632_smart_travel_planner.git (fetch)
origin  https://github.com/taiga2921/ICT632_smart_travel_planner.git (push)
```

---



## 2. Understand the Branch Structure

example:

```
main
 └── develop
      ├── eni
      ├── aten
      ├── kwan
      └── mancap
```

or if you want specific feature/work:

```
main
 └── develop
      ├── feature/flutter-ui          (Member 1)
      ├── feature/trip-planner-ui     (Member 1)
      ├── feature/express-api         (Member 2)
      ├── feature/trip-crud-api       (Member 2)
      ├── feature/firebase-auth       (Member 3)
      ├── feature/weather-api         (Member 3)
      ├── feature/mysql-database      (Member 4)
      ├── feature/testing             (Member 4)
      └── fix/bug-name                (Any member)
```


| Branch                    | Rule                                                                                      |
| ------------------------- | ----------------------------------------------------------------------------------------- |
| `main`                    | Final stable submission only. Nobody pushes directly here.                                |
| `develop`                 | Active integration branch. All feature branches merge here.                               |
| `<your_name>`/`feature/*` | Your working branch. Created from `develop`. Merged back into `develop` via Pull Request. |


> **Rule:** You never push directly to `main` or `develop`.
> You always work on a `feature/` branch and open a Pull Request.

---



## 3. Correct Full Workflow — Every Session

This is the correct order of steps. Read this before every session.

```
START OF SESSION
│
├── 1. Go to your project folder
├── 2. Switch to develop
├── 3. Pull latest from develop          ← Always do this first
├── 4. Create your feature branch        ← From develop, BEFORE doing work
├── 5. Do your work and commit regularly
├── 6. Push your feature branch to GitHub
│
├── 7. When feature is DONE:
│       └── Open a Pull Request on GitHub (feature branch → develop)
│
├── 8. Team reviews and merges the PR on GitHub
├── 9. Delete the feature branch (GitHub will offer this after merge)
│
└── 10. Everyone pulls from develop to get the latest code
```

> **Key correction from your original plan:**
>
> - Create the branch **BEFORE** doing work, not after.
> - Pull from `develop`, not `main`.
> - Only open a Pull Request when the work is **done and ready to merge**.
> - GitHub calls it a **Pull Request (PR)**, not a Merge Request.

---



## 4. Step-by-Step Commands Reference



### Step 1 — Go to your project folder

```bash
cd smart-travel-planner
```

---



### Step 2 — Switch to develop

```bash
git checkout develop
```

---



### Step 3 — Pull the latest code from develop

> Always do this before creating a new branch or starting work.
> This makes sure your starting point has everyone's latest code.

```bash
git pull origin develop
```

---



### Step 4 — Create your branch from develop

> Create the branch first. Work on it second.
> Name your branch.

```bash
# Create a new branch and switch to it at the same time
git checkout -b eni
```

Examples:

```bash
git checkout -b eni
git checkout -b aten
git checkout -b kwan
git checkout -b mancap
git checkout -b feature/flutter-ui
git checkout -b feature/trip-planner-ui
git checkout -b feature/express-api
git checkout -b feature/trip-crud-api
git checkout -b feature/firebase-auth
git checkout -b feature/weather-api
git checkout -b feature/mysql-database
git checkout -b feature/testing
git checkout -b fix/itinerary-loading-bug
```

Check which branch you are on:

```bash
git branch
```

The branch with `*` is your current branch:

```
  develop
* eni
  feature/flutter-ui
  main
```

---



### Step 5 — Do your work and commit regularly

After making changes to your files:

```bash
# See what files you changed
git status

# Stage all changed files
git add .

# Or stage a specific file only
git add lib/screens/trip/trip_list_screen.dart

# Commit with a clear message
git commit -m "feat: add trip list screen UI"
```

**Commit message format:**

```
feat: add trip creation screen
feat: create trip CRUD API with Express
feat: integrate Firebase login
feat: add weather API service
feat: add MySQL schema for trips
fix: resolve itinerary loading issue
fix: correct budget total calculation
docs: update system architecture document
test: add Postman collection for trip API
```

> **Commit often.** Do not wait until everything is done to commit.
> Small, frequent commits are easier to review and safer to recover from.

---



### Step 6 — Push your feature branch to GitHub

```bash
# First push — sets up the tracking branch on GitHub
git push -u origin feature/your-feature-name

# Every push after that (shorter)
git push
```

Example:

```bash
git push -u origin feature/flutter-ui

# After the first push, just use:
git push
```

---



### Step 7 — Check your branch and commit history

```bash
# See your recent commits
git log --oneline

# See your current branch
git branch

# See all branches including remote ones
git branch -a

# See what is changed but not yet staged
git status
```

---



## 5. Opening a Pull Request on GitHub

> Only open a Pull Request when your feature is **done and working**.
> Do not open a PR for incomplete work unless you need team feedback.

**Steps on GitHub website:**

1. Go to your repository on GitHub.
2. Click the **"Compare & pull request"** button that appears after you push a branch.
  Or go to **Pull Requests tab** → **New Pull Request**.
3. Set the branches:
  - **base:** `develop`
  - **compare:** `feature/your-feature-name`
4. Write a clear title and description:

```
Nak tinggal kosong pon boleh, kalau rajin boleh buat

Example:

Title: feat: add trip list screen and create trip screen

Description:
- Added trip list screen showing all user trips
- Added create trip form with destination, dates, budget fields
- Added navigation between trip screens
- Connected to Express API /api/trips endpoint
```

1. Assign a reviewer (another team member).
2. Click **"Create Pull Request"**.
3. Wait for the reviewer to approve.
4. After approval, click **"Merge Pull Request"**.
5. Click **"Delete Branch"** to clean up the merged branch.

---



## 6. After Pull Request is Merged

After your PR or someone else's PR is merged into `develop`, everyone must update their local copy.

```bash
# Switch to develop
git checkout develop

# Pull the latest merged code from develop
git pull origin develop
```

Now your `develop` branch has the latest code from all merged PRs.

If you are continuing work on a new feature, start from Step 3 again:
create a fresh branch from the updated `develop`.

---



## 7. How to Update Your Branch If develop Changed

Situation: You are working on `feature/flutter-ui` and your teammate just merged their PR into `develop`. You want to bring those changes into your branch without switching away from your current work.

```bash
# Make sure you commit your current work first
git add .
git commit -m "feat: work in progress on trip list screen"

# Fetch the latest changes from GitHub without merging yet
git fetch origin

# Merge the latest develop into your current feature branch
git merge origin/develop
```

Or using rebase (cleaner history, more advanced):

```bash
git fetch origin
git rebase origin/develop
```

> If there are no conflicts, your branch is now up to date with develop.
> If there are conflicts, see Section 8 below.

---



## 8. Handling Merge Conflicts

A conflict happens when two people changed the same part of the same file.
Git cannot decide which version to keep, so you must resolve it manually.

```bash
# After a merge or pull, if you see a conflict:
git status
```

Conflicted files will show:

```
both modified: lib/config/app_config.dart
```

Open the file. You will see conflict markers like this:

```
<<<<<<< HEAD
const String apiBaseUrl = 'http://10.0.2.2:3000/api';
=======
const String apiBaseUrl = 'http://192.168.1.10:3000/api';
>>>>>>> origin/develop
```

Edit the file to keep the correct version:

```dart
const String apiBaseUrl = 'http://10.0.2.2:3000/api';
```

Delete the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).

Then:

```bash
# Stage the resolved file
git add lib/config/app_config.dart

# Complete the merge
git commit -m "fix: resolve merge conflict in app_config"
```

---



## 9. Common Mistakes to Avoid



### ❌ Mistake 1 — Working directly on develop or main

```bash
# WRONG — Never do this
git checkout develop
# ... make changes and commit directly to develop
git push origin develop
```

```bash
# CORRECT — Always create a feature branch
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
# ... make changes on the feature branch
```

---



### ❌ Mistake 2 — Creating branch after doing work on develop

```bash
# WRONG — Made changes on develop then tried to create a branch
# Changes are already on develop — risky
```

```bash
# CORRECT — Always create branch FIRST before touching any file
git checkout -b feature/your-feature-name
# Now open your files and start working
```

---



### ❌ Mistake 3 — Forgetting to pull from develop before creating a new branch

```bash
# WRONG — Creating a branch from an old develop
git checkout develop
git checkout -b feature/new-feature
# Your branch is missing the latest merged code
```

```bash
# CORRECT — Always pull first
git checkout develop
git pull origin develop         # ← this step is critical
git checkout -b feature/new-feature
```

---



### ❌ Mistake 4 — Opening a Pull Request into main instead of develop

- Always set **base** to `develop`, not `main`.
- `main` is only touched at the very end for final submission.

---



### ❌ Mistake 5 — Not committing before switching branches

```bash
# WRONG — Switching branches with uncommitted changes
git checkout develop
# Git may carry your changes over or throw an error
```

```bash
# CORRECT — Commit first, then switch
git add .
git commit -m "feat: work in progress"
git checkout develop
```

---



### ❌ Mistake 6 — Pulling from main instead of develop

```bash
# WRONG
git pull origin main

# CORRECT — Pull from develop for day-to-day work
git pull origin develop
```

---



## 10. Quick Command Cheat Sheet



### Starting a New Working Session

```bash
cd smart-travel-planner
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```



### During Work — Save Progress

```bash
git status
git add .
git commit -m "feat: describe what you did"
```



### Push to GitHub

```bash
# First time pushing this branch
git push -u origin feature/your-feature-name

# After first push
git push
```



### After Someone Else's PR is Merged

```bash
git checkout develop
git pull origin develop
```



### Update Your Current Branch with Latest develop

```bash
git fetch origin
git merge origin/develop
```



### See What Branch You Are On

```bash
git branch
```



### See Recent Commits

```bash
git log --oneline
```



### Undo Last Commit (Keep Changes)

```bash
git reset --soft HEAD~1
```



### Discard All Uncommitted Changes (Careful — Cannot Undo)

```bash
git checkout -- .
```



### Delete a Local Branch After PR is Merged

```bash
git branch -d feature/your-feature-name
```



### Delete a Remote Branch (If Not Done via GitHub)

```bash
git push origin --delete feature/your-feature-name
```

---



## 11. Complete Example Walkthrough

This is a full example of **Member 1** working on the trip list screen from start to finish.

---



### Day 1 — First time joining the project

```bash
# Clone the repository once
git clone https://github.com/taiga2921/ICT632_smart_travel_planner.git
cd smart-travel-planner

# Verify remote
git remote -v
```

---



### Day 2 — Starting work on the trip list screen

```bash
# Go to project folder
cd smart-travel-planner

# Switch to develop and pull the latest
git checkout develop
git pull origin develop

# Create a new feature branch BEFORE touching any file
git checkout -b feature/trip-planner-ui

# Verify you are on the right branch
git branch
# Output should show:
#   develop
# * feature/trip-planner-ui
#   main
```

Now open VS Code or Android Studio and start coding.

```bash
# After working for a while, save your progress
git status
git add .
git commit -m "feat: add trip list screen skeleton"

# Continue working...
git add .
git commit -m "feat: add trip card widget"

# Continue working...
git add .
git commit -m "feat: connect trip list to API service"

# Push your branch to GitHub at the end of the day
git push -u origin feature/trip-planner-ui
```

---



### Day 3 — Continue working (teammate merged something into develop)

```bash
# Start session
cd smart-travel-planner

# Switch to your feature branch (already exists)
git checkout feature/trip-planner-ui

# Fetch and merge latest develop into your branch
git fetch origin
git merge origin/develop

# If there are conflicts, resolve them, then:
git add .
git commit -m "fix: resolve merge conflict with develop"

# Continue your work
git add .
git commit -m "feat: add empty state for trip list"

# Push
git push
```

---



### Day 4 — Feature is done, open Pull Request

```bash
# Final commit
git add .
git commit -m "feat: complete trip planner UI screens"

# Push to GitHub
git push
```

Now go to GitHub:

1. Click **"Compare & pull request"** for `feature/trip-planner-ui`.
2. Set **base: develop**, **compare: feature/trip-planner-ui**.
3. Write title: `feat: add trip list and create trip screens`
4. Add description of what was done.
5. Assign a reviewer.
6. Click **"Create Pull Request"**.

Reviewer checks the code and approves.

Member 1 (or reviewer) clicks **"Merge Pull Request"** then **"Delete Branch"**.

---



### After PR is Merged — All Members Update

Every team member runs this after a PR is merged:

```bash
cd smart-travel-planner
git checkout develop
git pull origin develop
```

Now everyone has the latest code including the merged trip planner screens.

---



### Final Submission — Merge develop into main

> Only done once at the end by the team leader.

```bash
git checkout main
git pull origin main
git merge develop
git push origin main
```

---

**Corrected plan:**

```
1. Clone the repo once
2. git checkout develop → git pull origin develop
3. git checkout -b feature/your-feature-name   ← FIRST
4. Do your work and commit regularly
5. git push origin feature/your-feature-name
6. When done → open Pull Request on GitHub (feature → develop)
7. Reviewer approves → Merge PR → Delete branch on GitHub
8. Everyone: git checkout develop → git pull origin develop
9. Repeat from step 2 for next feature
```

---

*Smart Travel Planner — ITT632 Mobile Cloud Computing Group Project*
*GitHub Workflow Guide*