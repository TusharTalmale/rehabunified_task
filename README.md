<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>RehabUnified – Live Session & Video Calling App</title>
</head>
<body>

<h1>📱  Live Session & Video Calling App</h1>

<p>
  <strong>RehabUnified</strong> is a Flutter-based mobile application designed for managing and attending
  live rehabilitation sessions with real-time video calling. The app delivers a smooth and modern
  experience similar to platforms like Google Meet or YouTube, including Picture-in-Picture support
  and floating mini video playback.
</p>

<hr />

<h2>🚀 Features</h2>

<h3>📅 Session Management</h3>
<ul>
  <li>Browse sessions categorized as <strong>Upcoming</strong>, <strong>Live</strong>, and <strong>Completed</strong></li>
  <li>Real-time search with highlighted text</li>
  <li>Infinite scrolling with pagination</li>
  <li>Skeleton loaders for better loading UX</li>
  <li>Proper empty and error state handling</li>
</ul>

<h3>🎥 Live Video Calling</h3>
<ul>
  <li>Real-time camera and microphone access</li>
  <li>Self video preview inside the call screen</li>
  <li>Mute / unmute microphone</li>
  <li>Turn camera on / off during the call</li>
  <li>Speaker ↔ earpiece audio routing</li>
</ul>

<h3>📱 Picture-in-Picture (PiP)</h3>
<ul>
  <li>YouTube-style floating mini video player</li>
  <li>Draggable mini player overlay</li>
  <li>Expand back to full-screen call</li>
  <li>Continue call while navigating other screens</li>
</ul>

<h3>🧠 Architecture & State Management</h3>
<ul>
  <li>GetX for state management and navigation</li>
  <li>Clean separation of UI, controllers, and services</li>
  <li>Reactive UI updates without unnecessary rebuilds</li>
</ul>

<hr />

<h2>🛠️ Tech Stack</h2>

<table border="1" cellpadding="8" cellspacing="0">
  <tr>
    <th>Category</th>
    <th>Technology</th>
  </tr>
  <tr>
    <td>Framework</td>
    <td>Flutter</td>
  </tr>
  <tr>
    <td>State Management</td>
    <td>GetX</td>
  </tr>
  <tr>
    <td>Video & Audio</td>
    <td>flutter_webrtc</td>
  </tr>
  <tr>
    <td>Audio Routing</td>
    <td>flutter_audio_manager_plus</td>
  </tr>
  <tr>
    <td>Backend</td>
    <td>Firebase </td>
  </tr>
  <tr>
    <td>Platform</td>
    <td>Android (Web partially supported)</td>
  </tr>
</table>

<hr />

<h2>📦 Key Packages</h2>

<pre>
flutter_webrtc
flutter_audio_manager_plus
get
firebase_core
cloud_firestore
</pre>

<hr />

<h2>🧩 Project Structure</h2>

<pre>
lib/
 ├── controllers/
 │    ├── session_controller.dart
 │    ├── call_controller.dart
 ├── services/
 │    ├── session_service.dart
 ├── models/
 │    ├── session_model.dart
 ├── screens/
 │    ├── appointments_screen.dart
 │    ├── video_call_screen.dart
 ├── custom_widgets/
 │    ├── session_card.dart
 │    ├── floating_video_view.dart
 │    ├── highlight_text.dart
 │    ├── session_card_skeleton.dart
</pre>

<hr />

<h2>🎯 Project Highlights</h2>
<ul>
  <li>Implements real-world video calling concepts using WebRTC</li>
  <li>Android Picture-in-Picture (PiP) support</li>
  <li>Advanced audio routing (speaker / earpiece)</li>
  <li>Optimized UI with debounced search</li>
  <li>Production-ready UX patterns and error handling</li>
</ul>

<hr />

<h2>▶️ How to Run</h2>

<h3>Prerequisites</h3>
<ul>
  <li>Flutter SDK</li>
  <li>Android Studio / Emulator</li>
  <li>Physical Android device recommended</li>
</ul>

<h3>Steps</h3>

<pre>
flutter clean
flutter pub get
flutter run
</pre>

<p>
  <strong>Note:</strong> Audio routing and Picture-in-Picture work only on Android/iOS.
</p>

<hr />

<h2>🔐 Android Permissions</h2>

<pre>
&lt;uses-permission android:name="android.permission.CAMERA"/&gt;
&lt;uses-permission android:name="android.permission.RECORD_AUDIO"/&gt;
&lt;uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/&gt;
</pre>

<hr />

<h2>📌 Future Enhancements</h2>
<ul>
  <li>Multi-user video calls</li>
  <li>Remote peer streaming</li>
  <li>Network quality indicators</li>
  <li>Screen sharing</li>
  <li>Call recording</li>
</ul>

<hr />

<h2>👨‍💻 Author</h2>

<p>
  <strong>Tushar Talmale</strong><br />
  Full Stack & Mobile Developer<br />
  Flutter | Kotlin | Spring Boot | React | Docker<br />
  📧 Email: tushartal2@gmail.com<br />

  🔗 LinkedIn:
  <a href="https://www.linkedin.com/in/tushartalmale" target="_blank">
    https://www.linkedin.com/in/tushartalmale
  </a>
</p>

<hr />
