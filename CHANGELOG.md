# Changelog

All notable changes to NoteLeaf will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **World Building Tab** - Comprehensive world-building system for novelists
  - Create and manage world elements (locations, lore, magic systems, timelines, cultures, languages)
  - 6 predefined element types with custom field support
  - Tag system for organization and categorization
  - Search and filter functionality
  - Full CRUD operations with dedicated editor
- **Scene Management** - Break chapters into manageable scenes
  - Access via chapter menu (three-dot icon)
  - Track scene location, characters, summary, and tags
  - Scene editor with markdown support and readability stats
  - Reorder scenes within chapters
  - Full scene content editing capabilities
- **Version History** - Track and restore chapter revisions
  - Automatic version snapshots as you write
  - View historical versions with timestamps
  - Restore any previous version
  - Compare changes between versions
- **Inspirational Quotes Settings** - User control over startup quotes
  - "Don't show again" button now persists across app launches
  - Toggle setting in Settings → Preferences
  - Re-enable quotes anytime from settings
- **SharedPreferences Integration** - Persistent user preferences

### Changed
- **Project Workspace** - Increased tab count from 5 to 6
  - Added "World" tab with globe icon
  - Improved tab navigation with scrollable tabs
- **Chapter Editor** - Enhanced toolbar
  - Added History icon for version history access
  - Reorganized action buttons for better UX
- **Chapters Tab** - Enhanced chapter management
  - Added "Manage Scenes" option to chapter context menu
  - Improved menu organization
- **App Name** - Rebranded from "Litewriter" to "NoteLeaf"
- **Package Name** - Updated to `com.sleepy.noteleaf`
- **App Icon** - Now uses adaptive icon with white background
  - Configured for Material You support
  - Adaptive foreground and background layers

### Fixed
- **Inspirational Quotes Bug** - "Don't show again" button now properly persists
  - Previously showed quotes on every app launch despite user preference
  - Now uses SharedPreferences to remember user choice
  - Can be re-enabled in Settings if needed

### Technical
- Added `shared_preferences: ^2.2.2` dependency
- Registered `SceneAdapter` (typeId: 8) in Hive
- Registered `WorldElementAdapter` (typeId: 9) in Hive
- Generated Hive adapters for Scene and WorldElement models
- Added box getters for scenes and world elements in HiveService
- Created `WorldElementEditorView` with custom fields support
- Integrated existing scene and world building views into main navigation
- Updated GitHub workflow for Android builds
- Added model generation workflow for CI/CD

### Removed
- iOS support (Android-only app)
- iOS folder and configuration files
- Old package name references (`dev.sleepy.unknown.litewriter`)
- Unused `assets/images/hello.py` file

## [1.0.0] - Initial Release

### Core Features
- **Project-Based Structure** - Create and manage multiple novel projects
- **Chapter Management** - Create, edit, delete, and rearrange chapters with drag-and-drop
- **Writing Editor** - Smooth 60fps editor with Markdown support
- **Character Manager** - Track character names, roles, backstories, and personality traits
- **Plot Manager** - Organize plot points, arcs, and timelines with tagging and hierarchy
- **Theme Manager** - Define and track major and minor themes throughout your story
- **Notes Section** - Freeform notes for ideas, research, and scene details
- **Export Options** - Export full novel or selected chapters in .txt, .csv, or .md formats

### Design & User Experience
- **Material You Design** - Clean, modern interface following Material Design 3 guidelines
- **Light/Dark Theme** - Toggle between themes with settings
- **Responsive Layout** - White, round, aesthetic design with smooth animations
- **Autosave** - Automatic saving every 30 seconds with session restore
- **Offline-First** - All data stored locally for privacy and reliability

### Add-on Features
- **Writing Goals** - Set daily and total word count goals with progress tracking
- **Statistics** - Comprehensive word count tracking and progress charts
- **Distraction-Free Mode** - Fullscreen writing environment for focused sessions
- **Rich-Text Preview** - Live Markdown preview for formatted text
- **Inspirational Quotes** - Daily motivation on startup
- **Backup & Restore** - Export and import projects via .zip files
- **Readability Statistics** - Flesch Reading Ease and Flesch-Kincaid Grade Level analysis

### Technical Details
- **Framework**: Flutter 3.32.3
- **Architecture**: MVVM with Provider state management
- **Database**: Hive for local data persistence
- **Platform**: Android (API 21+)

---

## Version History Summary

- **Unreleased** - Major feature update with World Building, Scenes, and Version History
- **v1.0.0** - Initial release with core writing and organization features

---

## Upgrade Notes

### From v1.0.0 to Unreleased

**Database Changes:**
- Two new Hive boxes will be created automatically: `scenes` and `world_elements`
- Existing data is fully compatible and will not be affected
- No migration required

**New Dependencies:**
- `shared_preferences: ^2.2.2` - Used for persistent user settings

**Behavioral Changes:**
- Inspirational quotes will show by default on first launch after update
- Users who previously dismissed quotes will need to use Settings to disable them again
- This is a one-time reset of the quote preference

**New Permissions:**
- None required

---

## Support

For issues, feature requests, or questions:
- Create an issue on GitHub
- Contact: Sleepy 😴

---

*"The first draft of anything is shit." - Ernest Hemingway*

*"You can't wait for inspiration. You have to go after it with a club." - Jack London*

*"Write what should not be forgotten." - Isabel Allende*
