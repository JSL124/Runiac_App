import 'package:flutter_test/flutter_test.dart';
import 'package:runiac_app/app.dart';
import 'package:runiac_app/features/account/domain/models/user_profile_read_model.dart';
import 'package:runiac_app/features/account/domain/repositories/user_profile_repository.dart';

void main() {
  testWidgets(
    'Account profile displays saved profile values from the repository',
    (tester) async {
      await tester.pumpWidget(
        RuniacApp(
          showSplash: false,
          enableForegroundGps: false,
          profileRepository: _SingleProfileRepository(
            UserProfileReadModel(
              userId: 'test-auth-user-1',
              displayName: 'Maya Tan',
              avatarInitials: 'MT',
              locationLabel: 'Queenstown, Singapore',
              previewLevelBadge: '',
              previewNote: 'Loaded from your saved profile.',
              setupSectionLabel: 'RUNNING SETUP',
              manageSectionLabel: 'MANAGE',
              footerCaption: 'Runiac · Preview build · Built for new runners',
              setupItems: const <UserProfileInfoItemReadModel>[
                UserProfileInfoItemReadModel(
                  title: 'Current goal',
                  value: 'First relaxed 5K',
                ),
                UserProfileInfoItemReadModel(
                  title: 'Weekly rhythm',
                  value: '4 sessions / week',
                ),
                UserProfileInfoItemReadModel(
                  title: 'Experience',
                  value: 'Returning runner',
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.bySemanticsLabel('Profile'));
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Maya Tan'), findsOneWidget);
      expect(find.text('MT'), findsOneWidget);
      expect(find.text('Queenstown, Singapore'), findsOneWidget);
      expect(find.text('Lv. 12'), findsNothing);
      expect(find.text('First relaxed 5K'), findsOneWidget);
      expect(find.text('4 sessions / week'), findsOneWidget);
      expect(find.text('Returning runner'), findsOneWidget);
    },
  );

  testWidgets('Account profile falls back to the demo profile snapshot', (
    tester,
  ) async {
    await tester.pumpWidget(
      const RuniacApp(showSplash: false, enableForegroundGps: false),
    );

    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Runiac Runner'), findsOneWidget);
    expect(find.text('RR'), findsOneWidget);
    expect(find.text('Jurong East, Singapore'), findsOneWidget);
    expect(find.text('Lv. 12'), findsOneWidget);
    expect(find.text('Build a consistent 10K habit'), findsOneWidget);
  });
}

class _SingleProfileRepository implements UserProfileRepository {
  const _SingleProfileRepository(this.profile);

  final UserProfileReadModel profile;

  @override
  Future<UserProfileReadModel> loadUserProfile() async => profile;
}
