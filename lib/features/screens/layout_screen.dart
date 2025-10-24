import 'package:clinic/features/managers/add_user/add_user/patient_cubit.dart';
import 'package:clinic/features/managers/examination/examination/examination_cubit.dart';
import 'package:clinic/features/managers/labs/labs_cubit.dart';
import 'package:clinic/features/managers/labs/virology/virology_cubit.dart';
import 'package:clinic/features/managers/labs/inflammatory_markers/inflammatory_markers_cubit.dart';
import 'package:clinic/features/managers/labs/pancreatic_enzymes/pancreatic_enzymes_cubit.dart';
import 'package:clinic/features/managers/labs/autoimmune_markers/autoimmune_markers_cubit.dart';
import 'package:clinic/features/managers/labs/coagulation_profile/coagulation_profile_cubit.dart';
import 'package:clinic/features/screens/complaint_screen.dart';
import 'package:clinic/features/screens/examination_screen.dart';
import 'package:clinic/features/screens/labs_screen.dart';
import 'package:clinic/features/screens/patient_history_screen.dart';
import 'package:clinic/features/screens/patient_screen.dart';
import 'package:clinic/features/screens/imaging_screen.dart';
import 'package:clinic/features/screens/endoscopy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';

class LayoutScrren extends StatefulWidget {
  const LayoutScrren({super.key});

  @override
  State<LayoutScrren> createState() => _LayoutScrrenState();
}

class _LayoutScrrenState extends State<LayoutScrren> {
  int _selectedIndex = 0;
  final _titles = [
    'Patients',
    'Complaint',
    'Patient History',
    'Examination',
    "Labs",
    "Imaging",
    "Endoscopy",
    "Pathology",
    "Precription",
  ];

