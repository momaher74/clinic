import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/manager/imaging_cubit.dart';
import '../../core/models/imaging_item.dart';

class ImagingScreen extends StatefulWidget {
  const ImagingScreen({super.key});

  @override
  State<ImagingScreen> createState() => _ImagingScreenState();
}

class _ImagingScreenState extends State<ImagingScreen> {
  ImagingCubit? cubit;
  final _typeController = TextEditingController();
  final _doctorController = TextEditingController();
  final _whereController = TextEditingController();
  final _reportController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      cubit = ImagingCubit(prefs);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _typeController.dispose();
    _doctorController.dispose();
    _whereController.dispose();
    _reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted || (cubit == null)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: cubit!,
      child: Scaffold(
        appBar: AppBar(title: const Text('Imaging')),
        body: BlocBuilder<ImagingCubit, ImagingState>(builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header / instruction area. Use Add button (FAB) to open dialog for input.
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
                    child: Row(
                      children: const [
                        Icon(Icons.photo_camera, color: Colors.blue),
                        SizedBox(width: 12),
                        Expanded(child: Text('Tap "Add" to attach an image and enter type/doctor/where/report')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: state.items.isEmpty
                      ? const Center(child: Text('No imaging items yet'))
                      : ListView.separated(
                          itemCount: state.items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return _ImagingCard(item: item, onDelete: () => cubit!.removeItem(item.id));
                          },
                        ),
                ),
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAddDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
        ),
      ),
    );
  }

  Future<void> _openAddDialog() async {
    if (cubit == null) return;
    final typeCtl = TextEditingController();
    final doctorCtl = TextEditingController();
    final whereCtl = TextEditingController();
    final reportCtl = TextEditingController();
    String? pickedPath;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          Widget preview = const SizedBox.shrink();
          if (pickedPath != null) preview = Image.file(File(pickedPath!), width: 160, height: 160, fit: BoxFit.cover);

          return AlertDialog(
            title: const Text('Add Imaging'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: typeCtl, decoration: const InputDecoration(labelText: 'Type')),
                  const SizedBox(height: 8),
                  TextField(controller: doctorCtl, decoration: const InputDecoration(labelText: 'Doctor')),
                  const SizedBox(height: 8),
                  TextField(controller: whereCtl, decoration: const InputDecoration(labelText: 'Where')),
                  const SizedBox(height: 8),
                  TextField(controller: reportCtl, decoration: const InputDecoration(labelText: 'Report'), maxLines: 3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['png', 'jpg', 'jpeg', 'heic', 'bmp'],
                              allowMultiple: false,
                            );
                            if (result != null && result.files.isNotEmpty) {
                              final path = result.files.single.path;
                              if (path != null) {
                                setState(() => pickedPath = path);
                              } else {
                                final msg = 'Selected file has no path.';
                                print('FilePicker: $msg result=$result');
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                              }
                            }
                          } catch (e, st) {
                            print('FilePicker error: $e\n$st');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open file picker: $e')));
                          }
                        },
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Select file'),
                      ),
                      const SizedBox(width: 12),
                      Flexible(child: preview),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: (typeCtl.text.trim().isEmpty || pickedPath == null)
                    ? null
                    : () async {
                        final file = File(pickedPath!);
                        await cubit!.addItem(
                          type: typeCtl.text.trim(),
                          doctor: doctorCtl.text.trim(),
                          where: whereCtl.text.trim(),
                          report: reportCtl.text.trim(),
                          imageFile: file,
                        );
                        Navigator.of(context).pop();
                      },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }
}

class _ImagingCard extends StatelessWidget {
  final ImagingItem item;
  final VoidCallback onDelete;
  const _ImagingCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 96,
                height: 96,
                child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                    ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                    : Container(color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  if (item.doctor.isNotEmpty) ...[
                    Text('Doctor: ${item.doctor}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                  ],
                  if (item.where.isNotEmpty) ...[
                    Text('Where: ${item.where}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                  ],
                  if (item.report.isNotEmpty) ...[
                    Text(item.report, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                  ],
                  Text('Added: ${DateTime.fromMillisecondsSinceEpoch(item.createdAt)}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (c) => AlertDialog(
                    title: const Text('Delete'),
                    content: const Text('Delete this imaging item?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) onDelete();
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}