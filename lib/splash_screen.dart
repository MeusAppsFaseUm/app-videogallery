import 'package:flutter/material.dart';
import 'main.dart';
import 'theme_manager.dart';

class SplashScreen extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;
  final bool skipAnimation;

  const SplashScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    this.skipAnimation = false,
  });

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: widget.skipAnimation ? 100 : 3000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.skipAnimation ? 1.0 : 0.1,
      end: widget.skipAnimation ? 1.0 : 3.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: widget.skipAnimation ? 1.0 : 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();

    Future.delayed(Duration(milliseconds: widget.skipAnimation ? 200 : 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MyApp(
              currentTheme: widget.currentTheme,
              onThemeChanged: widget.onThemeChanged,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeManager.themes[widget.currentTheme] ?? ThemeManager.themes['Azul Original']!,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: widget.skipAnimation
            ? Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        )
            : AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              children: [
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: Image.asset(
                          'assets/images/splash_screen.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context).primaryColor,
                              child: const Center(
                                child: Icon(
                                  Icons.video_library,
                                  color: Colors.white,
                                  size: 100,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
