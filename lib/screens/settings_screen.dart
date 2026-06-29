import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              l.settings,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            _buildSettingCard(
              context,
              icon: Icons.info_outline,
              title: l.about,
              subtitle: l.version,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context,
              icon: Icons.audiotrack_outlined,
              title: l.audioSettings,
              subtitle: l.audioSettingsDesc,
            ),
            const SizedBox(height: 12),
            _buildSettingCard(
              context,
              icon: Icons.folder_outlined,
              title: l.storage,
              subtitle: l.storageDesc,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
