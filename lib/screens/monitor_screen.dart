import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../providers/audio_provider.dart';
import '../providers/recording_provider.dart';
import '../models/recording.dart';
import '../widgets/effect_controls.dart';
import '../services/permission_service.dart';
import '../l10n/app_localizations.dart';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen>
    with SingleTickerProviderStateMixin {
  final _recorder = AudioRecorder();
  final _permissionService = PermissionService();
  bool _hasPermission = false;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  late final AnimationController _pulseController;
  String? _monitorSavePath;
  DateTime? _monitorStartTime;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await _permissionService.hasMicrophonePermission();
    if (!granted) {
      final requested = await _permissionService.requestMicrophonePermission();
      setState(() => _hasPermission = requested);
    } else {
      setState(() => _hasPermission = true);
    }
  }

  Future<void> _toggleMonitoring() async {
    final audio = context.read<AudioProvider>();

    if (audio.isMonitoring) {
      final confirm = await _showStopConfirmDialog('耳返');
      if (confirm != true) return;
      await audio.stopSaveToFile();
      await audio.toggleMonitoring();
      if (!mounted) return;
      if (_monitorSavePath != null && _monitorStartTime != null) {
        final file = File(_monitorSavePath!);
        if (await file.exists()) {
          final duration = DateTime.now().difference(_monitorStartTime!);
          final formatted = DateFormat('yyyyMMdd_HHmmss').format(_monitorStartTime!);
          final defaultName = '监听_$formatted';
          final name = await _showSaveDialog(defaultName);
          if (name != null) {
            if (!mounted) return;
            final provider = context.read<RecordingProvider>();
            await provider.addRecording(Recording(
              filePath: _monitorSavePath!,
              fileName: name,
              durationMs: duration.inMilliseconds,
              createdAt: _monitorStartTime!,
            ));
          }
        }
      }
      _monitorSavePath = null;
      _monitorStartTime = null;
    } else {
      if (audio.isRecording) return;
      if (!_hasPermission) {
        await _checkPermission();
        if (!_hasPermission) return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final recDir = Directory('${dir.path}/recordings');
      if (!await recDir.exists()) {
        await recDir.create(recursive: true);
      }
      final now = DateTime.now();
      _monitorSavePath = '${recDir.path}/monitor_${now.millisecondsSinceEpoch}.wav';
      _monitorStartTime = now;

      final success = await audio.toggleMonitoring();
      if (success) {
        await audio.startSaveToFile(_monitorSavePath!);
      }
    }
  }

  Future<void> _toggleRecording() async {
    final audio = context.read<AudioProvider>();

    if (audio.isRecording) {
      final confirm = await _showStopConfirmDialog('录音');
      if (confirm != true) return;
      _recordingTimer?.cancel();
      _recordingTimer = null;
      _pulseController.reverse().then((_) => _pulseController.stop());
      final path = await _recorder.stop();
      if (!mounted) return;
      audio.setRecording(false);
      setState(() => _recordingSeconds = 0);
      if (path != null) {
        final dir = await getApplicationDocumentsDirectory();
        final now = DateTime.now();
        final formatted = DateFormat('yyyyMMdd_HHmmss').format(now);
        final newPath = '${dir.path}/recordings/recording_$formatted.m4a';
        await File(path).rename(newPath);

        if (!mounted) return;
        final name = await _showSaveDialog('录音_$formatted');
        if (name != null) {
          if (!mounted) return;
          final provider = context.read<RecordingProvider>();
          await provider.addRecording(Recording(
            filePath: newPath,
            fileName: name,
            durationMs: _recordingSeconds * 1000,
            createdAt: now,
          ));
        }
      }
    } else {
      if (audio.isRecording) return;
      if (!_hasPermission) {
        await _checkPermission();
        if (!_hasPermission) return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final recDir = Directory('${dir.path}/recordings');
      if (!await recDir.exists()) {
        await recDir.create(recursive: true);
      }
      final path = '${recDir.path}/temp_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );
      audio.setRecording(true);
      _pulseController.repeat(reverse: true);
      setState(() => _recordingSeconds = 0);
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _recordingSeconds++);
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recordingTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audio, _) {
        final l = AppLocalizations.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: Column(
              children: [
                const SizedBox(height: 40),
                Text(
                  'EchoBack',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l.subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[400],
                      ),
                ),
                const SizedBox(height: 32),
                if (audio.isRecording)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child:                   Text(
                    '${_recordingSeconds ~/ 60}:${(_recordingSeconds % 60).toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w200,
                        color: Colors.redAccent.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                _buildBreathingMic(audio),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                      _buildActionButton(
                      context,
                      icon: audio.isMonitoring ? Icons.headphones : Icons.headphones_outlined,
                      label: audio.isMonitoring ? l.earpieceOn : l.earpiece,
                      color: audio.isMonitoring ? Colors.green : Colors.grey,
                      enabled: !audio.isRecording,
                      onTap: _toggleMonitoring,
                    ),
                    _buildActionButton(
                      context,
                      icon: audio.isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
                      label: audio.isRecording ? l.stop : l.record,
                      color: audio.isRecording ? Colors.red : Colors.grey,
                      enabled: !audio.isMonitoring,
                      onTap: _toggleRecording,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (audio.isMonitoring) ...[
                  EffectControls(
                    pitchShift: audio.pitchShift,
                    reverbMix: audio.reverbMix,
                    volumeGain: audio.volumeGain,
                    onPitchChanged: (v) => audio.setPitchShift(v.round()),
                    onReverbChanged: (v) => audio.setReverb(v),
                    onVolumeChanged: (v) => audio.setVolume(v),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      },
    );
  }

  Future<bool> _showStopConfirmDialog(String mode) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('结束$mode'),
        content: Text('确定结束当前$mode吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<String?> _showSaveDialog(String defaultName) {
    final controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('保存录音'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '文件名',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('不保存'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              Navigator.pop(ctx, name.isNotEmpty ? name : defaultName);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingMic(AudioProvider audio) {
    final isActive = audio.isMonitoring || audio.isRecording;
    final volume = audio.currentVolume;
    final hasVolume = volume > 0.01;
    final breatheScale = isActive
        ? (hasVolume ? 1.0 + volume * 0.25 : 1.0 + _pulseController.value * 0.1)
        : 1.0;
    final color = !isActive
        ? Colors.grey
        : audio.isRecording
            ? Colors.redAccent
            : Color.lerp(Colors.greenAccent, Colors.redAccent, volume)!;

    return GestureDetector(
      onTap: _toggleMonitoring,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 120,
        height: 120,
        transform: Matrix4.identity()..scaleByDouble(breatheScale, breatheScale, 1.0, 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? null : Colors.grey[850],
          gradient: isActive
              ? RadialGradient(
                  colors: [
                    color.withValues(alpha: 0.4),
                    Colors.grey[900]!,
                  ],
                  stops: [math.max(0.05, volume * 0.6), 1.0],
                )
              : null,
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.6)
                : Colors.grey[700]!,
            width: 3,
          ),
        ),
        child: Icon(
          isActive ? Icons.mic : Icons.mic_none,
          size: 48,
          color: isActive ? color : Colors.grey[500],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final effectiveColor = enabled ? color : Colors.grey[600]!;
    return Column(
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: effectiveColor.withValues(alpha: 0.15),
              border: Border.all(color: effectiveColor, width: 2),
            ),
            child: Icon(icon, color: effectiveColor, size: 32),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: effectiveColor, fontSize: 12)),
      ],
    );
  }
}
