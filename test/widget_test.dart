import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:city_guide_app/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo renders at the requested size', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: AppLogo(size: 120))),
    ));
    expect(find.byType(AppLogo), findsOneWidget);
    final size = tester.getSize(find.byType(AppLogo));
    expect(size.width, 120);
    expect(size.height, 120);
  });
}
