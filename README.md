📱 Session Join App (Flutter + GetX + Firebase)

A production-ready Flutter application that allows users to view, subscribe to, and join live sessions using Firebase Firestore, GetX state management, and Anonymous Authentication.

This app is designed as a participant / attendee-only application.
Sessions are assumed to be pre-created externally (e.g., admin or backend system).

🚀 Features
✅ Core Features

View Upcoming & Ongoing Sessions

Subscribe to upcoming sessions

Join ongoing sessions

Camera & Microphone permission handling

Mock video call UI

Real-time session stopwatch

Session duration saved to Firestore

Anonymous user identification (no login UI)

🧱 Tech Stack
Layer	Technology
UI	Flutter
State Management	GetX
Backend	Firebase Firestore
Authentication	Firebase Anonymous Auth
Permissions	permission_handler
Navigation	GetX routing (inline routes)
🧠 Architectural Decisions
1️⃣ Why GetX?

Lightweight

Reactive state management

Simple navigation

Minimal boilerplate

Perfect for small–medium apps

2️⃣ Why Anonymous Authentication?

No login/signup UI required

Each user still gets a unique UID

Enables:

Secure Firestore rules

Session subscriptions

Future push notifications

Can be upgraded later to full auth (Google / Email)

👉 Auth runs silently at app start.

3️⃣ Why No Session Creation?

This app is NOT a platform to create sessions.

Responsibilities:

❌ Creating / editing sessions

❌ Ownership or admin control

Focus:

✅ Viewing sessions

✅ Subscribing

✅ Joining

✅ Tracking duration

This keeps the app simple, focused, and scalable.

📁 Project Structure
lib/
├── main.dart
│
├── constants/
│   ├── firestore_constants.dart
│   ├── session_status.dart
│   └── app_constants.dart
│
├── models/
│   └── session_model.dart
│
├── services/
│   ├── auth_service.dart
│   └── session_service.dart
│
├── controllers/
│   ├── session_controller.dart
│   └── call_controller.dart
│
├── utils/
│   └── permission_utils.dart
│
├── screens/
│   ├── appointments_screen.dart
│   └── video_call_screen.dart

Folder Responsibilities

models → Pure data structures

services → Firebase & external logic

controllers → Business logic & state

screens → UI only

utils → Reusable helpers

constants → Single source of truth

🗂️ Firestore Data Model
Collection: sessions
{
  "title": "Knee Rehab Session",
  "description": "Guided physiotherapy exercises",
  "ownerName": "Dr. Sharma",
  "status": "upcoming",
  "startTime": "Timestamp",
  "durationSeconds": 0,
  "awaitingCount": 5,
  "joinedCount": 0,
  "subscribers": ["uid_1", "uid_2"]
}

Status Values

upcoming

ongoing

completed

🔁 Application Flow
App Start

Firebase initializes

Anonymous authentication happens silently

UID is stored by Firebase

Appointments Screen

Fetches sessions from Firestore

Displays:

Title

Description

Owner

Awaiting / Joined counts

Actions:

Subscribe → adds UID to subscribers

Join → checks permissions → updates Firestore → navigates

Video Call Screen

Mock video UI

Stopwatch starts automatically

Duration updates in Firestore on end

User navigates back safely

🔐 Permissions Handling

Camera & Microphone permissions requested only when joining

Handles:

Granted

Denied

Permanently denied (opens app settings)

This follows correct UX and platform guidelines.

🔔 Notification Design (Planned)
Current

Real-time Firestore listeners

In-app awareness when session becomes ongoing

Future (No refactor required)

Store FCM token per UID

Cloud Function triggers notification when:

status: upcoming → ongoing


Notify all subscribers

The data model is already notification-ready.

🔒 Firestore Security Rules (Recommended)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /sessions/{sessionId} {
      allow read, update: if request.auth != null;
    }
  }
}

🧪 Error & State Handling

Loading states handled via GetX

Errors captured and displayed safely

UI remains responsive

📦 Dependencies
get: ^4.6.6
firebase_core: ^2.27.0
firebase_auth: ^4.17.0
cloud_firestore: ^4.15.0
permission_handler: ^11.3.0

🛠️ Future Enhancements

Push notifications (FCM)

Real video SDK (Agora / WebRTC)

Session filters

User profiles

Analytics

🧾 Key Takeaways

Clean architecture

No overengineering

Production-ready patterns

Easy to scale

Task requirements fully satisfied

👨‍💻 Author

Tushar Talmale
Flutter & Full-Stack Developer
📍 India