// lib/screens/setup_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _step = 0;
  int _selectedInstanceCount = 4;
  String _selectedApp = '';
  String _selectedAppName = '';

  // Mock installed apps list
  final List<Map<String, String>> _mockApps = [
    {'package': 'com.instagram.android', 'name': 'Instagram', 'icon': '📸'},
    {'package': 'com.whatsapp', 'name': 'WhatsApp', 'icon': '💬'},
    {'package': 'com.facebook.katana', 'name': 'Facebook', 'icon': '👤'},
    {'package': 'com.twitter.android', 'name': 'Twitter/X', 'icon': '🐦'},
    {'package': 'com.tiktok.android', 'name': 'TikTok', 'icon': '🎵'},
    {'package': 'com.snapchat.android', 'name': 'Snapchat', 'icon': '👻'},
    {'package': 'com.telegram.messenger', 'name': 'Telegram', 'icon': '✈️'},
    {'package': 'com.youtube.android', 'name': 'YouTube', 'icon': '▶️'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: _step == 0
                  ? _buildWelcomeStep()
                  : _step == 1
                      ? _buildInstanceCountStep()
                      : _buildAppSelectStep(),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text('MD',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 16),
          const Text('MultiDroid',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
          const Text('Multi-Instance App Manager',
              style: TextStyle(color: Color(0xFF666666), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        children: List.generate(3, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? const Color(0xFF69F0AE)
                        : active
                            ? const Color(0xFF00E5FF)
                            : const Color(0xFF222222),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check,
                            color: Colors.black, size: 14)
                        : Text('${i + 1}',
                            style: TextStyle(
                                color: active
                                    ? Colors.black
                                    : const Color(0xFF555555),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
                if (i < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done
                          ? const Color(0xFF69F0AE)
                          : const Color(0xFF222222),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _featureRow('📱', '6 Virtual Instances',
              'Run same app with 6 different accounts'),
          const SizedBox(height: 16),
          _featureRow('🌐', 'Per Instance Proxy',
              'Different country IP for each instance'),
          const SizedBox(height: 16),
          _featureRow('🤖', 'Macro Automation',
              'Image detection + auto click'),
          const SizedBox(height: 16),
          _featureRow('👑', 'Master Control',
              'Control all instances simultaneously'),
          const SizedBox(height: 16),
          _featureRow(
              '⚡', 'Low End Optimized', 'Works on 2GB RAM devices'),
          const Spacer(),
          // Requirements
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Requirements',
                    style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _reqRow('Shizuku app', true),
                _reqRow('Developer Options enabled', true),
                _reqRow('Freeform Windows enabled', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstanceCountStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How many instances?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Choose based on your device RAM',
              style: TextStyle(color: Color(0xFF666666))),
          const SizedBox(height: 32),
          Row(
            children: [
              _instanceCountCard(2, '1GB-2GB RAM', '⚡ Fastest'),
              const SizedBox(width: 12),
              _instanceCountCard(4, '2GB-3GB RAM', '⚖️ Balanced'),
              const SizedBox(width: 12),
              _instanceCountCard(6, '3GB+ RAM', '🔥 Full Power'),
            ],
          ),
          const SizedBox(height: 32),
          // Preview grid
          const Text('Grid Preview',
              style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildGridPreview(),
        ],
      ),
    );
  }

  Widget _buildAppSelectStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select App to Clone',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Will create $_selectedInstanceCount instances',
              style: const TextStyle(color: Color(0xFF666666))),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: _mockApps.length,
              itemBuilder: (ctx, i) {
                final app = _mockApps[i];
                final selected = _selectedApp == app['package'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedApp = app['package']!;
                    _selectedAppName = app['name']!;
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? const Color(0xFF00E5FF)
                              : const Color(0xFF2A2A2A),
                          width: selected ? 2 : 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(app['icon']!,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 6),
                        Text(app['name']!,
                            style: TextStyle(
                                color: selected
                                    ? const Color(0xFF00E5FF)
                                    : Colors.white,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    final canProceed = _step == 0 ||
        (_step == 1 && _selectedInstanceCount > 0) ||
        (_step == 2 && _selectedApp.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_step > 0)
            GestureDetector(
              onTap: () => setState(() => _step--),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: const Text('Back',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: canProceed
                  ? () {
                      if (_step < 2) {
                        setState(() => _step++);
                      } else {
                        // Complete setup
                        context.read<AppState>().completeSetup(
                              instanceCount: _selectedInstanceCount,
                              appPackage: _selectedApp,
                              appName: _selectedAppName,
                            );
                      }
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: canProceed
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF00E5FF),
                            Color(0xFF7C4DFF)
                          ],
                        )
                      : null,
                  color: canProceed ? null : const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _step == 2 ? '🚀 Start MultiDroid' : 'Continue →',
                    style: TextStyle(
                        color: canProceed
                            ? Colors.white
                            : const Color(0xFF444444),
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _instanceCountCard(int count, String ram, String label) {
    final selected = _selectedInstanceCount == count;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedInstanceCount = count),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF00E5FF).withOpacity(0.1)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected
                    ? const Color(0xFF00E5FF)
                    : const Color(0xFF2A2A2A),
                width: selected ? 2 : 1),
          ),
          child: Column(
            children: [
              Text('$count',
                  style: TextStyle(
                      color: selected
                          ? const Color(0xFF00E5FF)
                          : Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF888888), fontSize: 10)),
              const SizedBox(height: 4),
              Text(ram,
                  style: const TextStyle(
                      color: Color(0xFF555555), fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridPreview() {
    final rows = _selectedInstanceCount == 2
        ? 1
        : _selectedInstanceCount == 4
            ? 2
            : 3;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: rows == 1 ? 3 : rows == 2 ? 1.5 : 1,
        ),
        itemCount: _selectedInstanceCount,
        itemBuilder: (ctx, i) => Container(
          decoration: BoxDecoration(
            color: Color(int.parse(
                    'FF${InstanceModel.colorForId(i).replaceAll('#', '')}',
                    radix: 16))
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
                color: Color(int.parse(
                        'FF${InstanceModel.colorForId(i).replaceAll('#', '')}',
                        radix: 16))
                    .withOpacity(0.5)),
          ),
          child: Center(
            child: Text('${i + 1}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _featureRow(String icon, String title, String subtitle) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            Text(subtitle,
                style: const TextStyle(
                    color: Color(0xFF666666), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _reqRow(String text, bool available) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
              available ? Icons.check_circle : Icons.cancel,
              color: available
                  ? const Color(0xFF69F0AE)
                  : const Color(0xFFFF5252),
              size: 16),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  color: Color(0xFFAAAAAA), fontSize: 12)),
        ],
      ),
    );
  }
}
