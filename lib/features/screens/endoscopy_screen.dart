import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/features/managers/endoscopy/ogd_cubit.dart';
import 'package:clinic/features/managers/endoscopy/colonoscopy_cubit.dart';
import 'package:clinic/features/managers/endoscopy/ercp_cubit.dart';
import 'package:clinic/features/managers/endoscopy/eus_cubit.dart';
import 'package:clinic/features/widgets/ogd_section_widgets.dart';
import 'package:clinic/features/widgets/colonoscopy_section_widgets.dart';
import 'package:clinic/features/widgets/ercp_section_widgets.dart';
import 'package:clinic/features/widgets/eus_section_widgets.dart';

class EndoscopyScreen extends StatelessWidget {
  final Patient patient;

  const EndoscopyScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => OgdCubit()..loadForPatient(patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) => ColonoscopyC()..loadForPatient(patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) => ErcpCubit()..loadForPatient(patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) => EusCubit()..loadForPatient(patient.id!, force: true),
        ),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            OgdSection(patient: patient),
            const SizedBox(height: 12),
            ColonoscopySection(patient: patient),
            const SizedBox(height: 12),
            ErcpSection(patient: patient),
            const SizedBox(height: 12),
            EusSection(patient: patient),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}