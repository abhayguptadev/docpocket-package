import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:open_filex/open_filex.dart';
import 'package:docpocket/src/models/category_model.dart';
import 'package:docpocket/src/models/document_model.dart';
import 'package:docpocket/src/services/app_provider.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryModel category;
  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final docs = provider.filteredDocuments(category.id);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (value) => provider.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: "Search in ${category.name}...",
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: docs.isEmpty
                ? const Center(child: Text("No documents found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      return _buildDocumentCard(context, doc);
                    },
                  ),
          ),

          // Scan Button at bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => _showAddDocumentBottomSheet(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blue[600],
                  elevation: 0,
                ),
                child: const Text(
                  "Scan Your Document",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentModel doc) {
    return GestureDetector(
      onTap: () async {
        final result = await OpenFilex.open(doc.filePath);
        if (result.type != ResultType.done) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Could not open file: ${result.message}")),
            );
          }
        }
      },
      onLongPress: () => _showDocumentActions(context, doc),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconBgColor(doc.filePath),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getFileIcon(doc.filePath),
                color: _getIconColor(doc.filePath),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_formatDate(doc.dateAdded)} • ${doc.fileSize}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                doc.isPinned ? Icons.star : Icons.star_border,
                color: doc.isPinned ? Colors.amber : Colors.grey[300],
                size: 22,
              ),
              onPressed: () => context.read<AppProvider>().togglePin(doc),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.pdf') return Icons.picture_as_pdf;
    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') return Icons.image;
    if (ext == '.doc' || ext == '.docx') return Icons.description;
    if (ext == '.xls' || ext == '.xlsx') return Icons.grid_on;
    return Icons.insert_drive_file;
  }

  Color _getIconColor(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.pdf') return Colors.red[600]!;
    if (ext == '.xls' || ext == '.xlsx') return Colors.green[600]!;
    if (ext == '.doc' || ext == '.docx') return Colors.blue[600]!;
    return Colors.orange[600]!;
  }

  Color _getIconBgColor(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.pdf') return Colors.red[50]!;
    if (ext == '.xls' || ext == '.xlsx') return Colors.green[50]!;
    if (ext == '.doc' || ext == '.docx') return Colors.blue[50]!;
    return Colors.orange[50]!;
  }

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}";
  }

  void _showAddDocumentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    "Add Document",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildActionIcon(context, Icons.camera_alt_outlined, "Camera", Colors.blue, _pickFromCamera),
                      _buildActionIcon(context, Icons.image_outlined, "Gallery", Colors.purple, _pickFromGallery),
                      _buildActionIcon(context, Icons.folder_open_outlined, "File Manager", Colors.green, _pickFromFile),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionIcon(BuildContext context, IconData icon, String label, Color color, Function(BuildContext) onTap) {
    return InkWell(
      onTap: () => onTap(context),
      child: SizedBox(
        width: 80,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.1)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      if (context.mounted) _showInitialRenameDialog(context, image.path, image.name);
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (context.mounted) _showInitialRenameDialog(context, image.path, image.name);
    }
  }

  Future<void> _pickFromFile(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      if (context.mounted) _showInitialRenameDialog(context, result.files.single.path!, result.files.single.name);
    }
  }

  void _showInitialRenameDialog(BuildContext context, String path, String defaultName) {
    final controller = TextEditingController(text: defaultName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Name Document"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Document Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            }, 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _saveDocument(context, path, controller.text);
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _saveDocument(BuildContext context, String path, String name) {
    final file = File(path);
    final sizeInBytes = file.lengthSync();
    String sizeText;
    if (sizeInBytes < 1024) {
      sizeText = "$sizeInBytes B";
    } else if (sizeInBytes < 1024 * 1024) {
      sizeText = "${(sizeInBytes / 1024).toStringAsFixed(1)} KB";
    } else {
      sizeText = "${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB";
    }
    
    context.read<AppProvider>().addDocument(
      categoryId: category.id,
      name: name,
      filePath: path,
      fileSize: sizeText,
    );
  }

  void _showDocumentActions(BuildContext context, DocumentModel doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(doc.isPinned ? Icons.star : Icons.star_border, color: Colors.blue),
                title: Text(doc.isPinned ? "Unpin from home" : "Pin to home"),
                onTap: () {
                  context.read<AppProvider>().togglePin(doc);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.blue),
                title: const Text("Rename document"),
                onTap: () {
                  Navigator.pop(context);
                  _showRenameDialog(context, doc);
                },
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_move_outlined, color: Colors.blue),
                title: const Text("Move to another category"),
                onTap: () {
                  Navigator.pop(context);
                  _showMoveDialog(context, doc);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.blue),
                title: const Text("Share document"),
                onTap: () {
                  Share.shareXFiles([XFile(doc.filePath)], text: doc.name);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Delete document", style: TextStyle(color: Colors.red)),
                onTap: () {
                  context.read<AppProvider>().deleteDocument(doc.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, DocumentModel doc) {
    final controller = TextEditingController(text: doc.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rename Document"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<AppProvider>().renameDocument(doc, controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Rename"),
          ),
        ],
      ),
    );
  }

  void _showMoveDialog(BuildContext context, DocumentModel doc) {
    final categories = context.read<AppProvider>().categories;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Move to Category"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ListTile(
                title: Text(cat.name),
                leading: Icon(IconData(cat.iconCode)),
                onTap: () {
                  context.read<AppProvider>().moveDocument(doc, cat.id);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
