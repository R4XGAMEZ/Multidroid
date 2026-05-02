// lib/screens/home_grid.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../models/instance_model.dart';
import '../services/geonode_service.dart';
import 'instance_fullscreen.dart';

class HomeGridScreen extends StatelessWidget {
  const HomeGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildAppBar(context, state),
      body: Column(
        children: [
          _buildTopBar(context, state),
          Expanded(
            child: _buildGrid(context, state),
          ),
          _buildBottomBar(context, state),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState state) {
    return AppBar(
      backgroundColor: const Color(0xFF111111),
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'MD',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MultiDroid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                state.selectedAppName.isEmpty
                    ? 'No app selected'
                    : state.selectedAppName,
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Master mode toggle
        IconButton(
          onPressed: () => context.read<AppState>().toggleMasterMode(),
          icon: Icon(
            Icons.military_tech,
            color: state.masterModeEnabled
                ? const Color(0xFFFFD700)
                : const Color(0xFF555555),
          ),
          tooltip: 'Master Control',
        ),
        // Settings
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings, color: Color(0xFF888888)),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFF111111),
      child: Row(
        children: [
          // Master volume
          const Icon(Icons.volume_up, color: Color(0xFF888888), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: const Color(0xFF00E5FF),
                inactiveTrackColor: const Color(0xFF333333),
                thumbColor: const Color(0xFF00E5FF),
                overlayColor: const Color(0x2200E5FF),
              ),
              child: Slider(
                value: state.masterVolume,
                onChanged: (v) =>
                    context.read<AppState>().setMasterVolume(v),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Mute all
          GestureDetector(
            onTap: () => context.read<AppState>().muteAll(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Mute All',
                style: TextStyle(color: Color(0xFF888888), fontSize: 11),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Proxy check
          GestureDetector(
            onTap: () => context.read<AppState>().checkAllProxies(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '🔍 Proxy',
                style: TextStyle(color: Color(0xFF888888), fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, AppState state) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.72,
      ),
      itemCount: state.instanceCount,
      itemBuilder: (ctx, i) => _InstanceCard(instance: state.instances[i]),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppState state) {
    final anyRunning =
        state.instances.any((i) => i.macroStatus == MacroStatus.running);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF222222))),
      ),
      child: Row(
        children: [
          // Run All Macros
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (anyRunning) {
                  context.read<AppState>().stopAllMacros();
                } else {
                  context.read<AppState>().runAllMacros();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: anyRunning
                        ? [const Color(0xFFFF5252), const Color(0xFFFF1744)]
                        : [
                            const Color(0xFF00E5FF),
                            const Color(0xFF7C4DFF)
                          ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      anyRunning ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      anyRunning ? 'Stop All Macros' : '▶ Run All Macros',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Master mode indicator
          if (state.masterModeEnabled)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF222222),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFD700), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.military_tech,
                      color: Color(0xFFFFD700), size: 18),
                  SizedBox(width: 4),
                  Text(
                    'MASTER',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Instance Card ──────────────────────────────────────────────────────────────

class _InstanceCard extends StatelessWidget {
  final InstanceModel instance;
  const _InstanceCard({required this.instance});

  Color get borderColor {
    final hex = instance.borderColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final flag = GeonodeService.getFlagForCode(instance.selectedCountryCode);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                InstanceFullscreenScreen(instanceId: instance.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(flag),
            // App preview area
            Expanded(child: _buildPreview()),
            // Quick action buttons
            _buildQuickActions(context, state),
            // Volume slider
            _buildVolumeBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String flag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: borderColor.withOpacity(0.1),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          // Instance number
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: borderColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${instance.id + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(flag, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            instance.selectedCountryCode,
            style: const TextStyle(
              color: Color(0xFFAAAAAA),
              fontSize: 10,
            ),
          ),
          const Spacer(),
          // Proxy status dot
          _buildProxyDot(),
          const SizedBox(width: 4),
          // Macro status
          if (instance.isMacroRunning)
            const Icon(Icons.bolt, color: Color(0xFFFFD740), size: 14)
          else
            const Icon(Icons.circle, color: Color(0xFF333333), size: 10),
        ],
      ),
    );
  }

  Widget _buildProxyDot() {
    Color dotColor;
    if (instance.proxy == null) {
      dotColor = const Color(0xFF555555);
    } else {
      switch (instance.proxy!.status) {
        case ProxyStatus.good:
          dotColor = const Color(0xFF69F0AE);
          break;
        case ProxyStatus.slow:
          dotColor = const Color(0xFFFFD740);
          break;
        case ProxyStatus.dead:
          dotColor = const Color(0xFFFF5252);
          break;
        case ProxyStatus.checking:
          dotColor = const Color(0xFF00E5FF);
          break;
      }
    }

    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        if (instance.proxy != null && instance.proxy!.pingMs > 0)
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Text(
              '${instance.proxy!.pingMs}ms',
              style: TextStyle(color: dotColor, fontSize: 9),
            ),
          ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: instance.screenshotPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(instance.screenshotPath!,
                    fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_android,
                      color: borderColor.withOpacity(0.3), size: 32),
                  const SizedBox(height: 6),
                  Text(
                    instance.status == InstanceStatus.idle
                        ? 'Tap to open'
                        : instance.status.name.toUpperCase(),
                    style: TextStyle(
                      color: borderColor.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          // Macro start/stop
          Expanded(
            child: _QuickBtn(
              icon: instance.isMacroRunning ? Icons.stop : Icons.play_arrow,
              color: instance.isMacroRunning
                  ? const Color(0xFFFF5252)
                  : const Color(0xFF69F0AE),
              onTap: () {
                if (instance.isMacroRunning) {
                  state.stopMacro(instance.id);
                } else {
                  state.startMacro(instance.id);
                }
              },
            ),
          ),
          const SizedBox(width: 4),
          // Mute
          Expanded(
            child: _QuickBtn(
              icon: instance.isMuted ? Icons.volume_off : Icons.volume_up,
              color: instance.isMuted
                  ? const Color(0xFFFF5252)
                  : const Color(0xFF00E5FF),
              onTap: () => state.toggleMute(instance.id),
            ),
          ),
          const SizedBox(width: 4),
          // Screenshot
          Expanded(
            child: _QuickBtn(
              icon: Icons.photo_camera,
              color: const Color(0xFFFFD740),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Screenshot taken: Instance ${instance.id + 1}'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: const Color(0xFF222222),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
      child: Row(
        children: [
          Icon(
            instance.isMuted ? Icons.volume_off : Icons.volume_down,
            color: const Color(0xFF555555),
            size: 12,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 5),
                activeTrackColor: borderColor,
                inactiveTrackColor: const Color(0xFF333333),
                thumbColor: borderColor,
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: instance.isMuted ? 0 : instance.volume,
                onChanged: (v) {
                  context.read<AppState>().setInstanceVolume(instance.id, v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
