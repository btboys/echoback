import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:echoback/app.dart';
import 'package:echoback/providers/audio_provider.dart';
import 'package:echoback/providers/recording_provider.dart';

void main() {
  testWidgets('App renders monitor screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AudioProvider()),
          ChangeNotifierProvider(create: (_) => RecordingProvider()),
        ],
        child: const EchoBackApp(),
      ),
    );

    expect(find.text('EchoBack'), findsOneWidget);
    expect(find.text('Real-time Ear Monitor'), findsOneWidget);
  });
}
