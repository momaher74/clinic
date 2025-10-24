import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/virology.dart';
import 'package:clinic/features/managers/labs/virology/virology_cubit.dart';

class VirologySection extends StatelessWidget {
  final Patient patient;
  const VirologySection({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<VirologyCubit>().loadForPatient(patient.id!, force: true);
      } catch (_) {}
    });

    return BlocBuilder<VirologyCubit, VirologyState>(
      builder: (context, state) {
        if (state.isLoading) return const Center(child: CircularProgressIndicator());

        if (state.list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Virology', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    _buildAddButton(context),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('No virology records', style: TextStyle(fontSize: 13, color: Colors.black54)),
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
         
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Virology', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  _buildAddButton(context),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state.list.map((item) => _buildCard(context, item)).toList(),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
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
                Text('Add Virology', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }

   Widget _buildCard(BuildContext context, Virology item) {
     return Container(
       margin: const EdgeInsets.symmetric(vertical: 6),
       decoration: BoxDecoration(
         color: Colors.blue.shade50,
         borderRadius: BorderRadius.circular(14),
         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))],
       ),
       child: Row(
         children: [
           Container(
             width: 6,
             height: 160,
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
                       _infoChip('HAV IgM', item.havIgm),
                       _infoChip('HAV IgG', item.havIgG),
                       _infoChip('HBsAg', item.hbsAg),
                       _infoChip('HBsAb', item.hbsAb),
                       _infoChip('HBC IgM', item.hbcIgM),
                       _infoChip('HBC IgG', item.hbcIgG),
                       _infoChip('HBeAg', item.hbeAg),
                       _infoChip('HBeAb', item.hbeAb),
                       _infoChip('HCV Ab', item.hcvAb),
                       _infoChip('HIV Ab I/II', item.hivAbI_II),
                       _infoChip('HBV DNA PCR', item.hbvDnaPcr),
                       _infoChip('HCV RNA PCR', item.hcvRnaPcr),
                     ],
                   ),
                 ],
               ),
             ),
           ),
           Padding(
             padding: const EdgeInsets.only(right: 8.0),
             child: IconButton(onPressed: () => context.read<VirologyCubit>().delete(item.id!), icon: const Icon(Icons.delete_outline, color: Colors.grey)),
           ),
         ],
       ),
     );
   }

   String _formatDate(String raw) {
     try {
       final parsed = DateTime.tryParse(raw);
       if (parsed != null) return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
     } catch (_) {}
     return raw.contains('T') ? raw.split('T').first : raw;
   }

   void _showAddDialog(BuildContext context) {
     showDialog(
       context: context,
       builder: (dialogContext) => BlocProvider.value(value: context.read<VirologyCubit>(), child: AddVirologyDialog(patientId: patient.id!)),
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

class AddVirologyDialog extends StatefulWidget {
  final int patientId;
  const AddVirologyDialog({Key? key, required this.patientId}) : super(key: key);

  @override
  State<AddVirologyDialog> createState() => _AddVirologyDialogState();
}

class _AddVirologyDialogState extends State<AddVirologyDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;

  final havIgmCtrl = TextEditingController();
  final havIggCtrl = TextEditingController();
  final hbsAgCtrl = TextEditingController();
  final hbsAbCtrl = TextEditingController();
  final hbcIgMCtrl = TextEditingController();
  final hbcIggCtrl = TextEditingController();
  final hbeAgCtrl = TextEditingController();
  final hbeAbCtrl = TextEditingController();
  final hcvAbCtrl = TextEditingController();
  final hivAbCtrl = TextEditingController();
  final hbvDnaCtrl = TextEditingController();
  final hcvRnaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    havIgmCtrl.dispose();
    havIggCtrl.dispose();
    hbsAgCtrl.dispose();
    hbsAbCtrl.dispose();
    hbcIgMCtrl.dispose();
    hbcIggCtrl.dispose();
    hbeAgCtrl.dispose();
    hbeAbCtrl.dispose();
    hcvAbCtrl.dispose();
    hivAbCtrl.dispose();
    hbvDnaCtrl.dispose();
    hcvRnaCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;

    final item = Virology(
      patientId: widget.patientId,
      date: _date!.toIso8601String(),
      havIgm: havIgmCtrl.text.trim().isEmpty ? null : havIgmCtrl.text.trim(),
      havIgG: havIggCtrl.text.trim().isEmpty ? null : havIggCtrl.text.trim(),
      hbsAg: hbsAgCtrl.text.trim().isEmpty ? null : hbsAgCtrl.text.trim(),
      hbsAb: hbsAbCtrl.text.trim().isEmpty ? null : hbsAbCtrl.text.trim(),
      hbcIgM: hbcIgMCtrl.text.trim().isEmpty ? null : hbcIgMCtrl.text.trim(),
      hbcIgG: hbcIggCtrl.text.trim().isEmpty ? null : hbcIggCtrl.text.trim(),
      hbeAg: hbeAgCtrl.text.trim().isEmpty ? null : hbeAgCtrl.text.trim(),
      hbeAb: hbeAbCtrl.text.trim().isEmpty ? null : hbeAbCtrl.text.trim(),
      hcvAb: hcvAbCtrl.text.trim().isEmpty ? null : hcvAbCtrl.text.trim(),
      hivAbI_II: hivAbCtrl.text.trim().isEmpty ? null : hivAbCtrl.text.trim(),
      hbvDnaPcr: hbvDnaCtrl.text.trim().isEmpty ? null : hbvDnaCtrl.text.trim(),
      hcvRnaPcr: hcvRnaCtrl.text.trim().isEmpty ? null : hcvRnaCtrl.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await context.read<VirologyCubit>().add(item);
      Navigator.of(context).pop();
    } catch (e) {
      // handle error (optional: show snackbar)
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: now);
    if (picked != null) setState(() => _date = picked);
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
                    const Text('Add Virology', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
                      _TextField(controller: havIgmCtrl, label: 'HAV IgM'),
                      _TextField(controller: havIggCtrl, label: 'HAV IgG'),
                      _TextField(controller: hbsAgCtrl, label: 'HBsAg'),
                      _TextField(controller: hbsAbCtrl, label: 'HBsAb'),
                      _TextField(controller: hbcIgMCtrl, label: 'HBC IgM'),
                      _TextField(controller: hbcIggCtrl, label: 'HBC IgG'),
                      _TextField(controller: hbeAgCtrl, label: 'HBeAg'),
                      _TextField(controller: hbeAbCtrl, label: 'HBeAb'),
                      _TextField(controller: hcvAbCtrl, label: 'HCV Ab'),
                      _TextField(controller: hivAbCtrl, label: 'HIV Ab I/II'),
                      _TextField(controller: hbvDnaCtrl, label: 'HBV DNA PCR'),
                      _TextField(controller: hcvRnaCtrl, label: 'HCV RNA PCR'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 4))],
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
                                  children: const [Icon(Icons.check, color: Colors.white, size: 20), SizedBox(width: 10), Text('Add Virology', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16))],
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

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _TextField({Key? key, required this.controller, this.label = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
