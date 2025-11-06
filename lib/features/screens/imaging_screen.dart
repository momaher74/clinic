import 'dart:io';
import 'dart:math';

import 'package:clinic/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/services/image_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/manager/imaging_cubit.dart';
import '../../core/models/imaging_item.dart';
import '../../core/models/patient.dart';

class ImagingScreen extends StatefulWidget {
  final Patient? patient;

  const ImagingScreen({super.key, this.patient});

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
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Imaging'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
          ),
          body: BlocBuilder<ImagingCubit, ImagingState>(
            builder: (context, state) {
              // filter items for selected patient (if any)
              final selectedPatientId = widget.patient?.id;
              final visibleItems = selectedPatientId == null
                  ? state.items
                  : state.items
                        .where((i) => i.patientId == selectedPatientId)
                        .toList();
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Modern header

                    // Contents
                    Expanded(
                      child: visibleItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.photo_album_outlined,
                                    size: 72,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No imaging items yet',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: visibleItems.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = visibleItems[index];
                                return _ImagingCard(
                                  item: item,
                                  onDelete: () => cubit!.removeItem(item.id),
                                  onPreview: (path, title) =>
                                      _showImagePreview(path, title),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openAddDialog,
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
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
        return StatefulBuilder(
          builder: (context, setState) {
            if (pickedPath != null) {
              /* pickedPath used below for preview */
            }

            final isSaveEnabled =
                (typeCtl.text.trim().isNotEmpty && pickedPath != null);

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header (white background)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Add Imaging',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Type
                          TextField(
                            controller: typeCtl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Type',
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
                          const SizedBox(height: 12),

                          // Doctor
                          TextField(
                            controller: doctorCtl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Doctor',
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
                          const SizedBox(height: 12),

                          // Where
                          TextField(
                            controller: whereCtl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Where',
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
                          const SizedBox(height: 12),

                          // Report
                          TextField(
                            controller: reportCtl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Report',
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
                            maxLines: 4,
                          ),

                          const SizedBox(height: 12),

                          // File picker + preview
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () async {
                                  // Use ImageService to pick and persist the image so
                                  // it remains available even if the original file
                                  // is moved/deleted.
                                  final stored =
                                      await ImageService.pickAndStoreImage();
                                  if (stored != null)
                                    setState(() => pickedPath = stored);
                                },
                                icon: const Icon(
                                  Icons.folder_open,
                                  color: Colors.white,
                                ),
                                label: Text('Select file', style: whiteStyle),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: const Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // preview box
                              if (pickedPath != null)
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(pickedPath!),
                                      height: 84,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              else
                                Expanded(
                                  child: Container(
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'No file selected',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                      child: Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          const Spacer(),
                          // Gradient Save button
                          ElevatedButton(
                            onPressed: isSaveEnabled
                                ? () async {
                                    final file = File(pickedPath!);
                                    await cubit!.addItem(
                                      type: typeCtl.text.trim(),
                                      doctor: doctorCtl.text.trim(),
                                      where: whereCtl.text.trim(),
                                      report: reportCtl.text.trim(),
                                      imageFile: file,
                                      patientId: widget.patient?.id,
                                    );
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Done', style: whiteStyle),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Fullscreen image preview dialog
  Future<void> _showImagePreview(String imagePath, String title) async {
    // show a polished preview dialog with zoom/pan support
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final mq = MediaQuery.of(context).size;
        final maxWidth = mq.width * 0.8;
        final maxHeight = mq.height * 0.8;

        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: Colors.white,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.white,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Image area
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: InteractiveViewer(
                          panEnabled: true,
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Center(
                            child: Image.file(
                              File(imagePath),
                              fit: BoxFit.contain,
                              width: double.infinity,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImagingCard extends StatelessWidget {
  final ImagingItem item;
  final VoidCallback onDelete;
  final void Function(String imagePath, String title)? onPreview;

  const _ImagingCard({
    required this.item,
    required this.onDelete,
    this.onPreview,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPreview?.call(item.imagePath, item.type),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxH =
                constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : 180.0;
            final maxW =
                constraints.maxWidth.isFinite && constraints.maxWidth > 0
                ? constraints.maxWidth
                : 360.0;
            final imageWidth = min(140.0, maxW * 0.36);

            return Row(
              children: [
                // image preview area with overlay, height matches available height
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: imageWidth,
                    height: maxH,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (item.imagePath.isNotEmpty &&
                            File(item.imagePath).existsSync())
                          Image.file(File(item.imagePath), fit: BoxFit.cover)
                        else
                          Container(
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  onPreview?.call(item.imagePath, item.type),
                              child: Container(
                                alignment: Alignment.center,
                                color: Colors.black.withOpacity(0.04),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.open_in_full,
                                    color: Colors.black54,
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
                const SizedBox(width: 12),
                // details column that adapts to available height
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: maxH,
                      maxHeight: maxH,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.type,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text('Delete'),
                                        content: const Text(
                                          'Delete this imaging item?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(c).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(c).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) onDelete();
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // metadata and report (flexible so it can shrink on small tiles)
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.doctor.isNotEmpty)
                                  Text(
                                    'Doctor: ${item.doctor}',
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (item.where.isNotEmpty)
                                  Text(
                                    'Where: ${item.where}',
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 6),
                                if (item.report.isNotEmpty)
                                  Text(
                                    item.report,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                              ],
                            ),
                          ),

                          // added timestamp at bottom
                          Text(
                            'Added: ${DateTime.fromMillisecondsSinceEpoch(item.createdAt)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
