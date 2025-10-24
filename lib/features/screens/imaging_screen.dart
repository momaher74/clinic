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
        appBar: AppBar(
          title: const Text('Imaging'),
          centerTitle: true,
          elevation: 1,
        ),
        body: BlocBuilder<ImagingCubit, ImagingState>(builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Modern header
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Icon(Icons.photo_library_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Imaging', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Save images and reports — files are copied into the app storage', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _openAddDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Contents
                Expanded(
                  child: state.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.photo_album_outlined, size: 72, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              const Text('No imaging items yet', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      : LayoutBuilder(builder: (context, constraints) {
                          final crossAxis = (constraints.maxWidth ~/ 260).clamp(1, 4);
                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxis,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 3.2,
                            ),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return _ImagingCard(item: item, onDelete: () => cubit!.removeItem(item.id));
                            },
                          );
                        }),
                ),
              ],
            ),
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: _openAddDialog,
          child: const Icon(Icons.add),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // Fullscreen image preview dialog
  Future<void> _showImagePreview(String imagePath, String title) async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title.isNotEmpty) Padding(padding: const EdgeInsets.all(12), child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            Flexible(child: Image.file(File(imagePath), fit: BoxFit.contain)),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        ),
      ),
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