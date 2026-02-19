import 'package:flutter/material.dart';
import '../core/audio_manager.dart';

/// Route names for navigation
class Routes {
  Routes._();
  
  static const String home = '/';
  static const String gameMenu = '/game-menu';
  static const String snake = '/games/snake';
  static const String fruitMerge = '/games/fruit-merge';
  static const String balloonMerge = '/games/balloon-merge';
  static const String waterSort = '/games/water-sort';
  static const String sudoku = '/games/sudoku';
  static const String colorConnect = '/games/color-connect';
  static const String settings = '/settings';
  static const String about = '/about';
}

/// Custom page transitions for cute animations
class TokiPageTransitions {
  TokiPageTransitions._();

  /// Bouncy slide transition
  static PageRouteBuilder<T> bouncy<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.elasticOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }

  /// Scale bounce transition
  static PageRouteBuilder<T> scale<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.bounceOut;
        var tween = Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: curve),
        );

        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }

  /// Fade with scale transition
  static PageRouteBuilder<T> fadeScale<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide up transition
  static PageRouteBuilder<T> slideUp<T>({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}

/// Navigation helper with sound effects
class TokiNavigator {
  final BuildContext context;
  final AudioManager _audio = AudioManager();

  TokiNavigator(this.context);

  /// Navigate to home with sound
  Future<void> goHome() async {
    await _audio.click();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(Routes.home);
    }
  }

  /// Navigate to game menu with sound
  Future<void> goToGameMenu() async {
    await _audio.click();
    if (context.mounted) {
      Navigator.of(context).pushNamed(Routes.gameMenu);
    }
  }

  /// Navigate to a specific game with transition
  Future<void> goToGame(String route, {String? bgmTrack}) async {
    await _audio.click();
    if (bgmTrack != null) {
      await _audio.playBgm(bgmTrack);
    }
    if (context.mounted) {
      Navigator.of(context).push(
        TokiPageTransitions.bouncy(builder: (_) {
          // Return the appropriate game screen based on route
          return _getGameScreen(route);
        }),
      );
    }
  }

  /// Navigate with custom transition
  Future<void> navigateWithTransition(
    String route, {
    required TokiTransitionType transition,
    String? bgmTrack,
  }) async {
    await _audio.click();
    if (bgmTrack != null) {
      await _audio.playBgm(bgmTrack);
    }
    if (context.mounted) {
      final routeBuilder = _getTransitionRoute(transition, route);
      Navigator.of(context).push(routeBuilder);
    }
  }

  /// Go back with sound
  Future<void> goBack() async {
    await _audio.click();
    if (context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Show dialog with sound
  Future<void> showCuteDialog(Widget dialog) async {
    await _audio.pop();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => dialog,
        barrierDismissible: true,
      );
    }
  }

  /// Helper to get game screen widget
  Widget _getGameScreen(String route) {
    // This will be implemented by other agents
    // Return placeholder for now
    return Scaffold(
      body: Center(
        child: Text(
          'Game: $route',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  /// Helper to get transition route
  PageRouteBuilder _getTransitionRoute(TokiTransitionType type, String route) {
    final builder = (_) => _getGameScreen(route);
    
    switch (type) {
      case TokiTransitionType.bouncy:
        return TokiPageTransitions.bouncy(builder: builder);
      case TokiTransitionType.scale:
        return TokiPageTransitions.scale(builder: builder);
      case TokiTransitionType.fadeScale:
        return TokiPageTransitions.fadeScale(builder: builder);
      case TokiTransitionType.slideUp:
        return TokiPageTransitions.slideUp(builder: builder);
    }
  }
}

/// Transition types
enum TokiTransitionType {
  bouncy,
  scale,
  fadeScale,
  slideUp,
}

/// Navigation observer for analytics or state management
class TokiNavigationObserver extends NavigatorObserver {
  final AudioManager _audio = AudioManager();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route, previousRoute, 'push');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _handleRouteChange(route, previousRoute, 'pop');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleRouteChange(newRoute, oldRoute, 'replace');
    }
  }

  void _handleRouteChange(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
    String action,
  ) {
    // Handle BGM changes based on route
    final routeName = route.settings.name ?? '';
    
    switch (routeName) {
      case Routes.home:
        _audio.playBgm('main_menu');
        break;
      case Routes.gameMenu:
        _audio.playBgm('menu');
        break;
      case Routes.snake:
      case Routes.fruitMerge:
      case Routes.balloonMerge:
      case Routes.waterSort:
      case Routes.sudoku:
      case Routes.colorConnect:
        // Each game will handle its own BGM
        break;
      default:
        break;
    }
  }
}
