import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'pages/video_gallery_page.dart';
import 'splash_screen.dart';
import 'theme_manager.dart';

void main() {
  runApp(VideoGalleryApp());
}

class VideoGalleryApp extends StatefulWidget {
  const VideoGalleryApp({super.key});

  @override
  _VideoGalleryAppState createState() => _VideoGalleryAppState();
}

class _VideoGalleryAppState extends State<VideoGalleryApp> {
  String _currentTheme = 'Azul Original';
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final theme = await ThemeManager.loadTheme();
    setState(() {
      _currentTheme = theme;
    });
  }

  void _changeTheme(String themeName) async {
    await ThemeManager.saveTheme(themeName);
    setState(() {
      _currentTheme = themeName;
    });

    // ✅ NOVO: Força rebuild de toda a árvore de widgets
    if (_navigatorKey.currentState?.mounted == true) {
      _navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SplashScreen(
            currentTheme: _currentTheme,
            onThemeChanged: _changeTheme,
            skipAnimation: true,
          ),
        ),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: ThemeManager.themes[_currentTheme],
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        currentTheme: _currentTheme,
        onThemeChanged: _changeTheme,
      ),
    );
  }
}

// Resto do código permanece igual...
class MyApp extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const MyApp({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermission = false;
  bool _isLoading = true;
  String _permissionStatus = '';

  @override
  void initState() {
    super.initState();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    setState(() {
      _isLoading = true;
      _permissionStatus = 'Verificando permissões...';
    });

    bool hasPermission = await _checkVideoPermission();

    if (!hasPermission) {
      hasPermission = await _requestVideoPermission();
    }

    setState(() {
      _hasPermission = hasPermission;
      _isLoading = false;
      _permissionStatus = hasPermission ? 'Permissão concedida' : 'Permissão negada';
    });
  }

  Future<bool> _checkVideoPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.videos.isGranted;
      } else if (sdkInt >= 23) {
        return await Permission.storage.isGranted;
      } else {
        return true;
      }
    } catch (e) {
      print('Erro ao verificar permissão: $e');
      return false;
    }
  }

  Future<bool> _requestVideoPermission() async {
    if (!Platform.isAndroid) return true;

    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      setState(() {
        _permissionStatus = 'Solicitando permissão...';
      });

      if (sdkInt >= 33) {
        final status = await Permission.videos.request();
        return status.isGranted;
      } else if (sdkInt >= 23) {
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        return true;
      }
    } catch (e) {
      print('Erro ao solicitar permissão: $e');
      setState(() {
        _permissionStatus = 'Erro ao solicitar permissão';
      });
      return false;
    }
  }

  Future<void> _handlePermissionDenied() async {
    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;

      Permission permission = sdkInt >= 33 ? Permission.videos : Permission.storage;
      final status = await permission.status;

      if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      } else {
        await _initializePermissions();
      }
    } catch (e) {
      print('Erro ao lidar com permissão negada: $e');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permissão Necessária'),
          content: const Text(
            'Para exibir seus vídeos, este app precisa de acesso ao armazenamento.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Abrir Configurações'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeManager.themes[widget.currentTheme] ?? ThemeManager.themes['Azul Original']!,
      child: Builder(
        builder: (context) => Scaffold(
          body: _isLoading
              ? LoadingScreen(status: _permissionStatus)
              : _hasPermission
              ? VideoGalleryPage(
            currentTheme: widget.currentTheme,
            onThemeChanged: widget.onThemeChanged,
          )
              : PermissionDeniedScreen(
            onRetry: _initializePermissions,
            onOpenSettings: _handlePermissionDenied,
          ),
        ),
      ),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final String status;

  const LoadingScreen({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              status,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PermissionDeniedScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  const PermissionDeniedScreen({
    super.key,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Permissão Necessária'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.folder_off,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              const Text(
                'Este app precisa de acesso ao armazenamento para exibir seus vídeos.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar Novamente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings),
                  label: const Text('Abrir Configurações'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
