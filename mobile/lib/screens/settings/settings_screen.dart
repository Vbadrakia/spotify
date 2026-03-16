import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _normalization = true;
  bool _autoplay = true;
  String _audioQuality = 'High';
  double _crossfade = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Playback Section
          _buildSectionHeader('Playback'),
          _buildSwitchTile(
            title: 'Audio Normalization',
            subtitle: 'Keep the same volume level for all tracks',
            value: _normalization,
            onChanged: (value) => setState(() => _normalization = value),
          ),
          _buildSwitchTile(
            title: 'Autoplay',
            subtitle: 'Automatically play similar songs',
            value: _autoplay,
            onChanged: (value) => setState(() => _autoplay = value),
          ),
          _buildListTile(
            title: 'Audio Quality',
            subtitle: _audioQuality,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAudioQualityDialog(),
          ),
          _buildSliderTile(
            title: 'Crossfade',
            subtitle: 'Smooth transition between songs',
            value: _crossfade,
            min: 0,
            max: 12,
            divisions: 12,
            label: _crossfade == 0 ? 'Off' : '${_crossfade.toInt()}s',
            onChanged: (value) => setState(() => _crossfade = value),
          ),

          const Divider(height: 32),

          // Storage Section
          _buildSectionHeader('Storage'),
          _buildListTile(
            title: 'Download Quality',
            subtitle: 'High',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _buildListTile(
            title: 'Downloaded Music',
            subtitle: '0 tracks',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _buildListTile(
            title: 'Storage Used',
            subtitle: '0 MB',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(height: 32),

          // App Section
          _buildSectionHeader('App'),
          _buildListTile(
            title: 'Theme',
            subtitle: 'Dark',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _buildListTile(
            title: 'Language',
            subtitle: 'English',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const Divider(height: 32),

          // About Section
          _buildSectionHeader('About'),
          _buildListTile(
            title: 'Version',
            subtitle: '1.0.0',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          _buildListTile(
            title: 'Privacy Policy',
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () {},
          ),
          _buildListTile(
            title: 'Terms of Service',
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () {},
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    int? divisions,
    String? label,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showAudioQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Low (96 kbps)'),
              value: 'Low',
              groupValue: _audioQuality,
              onChanged: (value) {
                setState(() => _audioQuality = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Normal (160 kbps)'),
              value: 'Normal',
              groupValue: _audioQuality,
              onChanged: (value) {
                setState(() => _audioQuality = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('High (320 kbps)'),
              value: 'High',
              groupValue: _audioQuality,
              onChanged: (value) {
                setState(() => _audioQuality = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
