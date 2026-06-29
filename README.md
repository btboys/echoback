# EchoBack

**实时耳返监听 · Real-time Ear Monitor**

EchoBack 是一款基于 Flutter 开发的移动端实时耳返监听应用，支持低延迟音频监听、录音、变调、混响等音效处理，并提供多语言支持（中文/English）。

## 功能特性

- **实时耳返监听** — 低延迟音频采集与回放，支持音量增益、变调、混响效果
- **录音** — AAC 编码录音（44100Hz, 128kbps），支持设备内直接回放
- **耳返自动存录** — 开启耳返时自动保存录音（16-bit PCM WAV），关闭时可重命名
- **呼吸灯效果** — 话筒图标根据麦克风音量实时脉动
- **全屏模式** — 监听/录音中自动隐藏底部导航栏
- **录音管理** — 列表浏览、重命名、单条/批量删除
- **播放器** — 进度条控制、播放/暂停、旋转动画
- **多语言** — 自动跟随系统语言切换中文/英文
- **深色主题** — Material 3 深色主题

## 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Flutter 3.44+ / Dart 3.12+ |
| 音频采集 | Android `AudioRecord` + `AudioTrack` (PCM Float) |
| 录音编码 | `record` 包 (AAC/MPEG4) |
| 回放 | `just_audio` (ExoPlayer) |
| 状态管理 | `provider` |
| 本地存储 | `sqflite` + `path_provider` |
| 原生平台 | Kotlin (Android) |

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── app.dart               # MaterialApp + 路由 + 底部导航
├── l10n/                  # 国际化
│   └── app_localizations.dart
├── models/                # 数据模型
│   ├── recording.dart
│   └── audio_settings.dart
├── providers/             # 状态管理
│   ├── audio_provider.dart
│   └── recording_provider.dart
├── screens/               # 页面
│   ├── monitor_screen.dart      # 耳返 + 录音
│   ├── recordings_screen.dart   # 录音列表
│   ├── playback_screen.dart     # 回放
│   └── settings_screen.dart     # 设置
├── services/              # 服务层
│   ├── audio_engine.dart
│   ├── audio_engine_platform.dart
│   ├── permission_service.dart
│   ├── recording_service.dart
│   └── storage_service.dart
└── widgets/               # UI 组件
    ├── effect_controls.dart
    ├── recording_card.dart
    ├── volume_indicator.dart
    └── waveform_widget.dart

android/app/src/main/kotlin/.../
└── EarMonitorPlugin.kt    # 原生音频处理插件
```

## 构建

```bash
# 获取依赖
flutter pub get

# 运行调试
flutter run

# 构建 APK
flutter build apk --release

# 构建 App Bundle
flutter build appbundle --release
```

## 环境要求

- Flutter SDK >= 3.12
- Dart SDK >= 3.12
- Android SDK 21+ (Android 5.0+)
- 麦克风权限

## 许可证

[MIT License](LICENSE)

Copyright (c) 2026 EchoBack
