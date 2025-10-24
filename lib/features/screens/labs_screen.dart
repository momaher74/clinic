import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/features/managers/labs/cbc/cbc_cubit.dart';
import 'package:clinic/features/widgets/cbc_section_widgets.dart';
import 'package:clinic/features/managers/labs/liver_function_test/liver_function_test_cubit.dart';
import 'package:clinic/features/widgets/liver_function_section_widgets.dart';

class LabsScreen extends StatelessWidget {
  final Patient patient;

  const LabsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CbcCubit()..loadForPatient(patient.id!),
        ),
        BlocProvider(
          create: (_) => LiverFunctionTestCubit()..loadForPatient(patient.id!),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CbcSection(patient: patient),
          const SizedBox(height: 12),
          LiverFunctionSection(patient: patient),
        ],
      ),
    );
  }
}