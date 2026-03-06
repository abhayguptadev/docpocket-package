import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import '../services/app_provider.dart';
import '../models/category_model.dart';
import '../models/document_model.dart';
import 'category_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isSearching = provider.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "DocPocket",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (value) => context.read<AppProvider>().updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: "Search documents or categories",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (isSearching) ...[
              _buildSearchResults(context, provider),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Pinned",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildPinnedList(context),
              const SizedBox(height: 24),
              const Text(
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildCategoryGrid(context),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, AppProvider provider) {
    final filteredDocs = provider.filteredGlobalDocuments;
    final filteredCats = provider.filteredCategories;

    if (filteredDocs.isEmpty && filteredCats.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text("No results found", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredDocs.isNotEmpty) ...[
          const Text("Documents", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final doc = filteredDocs[index];
              final cat = provider.getCategoryById(doc.categoryId);
              return ListTile(
                leading: Icon(_getFileIcon(doc.filePath), color: Colors.blue),
                title: Text(doc.name),
                subtitle: Text("In ${cat?.name ?? 'Unknown'} • ${doc.fileSize}"),
                onTap: () => OpenFilex.open(doc.filePath),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
        if (filteredCats.isNotEmpty) ...[
          const Text("Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredCats.length,
            itemBuilder: (context, index) {
              final category = filteredCats[index];
              return _buildCategoryCard(context, category, index);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPinnedList(BuildContext context) {
    final pinnedDocs = context.watch<AppProvider>().pinnedDocuments;

    if (pinnedDocs.isEmpty) {
      return const Text("No pinned documents");
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: pinnedDocs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final doc = pinnedDocs[index];
          return GestureDetector(
            onTap: () => OpenFilex.open(doc.filePath),
            onLongPress: () => _showPinnedActions(context, doc),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Icon(Icons.description, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          "Added ${doc.dateAdded.day}/${doc.dateAdded.month}",
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = context.watch<AppProvider>().filteredCategories;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category, index);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, CategoryModel category, int index) {
    final docCount = context.read<AppProvider>().getDocumentsByCategory(category.id).length;
    final cardColor = index % 2 == 0 ? Colors.red[50] : Colors.blue[50];
    final accentColor = index % 2 == 0 ? Colors.red[600] : Colors.blue[600];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoryScreen(category: category)),
        );
      },
      onLongPress: () => _showCategoryActions(context, category),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: accentColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "$docCount docs",
                    style: TextStyle(color: accentColor?.withOpacity(0.7), fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accentColor, size: 18),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    if (ext == '.pdf') return Icons.picture_as_pdf;
    if (ext == '.jpg' || ext == '.jpeg' || ext == '.png') return Icons.image;
    return Icons.insert_drive_file;
  }

  void _showCategoryActions(BuildContext context, CategoryModel category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Category Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text("Delete Category", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDeleteCategory(context, category);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteCategory(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Category?"),
        content: Text("Are you sure you want to delete '${category.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<AppProvider>().deleteCategory(category.id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPinnedActions(BuildContext context, DocumentModel doc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return ListTile(
          leading: const Icon(Icons.star_outline, color: Colors.blue),
          title: const Text("Unpin from home"),
          onTap: () {
            context.read<AppProvider>().togglePin(doc);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Category"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Category Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<AppProvider>().addCategory(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
