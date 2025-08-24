import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'theme_manager.dart';

class SettingsDrawer extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const SettingsDrawer({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {

  void _copyPixKey() {
    Clipboard.setData(const ClipboardData(text: '24642660860'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Chave Pix copiada!'),
          ],
        ),
        backgroundColor: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openEmail() async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'angelofel@hotmail.com',
        query: 'subject=Sugestões Video Gallery App&body=Olá Angel,%0A%0AEu tenho algumas sugestões para o Video Gallery:%0A%0A',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      } else {
        _copyEmailToClipboard();
      }
    } catch (e) {
      print('Erro ao abrir email: $e');
      _copyEmailToClipboard();
    }
  }

  void _copyEmailToClipboard() {
    Clipboard.setData(const ClipboardData(text: 'angelofel@hotmail.com'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text('Email copiado!'),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'angelofel@hotmail.com',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ThemeManager.getPrimaryColor(widget.currentTheme),
                  ThemeManager.getPrimaryColor(widget.currentTheme).withOpacity(0.7),
                ],
              ),
            ),
            child: const SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Video Gallery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Configurações',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Temas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ...ThemeManager.themes.keys.map((themeName) {
                  final isSelected = widget.currentTheme == themeName;
                  final themeColor = ThemeManager.getPrimaryColor(themeName);

                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
                    ),
                    title: Text(
                      themeName,
                      style: TextStyle(
                        color: isSelected ? themeColor : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.radio_button_checked, color: themeColor)
                        : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
                    onTap: () {
                      widget.onThemeChanged(themeName);
                      Navigator.pop(context);
                    },
                  );
                }),

                Divider(color: Colors.grey[700]),

                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Apoie o Desenvolvedor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.pix, color: Colors.green),
                  title: const Text(
                    'Doe um Pix para o Angel',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'CPF: 24642660860',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: const Icon(Icons.copy, color: Colors.green),
                  onTap: _copyPixKey,
                ),

                Divider(color: Colors.grey[700]),

                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Suporte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text(
                    'Enviar sugestões',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    'angelofel@hotmail.com',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  trailing: const Icon(Icons.send, color: Colors.blue),
                  onTap: _openEmail,
                ),

                Divider(color: Colors.grey[700]),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Video Gallery v1.0.0',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Desenvolvido por Angel',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
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
