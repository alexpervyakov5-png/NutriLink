// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:Nutrilink/lib/main.dart'; 

// void main() {
//   testWidgets('NutriLinkApp запускается без ошибок', (WidgetTester tester) async {

//     await tester.pumpWidget(const NutriLinkApp());


//     expect(find.byType(MaterialApp), findsOneWidget);

//     expect(find.text('NutriLink'), findsOneWidget);
//   });

//   testWidgets('Главный экран содержит навигацию', (WidgetTester tester) async {
//     await tester.pumpWidget(const NutriLinkApp());

//     expect(find.byType(BottomNavigationBar), findsOneWidget);
    

//     expect(find.text('Главная'), findsOneWidget);
//     expect(find.text('Дневник'), findsOneWidget);
//     expect(find.text('Замеры'), findsOneWidget);
//     expect(find.text('Статистика'), findsOneWidget);
//   });
// }