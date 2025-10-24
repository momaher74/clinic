import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/liver_function_test.dart';
import 'package:clinic/features/managers/labs/liver_function_test/liver_function_test_cubit.dart';

class LiverFunctionSection extends StatelessWidget {
  final Patient patient;
  const LiverFunctionSection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiverFunctionTestCubit, LiverFunctionTestState>(
      builder: (context, state) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());

        if (state.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Liver Function', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                _buildAddButton(context),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Liver Function', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildAddButton(context),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.list.length,
                  itemBuilder: (context, index) {
                    final item = state.list[index];
                    return _buildCard(context, item);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)]),
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
              children: const [Icon(Icons.add, color: Colors.white, size: 18), SizedBox(width: 8), Text('Add LFT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, LiverFunctionTest item) {
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
        children: [
          Container(
            width: 6,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
          ),
          const SizedBox(width: 12),
          const Padding(
            padding: EdgeInsets.only(left: 6, right: 6),
            child: CircleAvatar(radius: 22, backgroundColor: Color(0xFFEEF2FF), child: Icon(Icons.biotech, color: Color(0xFF3B82F6))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(item.date),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _infoChip('TBIL', item.tbill),
                      _infoChip('DBIL', item.dbill),
                      _infoChip('TP', item.tp),
                      _infoChip('sAlb', item.salb),
                      _infoChip('ALT', item.alt),
                      _infoChip('AST', item.ast),
                      _infoChip('ALP', item.alp),
                      _infoChip('GGT', item.ggt),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(onPressed: () => context.read<LiverFunctionTestCubit>().delete(item.id!), icon: const Icon(Icons.delete_outline, color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
    } catch (_) {}
    return raw.contains('T') ? raw.split('T').first : raw;
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(value: context.read<LiverFunctionTestCubit>(), child: AddLftDialog(patientId: patient.id!)),
    );
  }

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
}

class AddLftDialog extends StatefulWidget {
  final int patientId;
  const AddLftDialog({super.key, required this.patientId});

  @override
  State<AddLftDialog> createState() => _AddLftDialogState();
}

class _AddLftDialogState extends State<AddLftDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
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
    _date = DateTime.now();
  }

  @override
  void dispose() {
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
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: now);
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;
    final item = LiverFunctionTest(
      patientId: widget.patientId,
      date: _date!.toIso8601String(),
      tbill: tbillCtrl.text.trim(),
      dbill: dbillCtrl.text.trim(),
      tp: tpCtrl.text.trim(),
      salb: salbCtrl.text.trim(),
      alt: altCtrl.text.trim(),
      ast: astCtrl.text.trim(),
      alp: alpCtrl.text.trim(),
      ggt: ggtCtrl.text.trim(),
    );
    try {
      await context.read<LiverFunctionTestCubit>().add(item);
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding LFT: $e');
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
            gradient: LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    const Text('Add LFT', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: InputDecoration(labelText: 'Date', border: const OutlineInputBorder(), filled: true, fillColor: Colors.grey.shade50),
                          child: Text(_date == null ? 'Select Date' : '${_date!.day}/${_date!.month}/${_date!.year}'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _CustomTextField(controller: tbillCtrl, label: 'TBIL'),
                      _CustomTextField(controller: dbillCtrl, label: 'DBIL'),
                      _CustomTextField(controller: tpCtrl, label: 'TP'),
                      _CustomTextField(controller: salbCtrl, label: 'sAlb'),
                      _CustomTextField(controller: altCtrl, label: 'ALT'),
                      _CustomTextField(controller: astCtrl, label: 'AST'),
                      _CustomTextField(controller: alpCtrl, label: 'ALP'),
                      _CustomTextField(controller: ggtCtrl, label: 'GGT'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.centerLeft, end: Alignment.centerRight),
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
                                  children: const [Icon(Icons.check, color: Colors.white, size: 20), SizedBox(width: 10), Text('Add LFT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))],
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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _CustomTextField({Key? key, required this.controller, this.label = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
    );
  }
}
