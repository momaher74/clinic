import 'package:clinic/core/constants/constants.dart';
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // ensure the column fills at least the viewport height so its children stay at the top
            minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - kToolbarHeight,
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OgdSection(patient: patient),
                 sharedDivider(),
                ColonoscopySection(patient: patient),
                sharedDivider(),
                ErcpSection(patient: patient),
                sharedDivider(),
                EusSection(patient: patient),
                sharedDivider(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}