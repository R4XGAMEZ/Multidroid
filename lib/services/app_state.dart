// lib/services/app_state.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/instance_model.dart';
import 'geonode_service.dart';

enum PerformanceMode { batterySaver, balanced, performance }

class AppState extends ChangeNotifier {
  // Instance count — 2, 4, or 6
  int _instanceCount = 6;
  int get instanceCount => _instanceCount;

  // All instances
  List<InstanceModel> _instances = [];
  List<InstanceModel> get instances => _instances;

  // Selected app to clone
  String _selectedAppPackage = '';
  String _selectedAppName = '';
  String get selectedAppPackage => _selectedAppPackage;
  String get selectedAppName => _selectedAppName;

  // Master control
  bool _masterModeEnabled = false;
  int _masterInstanceId = 0;
  bool get masterModeEnabled => _masterModeEnabled;
  int get masterInstanceId => _masterInstanceId;

  // Performance mode
  PerformanceMode _performanceMode = PerformanceMode.balanced;
  PerformanceMode get performanceMode => _performanceMode;

  // Master volume
  double _masterVolume = 1.0;
  double get masterVolume => _masterVolume;

  // Setup complete?
  bool _isSetupDone = false;
  bool get isSetupDone => _isSetupDone;

  // Shizuku available?
  bool _shizukuAvailable = false;
  bool get shizukuAvailable => _shizukuAvailable;

  // Freeform available?
  bool _freeformAvailable = false;
  bool get freeformAvailable => _freeformAvailable;

  // Initialize
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isSetupDone = prefs.getBool('setup_done') ?? false;
    _instanceCount = prefs.getInt('instance_count') ?? 6;
    _selectedAppPackage = prefs.getString('selected_app') ?? '';
    _selectedAppName = prefs.getString('selected_app_name') ?? '';
    _performanceMode = PerformanceMode.values[
        prefs.getInt('performance_mode') ?? 1];

