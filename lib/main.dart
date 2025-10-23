import 'package:clinic/core/services/sql_service.dart';
import 'package:clinic/features/managers/add_user/add_user/patient_cubit.dart';
import 'package:clinic/features/screens/layout_scrren.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      providers: [
        BlocProvider(create: (_) =>PatientCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        debugShowCheckedModeBanner: false,
        home: LayoutScrren(),
      ),
    );
  }
}
