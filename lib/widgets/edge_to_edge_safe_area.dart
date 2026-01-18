import 'package:flutter/material.dart';

/// Widget que maneja automáticamente el edge-to-edge en Android 15+
class EdgeToEdgeSafeArea extends StatelessWidget {
  final Widget child;
  final bool applyTopPadding;
  final bool applyBottomPadding;
  final Color? statusBarColor;
  final Color? navigationBarColor;
  
  const EdgeToEdgeSafeArea({
    super.key,
    required this.child,
    this.applyTopPadding = true,
    this.applyBottomPadding = false,
    this.statusBarColor,
    this.navigationBarColor,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: false,
      removeBottom: true,
      child: SafeArea(
        top: applyTopPadding,
        bottom: applyBottomPadding,
        minimum: EdgeInsets.only(
          top: applyTopPadding ? 0 : 0,
          bottom: applyBottomPadding ? 0 : 0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: statusBarColor ?? Colors.transparent,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Mixin para facilitar el uso en todas las pantallas
mixin EdgeToEdgeMixin<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Configurar color de barras del sistema si es necesario
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ));
    });
  }
}