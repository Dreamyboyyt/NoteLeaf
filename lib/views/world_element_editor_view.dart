import 'package:flutter/material.dart';
import 'package:noteleaf/models/world_element.dart';
import 'package:noteleaf/viewmodels/world_building_viewmodel.dart';

class WorldElementEditorView extends StatefulWidget {
  final WorldElement? element;

  const WorldElementEditorView({super.key, this.element});

  @override
  State<WorldElementEditorView> createState() => _WorldElementEditorViewState();
}

class _WorldElementEditorViewState extends State<WorldElementEditorView> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  late WorldBuildingViewModel _viewModel;
  String _selectedType = 'location';
  List<String> _tags = [];
  Map<String, String> _customFields = {};

  final List<String> _elementTypes = [
    'location',
    'lore',
    'magic_system',
    'timeline',
    'culture',
    'language',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = WorldBuildingViewModel();
    
    if (widget.element != null) {
      _nameController = TextEditingController(text: widget.element!.name);
      _descriptionController = TextEditingController(text: widget.element!.description);
      _selectedType = widget.element!.type;
      _tags = List.from(widget.element!.tags);
      _customFields = Map.from(widget.element!.customFields);
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
    }
    _tagController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _saveElement() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    if (widget.element != null) {
      widget.element!.name = _nameController.text.trim();
      widget.element!.description = _descriptionController.text;
      widget.element!.type = _selectedType;
      widget.element!.tags = _tags;
      widget.element!.customFields = _customFields;
      widget.element!.lastModified = DateTime.now();
      _viewModel.updateWorldElement(widget.element!);
    }

    Navigator.pop(context);
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addCustomField() {
    showDialog(
      context: context,
      builder: (context) {
        String fieldName = '';
        String fieldValue = '';
        
        return AlertDialog(
          title: const Text('Add Custom Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Field Name'),
                onChanged: (value) => fieldName = value,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Field Value'),
                onChanged: (value) => fieldValue = value,
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
                if (fieldName.trim().isNotEmpty) {
                  setState(() {
                    _customFields[fieldName.trim()] = fieldValue.trim();
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeCustomField(String key) {
    setState(() {
      _customFields.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.element != null ? 'Edit World Element' : 'New World Element'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveElement,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter element name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: _elementTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Description Field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter description',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 16),

            // Tags Section
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'Add tag',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Custom Fields Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Custom Fields',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addCustomField,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_customFields.isEmpty)
              const Text(
                'No custom fields added',
                style: TextStyle(color: Colors.grey),
              )
            else
              ..._customFields.entries.map((entry) {
                return Card(
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeCustomField(entry.key),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

