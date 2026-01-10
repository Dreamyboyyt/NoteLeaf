import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/world_element.dart';
import 'package:noteleaf/viewmodels/world_building_viewmodel.dart';
import 'package:noteleaf/views/world_element_editor_view.dart';

class WorldBuildingTab extends StatefulWidget {
  final String projectId;

  const WorldBuildingTab({super.key, required this.projectId});

  @override
  State<WorldBuildingTab> createState() => _WorldBuildingTabState();
}

class _WorldBuildingTabState extends State<WorldBuildingTab> {
  late WorldBuildingViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  List<WorldElement> _filteredElements = [];

  @override
  void initState() {
    super.initState();
    _viewModel = WorldBuildingViewModel();
    _viewModel.loadWorldElements(widget.projectId);
    _searchController.addListener(_filterElements);
  }

  void _filterElements() {
    setState(() {
      _filteredElements = _viewModel.searchElements(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        body: Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search world elements...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer<WorldBuildingViewModel>(
                    builder: (context, viewModel, child) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: viewModel.availableTypes.map((type) {
                            final isSelected = viewModel.selectedType == type;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(_getTypeDisplayName(type)),
                                selected: isSelected,
                                onSelected: (selected) {
                                  viewModel.setSelectedType(type);
                                  _filterElements();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // World elements list
            Expanded(
              child: Consumer<WorldBuildingViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => viewModel.loadWorldElements(widget.projectId),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final elements = _searchController.text.isNotEmpty 
                      ? _filteredElements 
                      : viewModel.worldElements;

                  if (elements.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getTypeIcon(viewModel.selectedType),
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'No elements found'
                                : 'No world elements yet',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchController.text.isNotEmpty
                                ? 'Try adjusting your search terms'
                                : 'Start building your world by adding locations, lore, and more',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: elements.length,
                    itemBuilder: (context, index) {
                      final element = elements[index];
                      return _buildElementCard(element);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateElementDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildElementCard(WorldElement element) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(element.type),
          child: Icon(
            _getTypeIcon(element.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          element.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getTypeDisplayName(element.type),
              style: TextStyle(
                color: _getTypeColor(element.type),
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            if (element.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                element.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (element.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: element.tags.take(3).map((tag) => Chip(
                  label: Text(tag),
                  labelStyle: const TextStyle(fontSize: 10),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Duplicate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              _editElement(element);
            } else if (value == 'duplicate') {
              _duplicateElement(element);
            } else if (value == 'delete') {
              _showDeleteDialog(element);
            }
          },
        ),
        onTap: () => _editElement(element),
      ),
    );
  }

  void _editElement(WorldElement element) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorldElementEditorView(element: element),
      ),
    ).then((_) {
      _viewModel.loadWorldElements(widget.projectId);
      _filterElements();
    });
  }

  void _duplicateElement(WorldElement element) {
    _viewModel.createElement(
      widget.projectId,
      '${element.name} (Copy)',
      element.type,
      element.description,
      Map<String, String>.from(element.customFields),
      List<String>.from(element.tags),
    ).then((_) {
      _filterElements();
    });
  }

  void _showCreateElementDialog() {
    String selectedType = 'location';
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create World Element'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter element name',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: _viewModel.availableTypes
                    .where((type) => type != 'all')
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(_getTypeIcon(type), size: 16),
                              const SizedBox(width: 8),
                              Text(_getTypeDisplayName(type)),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final defaultFields = _viewModel.getDefaultFieldsForType(selectedType);
                  _viewModel.createElement(
                    widget.projectId,
                    nameController.text.trim(),
                    selectedType,
                    '',
                    defaultFields,
                    [],
                  ).then((_) {
                    _filterElements();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(WorldElement element) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete World Element'),
        content: Text('Are you sure you want to delete "${element.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _viewModel.deleteElement(element.id);
              Navigator.pop(context);
              _filterElements();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'all': return 'All';
      case 'location': return 'Location';
      case 'lore': return 'Lore';
      case 'magic_system': return 'Magic System';
      case 'timeline': return 'Timeline';
      case 'culture': return 'Culture';
      case 'language': return 'Language';
      case 'religion': return 'Religion';
      case 'organization': return 'Organization';
      case 'technology': return 'Technology';
      default: return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'all': return Icons.public;
      case 'location': return Icons.location_on;
      case 'lore': return Icons.auto_stories;
      case 'magic_system': return Icons.auto_fix_high;
      case 'timeline': return Icons.timeline;
      case 'culture': return Icons.groups;
      case 'language': return Icons.translate;
      case 'religion': return Icons.temple_buddhist;
      case 'organization': return Icons.business;
      case 'technology': return Icons.precision_manufacturing;
      default: return Icons.help;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'location': return Colors.green;
      case 'lore': return Colors.purple;
      case 'magic_system': return Colors.indigo;
      case 'timeline': return Colors.orange;
      case 'culture': return Colors.teal;
      case 'language': return Colors.blue;
      case 'religion': return Colors.amber;
      case 'organization': return Colors.red;
      case 'technology': return Colors.cyan;
      default: return Colors.grey;
    }
  }
}

