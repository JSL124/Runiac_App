import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/core/characters/local_selected_runner_character_storage.dart';
import 'package:runiac_app/core/characters/runner_character.dart';
import 'package:runiac_app/features/onboarding/presentation/character_selection_screen.dart';
import 'package:runiac_app/features/onboarding/presentation/runiac_character_selection_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CharacterSelectionScreen', () {
    testWidgets('shows all four guide characters and requires a choice', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      RunnerCharacter? confirmed;
      await tester.pumpWidget(
        MaterialApp(
          home: CharacterSelectionScreen(
            onConfirm: (character) => confirmed = character,
          ),
        ),
      );

      for (final name in ['Bolt', 'Cap', 'Mila', 'Ivy']) {
        expect(find.text(name), findsOneWidget);
      }

      // The confirm CTA is disabled until a character is picked.
      FilledButton confirmButton() =>
          tester.widget<FilledButton>(find.byType(FilledButton));
      expect(confirmButton().onPressed, isNull);
      expect(find.text('Pick a buddy to continue'), findsOneWidget);
      expect(confirmed, isNull);

      await tester.tap(find.text('Mila'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(confirmButton().onPressed, isNotNull);
      expect(find.text("Let's go with Mila"), findsOneWidget);

      await tester.tap(find.text("Let's go with Mila"));
      await tester.pump();

      expect(confirmed, RunnerCharacter.pink);
    });
  });

  group('RuniacCharacterSelectionGate', () {
    testWidgets('shows selection screen then reveals child after confirm', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = SelectedRunnerCharacterStore();
      addTearDown(store.dispose);
      RunnerCharacter? persisted;

      await tester.pumpWidget(
        MaterialApp(
          home: SelectedRunnerCharacterScope(
            store: store,
            child: RuniacCharacterSelectionGate(
              active: true,
              store: store,
              onCharacterConfirmed: (character) => persisted = character,
              child: const Text('ONBOARDING'),
            ),
          ),
        ),
      );

      expect(find.text('Choose your running buddy'), findsOneWidget);
      expect(find.text('ONBOARDING'), findsNothing);

      await tester.tap(find.text('Bolt'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text("Let's go with Bolt"));
      await tester.pump();

      expect(persisted, RunnerCharacter.blue);
      expect(store.selected, RunnerCharacter.blue);
      expect(find.text('Choose your running buddy'), findsNothing);
      expect(find.text('ONBOARDING'), findsOneWidget);
    });

    testWidgets('skips selection when a choice is already restored', (
      tester,
    ) async {
      final store = SelectedRunnerCharacterStore()
        ..select(RunnerCharacter.purple);
      addTearDown(store.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: SelectedRunnerCharacterScope(
            store: store,
            child: RuniacCharacterSelectionGate(
              active: true,
              store: store,
              onCharacterConfirmed: (_) {},
              child: const Text('ONBOARDING'),
            ),
          ),
        ),
      );

      expect(find.text('Choose your running buddy'), findsNothing);
      expect(find.text('ONBOARDING'), findsOneWidget);
    });

    testWidgets('passes through to child when inactive', (tester) async {
      final store = SelectedRunnerCharacterStore();
      addTearDown(store.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: RuniacCharacterSelectionGate(
            active: false,
            store: store,
            onCharacterConfirmed: (_) {},
            child: const Text('ONBOARDING'),
          ),
        ),
      );

      expect(find.text('Choose your running buddy'), findsNothing);
      expect(find.text('ONBOARDING'), findsOneWidget);
    });
  });

  group('SharedPreferencesSelectedRunnerCharacterStorage', () {
    test('persists per uid and restores on next launch', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const storage = SharedPreferencesSelectedRunnerCharacterStorage();

      expect(await storage.readSelectedCharacter(uid: 'user-1'), isNull);

      await storage.writeSelectedCharacter(
        uid: 'user-1',
        character: RunnerCharacter.pink,
      );

      // Simulates a fresh launch reading the same stored value back.
      expect(
        await storage.readSelectedCharacter(uid: 'user-1'),
        RunnerCharacter.pink,
      );
      // A different uid does not inherit another user's choice.
      expect(await storage.readSelectedCharacter(uid: 'user-2'), isNull);
    });

    test('uses an anonymous fallback key when uid is null', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      const storage = SharedPreferencesSelectedRunnerCharacterStorage();

      await storage.writeSelectedCharacter(
        uid: null,
        character: RunnerCharacter.cap,
      );

      expect(
        await storage.readSelectedCharacter(uid: null),
        RunnerCharacter.cap,
      );
      expect(
        selectedRunnerCharacterPreferenceKey(null),
        'selected_runner_character_anonymous',
      );
    });

    test('restored selection lands in SelectedRunnerCharacterStore', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'selected_runner_character_user-1': 'purple',
      });
      const storage = SharedPreferencesSelectedRunnerCharacterStorage();
      final store = SelectedRunnerCharacterStore();
      addTearDown(store.dispose);

      final restored = await storage.readSelectedCharacter(uid: 'user-1');
      expect(restored, RunnerCharacter.purple);

      store.select(restored!);
      expect(store.hasSelection, isTrue);
      expect(store.selected, RunnerCharacter.purple);
    });
  });
}
