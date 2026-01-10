import 'package:noteleaf/models/plot.dart';
import 'package:noteleaf/services/hive_service.dart';
import 'package:noteleaf/viewmodels/base_viewmodel.dart';

class PlotViewModel extends BaseViewModel {
  final HiveService _hiveService = HiveService();
  List<Plot> _plots = [];

  List<Plot> get plots => _plots;

  Future<void> loadPlots(String projectId) async {
    setLoading(true);
    try {
      final box = await _hiveService.plotBox;
      _plots = box.values
          .where((plot) => plot.projectId == projectId)
          .toList();
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to load plot points: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<Plot?> createPlot(
    String projectId,
    String title,
    String description,
    String tags,
  ) async {
    setLoading(true);
    try {
      final plotId = DateTime.now().millisecondsSinceEpoch.toString();
      final plot = Plot(
        id: plotId,
        projectId: projectId,
        title: title,
        description: description,
        tags: tags,
      );

      final box = await _hiveService.plotBox;
      await box.put(plotId, plot);
      _plots.add(plot);
      notifyListeners();
      return plot;
    } catch (e) {
      setErrorMessage('Failed to create plot point: $e');
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> updatePlot(Plot plot) async {
    try {
      final box = await _hiveService.plotBox;
      await box.put(plot.id, plot);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to update plot point: $e');
    }
  }

  Future<void> deletePlot(String plotId) async {
    setLoading(true);
    try {
      final box = await _hiveService.plotBox;
      await box.delete(plotId);
      _plots.removeWhere((p) => p.id == plotId);
      notifyListeners();
    } catch (e) {
      setErrorMessage('Failed to delete plot point: $e');
    } finally {
      setLoading(false);
    }
  }
}

