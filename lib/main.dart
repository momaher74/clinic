import 'dart:io';
import 'package:clinic/core/services/sql_service.dart';
import 'package:clinic/features/managers/add_user/add_user/patient_cubit.dart';
import 'package:clinic/features/screens/layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Maximize/resize desktop window on app start
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    try {
      setWindowTitle("Dr Saad Elbelasy Clinic's");
      // ensure minimum width 900; use primary screen visible height as min height so height cannot be reduced below visible area
      final info = await getWindowInfo();
      final frame = info.screen?.visibleFrame;
      if (frame != null) {
        setWindowMinSize(Size(900, frame.height));
        // set window to occupy the visible frame
        setWindowFrame(frame);
      } else {
        // fallback: use conservative min height
        setWindowMinSize(const Size(900, 600));
        setWindowFrame(Rect.fromLTWH(0, 0, 1600, 900));
      }
    } catch (_) {}
  }

  // Initialize database early so it's ready when the app starts
  try {
    await DatabaseService().database;
    // ignore: avoid_print
    print('✅ Database initialized');
  } catch (e) {
    // ignore: avoid_print
    print('❌ Database initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => PatientCubit())],
      child: MaterialApp(
        title: "Dr Saad Elbelasy Clinic's",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: LayoutScrren(),
      ),
    );
  }
}