  void _onSelect(int idx) {
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Responsive body: persistent sidebar on wide screens, Drawer on small
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 800;
          return Row(
            children: [
              if (isWide) ...[
                _buildSidebar(isWide: true),
                Expanded(child: _buildContent()),
              ] else ...[
                Expanded(child: _buildContent()),
              ],
            ],
          );
        },
      ),

      // Drawer for small screens
      drawer: Drawer(child: SafeArea(child: _buildSidebar(isWide: false))),
    );
  }

  Widget _buildSidebar({required bool isWide}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isWide ? 220 : 300,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // optional header in sidebar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
            child: Text(
              'Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // menu items (text-only as requested)
          ...List.generate(_titles.length, (index) {
            final selected = index == _selectedIndex;
            return GestureDetector(
              onTap: () {
                _onSelect(index);
                if (!isWide) Navigator.of(context).pop();
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFEEF2FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    // small selected indicator
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF3B82F6)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _titles[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? const Color(0xFF0F1724)
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Spacer(),
          // bottom actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _patientsView();

      case 1:
        // Safely read selected patient from PatientCubit
        try {
          final cubit = context.read<PatientCubit>();
          final state = cubit.state;
          if (state.selectedIds.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No patient selected. Please select a patient from the Patients screen.',
                ),
              ),
            );
          }

          final selectedId = state.selectedIds.first;
          Patient? patient;
          try {
            patient = state.patients.firstWhere((p) => p.id == selectedId);
          } catch (_) {
            patient = null;
          }

          if (patient == null) {
            return const Center(child: Text('Selected patient not found.'));
          }

          return ComplaintScreen(patient: patient);
        } catch (e) {
          return Center(child: Text('Error accessing patient selection: $e'));
        }

      case 2:
        final cubit = context.read<PatientCubit>();
        final state = cubit.state;
        if (state.selectedIds.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No patient selected. Please select a patient from the Patients screen.',
              ),
            ),
          );
        }

        final selectedId = state.selectedIds.first;
        Patient? patient;
        try {
          patient = state.patients.firstWhere((p) => p.id == selectedId);
        } catch (_) {
          patient = null;
        }

        if (patient == null) {
          return const Center(child: Text('Selected patient not found.'));
        }
        return PatientHistoryScreen(patient: patient);
      case 3:
        final cubit = context.read<PatientCubit>();
        final state = cubit.state;
        if (state.selectedIds.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No patient selected. Please select a patient from the Patients screen.',
              ),
            ),
          );
        }

        final selectedId = state.selectedIds.first;
        Patient? patient;
        try {
          patient = state.patients.firstWhere((p) => p.id == selectedId);
        } catch (_) {
          patient = null;
        }

        if (patient == null) {
          return const Center(child: Text('Selected patient not found.'));
        }
        return BlocProvider(
          create: (_) => ExaminationCubit(),
          child: ExaminationScreen(),
        );

      case 4:
        // Safely read selected patient from PatientCubit
        try {
          final cubit = context.read<PatientCubit>();
          final state = cubit.state;
          if (state.selectedIds.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No patient selected. Please select a patient from the Patients screen.',
                ),
              ),
            );
          }

          final selectedId = state.selectedIds.first;
          Patient? patient;
          try {
            patient = state.patients.firstWhere((p) => p.id == selectedId);
          } catch (_) {
            patient = null;
          }

          if (patient == null) {
            return const Center(child: Text('Selected patient not found.'));
          }

          return BlocProvider(
            create: (BuildContext context) {
              return LabsCubit();
            },
            child: Builder(builder: (ctx) {
              final sel = patient!; // capture non-null patient for provider closures
              return BlocProvider<VirologyCubit>(
                create: (_) => VirologyCubit()..loadForPatient(sel.id!, force: true),
                child: BlocProvider<InflammatoryMarkersCubit>(
                  create: (_) => InflammatoryMarkersCubit()..loadForPatient(sel.id!, force: true),
                  child: BlocProvider<PancreaticEnzymesCubit>(
                    create: (_) => PancreaticEnzymesCubit()..loadForPatient(sel.id!, force: true),
                    child: BlocProvider<AutoimmuneMarkersCubit>(
                      create: (_) => AutoimmuneMarkersCubit()..loadForPatient(sel.id!, force: true),
                      child: BlocProvider<CoagulationProfileCubit>(
                        create: (_) => CoagulationProfileCubit()..loadForPatient(sel.id!, force: true),
                        child: LabsScreen(patient: sel),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        } catch (e) {
          return Center(child: Text('Error accessing patient selection: $e'));
        }
      case 5:
        return ImagingScreen();
      case 6:
        // Safely read selected patient from PatientCubit and show EndoscopyScreen
        try {
          final cubit = context.read<PatientCubit>();
          final state = cubit.state;
          if (state.selectedIds.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No patient selected. Please select a patient from the Patients screen.',
                ),
              ),
            );
          }

          final selectedId = state.selectedIds.first;
          Patient? patient;
          try {
            patient = state.patients.firstWhere((p) => p.id == selectedId);
          } catch (_) {
            patient = null;
          }

          if (patient == null) {
            return const Center(child: Text('Selected patient not found.'));
          }

          return EndoscopyScreen(patient: patient);
        } catch (e) {
          return Center(child: Text('Error accessing patient selection: $e'));
        }
      default:
        return Center(
          child: Text(
            'No view implemented for "${_titles[_selectedIndex]}" yet.',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
    }
  }

  Widget _patientsView() {
    return PatientScreen();
  }

  Widget _appointmentsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Appointments',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F1724),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: List.generate(5, (i) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '10:${i}0',
                        style: const TextStyle(color: Color(0xFF6D28D9)),
                      ),
                    ),
                    title: Text('Patient ${i + 1}'),
                    subtitle: const Text('Checkup'),
                    trailing: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Open'),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: Colors.blue.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Medical Records',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Access patient files and history'),
        ],
      ),
    );
  }

  Widget _moreView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text('Enable Notifications'),
              value: true,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text('Account'),
              leading: const Icon(Icons.person_outline),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
