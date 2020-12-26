import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TileLoading extends StatelessWidget {
  const TileLoading({Key key, this.animate = true, this.child})
      : super(key: key);

  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.2),
      enabled: animate,
      child: child,
    );
  }
}
