import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'EchoBack',
      'subtitle': 'Real-time Ear Monitor',
      'earpiece': 'Monitor',
      'earpieceOn': 'Monitoring',
      'record': 'Record',
      'stop': 'Stop',
      'recordList': 'Recordings',
      'noRecordings': 'No recordings yet',
      'noRecordingsHint': 'Go to Monitor to start recording',
      'playback': 'Playback',
      'effects': 'Audio Effects',
      'pitch': 'Pitch',
      'reverb': 'Reverb',
      'volume': 'Volume',
      'settings': 'Settings',
      'language': 'Language',
      'chinese': '中文',
      'english': 'English',
      'recording': 'Recording',
      'back': 'Back',
      'about': 'About EchoBack',
      'version': 'Version 1.0.0',
      'audioSettings': 'Audio Settings',
      'audioSettingsDesc': 'Sample rate 44100Hz, AAC',
      'storage': 'Storage',
      'storageDesc': 'App documents directory',
    },
    'zh': {
      'appTitle': 'EchoBack',
      'subtitle': '实时耳返监听',
      'earpiece': '耳返',
      'earpieceOn': '监听中',
      'record': '录音',
      'stop': '停止',
      'recordList': '录音列表',
      'noRecordings': '暂无录音',
      'noRecordingsHint': '进入耳返页面开始录音吧',
      'playback': '回放',
      'effects': '音效控制',
      'pitch': '变调',
      'reverb': '混响',
      'volume': '音量',
      'settings': '设置',
      'language': '语言',
      'chinese': '中文',
      'english': 'English',
      'recording': '录音中',
      'back': '返回',
      'about': '关于 EchoBack',
      'version': '版本 1.0.0',
      'audioSettings': '音频设置',
      'audioSettingsDesc': '采样率 44100Hz, AAC 编码',
      'storage': '存储位置',
      'storageDesc': '应用文档目录',
    },
  };

  String get appTitle => _t('appTitle');
  String get subtitle => _t('subtitle');
  String get earpiece => _t('earpiece');
  String get earpieceOn => _t('earpieceOn');
  String get record => _t('record');
  String get stop => _t('stop');
  String get recordList => _t('recordList');
  String get noRecordings => _t('noRecordings');
  String get noRecordingsHint => _t('noRecordingsHint');
  String get playback => _t('playback');
  String get effects => _t('effects');
  String get pitch => _t('pitch');
  String get reverb => _t('reverb');
  String get volume => _t('volume');
  String get settings => _t('settings');
  String get language => _t('language');
  String get chinese => _t('chinese');
  String get english => _t('english');
  String get recording => _t('recording');
  String get back => _t('back');
  String get about => _t('about');
  String get version => _t('version');
  String get audioSettings => _t('audioSettings');
  String get audioSettingsDesc => _t('audioSettingsDesc');
  String get storage => _t('storage');
  String get storageDesc => _t('storageDesc');

  String semitones(int n) => locale.languageCode == 'zh' ? '$n 半音' : '${n >= 0 ? "+" : ""}$n semitones';

  String progress(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final pad = s.toString().padLeft(2, '0');
    return '$m:$pad';
  }

  String durationText(int ms) {
    final s = ms ~/ 1000;
    return '$s${locale.languageCode == 'zh' ? '秒' : 's'}';
  }

  String _t(String key) => _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key]!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
