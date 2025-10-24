import 'package:clinic/core/constants/constants.dart';
import 'package:clinic/features/managers/add_user/add_user/patient_cubit.dart';
import 'package:clinic/features/managers/labs/cbc/cbc_cubit.dart';
import 'package:clinic/features/managers/labs/coagulation_profile/coagulation_profile_cubit.dart';
import 'package:clinic/features/managers/labs/liver_function_test/liver_function_test_cubit.dart';
import 'package:clinic/features/managers/labs/kidney_function_test/kidney_function_test_cubit.dart';
import 'package:clinic/core/models/cbc.dart';
import 'package:clinic/core/models/coagulation_profile.dart';
import 'package:clinic/core/models/liver_function_test.dart';
import 'package:clinic/core/models/kidney_function_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LabsScreen extends StatelessWidget {
  const LabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CbcCubit>(create: (_) => CbcCubit()),
        BlocProvider<CoagulationProfileCubit>(create: (_) => CoagulationProfileCubit()),
        BlocProvider<LiverFunctionTestCubit>(create: (_) => LiverFunctionTestCubit()),
        BlocProvider<KidneyFunctionTestCubit>(create: (_) => KidneyFunctionTestCubit()),
      ],
      child: Builder(builder: (buildCtx) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            final pState = buildCtx.read<PatientCubit>().state;
            if (pState.selectedIds.isNotEmpty) {
              final pid = pState.selectedIds.first;
              buildCtx.read<CbcCubit>().loadForPatient(pid);
              buildCtx.read<CoagulationProfileCubit>().loadForPatient(pid);
              buildCtx.read<LiverFunctionTestCubit>().loadForPatient(pid);
              buildCtx.read<KidneyFunctionTestCubit>().loadForPatient(pid);
            }
          } catch (_) {}
        });

        return BlocListener<PatientCubit, dynamic>(
          listenWhen: (prev, cur) => prev.selectedIds != cur.selectedIds,
          listener: (context, pState) {
            final ids = pState.selectedIds as List<int>;
            if (ids.isNotEmpty) {
              final pid = ids.first;
              context.read<CbcCubit>().loadForPatient(pid, force: true);
              context.read<CoagulationProfileCubit>().loadForPatient(pid, force: true);
              context.read<LiverFunctionTestCubit>().loadForPatient(pid, force: true);
              context.read<KidneyFunctionTestCubit>().loadForPatient(pid, force: true);
            } else {
              context.read<CbcCubit>().resetLoaded();
              context.read<CoagulationProfileCubit>().resetLoaded();
              context.read<LiverFunctionTestCubit>().resetLoaded();
              context.read<KidneyFunctionTestCubit>().resetLoaded();
            }
          },
          child: Container(
            color: Colors.white,
            child: CustomScrollView(
              key: const PageStorageKey('labs-scroll'),
              slivers: <Widget>[
                // CBC Section
                ..._cbcSection(context),
                
                // Section Divider
                _buildSectionDivider(),
                
                // Coagulation Profile Section
                ..._coagulationSection(context),
                
                // Section Divider
                _buildSectionDivider(),
                
                // Liver Function Test Section
                ..._liverSection(context),
                
                // Section Divider
                _buildSectionDivider(),
                
                // Kidney Function Test Section
                ..._kidneySection(context),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Beautiful section divider
  Widget _buildSectionDivider() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Expanded(child: Divider(thickness: 1.5, color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.fiber_manual_record, size: 8, color: Colors.grey.shade400),
            ),
            Expanded(child: Divider(thickness: 1.5, color: Colors.grey.shade300)),
          ],
        ),
      ),
    );
  }

  // CBC Section Slivers
  List<Widget> _cbcSection(BuildContext context) {
    return [
      SliverSafeArea(
        top: true,
        sliver: SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 2,
          title: const Text('Complete Blood Count (CBC)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Builder(builder: (buttonCtx) {
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _openAddCbcDialog(buttonCtx),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text('Add CBC', style: TextStyle(color: Colors.white)),
                );
              }),
            ),
          ],
        ),
      ),
      BlocBuilder<CbcCubit, CbcState>(builder: (context, state) {
        final pState = context.watch<PatientCubit>().state;
        if (pState.selectedIds.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No patient selected', style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        if (state.isLoading) {
          return const SliverToBoxAdapter(
            child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
          );
        }
        final items = state.list;
        if (items.isEmpty) {
          return SliverToBoxAdapter(child: _emptyState('No CBC records yet'));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, idx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: _cbcCard(items[idx], context),
            ),
            childCount: items.length,
          ),
        );
      }),
    ];
  }

  // Coagulation Profile Section Slivers
  List<Widget> _coagulationSection(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Coagulation Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              Builder(builder: (btnCtx) {
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _openAddCoagulationDialog(btnCtx),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text('Add', style: TextStyle(color: Colors.white)),
                );
              }),
            ],
          ),
        ),
      ),
      BlocBuilder<CoagulationProfileCubit, CoagulationProfileState>(builder: (context, state) {
        final pState = context.watch<PatientCubit>().state;
        if (pState.selectedIds.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        if (state.isLoading) {
          return const SliverToBoxAdapter(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
        }
        final items = state.list;
        if (items.isEmpty) {
          return SliverToBoxAdapter(child: _emptyState('No Coagulation Profile records'));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, idx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: _coagulationCard(items[idx], context),
            ),
            childCount: items.length,
          ),
        );
      }),
    ];
  }

  // Liver Function Test Section Slivers
  List<Widget> _liverSection(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Liver Function Test', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              Builder(builder: (btnCtx) {
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _openAddLiverDialog(btnCtx),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text('Add', style: TextStyle(color: Colors.white)),
                );
              }),
            ],
          ),
        ),
      ),
      BlocBuilder<LiverFunctionTestCubit, LiverFunctionTestState>(builder: (context, state) {
        final pState = context.watch<PatientCubit>().state;
        if (pState.selectedIds.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        if (state.isLoading) {
          return const SliverToBoxAdapter(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
        }
        final items = state.list;
        if (items.isEmpty) {
          return SliverToBoxAdapter(child: _emptyState('No Liver Function Test records'));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, idx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: _liverCard(items[idx], context),
            ),
            childCount: items.length,
          ),
        );
      }),
    ];
  }

  // Kidney Function Test Section Slivers
  List<Widget> _kidneySection(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Kidney Function Test', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              Builder(builder: (btnCtx) {
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _openAddKidneyDialog(btnCtx),
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text('Add', style: TextStyle(color: Colors.white)),
                );
              }),
            ],
          ),
        ),
      ),
      BlocBuilder<KidneyFunctionTestCubit, KidneyFunctionTestState>(builder: (context, state) {
        final pState = context.watch<PatientCubit>().state;
        if (pState.selectedIds.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
        if (state.isLoading) {
          return const SliverToBoxAdapter(child: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
        }
        final items = state.list;
        if (items.isEmpty) {
          return SliverToBoxAdapter(child: _emptyState('No Kidney Function Test records'));
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, idx) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: _kidneyCard(items[idx], context),
            ),
            childCount: items.length,
          ),
        );
      }),
    ];
  }

  Widget _emptyState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.science_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(message, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _shortDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _openAddCbcDialog(BuildContext ctx) async {
    try {
      final pState = ctx.read<PatientCubit>().state;
      if (pState.selectedIds.isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Select a patient first')));
        return;
      }
      final pid = pState.selectedIds.first;

      final result = await showDialog<Cbc?>(
        context: ctx,
        builder: (_) => AddCbcDialog(pid: pid),
      );

      if (result != null) {
        try {
          await ctx.read<CbcCubit>().add(result);
        } catch (_) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('CBC provider not found. Try restarting the app.')));
        }
      }
    } catch (_) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Patient provider not found. Ensure PatientCubit is provided above LabsScreen and restart if needed.')));
    }
  }

  Widget _cbcCard(Cbc c, BuildContext context) {
    final hasDate = c.date.trim().isNotEmpty;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 12,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: defaultGradient,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasDate ? c.date : _shortDate(c.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                ),
                Row(
                  children: [
                    if (!hasDate)
                      TextButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: now,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            final updated = Cbc(
                              id: c.id,
                              patientId: c.patientId,
                              date: '${picked.day}/${picked.month}/${picked.year}',
                              hb: c.hb,
                              rbcs: c.rbcs,
                              mcv: c.mcv,
                              mch: c.mch,
                              tlc: c.tlc,
                              neut: c.neut,
                              lymph: c.lymph,
                              mono: c.mono,
                              eos: c.eos,
                              baso: c.baso,
                              ptt: c.ptt,
                              createdAt: c.createdAt,
                            );
                            await context.read<CbcCubit>().delete(c.id!);
                            await context.read<CbcCubit>().add(updated);
                          }
                        },
                        icon: const Icon(Icons.calendar_month_outlined, size: 18),
                        label: const Text('Set date'),
                        style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                      ),
                    IconButton(
                      onPressed: () => context.read<CbcCubit>().delete(c.id!),
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(builder: (ctx, constraints) {
              final twoColumn = constraints.maxWidth > 600;
              final tiles = [
                _infoTile('Hb', c.hb),
                _infoTile('RBCs', c.rbcs),
                _infoTile('MCV', c.mcv),
                _infoTile('MCH', c.mch),
                _infoTile('TLC', c.tlc),
                _infoTile('Neut', c.neut),
                _infoTile('Lymph', c.lymph),
                _infoTile('Mono', c.mono),
                _infoTile('Eos', c.eos),
                _infoTile('Baso', c.baso),
                _infoTile('PTT', c.ptt),
              ];
              return Wrap(
                runSpacing: 10,
                spacing: 12,
                children: tiles
                    .map((w) => SizedBox(width: twoColumn ? (constraints.maxWidth - 48) / 3 : constraints.maxWidth - 48, child: w))
                    .toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value.isEmpty ? '-' : value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ========== COAGULATION PROFILE METHODS ==========

  Future<void> _openAddCoagulationDialog(BuildContext ctx) async {
    try {
      final pState = ctx.read<PatientCubit>().state;
      if (pState.selectedIds.isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Select a patient first')));
        return;
      }
      final pid = pState.selectedIds.first;

      final result = await showDialog<CoagulationProfile?>(
        context: ctx,
        builder: (_) => AddCoagulationDialog(pid: pid),
      );

      if (result != null) {
        try {
          await ctx.read<CoagulationProfileCubit>().add(result);
        } catch (_) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Coagulation provider not found')));
        }
      }
    } catch (_) {}
  }

  Widget _coagulationCard(CoagulationProfile c, BuildContext context) {
    final hasDate = c.date.trim().isNotEmpty;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFF06292)]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(child: Text(hasDate ? c.date : _shortDate(c.createdAt), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
                IconButton(onPressed: () => context.read<CoagulationProfileCubit>().delete(c.id!), icon: const Icon(Icons.delete_outline, color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(builder: (ctx, constraints) {
              final twoColumn = constraints.maxWidth > 600;
              final tiles = [_infoTile('PT', c.pt), _infoTile('PTT', c.ptt), _infoTile('PC', c.pc), _infoTile('INR', c.inr)];
              return Wrap(
                runSpacing: 10,
                spacing: 12,
                children: tiles.map((w) => SizedBox(width: twoColumn ? (constraints.maxWidth - 48) / 2 : constraints.maxWidth - 48, child: w)).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ========== LIVER FUNCTION TEST METHODS ==========

  Future<void> _openAddLiverDialog(BuildContext ctx) async {
    try {
      final pState = ctx.read<PatientCubit>().state;
      if (pState.selectedIds.isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Select a patient first')));
        return;
      }
      final pid = pState.selectedIds.first;

      final result = await showDialog<LiverFunctionTest?>(
        context: ctx,
        builder: (_) => AddLiverDialog(pid: pid),
      );

      if (result != null) {
        try {
          await ctx.read<LiverFunctionTestCubit>().add(result);
        } catch (_) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Liver test provider not found')));
        }
      }
    } catch (_) {}
  }

  Widget _liverCard(LiverFunctionTest c, BuildContext context) {
    final hasDate = c.date.trim().isNotEmpty;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFB74D)]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(child: Text(hasDate ? c.date : _shortDate(c.createdAt), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
                IconButton(onPressed: () => context.read<LiverFunctionTestCubit>().delete(c.id!), icon: const Icon(Icons.delete_outline, color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(builder: (ctx, constraints) {
              final twoColumn = constraints.maxWidth > 600;
              final tiles = [_infoTile('TBill', c.tbill), _infoTile('DBill', c.dbill), _infoTile('TP', c.tp), _infoTile('Salb', c.salb), _infoTile('ALT', c.alt), _infoTile('AST', c.ast), _infoTile('ALP', c.alp), _infoTile('GGT', c.ggt)];
              return Wrap(
                runSpacing: 10,
                spacing: 12,
                children: tiles.map((w) => SizedBox(width: twoColumn ? (constraints.maxWidth - 48) / 3 : constraints.maxWidth - 48, child: w)).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ========== KIDNEY FUNCTION TEST METHODS ==========

  Future<void> _openAddKidneyDialog(BuildContext ctx) async {
    try {
      final pState = ctx.read<PatientCubit>().state;
      if (pState.selectedIds.isEmpty) {
        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Select a patient first')));
        return;
      }
      final pid = pState.selectedIds.first;

      final result = await showDialog<KidneyFunctionTest?>(
        context: ctx,
        builder: (_) => AddKidneyDialog(pid: pid),
      );

      if (result != null) {
        try {
          await ctx.read<KidneyFunctionTestCubit>().add(result);
        } catch (_) {
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Kidney test provider not found')));
        }
      }
    } catch (_) {}
  }

  Widget _kidneyCard(KidneyFunctionTest c, BuildContext context) {
    final hasDate = c.date.trim().isNotEmpty;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF009688), Color(0xFF4DB6AC)]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(child: Text(hasDate ? c.date : _shortDate(c.createdAt), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))),
                IconButton(onPressed: () => context.read<KidneyFunctionTestCubit>().delete(c.id!), icon: const Icon(Icons.delete_outline, color: Colors.white)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(builder: (ctx, constraints) {
              final twoColumn = constraints.maxWidth > 600;
              final tiles = [_infoTile('S.Creatinine', c.sCreatinine), _infoTile('Urea', c.urea), _infoTile('UA', c.ua), _infoTile('Na', c.na), _infoTile('K', c.k), _infoTile('Ca', c.ca), _infoTile('Mg', c.mg), _infoTile('Po4', c.po4), _infoTile('PTH', c.pth)];
              return Wrap(
                runSpacing: 10,
                spacing: 12,
                children: tiles.map((w) => SizedBox(width: twoColumn ? (constraints.maxWidth - 48) / 3 : constraints.maxWidth - 48, child: w)).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class AddCbcDialog extends StatefulWidget {
  final int pid;
  const AddCbcDialog({super.key, required this.pid});

  @override
  State<AddCbcDialog> createState() => _AddCbcDialogState();
}

class _AddCbcDialogState extends State<AddCbcDialog> {
  final _formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final hbCtrl = TextEditingController();
  final rbCtrl = TextEditingController();
  final mcvCtrl = TextEditingController();
  final mchCtrl = TextEditingController();
  final tlcCtrl = TextEditingController();
  final neutCtrl = TextEditingController();
  final lymphCtrl = TextEditingController();
  final monoCtrl = TextEditingController();
  final eosCtrl = TextEditingController();
  final basoCtrl = TextEditingController();
  final pttCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // default the date field to today's date so users don't have to pick it
    final now = DateTime.now();
    dateCtrl.text = '${now.day}/${now.month}/${now.year}';
  }

  @override
  void dispose() {
    dateCtrl.dispose();
    hbCtrl.dispose();
    rbCtrl.dispose();
    mcvCtrl.dispose();
    mchCtrl.dispose();
    tlcCtrl.dispose();
    neutCtrl.dispose();
    lymphCtrl.dispose();
    monoCtrl.dispose();
    eosCtrl.dispose();
    basoCtrl.dispose();
    pttCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // ensure a date is set (should already be set by initState)
    if (dateCtrl.text.trim().isEmpty) {
      final now = DateTime.now();
      dateCtrl.text = '${now.day}/${now.month}/${now.year}';
    }
    final c = Cbc(
      patientId: widget.pid,
      date: dateCtrl.text.trim(),
      hb: hbCtrl.text.trim(),
      rbcs: rbCtrl.text.trim(),
      mcv: mcvCtrl.text.trim(),
      mch: mchCtrl.text.trim(),
      tlc: tlcCtrl.text.trim(),
      neut: neutCtrl.text.trim(),
      lymph: lymphCtrl.text.trim(),
      mono: monoCtrl.text.trim(),
      eos: eosCtrl.text.trim(),
      baso: basoCtrl.text.trim(),
      ptt: pttCtrl.text.trim(),
    );
    Navigator.of(context).pop(c);
  }

  InputDecoration _dec(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add CBC', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(child: TextFormField(controller: dateCtrl, decoration: _dec('Date'), validator: (_) => null)),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [Expanded(child: TextFormField(controller: hbCtrl, decoration: _dec('Hb'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: rbCtrl, decoration: _dec('RBCs')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: mcvCtrl, decoration: _dec('MCV'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: mchCtrl, decoration: _dec('MCH')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: tlcCtrl, decoration: _dec('TLC'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: neutCtrl, decoration: _dec('Neut')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: lymphCtrl, decoration: _dec('Lymph'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: monoCtrl, decoration: _dec('Mono')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: eosCtrl, decoration: _dec('Eos'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: basoCtrl, decoration: _dec('Baso')))]),
                      const SizedBox(height: 8),
                      TextFormField(controller: pttCtrl, decoration: _dec('PTT')),

                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _submit,
                            child: const Text('Save'),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCoagulationDialog extends StatefulWidget {
  final int pid;
  const AddCoagulationDialog({super.key, required this.pid});

  @override
  State<AddCoagulationDialog> createState() => _AddCoagulationDialogState();
}

class _AddCoagulationDialogState extends State<AddCoagulationDialog> {
  final _formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final ptCtrl = TextEditingController();
  final pttCtrl = TextEditingController();
  final inrCtrl = TextEditingController();
  final pcCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // default the date field to today's date so users don't have to pick it
    final now = DateTime.now();
    dateCtrl.text = '${now.day}/${now.month}/${now.year}';
  }

  @override
  void dispose() {
    dateCtrl.dispose();
    ptCtrl.dispose();
    pttCtrl.dispose();
    inrCtrl.dispose();
    pcCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // ensure a date is set (should already be set by initState)
    if (dateCtrl.text.trim().isEmpty) {
      final now = DateTime.now();
      dateCtrl.text = '${now.day}/${now.month}/${now.year}';
    }
    final c = CoagulationProfile(
      patientId: widget.pid,
      date: dateCtrl.text.trim(),
      pt: ptCtrl.text.trim(),
      ptt: pttCtrl.text.trim(),
      inr: inrCtrl.text.trim(),
      pc: pcCtrl.text.trim(),
    );
    Navigator.of(context).pop(c);
  }

  InputDecoration _dec(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Coagulation Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(child: TextFormField(controller: dateCtrl, decoration: _dec('Date'), validator: (_) => null)),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [Expanded(child: TextFormField(controller: ptCtrl, decoration: _dec('PT'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: pttCtrl, decoration: _dec('PTT')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: pcCtrl, decoration: _dec('PC'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: inrCtrl, decoration: _dec('INR')))]),
                      
                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _submit,
                            child: const Text('Save'),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddLiverDialog extends StatefulWidget {
  final int pid;
  const AddLiverDialog({super.key, required this.pid});

  @override
  State<AddLiverDialog> createState() => _AddLiverDialogState();
}

class _AddLiverDialogState extends State<AddLiverDialog> {
  final _formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final tbillCtrl = TextEditingController();
  final dbillCtrl = TextEditingController();
  final tpCtrl = TextEditingController();
  final salbCtrl = TextEditingController();
  final altCtrl = TextEditingController();
  final astCtrl = TextEditingController();
  final alpCtrl = TextEditingController();
  final ggtCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // default the date field to today's date so users don't have to pick it
    final now = DateTime.now();
    dateCtrl.text = '${now.day}/${now.month}/${now.year}';
  }

  @override
  void dispose() {
    dateCtrl.dispose();
    tbillCtrl.dispose();
    dbillCtrl.dispose();
    tpCtrl.dispose();
    salbCtrl.dispose();
    altCtrl.dispose();
    astCtrl.dispose();
    alpCtrl.dispose();
    ggtCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // ensure a date is set (should already be set by initState)
    if (dateCtrl.text.trim().isEmpty) {
      final now = DateTime.now();
      dateCtrl.text = '${now.day}/${now.month}/${now.year}';
    }
    final c = LiverFunctionTest(
      patientId: widget.pid,
      date: dateCtrl.text.trim(),
      tbill: tbillCtrl.text.trim(),
      dbill: dbillCtrl.text.trim(),
      tp: tpCtrl.text.trim(),
      salb: salbCtrl.text.trim(),
      alt: altCtrl.text.trim(),
      ast: astCtrl.text.trim(),
      alp: alpCtrl.text.trim(),
      ggt: ggtCtrl.text.trim(),
    );
    Navigator.of(context).pop(c);
  }

  InputDecoration _dec(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Liver Function Test', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(child: TextFormField(controller: dateCtrl, decoration: _dec('Date'), validator: (_) => null)),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [Expanded(child: TextFormField(controller: tbillCtrl, decoration: _dec('T.Bil'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: dbillCtrl, decoration: _dec('D.Bil')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: tpCtrl, decoration: _dec('TP'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: salbCtrl, decoration: _dec('Salb')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: altCtrl, decoration: _dec('ALT'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: astCtrl, decoration: _dec('AST')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: alpCtrl, decoration: _dec('ALP'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: ggtCtrl, decoration: _dec('GGT')))]),

                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _submit,
                            child: const Text('Save'),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddKidneyDialog extends StatefulWidget {
  final int pid;
  const AddKidneyDialog({super.key, required this.pid});

  @override
  State<AddKidneyDialog> createState() => _AddKidneyDialogState();
}

class _AddKidneyDialogState extends State<AddKidneyDialog> {
  final _formKey = GlobalKey<FormState>();
  final dateCtrl = TextEditingController();
  final sCreatinineCtrl = TextEditingController();
  final ureaCtrl = TextEditingController();
  final uaCtrl = TextEditingController();
  final naCtrl = TextEditingController();
  final kCtrl = TextEditingController();
  final caCtrl = TextEditingController();
  final mgCtrl = TextEditingController();
  final po4Ctrl = TextEditingController();
  final pthCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // default the date field to today's date so users don't have to pick it
    final now = DateTime.now();
    dateCtrl.text = '${now.day}/${now.month}/${now.year}';
  }

  @override
  void dispose() {
    dateCtrl.dispose();
    sCreatinineCtrl.dispose();
    ureaCtrl.dispose();
    uaCtrl.dispose();
    naCtrl.dispose();
    kCtrl.dispose();
    caCtrl.dispose();
    mgCtrl.dispose();
    po4Ctrl.dispose();
    pthCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) dateCtrl.text = '${picked.day}/${picked.month}/${picked.year}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // ensure a date is set (should already be set by initState)
    if (dateCtrl.text.trim().isEmpty) {
      final now = DateTime.now();
      dateCtrl.text = '${now.day}/${now.month}/${now.year}';
    }
    final c = KidneyFunctionTest(
      patientId: widget.pid,
      date: dateCtrl.text.trim(),
      sCreatinine: sCreatinineCtrl.text.trim(),
      urea: ureaCtrl.text.trim(),
      ua: uaCtrl.text.trim(),
      na: naCtrl.text.trim(),
      k: kCtrl.text.trim(),
      ca: caCtrl.text.trim(),
      mg: mgCtrl.text.trim(),
      po4: po4Ctrl.text.trim(),
      pth: pthCtrl.text.trim(),
    );
    Navigator.of(context).pop(c);
  }

  InputDecoration _dec(String label) => InputDecoration(labelText: label, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none));

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Kidney Function Test', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close, color: Colors.white)),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickDate,
                        child: AbsorbPointer(child: TextFormField(controller: dateCtrl, decoration: _dec('Date'), validator: (_) => null)),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [Expanded(child: TextFormField(controller: sCreatinineCtrl, decoration: _dec('S.Creatinine'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: ureaCtrl, decoration: _dec('Urea')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: uaCtrl, decoration: _dec('UA'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: naCtrl, decoration: _dec('Na')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: kCtrl, decoration: _dec('K'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: caCtrl, decoration: _dec('Ca')))]),
                      const SizedBox(height: 8),
                      Row(children: [Expanded(child: TextFormField(controller: mgCtrl, decoration: _dec('Mg'))), const SizedBox(width: 8), Expanded(child: TextFormField(controller: po4Ctrl, decoration: _dec('Po4')))]),
                      const SizedBox(height: 8),
                      TextFormField(controller: pthCtrl, decoration: _dec('PTH')),

                      const SizedBox(height: 14),
                      Row(children: [
                        Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: _submit,
                            child: const Text('Save'),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}