import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/features/managers/add_user/add_user/patient_cubit.dart';
import 'package:clinic/features/managers/add_user/add_user/patient_state.dart';

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
 
  final TextEditingController _searchCtrl = TextEditingController();
  @override
  void initState() {
    super.initState();


    context.read<PatientCubit>().loadPatients();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() => context.read<PatientCubit>().search(_searchCtrl.text);

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    // Do not call context.read<PatientCubit>() here — looking up ancestors during dispose can be unsafe.
    // The cubit should be closed where it was created. If this widget created the cubit, store a reference and close it instead.
    super.dispose();
  }

  Future<void> _showAddDialog() async {
    final result = await showDialog<Patient?>(
      context: context,
      builder: (_) => const AddPatientDialog(),
    );

    if (result != null) {
      await context.read<PatientCubit>().addPatient(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<PatientCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title:  Text('Patients' , style: const TextStyle(color: Colors.black87 , fontWeight: FontWeight.bold , fontSize: 16),),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            
            preferredSize: const Size.fromHeight(72),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _searchCtrl,
                          label: 'Search by name, mobile or residency',
                          prefixIcon: Icons.search,
                          validator: (_) => null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _showAddDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                        ),
                        child:  Icon(Icons.add , color: Colors.white,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),

        body: BlocBuilder<PatientCubit, PatientState>(
          builder: (context, state) {
            if (state.isLoading) return const Center(child: CircularProgressIndicator());
            final list = state.filtered;
            if (list.isEmpty) return const Center(child: Text('No patients found'));
            return Container(
              color: Colors.white,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = list[index];
                  final selected = p.id != null && state.selectedIds.contains(p.id);
              
                  return GestureDetector(
                    onLongPress: () => context.read<PatientCubit>().toggleSelection(p.id!),
                    onTap: () {
                      if (state.selectedIds.isNotEmpty) context.read<PatientCubit>().toggleSelection(p.id!);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
                          width: selected ? 1.8 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Single-selection checkbox
                            Checkbox(
                              value: selected,
                              onChanged: (v) => context.read<PatientCubit>().toggleSelection(p.id!),
                            ),
              
                            const SizedBox(width: 8),
              
                            // Patient details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                      Column(
                                        children: [
                                          Text('${p.age} Y', style: TextStyle(color: Colors.grey.shade700)),
                                          IconButton(
                                            onPressed: () => context.read<PatientCubit>().deletePatient(p.id!),
                                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const SizedBox(height: 8),
              
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 6,
                                    children: [
                                      _infoChip(Icons.cake_outlined, _formatDate(p.birthdate)),
                                      _infoChip(Icons.male_outlined, p.sex),
                                      _infoChip(Icons.home_outlined, p.residency),
                                      _infoChip(Icons.phone_outlined, p.mobile),
                                    ],
                                  ),
              
                                  if (p.note != null && p.note!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text('Note: ${p.note}', style: TextStyle(color: Colors.grey.shade700)),
                                  ],
                                ],
                              ),
                            ),
              
                            // Action icons
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

// ------------------------- Add Patient Dialog (beautified) -------------------------
class AddPatientDialog extends StatefulWidget {
  const AddPatientDialog({super.key});

  @override
  State<AddPatientDialog> createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final residencyCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final noteCtrl = TextEditingController();
  DateTime? _birthdate;
  String _sex = 'Male';

  int _calculateAge(DateTime bd) {
    final now = DateTime.now();
    int age = now.year - bd.year;
    if (now.month < bd.month || (now.month == bd.month && now.day < bd.day))
      age--;
    return age;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    residencyCtrl.dispose();
    mobileCtrl.dispose();
    noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _birthdate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _birthdate == null) return;
    final age = _calculateAge(_birthdate!);

    final patient = Patient(
      name: nameCtrl.text.trim(),
      birthdate: _birthdate!.toIso8601String(),
      age: age,
      sex: _sex,
      residency: residencyCtrl.text.trim(),
      mobile: mobileCtrl.text.trim(),
      note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
    );

    Navigator.of(context).pop(patient);
  }

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
            // Gradient header row with title and close icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Patient',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
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
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 6),
                      CustomTextField(
                        controller: nameCtrl,
                        label: 'Name',
                        prefixIcon: Icons.person,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      // birthdate + age + sex
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickBirthdate,
                              child: AbsorbPointer(
                                child: CustomTextField(
                                  controller: TextEditingController(
                                    text: _birthdate == null ? '' : '${_birthdate!.day}/${_birthdate!.month}/${_birthdate!.year}',
                                  ),
                                  label: 'Birthdate',
                                  prefixIcon: Icons.cake_outlined,
                                  validator: (_) => _birthdate == null ? 'Select birthdate' : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Text(_birthdate == null ? '-' : '${_calculateAge(_birthdate!)} Y', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(child: RadioListTile<String>(value: 'Male', groupValue: _sex, title: const Text('Male'), onChanged: (v) => setState(() => _sex = v!))),
                          Expanded(child: RadioListTile<String>(value: 'Female', groupValue: _sex, title: const Text('Female'), onChanged: (v) => setState(() => _sex = v!))),
                        ],
                      ),

                      const SizedBox(height: 12),
                      CustomTextField(controller: residencyCtrl, label: 'Residency', prefixIcon: Icons.home_outlined, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      CustomTextField(controller: mobileCtrl, label: 'Mobile', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
                      const SizedBox(height: 12),
                      CustomTextField(controller: noteCtrl, label: 'Note (optional)', prefixIcon: Icons.note_outlined, maxLines: 4, validator: (_) => null),

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel'))),
                          const SizedBox(width: 12),
                          Expanded(child: ElevatedButton(onPressed: _submit, child: const Text('Save'))),
                        ],
                      ),
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

// ------------------------- Custom Text Field -------------------------
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
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
    );
  }
}
