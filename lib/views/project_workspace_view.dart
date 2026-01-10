import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteleaf/views/chapters_tab.dart';
import 'package:noteleaf/views/characters_tab.dart';
import 'package:noteleaf/views/plot_tab.dart';
import 'package:noteleaf/views/themes_tab.dart';
import 'package:noteleaf/views/notes_tab.dart';
import 'package:noteleaf/views/export_dialog.dart';
import 'package:noteleaf/models/project.dart';
import 'package:noteleaf/viewmodels/chapter_viewmodel.dart';

class ProjectWorkspaceView extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const ProjectWorkspaceView({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<ProjectWorkspaceView> createState() => _ProjectWorkspaceViewState();
}

class _ProjectWorkspaceViewState extends State<ProjectWorkspaceView> {
  late ChapterViewModel _chapterViewModel;

  @override
  void initState() {
    super.initState();
    _chapterViewModel = ChapterViewModel();
    _chapterViewModel.loadChapters(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chapterViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.projectTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.file_download),
              onPressed: () => _showExportDialog(context),
              tooltip: 'Export Project',
            ),
          ],
        ),
        body: DefaultTabController(
          length: 5,
          child: Column(
            children: [
              const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(icon: Icon(Icons.edit_note), text: 'Chapters'),
                  Tab(icon: Icon(Icons.people), text: 'Characters'),
                  Tab(icon: Icon(Icons.timeline), text: 'Plot'),
                  Tab(icon: Icon(Icons.palette), text: 'Themes'),
                  Tab(icon: Icon(Icons.note), text: 'Notes'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    ChaptersTab(projectId: widget.projectId),
                    CharactersTab(projectId: widget.projectId),
                    PlotTab(projectId: widget.projectId),
                    ThemesTab(projectId: widget.projectId),
                    NotesTab(projectId: widget.projectId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    final project = Project(
      id: widget.projectId,
      title: widget.projectTitle,
      path: '',
      createdAt: DateTime.now(),
      lastModified: DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider.value(
        value: _chapterViewModel,
        child: ExportDialog(project: project),
      ),
    );
  }
}

