import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/features/managers/labs/cbc/cbc_cubit.dart';
import 'package:clinic/features/widgets/cbc_section_widgets.dart';
import 'package:clinic/features/managers/labs/liver_function_test/liver_function_test_cubit.dart';
import 'package:clinic/features/widgets/liver_function_section_widgets.dart';
import 'package:clinic/features/managers/labs/kidney_function_test/kidney_function_test_cubit.dart';
import 'package:clinic/features/widgets/kidney_function_section_widgets.dart';
import 'package:clinic/features/managers/labs/thyroid_profile/thyroid_profile_cubit.dart';
import 'package:clinic/features/widgets/thyroid_profile_section_widgets.dart';
import 'package:clinic/features/managers/labs/diabetes_labs/diabetes_labs_cubit.dart';
import 'package:clinic/features/widgets/diabetes_labs_section_widgets.dart';
import 'package:clinic/features/managers/labs/lipid_profile/lipid_profile_cubit.dart';
import 'package:clinic/features/widgets/lipid_profile_section_widgets.dart';
import 'package:clinic/features/managers/labs/virology/virology_cubit.dart';
import 'package:clinic/features/widgets/virology_section_widgets.dart';
import 'package:clinic/features/managers/labs/inflammatory_markers/inflammatory_markers_cubit.dart';
import 'package:clinic/features/widgets/inflammatory_markers_section_widgets.dart';
import 'package:clinic/features/managers/labs/pancreatic_enzymes/pancreatic_enzymes_cubit.dart';
import 'package:clinic/features/widgets/pancreatic_enzymes_section_widgets.dart';
import 'package:clinic/features/managers/labs/autoimmune_markers/autoimmune_markers_cubit.dart';
import 'package:clinic/features/widgets/autoimmune_markers_section_widgets.dart';
import 'package:clinic/features/managers/labs/coagulation_profile/coagulation_profile_cubit.dart';
import 'package:clinic/features/widgets/coagulation_profile_section_widgets.dart';
import 'package:clinic/features/managers/labs/celiac_disease_labs/celiac_disease_labs_cubit.dart';
import 'package:clinic/features/widgets/celiac_disease_labs_section_widgets.dart';

class LabsScreen extends StatelessWidget {
  final Patient patient;

  const LabsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CbcCubit()..loadForPatient(patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) => LiverFunctionTestCubit()..loadForPatient(patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) => KidneyFunctionTestCubit()..loadForPatient(patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) => DiabetesLabsCubit()..loadForPatient(patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) => LipidProfileCubit()..loadForPatient(patient.id!, force: true),
        ),
        BlocProvider(
          create: (_) => ThyroidProfileCubit()..loadForPatient(patient.id!, force: true),
        ),
        // Re-provide the VirologyCubit from parent so the MultiBlocProvider and descendants use the same instance
        BlocProvider.value(
          value: context.read<VirologyCubit>(),
        ),
        // Re-provide the InflammatoryMarkersCubit from parent
        BlocProvider.value(
          value: context.read<InflammatoryMarkersCubit>(),
        ),
        // Re-provide the PancreaticEnzymesCubit from parent
        BlocProvider.value(
          value: context.read<PancreaticEnzymesCubit>(),
        ),
        // Re-provide the AutoimmuneMarkersCubit from parent
        BlocProvider.value(
          value: context.read<AutoimmuneMarkersCubit>(),
        ),
        // Re-provide the CoagulationProfileCubit from parent
        BlocProvider.value(
          value: context.read<CoagulationProfileCubit>(),
        ),
        // Provide CeliacDiseaseLabsCubit for this screen
        BlocProvider(
          create: (_) => CeliacDiseaseLabsCubit()..loadForPatient(patient.id!, force: true),
        ),
        // Note: AutoimmuneMarkersCubit is provided by the parent (LayoutScreen) so we do not attempt to re-read it here.
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CbcSection(patient: patient),
            const SizedBox(height: 12),
            LiverFunctionSection(patient: patient),
            const SizedBox(height: 12),
            KidneyFunctionSection(patient: patient),
            const SizedBox(height: 12),
            DiabetesLabsSection(patient: patient),
            const SizedBox(height: 12),
            LipidProfileSection(patient: patient),
            const SizedBox(height: 12),
            PancreaticEnzymesSection(patient: patient),
            const SizedBox(height: 12),
            VirologySection(patient: patient),
            const SizedBox(height: 12),
            InflammatoryMarkersSection(patient: patient),
            const SizedBox(height: 12),
            AutoimmuneMarkersSection(patient: patient),
            const SizedBox(height: 12),
            CoagulationProfileSection(patient: patient),
            const SizedBox(height: 12),
            CeliacDiseaseLabsSection(patient: patient),
            const SizedBox(height: 12),
            ThyroidProfileSection(patient: patient),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}