    _initInstances();
    _loadInstanceData(prefs);
    notifyListeners();
  }

  void _initInstances() {
    _instances = List.generate(_instanceCount, (i) {
      return InstanceModel(
        id: i,
        borderColor: InstanceModel.colorForId(i),
        selectedCountryCode: _defaultCountries[i % _defaultCountries.length],
      );
    });
  }

  static const List<String> _defaultCountries = [
    'US', 'GB', 'IN', 'JP', 'DE', 'BR'
  ];

  void _loadInstanceData(SharedPreferences prefs) {
    for (final instance in _instances) {
      final key = 'instance_${instance.id}';
      final data = prefs.getString(key);
      if (data != null) {
        final json = jsonDecode(data);
        instance.selectedCountryCode = json['country'] ?? 'US';
        instance.volume = json['volume'] ?? 1.0;
        instance.isMuted = json['muted'] ?? false;
        instance.instanceNote = json['note'];
        final macroData = json['macros'] as List? ?? [];
        instance.macros = macroData
            .map((m) => MacroModel.fromJson(m))
            .toList();
      }
    }
  }

  Future<void> _saveInstance(InstanceModel instance) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'instance_${instance.id}';
    final data = jsonEncode({
      'country': instance.selectedCountryCode,
      'volume': instance.volume,
      'muted': instance.isMuted,
      'note': instance.instanceNote,
      'macros': instance.macros.map((m) => m.toJson()).toList(),
    });
    await prefs.setString(key, data);
  }

  // ── Setup ──────────────────────────────────────────

  Future<void> completeSetup({
    required int instanceCount,
    required String appPackage,
    required String appName,
  }) async {
    _instanceCount = instanceCount;
    _selectedAppPackage = appPackage;
    _selectedAppName = appName;
    _isSetupDone = true;
    _initInstances();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('instance_count', instanceCount);
    await prefs.setString('selected_app', appPackage);
    await prefs.setString('selected_app_name', appName);
    await prefs.setBool('setup_done', true);
    notifyListeners();
  }

  // ── Instance controls ──────────────────────────────

  Future<void> setInstanceCountry(int instanceId, String countryCode) async {
    final instance = _instances[instanceId];
    instance.selectedCountryCode = countryCode;
    instance.proxy = null;
    instance.status = InstanceStatus.loading;
    notifyListeners();

    // Fetch proxy for new country
    final proxy = await GeonodeService.getBestProxy(countryCode);
    instance.proxy = proxy;
    instance.status = InstanceStatus.idle;
    await _saveInstance(instance);
    notifyListeners();
  }

  void setInstanceVolume(int instanceId, double volume) {
    _instances[instanceId].volume = volume;
    _instances[instanceId].isMuted = volume == 0;
    _saveInstance(_instances[instanceId]);
    notifyListeners();
  }

  void toggleMute(int instanceId) {
    final inst = _instances[instanceId];
    inst.isMuted = !inst.isMuted;
    _saveInstance(inst);
    notifyListeners();
  }

  void muteAll() {
    for (final inst in _instances) {
      inst.isMuted = true;
    }
    notifyListeners();
  }

  void unmuteAll() {
    for (final inst in _instances) {
      inst.isMuted = false;
    }
    notifyListeners();
  }

  void setMasterVolume(double volume) {
    _masterVolume = volume;
    for (final inst in _instances) {
      inst.volume = volume;
    }
    notifyListeners();
  }

  // ── Macro controls ─────────────────────────────────

  void addMacro(int instanceId, MacroModel macro) {
    _instances[instanceId].macros.add(macro);
    _saveInstance(_instances[instanceId]);
    notifyListeners();
  }

  void removeMacro(int instanceId, String macroId) {
    _instances[instanceId].macros.removeWhere((m) => m.id == macroId);
    _saveInstance(_instances[instanceId]);
    notifyListeners();
  }

  void startMacro(int instanceId) {
    _instances[instanceId].macroStatus = MacroStatus.running;
    notifyListeners();
  }

  void stopMacro(int instanceId) {
    _instances[instanceId].macroStatus = MacroStatus.idle;
    notifyListeners();
  }

  void runAllMacros() {
    for (final inst in _instances) {
      if (inst.macros.isNotEmpty) {
        inst.macroStatus = MacroStatus.running;
      }
    }
    notifyListeners();
  }

  void stopAllMacros() {
    for (final inst in _instances) {
      inst.macroStatus = MacroStatus.idle;
    }
    notifyListeners();
  }

  // ── Master control ─────────────────────────────────

  void toggleMasterMode() {
    _masterModeEnabled = !_masterModeEnabled;
    notifyListeners();
  }

  void setMasterInstance(int instanceId) {
    _masterInstanceId = instanceId;
    notifyListeners();
  }

  // ── Performance mode ───────────────────────────────

  void setPerformanceMode(PerformanceMode mode) {
    _performanceMode = mode;
    notifyListeners();
  }

  double get scanInterval {
    switch (_performanceMode) {
      case PerformanceMode.batterySaver: return 3.0;
      case PerformanceMode.balanced: return 1.0;
      case PerformanceMode.performance: return 0.5;
    }
  }

  // ── Proxy health check ─────────────────────────────

  Future<void> checkAllProxies() async {
    for (final inst in _instances) {
      if (inst.proxy != null) {
        final ping = await GeonodeService.testProxy(inst.proxy!);
        if (ping < 0) {
          inst.proxy!.status = ProxyStatus.dead;
          // Auto replace
          final newProxy = await GeonodeService.getBestProxy(
              inst.selectedCountryCode);
          inst.proxy = newProxy;
        } else if (ping > 2000) {
          inst.proxy!.status = ProxyStatus.slow;
          inst.proxy!.pingMs = ping;
        } else {
          inst.proxy!.status = ProxyStatus.good;
          inst.proxy!.pingMs = ping;
        }
        notifyListeners();
      }
    }
  }

  // ── Grid layout ────────────────────────────────────

  int get gridRows {
    switch (_instanceCount) {
      case 2: return 1;
      case 4: return 2;
      case 6: return 3;
      default: return 3;
    }
  }

  int get gridCols => 2;

  // Freeform bounds for each instance
  Map<String, int> getFreeformBounds(int instanceId, int screenW, int screenH) {
    final col = instanceId % gridCols;
    final row = instanceId ~/ gridCols;
    final cellW = screenW ~/ gridCols;
    final cellH = screenH ~/ gridRows;

    return {
      'left': col * cellW,
      'top': row * cellH,
      'right': (col + 1) * cellW,
      'bottom': (row + 1) * cellH,
    };
  }
}
