import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rehabunified_task/firebase_options.dart';

import 'screens/appointments_screen.dart';
import 'screens/video_call_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await AuthService().ensureAnonymousLogin();

  runApp(
    DevicePreview(enabled: !kReleaseMode, builder: (context) => const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Session Join App',

      // Initial screen
      initialRoute: '/',

      // Routes defined inline (NO separate routes file)
      getPages: [
        GetPage(name: '/', page: () => AppointmentsScreen()),
        GetPage(name: '/video-call', page: () => VideoCallScreen()),
      ],
    );
  }
}
