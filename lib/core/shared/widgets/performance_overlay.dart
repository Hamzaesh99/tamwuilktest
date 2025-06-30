import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PerformanceOverlayWidget extends StatelessWidget {
  const PerformanceOverlayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PerformanceOverlay.allEnabled();
  }
}
