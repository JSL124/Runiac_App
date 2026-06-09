import 'package:flutter/material.dart';

import 'route_preview_card.dart';

class SharedRouteSheetCard extends StatelessWidget {
  const SharedRouteSheetCard({
    required this.keySuffix,
    required this.title,
    required this.message,
    this.onTap,
    super.key,
  });

  final String keySuffix;
  final String title;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RoutePreviewCard(
      key: Key('route_preview_card_$keySuffix'),
      title: title,
      message: message,
      onTap: onTap,
    );
  }
}
