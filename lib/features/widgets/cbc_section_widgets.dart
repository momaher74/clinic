import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/cbc.dart';
import 'package:clinic/features/managers/labs/cbc/cbc_cubit.dart';

class CbcSection extends StatelessWidget {
  final Patient patient;

  const CbcSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    // Defensive reload: ensure CbcCubit loads patient data after first build (helps after restart)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<CbcCubit>().loadForPatient(patient.id!, force: true);
      } catch (_) {}
    });

    return BlocBuilder<CbcCubit, CbcState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'CBC',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Gradient add button (same style as in non-empty state)
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showAddDialog(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Add CBC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Show list of existing CBCs
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CBC',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    // Modern gradient Add button (replaces plain ElevatedButton)
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showAddDialog(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.add, color: Colors.white, size: 18),
                                SizedBox(width: 8),
                                Text('Add CBC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.list.length,
                    itemBuilder: (context, index) {
                      final cbc = state.list[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Accent strip
                            Container(
                              width: 6,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomLeft: Radius.circular(14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Icon/avatar
                            const Padding(
                              padding: EdgeInsets.only(left: 6, right: 6),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Color(0xFFEEF2FF),
                                child: Icon(Icons.bloodtype, color: Color(0xFF3B82F6)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      // format date nicely
                                      () {
                                        try {
                                          final parsed = DateTime.tryParse(cbc.date);
                                          if (parsed != null) {
                                            return '${parsed.day.toString().padLeft(2,'0')}/${parsed.month.toString().padLeft(2,'0')}/${parsed.year}';
                                          }
                                        } catch (_) {}
                                        return cbc.date.contains('T') ? cbc.date.split('T').first : cbc.date;
                                      }(),
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 8),
                                    // All CBC fields shown as chips for readability
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: [
                                        _infoChip('HB', cbc.hb),
                                        _infoChip('RBCS', cbc.rbcs),
                                        _infoChip('MCV', cbc.mcv),
                                        _infoChip('MCH', cbc.mch),
                                        _infoChip('TLC', cbc.tlc),
                                        _infoChip('Neut', cbc.neut),
                                        _infoChip('Lymph', cbc.lymph),
                                        _infoChip('Mono', cbc.mono),
                                        _infoChip('Eos', cbc.eos),
                                        _infoChip('Baso', cbc.baso),
                                        _infoChip('PTT', cbc.ptt),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Delete button
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                                onPressed: () => context.read<CbcCubit>().delete(cbc.id!),
                                tooltip: 'Delete',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CbcCubit>(),
        child: AddCbcDialog(patientId: patient.id!),
      ),
    );
  }
}

class AddCbcDialog extends StatefulWidget {
  final int patientId;

  const AddCbcDialog({super.key, required this.patientId});

  @override
  State<AddCbcDialog> createState() => _AddCbcDialogState();
}

class _AddCbcDialogState extends State<AddCbcDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  final hbCtrl = TextEditingController();
  final rbcsCtrl = TextEditingController();
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
    // default date is today
    _date = DateTime.now();
  }

  @override
  void dispose() {
    hbCtrl.dispose();
    rbcsCtrl.dispose();
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
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;
    final cbc = Cbc(
      patientId: widget.patientId,
      date: _date!.toIso8601String(),
      hb: hbCtrl.text.trim(),
      rbcs: rbcsCtrl.text.trim(),
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
    try {
      await context.read<CbcCubit>().add(cbc);
      Navigator.of(context).pop();
    } catch (e) {
      // Show error, but for now, just print
      print('Error adding CBC: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: SingleChildScrollView(
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
              // Gradient header row with title and close icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Text(
                      'Add CBC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // White card containing the form
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Date picker
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          child: Text(
                            _date == null
                                ? 'Select Date'
                                : '${_date!.day}/${_date!.month}/${_date!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Text fields
                      CustomTextField(controller: hbCtrl, label: 'HB'),
                      CustomTextField(controller: rbcsCtrl, label: 'RBCS'),
                      CustomTextField(controller: mcvCtrl, label: 'MCV'),
                      CustomTextField(controller: mchCtrl, label: 'MCH'),
                      CustomTextField(controller: tlcCtrl, label: 'TLC'),
                      CustomTextField(controller: neutCtrl, label: 'Neut'),
                      CustomTextField(controller: lymphCtrl, label: 'Lymph'),
                      CustomTextField(controller: monoCtrl, label: 'Mono'),
                      CustomTextField(controller: eosCtrl, label: 'Eos'),
                      CustomTextField(controller: basoCtrl, label: 'Baso'),
                      CustomTextField(controller: pttCtrl, label: 'PTT'),
                      const SizedBox(height: 16),
                      // Modern full-width gradient action button
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _submit,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.check, color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Add CBC',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Text Field (copied from patient_screen.dart)
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? prefixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label = '',
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon == null
              ? null
              : Icon(prefixIcon, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

// small helper to build uniform info chips
Widget _infoChip(String label, String? value) {
  return Chip(
    backgroundColor: Colors.grey.shade100,
    label: Text(
      '$label: ${value ?? '-'}',
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  );
}

// Helper: you can further customize pills/chips styles here if desired