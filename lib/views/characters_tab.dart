import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/models/character.dart';
import 'package:noteleaf/viewmodels/character_viewmodel.dart';

class CharactersTab extends StatefulWidget {
  final String projectId;

  const CharactersTab({super.key, required this.projectId});

  @override
  State<CharactersTab> createState() => _CharactersTabState();
}

class _CharactersTabState extends State<CharactersTab> {
  late CharacterViewModel _characterViewModel;

  @override
  void initState() {
    super.initState();
    _characterViewModel = CharacterViewModel();
    _characterViewModel.loadCharacters(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _characterViewModel,
      child: Scaffold(
        body: Consumer<CharacterViewModel>(
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
                      onPressed: () => viewModel.loadCharacters(widget.projectId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (viewModel.characters.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people,
                      size: 80,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No characters yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your first character to start building your cast',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.characters.length,
              itemBuilder: (context, index) {
                final character = viewModel.characters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(character.name.isNotEmpty ? character.name[0].toUpperCase() : '?'),
                    ),
                    title: Text(character.name),
                    subtitle: Text(character.role),
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
                          _showCharacterDialog(context, character: character);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context, character.id, character.name);
                        }
                      },
                    ),
                    onTap: () => _showCharacterDialog(context, character: character),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCharacterDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showCharacterDialog(BuildContext context, {Character? character}) {
    final nameController = TextEditingController(text: character?.name ?? '');
    final roleController = TextEditingController(text: character?.role ?? '');
    final backstoryController = TextEditingController(text: character?.backstory ?? '');
    final traitsController = TextEditingController(text: character?.personalityTraits ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(character == null ? 'Create Character' : 'Edit Character'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Character name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  hintText: 'Protagonist, Antagonist, etc.',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: backstoryController,
                decoration: const InputDecoration(
                  labelText: 'Backstory',
                  hintText: 'Character background',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: traitsController,
                decoration: const InputDecoration(
                  labelText: 'Personality Traits',
                  hintText: 'Brave, cunning, loyal, etc.',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                if (character == null) {
                  _characterViewModel.createCharacter(
                    widget.projectId,
                    nameController.text.trim(),
                    roleController.text.trim(),
                    backstoryController.text.trim(),
                    traitsController.text.trim(),
                  );
                } else {
                  character.name = nameController.text.trim();
                  character.role = roleController.text.trim();
                  character.backstory = backstoryController.text.trim();
                  character.personalityTraits = traitsController.text.trim();
                  _characterViewModel.updateCharacter(character);
                }
                Navigator.pop(context);
              }
            },
            child: Text(character == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String characterId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Character'),
        content: Text('Are you sure you want to delete "$name"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _characterViewModel.deleteCharacter(characterId);
              Navigator.pop(context);
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
}

