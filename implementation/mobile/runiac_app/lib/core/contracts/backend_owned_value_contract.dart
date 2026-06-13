/// Names and verbs reserved for backend-owned Runiac values.
///
/// Flutter may display these outputs after approved read paths exist, but the
/// client must not become the source of truth for them.
class BackendOwnedValueContract {
  const BackendOwnedValueContract._();

  static const protectedFieldNames = <String>[
    'xp',
    'level',
    'rank',
    'streak',
    'leaderboardScore',
    'weeklyXp',
    'monthlyXp',
    'subscriptionPrivilegeState',
    'expertPlanPublicationState',
    'validatedActivityContributionState',
  ];

  static const forbiddenClientMutationVerbs = <String>[
    'calculate',
    'derive',
    'aggregate',
    'validate',
    'award',
    'increment',
    'publish',
    'approve',
    'reject',
    'suspend',
  ];
}
