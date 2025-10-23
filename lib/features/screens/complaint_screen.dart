import 'package:clinic/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:clinic/core/models/patient.dart';
import 'package:clinic/core/models/complaint.dart';
import 'package:clinic/core/services/sql_service.dart';

class ComplaintScreen extends StatefulWidget {
  final Patient patient;
  const ComplaintScreen({super.key, required this.patient});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final DatabaseService _db = DatabaseService();
  final List<Complaint> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    await _db.createTableWithAttributes('complaints', ['patient_id','date','type','description']);
    final rows = await _db.getAll('complaints');
    _complaints.clear();
    _complaints.addAll(rows.map((r) => Complaint.fromMap(r)).where((c) => c.patientId == widget.patient.id));
    setState(() {});
  }

  Future<void> _addComplaint() async {
    final prev = _complaints.isNotEmpty ? _complaints.first.description : '';

    final result = await showDialog<Complaint?>(
      context: context,
      builder: (_) => AddComplaintDialog(initialDescription: prev, patientId: widget.patient.id!),
    );

    if (result != null) {
      final id = await _db.insert('complaints', result.toMap());
      result.id = id;
      _complaints.insert(0, result);
      setState(() {});
    }
  }

  String _formatDate(String iso) {
    final dt = DateTime.tryParse(iso) ?? DateTime.now();
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  Future<void> _confirmDelete(Complaint c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove complaint'),
        content: const Text('Are you sure you want to remove this complaint? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed != true) return;
    if (c.id == null) return;

    await _db.delete('complaints', c.id!);
    setState(() {
      _complaints.removeWhere((e) => e.id == c.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complaint removed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text('Complaints'), 
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor , width: 2),
                borderRadius: BorderRadius.circular(6),
                

              ),
              child: Text('— ${widget.patient.name}', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500))),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _complaints.isEmpty
          ? Center(child: Text('No complaints for ${widget.patient.name}', style: TextStyle(fontSize: 16, color: Colors.grey[700])))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _complaints.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final c = _complaints[i];
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  child: SizedBox(
                    height: 140,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      // Use a Row-based layout to avoid ListTile automatic sizing issues
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(Icons.comment, color: Colors.blue.shade700),
                          ),
                          const SizedBox(width: 12),
                          // Main content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                const SizedBox(height: 6),
                                Text(
                                  c.description,
                                  style: TextStyle(color: Colors.grey[800]),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Actions (date + delete)
                          const SizedBox(width: 12),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(_formatDate(c.date), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                backgroundColor: Colors.grey[100],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _confirmDelete(c),
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  tooltip: 'Remove complaint',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        
        onPressed: _addComplaint,
        icon:  Icon(Icons.add_comment_outlined , color: Colors.white,),
        label:  Text('New Complaint' , style: TextStyle(color: Colors.white),),
        backgroundColor: primaryColor,
      ),
    );
  }
}

class AddComplaintDialog extends StatefulWidget {
  final String initialDescription;
  final int patientId;
  const AddComplaintDialog({super.key, required this.initialDescription, required this.patientId});

  @override
  State<AddComplaintDialog> createState() => _AddComplaintDialogState();
}

class _AddComplaintDialogState extends State<AddComplaintDialog> {
  String _type = 'Check';
  final _descCtrl = TextEditingController();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _descCtrl.text = widget.initialDescription;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    final c = Complaint(
      patientId: widget.patientId,
      date: _selectedDate.toIso8601String(),
      type: _type,
      description: _descCtrl.text.trim(),
    );
    Navigator.of(context).pop(c);
  }

  String _formatDate(DateTime dt) => '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

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
                    'Add Complaint',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 6),

                    // Type dropdown
                    DropdownButtonFormField<String>(
                      value: _type,
                      items: const [
                        DropdownMenuItem(value: 'Check', child: Text('Check')),
                        DropdownMenuItem(value: 'Recheck', child: Text('Recheck')),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? 'Check'),
                      decoration: InputDecoration(
                        labelText: 'Type',
                        prefixIcon: const Icon(Icons.comment),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Date field (picker)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: _pickDate,
                            child: AbsorbPointer(
                              child: TextFormField(
                                initialValue: _formatDate(_selectedDate),
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Description
                    TextFormField(
                      controller: _descCtrl,
                      minLines: 3,
                      maxLines: 6,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        prefixIcon: const Icon(Icons.description_outlined),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),

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
          ],
        ),
      ),
    );
  }
}