# Runiac Voice Progress Coaching — Expanded TDD Plan

## 1. Feature 목표

러닝 시작 전 사용자가 Running Start Page의 톱니바퀴 설정에서 Voice Coaching을 활성화하면, 실제 러닝 도중 설정된 거리 또는 시간 milestone에 도달했을 때 진행 상황을 음성으로 알려준다.

첫 번째 버전은 AI가 실시간 문장을 생성하는 방식이 아니라, 로컬 규칙 엔진과 검증된 메시지 템플릿을 사용한다.

### MVP 사용자 흐름

```text
Running Start Page
→ 톱니바퀴 선택
→ Voice Coaching 활성화
→ 1 km 간격 선택
→ 설정 저장
→ Start Run
→ 러닝 거리 1 km 통과
→ “1킬로미터를 완료했습니다...” 음성 출력
→ Pause 중에는 안내 없음
→ 2 km 통과 시 다음 안내
→ End 시 음성 및 대기 queue 종료
```

---

# 2. MVP 범위

## 2.1 포함 범위

* Running Start Page 톱니바퀴에서 설정 진입
* Voice Coaching 활성화 및 비활성화
* 거리 안내 간격 설정
* 시간 안내 간격 설정
* 경과 시간 포함 여부
* 평균 페이스 포함 여부
* 설정 로컬 저장
* 러닝 시작 시 설정 snapshot 생성
* Active 상태에서만 milestone 검사
* 거리 milestone 음성 안내
* 시간 milestone 음성 안내
* 목표 거리 절반 안내
* 목표 거리 완료 안내
* 중복 안내 방지
* 동시에 여러 milestone 발생 시 우선순위 처리
* Pause 중 음성 금지
* End 후 음성 중단
* TTS 오류가 러닝 추적에 영향을 주지 않도록 예외 격리
* 한국어 메시지
* 실제 기기에서 화면 잠금 및 음악 동시 재생 QA

## 2.2 제외 범위

초기 MVP에서는 다음을 구현하지 않는다.

* 실시간 LLM 호출
* AI 생성 응원 문구
* 심박수 기반 코칭
* 케이던스 기반 코칭
* 현재 페이스가 빠르거나 느리다는 실시간 판단
* 사용자 이름 호출
* 성별 또는 음성 종류 선택
* 클라우드 설정 동기화
* 러닝 중 설정 화면 변경
* 완전히 종료된 앱에서 음성 세션 복구
* 음성 command를 통한 Pause 또는 Resume

---

# 3. Acceptance Criteria

## AC-01 설정 진입

```gherkin
Given 사용자가 Running Start Page에 있다
When 톱니바퀴 버튼을 누른다
Then Run Settings 화면이 열린다
And Voice Coaching 설정 영역이 표시된다
```

## AC-02 설정 저장

```gherkin
Given Voice Coaching이 비활성화되어 있다
When 사용자가 Voice Coaching을 활성화하고 설정 화면을 닫는다
Then 설정이 로컬 저장소에 저장된다
And Running Start Page에 돌아와도 활성화 상태가 유지된다
```

## AC-03 세션 설정 고정

```gherkin
Given Voice Coaching이 활성화되어 있다
When 사용자가 Start Run을 누른다
Then 현재 Voice Coaching 설정이 RunSession 전용 snapshot으로 복사된다
And 이후 전역 설정이 변경되어도 현재 러닝에는 영향을 주지 않는다
```

## AC-04 거리 milestone

```gherkin
Given Voice Coaching이 활성화되어 있다
And 거리 안내 간격이 1 km이다
And 러닝 상태가 Active이다
When accepted distance가 980 m에서 1020 m로 변경된다
Then 1 km 완료 음성이 정확히 한 번 출력된다
```

## AC-05 중복 방지

```gherkin
Given 1 km 안내가 이미 출력되었다
When 이후 거리 값이 1030 m, 1050 m, 1100 m로 업데이트된다
Then 1 km 안내가 다시 출력되지 않는다
```

## AC-06 Pause

```gherkin
Given 러닝이 950 m에서 Pause되었다
When GPS drift로 위치 샘플이 1030 m에 해당하는 값을 제공한다
Then 음성 안내가 출력되지 않는다
And accepted distance도 증가하지 않는다
```

## AC-07 TTS 장애 격리

```gherkin
Given TTS 시스템이 오류를 발생시킨다
When 러너가 1 km milestone을 통과한다
Then 러닝 세션은 Active 상태를 유지한다
And 위치 및 시간 추적은 계속된다
And RunSessionController가 error state로 전환되지 않는다
```

## AC-08 종료

```gherkin
Given 음성이 재생 중이거나 queue에 음성이 대기 중이다
When 사용자가 러닝을 종료한다
Then 현재 음성 재생이 중지된다
And 대기 queue가 비워진다
And 이후 음성 안내가 출력되지 않는다
```

---

# 4. 권장 아키텍처

```text
Running Start Settings UI
          │
          ▼
RunVoiceSettingsRepository
          │
          ▼
RunVoiceCoachingSettings
          │
       Start Run
          │
          ▼
RunVoiceSessionConfig
          │
          ▼
RunSessionController
          │
   RunSessionState update
          │
          ▼
RunVoiceSnapshotMapper
          │
          ▼
RunVoiceCoachingCoordinator
          │
    ┌─────┴─────────┐
    ▼               ▼
Announcement     Announcement
Policy           Selector
    │               │
    └──────┬────────┘
           ▼
RunVoiceMessageFormatter
           │
           ▼
RunSpeechOutput
           │
           ▼
FlutterTtsRunSpeechOutput
```

## 책임 구분

### RunSessionController

* 러닝 상태 관리
* 거리와 시간 tracking
* Pause, Resume, End 처리
* Voice Coaching Coordinator에 snapshot 전달
* 음성 메시지 생성 책임 없음
* TTS 직접 호출 금지

### RunVoiceAnnouncementPolicy

* 현재 상황에서 어떤 announcement가 필요한지 판단
* Flutter dependency 없음
* TTS dependency 없음
* 순수 Dart unit test 대상

### RunVoiceMessageFormatter

* 구조화된 announcement를 한국어 문장으로 변환
* GPS 또는 lifecycle 판단 없음

### RunVoiceCoachingCoordinator

* 이전 snapshot 보관
* announcement 중복 방지
* queue 관리
* 우선순위 처리
* TTS 오류 격리
* session cleanup

### RunSpeechOutput

* 실제 음성 출력 port
* 테스트에서는 fake로 대체
* production에서는 `flutter_tts` adapter 사용

---

# 5. Domain 모델

## 5.1 RunVoiceCoachingSettings

사용자가 저장하는 전역 설정이다.

```dart
class RunVoiceCoachingSettings {
  const RunVoiceCoachingSettings({
    required this.enabled,
    required this.distanceIntervalMeters,
    required this.timeInterval,
    required this.includeElapsedTime,
    required this.includeAveragePace,
  });

  const RunVoiceCoachingSettings.defaults()
      : enabled = false,
        distanceIntervalMeters = 1000,
        timeInterval = null,
        includeElapsedTime = true,
        includeAveragePace = true;

  final bool enabled;
  final int distanceIntervalMeters;
  final Duration? timeInterval;
  final bool includeElapsedTime;
  final bool includeAveragePace;

  RunVoiceCoachingSettings copyWith({
    bool? enabled,
    int? distanceIntervalMeters,
    Duration? timeInterval,
    bool clearTimeInterval = false,
    bool? includeElapsedTime,
    bool? includeAveragePace,
  }) {
    return RunVoiceCoachingSettings(
      enabled: enabled ?? this.enabled,
      distanceIntervalMeters:
          distanceIntervalMeters ?? this.distanceIntervalMeters,
      timeInterval:
          clearTimeInterval ? null : timeInterval ?? this.timeInterval,
      includeElapsedTime:
          includeElapsedTime ?? this.includeElapsedTime,
      includeAveragePace:
          includeAveragePace ?? this.includeAveragePace,
    );
  }
}
```

## 5.2 RunVoiceSessionConfig

러닝 시작 순간 고정되는 세션 설정이다.

```dart
class RunVoiceSessionConfig {
  const RunVoiceSessionConfig({
    required this.enabled,
    required this.distanceIntervalMeters,
    required this.timeInterval,
    required this.includeElapsedTime,
    required this.includeAveragePace,
    required this.targetDistanceMeters,
  });

  factory RunVoiceSessionConfig.fromSettings({
    required RunVoiceCoachingSettings settings,
    required double? targetDistanceMeters,
  }) {
    return RunVoiceSessionConfig(
      enabled: settings.enabled,
      distanceIntervalMeters: settings.distanceIntervalMeters,
      timeInterval: settings.timeInterval,
      includeElapsedTime: settings.includeElapsedTime,
      includeAveragePace: settings.includeAveragePace,
      targetDistanceMeters: targetDistanceMeters,
    );
  }

  final bool enabled;
  final int distanceIntervalMeters;
  final Duration? timeInterval;
  final bool includeElapsedTime;
  final bool includeAveragePace;
  final double? targetDistanceMeters;
}
```

전역 settings 객체를 coordinator가 직접 참조하지 않아야 한다.

```text
Global settings
→ Start 시 복사
→ RunVoiceSessionConfig
→ 현재 러닝이 끝날 때까지 불변
```

## 5.3 RunVoiceSnapshot

```dart
class RunVoiceSnapshot {
  const RunVoiceSnapshot({
    required this.phase,
    required this.elapsed,
    required this.distanceMeters,
    required this.isPaused,
    required this.averagePace,
  });

  final RunPhase phase;
  final Duration elapsed;
  final double distanceMeters;
  final bool isPaused;
  final Duration? averagePace;
}
```

가능하면 `distanceMeters`는 raw GPS distance가 아니라 기존 Runiac에서 필터링을 통과한 accepted distance를 사용한다.

## 5.4 Announcement

```dart
enum RunVoiceAnnouncementType {
  distanceMilestone,
  timeMilestone,
  targetHalfway,
  targetCompleted,
}

class RunVoiceAnnouncement {
  const RunVoiceAnnouncement({
    required this.id,
    required this.type,
    required this.priority,
    required this.distanceMeters,
    required this.elapsed,
    required this.averagePace,
  });

  final String id;
  final RunVoiceAnnouncementType type;
  final int priority;
  final int? distanceMeters;
  final Duration elapsed;
  final Duration? averagePace;
}
```

Announcement ID 예시:

```text
distance:1000
distance:2000
time:600
time:1200
target:halfway
target:completed
```

---

# 6. TDD 단계별 실행 계획

# Phase 0 — Existing Run Lifecycle Characterization

새 기능을 넣기 전에 기존 러닝 동작을 테스트로 고정한다.

## 목적

음성 기능이 다음 기능을 깨뜨리지 않도록 한다.

* Start
* Pause
* Resume
* End
* GPS tracking
* accepted distance 계산
* completion submission
* Cool Down 이동
* Summary 생성
* local analysis 유지
* 중복 End 방지

## 테스트 예시

```dart
group('RunSessionController lifecycle characterization', () {
  test('starts a new run in active state', () async {
    final controller = buildController();

    await controller.start();

    expect(controller.state.phase, RunPhase.active);
  });

  test('pause prevents active elapsed time from increasing', () async {
    final controller = buildController();

    await controller.start();
    controller.tick(const Duration(seconds: 30));
    await controller.pause();
    controller.tick(const Duration(seconds: 20));

    expect(
      controller.state.activeElapsed,
      const Duration(seconds: 30),
    );
  });

  test('resume continues the same session', () async {
    final controller = buildController();

    await controller.start();
    final originalSessionId = controller.state.sessionId;

    await controller.pause();
    await controller.resume();

    expect(controller.state.sessionId, originalSessionId);
    expect(controller.state.phase, RunPhase.active);
  });

  test('duplicate end does not submit run twice', () async {
    final repository = FakeRunRepository();
    final controller = buildController(repository: repository);

    await controller.start();

    await Future.wait([
      controller.end(),
      controller.end(),
    ]);

    expect(repository.completeRunCalls, 1);
  });
});
```

## Exit Criteria

* 기존 lifecycle 테스트 전부 통과
* voice dependency를 fake로 주입해도 기존 테스트 결과가 동일
* 기존 completion payload가 변경되지 않음

---

# Phase 1 — Settings Domain Tests

UI보다 먼저 settings 모델과 validation을 테스트한다.

## 테스트 케이스

```dart
group('RunVoiceCoachingSettings', () {
  test('uses safe defaults', () {
    const settings = RunVoiceCoachingSettings.defaults();

    expect(settings.enabled, isFalse);
    expect(settings.distanceIntervalMeters, 1000);
    expect(settings.timeInterval, isNull);
    expect(settings.includeElapsedTime, isTrue);
    expect(settings.includeAveragePace, isTrue);
  });

  test('rejects unsupported distance interval', () {
    expect(
      () => validateDistanceInterval(0),
      throwsArgumentError,
    );
  });

  test('accepts supported distance intervals', () {
    expect(() => validateDistanceInterval(500), returnsNormally);
    expect(() => validateDistanceInterval(1000), returnsNormally);
    expect(() => validateDistanceInterval(2000), returnsNormally);
  });

  test('rejects time interval shorter than product minimum', () {
    expect(
      () => validateTimeInterval(const Duration(minutes: 1)),
      throwsArgumentError,
    );
  });
});
```

## 추천 허용값

거리:

```text
500 m
1 km
2 km
```

시간:

```text
5 min
10 min
15 min
Off
```

자유 숫자 입력보다 고정 선택지를 제공하면 validation과 UX가 단순해진다.

---

# Phase 2 — Settings Repository TDD

처음에는 로컬 저장소만 사용한다.

```dart
abstract interface class RunVoiceSettingsRepository {
  Future<RunVoiceCoachingSettings> load();
  Future<void> save(RunVoiceCoachingSettings settings);
}
```

## Fake

```dart
class FakeRunVoiceSettingsRepository
    implements RunVoiceSettingsRepository {
  FakeRunVoiceSettingsRepository({
    RunVoiceCoachingSettings initial =
        const RunVoiceCoachingSettings.defaults(),
  }) : _settings = initial;

  RunVoiceCoachingSettings _settings;
  int loadCalls = 0;
  int saveCalls = 0;

  @override
  Future<RunVoiceCoachingSettings> load() async {
    loadCalls += 1;
    return _settings;
  }

  @override
  Future<void> save(
    RunVoiceCoachingSettings settings,
  ) async {
    saveCalls += 1;
    _settings = settings;
  }
}
```

## 테스트

```dart
group('LocalRunVoiceSettingsRepository', () {
  test('returns defaults when no stored value exists', () async {
    final repository = buildRepositoryWithEmptyStorage();

    final result = await repository.load();

    expect(
      result,
      const RunVoiceCoachingSettings.defaults(),
    );
  });

  test('persists and reloads voice settings', () async {
    final repository = buildRepositoryWithEmptyStorage();

    const expected = RunVoiceCoachingSettings(
      enabled: true,
      distanceIntervalMeters: 500,
      timeInterval: Duration(minutes: 10),
      includeElapsedTime: true,
      includeAveragePace: false,
    );

    await repository.save(expected);

    expect(await repository.load(), expected);
  });

  test('falls back safely when stored data is malformed', () async {
    final repository = buildRepositoryWithRawStorage({
      'enabled': 'invalid',
    });

    final result = await repository.load();

    expect(
      result,
      const RunVoiceCoachingSettings.defaults(),
    );
  });
});
```

## 중요한 원칙

손상된 설정 때문에 Start Run이 실패하면 안 된다.

```text
Malformed persisted settings
→ defaults 적용
→ 러닝 시작 가능
→ 오류는 logging만 수행
```

---

# Phase 3 — Settings UI TDD

Running Start Page의 톱니바퀴를 통해 설정 화면으로 진입한다.

## UI 구조

```text
Run Settings

Voice Coaching
[Switch] Voice progress updates

Distance updates
Every 1 km

Time updates
Off

Include in announcement
[Switch] Elapsed time
[Switch] Average pace
```

## Widget Test 1 — 톱니바퀴 진입

```dart
testWidgets(
  'opens run settings from start page gear',
  (tester) async {
    await tester.pumpWidget(
      buildRunningStartPage(),
    );

    await tester.tap(
      find.byKey(const Key('run_settings_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Run Settings'), findsOneWidget);
    expect(find.text('Voice Coaching'), findsOneWidget);
  },
);
```

## Widget Test 2 — Voice Coaching 활성화

```dart
testWidgets(
  'enables voice coaching from settings',
  (tester) async {
    final repository =
        FakeRunVoiceSettingsRepository();

    await tester.pumpWidget(
      buildRunSettingsPage(repository: repository),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const Key('voice_coaching_enabled_switch'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      (await repository.load()).enabled,
      isTrue,
    );
  },
);
```

## Widget Test 3 — Disabled state

```dart
testWidgets(
  'disables dependent controls when coaching is off',
  (tester) async {
    await tester.pumpWidget(
      buildRunSettingsPage(
        initialSettings:
            const RunVoiceCoachingSettings.defaults(),
      ),
    );

    final distanceControl = tester.widget<IgnorePointer>(
      find.byKey(
        const Key('voice_distance_interval_control'),
      ),
    );

    expect(distanceControl.ignoring, isTrue);
  },
);
```

## Widget Test 4 — 설정 복귀

```dart
testWidgets(
  'shows saved voice setting after returning to start page',
  (tester) async {
    final repository =
        FakeRunVoiceSettingsRepository();

    await tester.pumpWidget(
      buildRunStartFlow(repository: repository),
    );

    await tester.tap(
      find.byKey(const Key('run_settings_button')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const Key('voice_coaching_enabled_switch'),
      ),
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(
      find.text('Voice coaching on'),
      findsOneWidget,
    );
  },
);
```

이 요약 문구는 선택 사항이다. Start Page UI가 복잡해진다면 표시하지 않아도 된다.

---

# Phase 4 — Session Snapshot TDD

Start Run을 누르는 순간 저장된 설정을 고정한다.

## 테스트

```dart
group('Run voice session configuration', () {
  test('captures saved voice settings when run starts', () async {
    final settingsRepository =
        FakeRunVoiceSettingsRepository(
      initial: const RunVoiceCoachingSettings(
        enabled: true,
        distanceIntervalMeters: 1000,
        timeInterval: Duration(minutes: 10),
        includeElapsedTime: true,
        includeAveragePace: true,
      ),
    );

    final controller = buildController(
      voiceSettingsRepository: settingsRepository,
    );

    await controller.start();

    expect(controller.voiceSessionConfig.enabled, isTrue);
    expect(
      controller.voiceSessionConfig.distanceIntervalMeters,
      1000,
    );
  });

  test('current run does not observe later setting changes', () async {
    final repository =
        FakeRunVoiceSettingsRepository(
      initial: const RunVoiceCoachingSettings(
        enabled: true,
        distanceIntervalMeters: 1000,
        timeInterval: null,
        includeElapsedTime: true,
        includeAveragePace: true,
      ),
    );

    final controller = buildController(
      voiceSettingsRepository: repository,
    );

    await controller.start();

    await repository.save(
      const RunVoiceCoachingSettings(
        enabled: false,
        distanceIntervalMeters: 500,
        timeInterval: null,
        includeElapsedTime: false,
        includeAveragePace: false,
      ),
    );

    expect(controller.voiceSessionConfig.enabled, isTrue);
    expect(
      controller.voiceSessionConfig.distanceIntervalMeters,
      1000,
    );
  });

  test('next run uses newly saved settings', () async {
    final repository =
        FakeRunVoiceSettingsRepository(
      initial: const RunVoiceCoachingSettings.defaults(),
    );

    final firstRun = buildController(
      voiceSettingsRepository: repository,
    );
    await firstRun.start();

    await repository.save(
      const RunVoiceCoachingSettings(
        enabled: true,
        distanceIntervalMeters: 500,
        timeInterval: null,
        includeElapsedTime: true,
        includeAveragePace: true,
      ),
    );

    final secondRun = buildController(
      voiceSettingsRepository: repository,
    );
    await secondRun.start();

    expect(secondRun.voiceSessionConfig.enabled, isTrue);
    expect(
      secondRun.voiceSessionConfig.distanceIntervalMeters,
      500,
    );
  });
});
```

---

# Phase 5 — Distance Milestone Policy TDD

## Interface

```dart
abstract interface class RunVoiceAnnouncementPolicy {
  List<RunVoiceAnnouncement> evaluate({
    required RunVoiceSnapshot previous,
    required RunVoiceSnapshot current,
    required RunVoiceSessionConfig config,
    required Set<String> announcedIds,
  });
}
```

## 테스트 1 — 1 km crossing

```dart
test('emits 1 km milestone when distance crosses 1000 m', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 980),
    current: snapshot(distanceMeters: 1020),
    config: enabledConfig(
      distanceIntervalMeters: 1000,
    ),
    announcedIds: {},
  );

  expect(result, hasLength(1));
  expect(result.single.id, 'distance:1000');
});
```

## 테스트 2 — milestone 미도달

```dart
test('does not emit before reaching next milestone', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 800),
    current: snapshot(distanceMeters: 999),
    config: enabledConfig(),
    announcedIds: {},
  );

  expect(result, isEmpty);
});
```

## 테스트 3 — 정확한 값이 없어도 crossing

```dart
test('does not require an exact 1000 m sample', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 997.5),
    current: snapshot(distanceMeters: 1008.2),
    config: enabledConfig(),
    announcedIds: {},
  );

  expect(result.single.id, 'distance:1000');
});
```

## 테스트 4 — 중복 방지

```dart
test('does not repeat an announced distance milestone', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 1005),
    current: snapshot(distanceMeters: 1100),
    config: enabledConfig(),
    announcedIds: {'distance:1000'},
  );

  expect(result, isEmpty);
});
```

## 테스트 5 — 거리 감소

```dart
test('does not announce when corrected distance decreases', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 1010),
    current: snapshot(distanceMeters: 990),
    config: enabledConfig(),
    announcedIds: {},
  );

  expect(result, isEmpty);
});
```

## 테스트 6 — GPS jump

추천 정책은 여러 milestone을 모두 읽지 않고 가장 최근 것만 안내하는 것이다.

```dart
test('selects latest milestone after a large distance jump', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 900),
    current: snapshot(distanceMeters: 2100),
    config: enabledConfig(),
    announcedIds: {},
  );

  expect(result, hasLength(1));
  expect(result.single.id, 'distance:2000');
});
```

다만 내부적으로 1000 m도 지나간 것으로 소비 처리해야 한다.

그렇지 않으면 거리 보정 후 1000 m announcement가 늦게 발생할 수 있다.

이를 위해 결과를 다음처럼 분리할 수 있다.

```dart
class RunVoicePolicyResult {
  const RunVoicePolicyResult({
    required this.announcements,
    required this.consumedIds,
  });

  final List<RunVoiceAnnouncement> announcements;
  final Set<String> consumedIds;
}
```

GPS jump 테스트:

```dart
expect(result.announcements.single.id, 'distance:2000');
expect(
  result.consumedIds,
  containsAll(['distance:1000', 'distance:2000']),
);
```

---

# Phase 6 — Lifecycle Guard TDD

## 테스트

```dart
group('voice policy lifecycle guard', () {
  test('does not announce when feature is disabled', () {
    final result = evaluateCrossing(
      config: disabledConfig(),
    );

    expect(result.announcements, isEmpty);
  });

  test('does not announce in launch phase', () {
    final result = evaluateCrossing(
      phase: RunPhase.launch,
    );

    expect(result.announcements, isEmpty);
  });

  test('does not announce while paused', () {
    final result = policy.evaluate(
      previous: snapshot(
        phase: RunPhase.paused,
        distanceMeters: 980,
      ),
      current: snapshot(
        phase: RunPhase.paused,
        distanceMeters: 1020,
      ),
      config: enabledConfig(),
      announcedIds: {},
    );

    expect(result.announcements, isEmpty);
  });

  test('does not announce during completion', () {
    final result = evaluateCrossing(
      phase: RunPhase.completing,
    );

    expect(result.announcements, isEmpty);
  });

  test('does not announce after completion', () {
    final result = evaluateCrossing(
      phase: RunPhase.completed,
    );

    expect(result.announcements, isEmpty);
  });
});
```

Guard 순서:

```dart
if (!config.enabled) return emptyResult;
if (current.phase != RunPhase.active) return emptyResult;
if (current.isPaused) return emptyResult;
```

---

# Phase 7 — Time Milestone Policy TDD

시간 계산은 `DateTime.now()`가 아니라 기존 RunSession의 active elapsed 값을 사용한다.

## 테스트

```dart
test('emits a time announcement when crossing 10 minutes', () {
  final result = policy.evaluate(
    previous: snapshot(
      elapsed: const Duration(
        minutes: 9,
        seconds: 58,
      ),
    ),
    current: snapshot(
      elapsed: const Duration(
        minutes: 10,
        seconds: 2,
      ),
    ),
    config: enabledConfig(
      timeInterval: const Duration(minutes: 10),
    ),
    announcedIds: {},
  );

  expect(result.announcements.single.id, 'time:600');
});
```

## 추가 테스트

```dart
test('does not announce time when interval is disabled', () {
  final result = policy.evaluate(
    previous: snapshot(
      elapsed: const Duration(minutes: 9),
    ),
    current: snapshot(
      elapsed: const Duration(minutes: 11),
    ),
    config: enabledConfig(timeInterval: null),
    announcedIds: {},
  );

  expect(result.announcements, isEmpty);
});

test('does not repeat the same time milestone', () {
  final result = policy.evaluate(
    previous: snapshot(
      elapsed: const Duration(minutes: 10),
    ),
    current: snapshot(
      elapsed: const Duration(minutes: 11),
    ),
    config: enabledConfig(
      timeInterval: const Duration(minutes: 10),
    ),
    announcedIds: {'time:600'},
  );

  expect(result.announcements, isEmpty);
});

test('pause duration does not count toward milestone', () {
  final result = policy.evaluate(
    previous: snapshot(
      phase: RunPhase.paused,
      elapsed: const Duration(minutes: 9),
    ),
    current: snapshot(
      phase: RunPhase.paused,
      elapsed: const Duration(minutes: 12),
    ),
    config: enabledConfig(
      timeInterval: const Duration(minutes: 10),
    ),
    announcedIds: {},
  );

  expect(result.announcements, isEmpty);
});
```

---

# Phase 8 — Target Milestone TDD

## 절반 안내

```dart
test('emits halfway announcement when crossing half target', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 2400),
    current: snapshot(distanceMeters: 2550),
    config: enabledConfig(
      targetDistanceMeters: 5000,
    ),
    announcedIds: {},
  );

  expect(
    result.announcements.single.id,
    'target:halfway',
  );
});
```

## 목표 없음

```dart
test('does not emit halfway for free run', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 2400),
    current: snapshot(distanceMeters: 2550),
    config: enabledConfig(
      targetDistanceMeters: null,
    ),
    announcedIds: {},
  );

  expect(result.announcements, isEmpty);
});
```

## 목표 완료

```dart
test('emits target completion when target is crossed', () {
  final result = policy.evaluate(
    previous: snapshot(distanceMeters: 4950),
    current: snapshot(distanceMeters: 5030),
    config: enabledConfig(
      targetDistanceMeters: 5000,
    ),
    announcedIds: {},
  );

  expect(
    result.announcements.single.id,
    'target:completed',
  );
});
```

---

# Phase 9 — Priority Selection TDD

같은 snapshot에서 여러 announcement가 발생할 수 있다.

추천 우선순위:

```text
target completed      100
safety                 90
last kilometre         80
target halfway         70
distance milestone     50
time milestone         40
motivation             10
```

MVP에서는 safety와 motivation은 구현하지 않아도 enum 확장 가능성은 남겨둘 수 있다.

## Selector

```dart
abstract interface class RunVoiceAnnouncementSelector {
  RunVoiceAnnouncement? select(
    List<RunVoiceAnnouncement> candidates,
  );
}
```

## 테스트

```dart
test('target completion outranks distance milestone', () {
  final selected = selector.select([
    distanceAnnouncement(
      id: 'distance:5000',
      priority: 50,
    ),
    targetCompletedAnnouncement(priority: 100),
  ]);

  expect(
    selected?.type,
    RunVoiceAnnouncementType.targetCompleted,
  );
});

test('halfway outranks time milestone', () {
  final selected = selector.select([
    timeAnnouncement(priority: 40),
    halfwayAnnouncement(priority: 70),
  ]);

  expect(
    selected?.type,
    RunVoiceAnnouncementType.targetHalfway,
  );
});

test('returns null when no candidate exists', () {
  expect(selector.select([]), isNull);
});
```

동일 snapshot에서는 하나만 말한다.

---

# Phase 10 — Korean Message Formatter TDD

## Interface

```dart
abstract interface class RunVoiceMessageFormatter {
  String format(
    RunVoiceAnnouncement announcement,
    RunVoiceSessionConfig config,
  );
}
```

## 1 km 문장

```dart
test('formats Korean 1 km progress announcement', () {
  final message = formatter.format(
    distanceAnnouncement(
      distanceMeters: 1000,
      elapsed: const Duration(
        minutes: 6,
        seconds: 12,
      ),
      averagePace: const Duration(
        minutes: 6,
        seconds: 12,
      ),
    ),
    enabledConfig(
      includeElapsedTime: true,
      includeAveragePace: true,
    ),
  );

  expect(
    message,
    '1킬로미터를 완료했습니다. '
    '운동 시간은 6분 12초입니다. '
    '평균 페이스는 킬로미터당 6분 12초입니다.',
  );
});
```

## 페이스 없음

```dart
test('omits pace when average pace is unavailable', () {
  final message = formatter.format(
    distanceAnnouncement(
      distanceMeters: 1000,
      elapsed: const Duration(minutes: 6),
      averagePace: null,
    ),
    enabledConfig(
      includeElapsedTime: true,
      includeAveragePace: true,
    ),
  );

  expect(message, contains('1킬로미터'));
  expect(message, isNot(contains('평균 페이스')));
});
```

## 설정상 페이스 제외

```dart
test('omits pace when user disabled pace announcements', () {
  final message = formatter.format(
    distanceAnnouncement(
      distanceMeters: 1000,
      elapsed: const Duration(minutes: 6),
      averagePace: const Duration(minutes: 6),
    ),
    enabledConfig(
      includeElapsedTime: true,
      includeAveragePace: false,
    ),
  );

  expect(message, isNot(contains('평균 페이스')));
});
```

## 평균 페이스 신뢰성

기존 Runiac에서 invalid pace를 이미 구분하고 있다면 `Duration?`만 넘기지 말고 신뢰 가능한 pace만 snapshot에 전달한다.

```text
unreliable pace
→ snapshot.averagePace = null
→ formatter가 pace 문구 생략
```

UI와 Voice에서 pace validity 규칙을 따로 구현하면 안 된다.

---

# Phase 11 — Speech Output Port TDD

## Interface

```dart
abstract interface class RunSpeechOutput {
  Future<void> initialize();
  Future<void> speak(String message);
  Future<void> stop();
}
```

## Fake

```dart
class FakeRunSpeechOutput implements RunSpeechOutput {
  final List<String> spokenMessages = [];
  int initializeCalls = 0;
  int stopCalls = 0;
  bool throwOnSpeak = false;
  Completer<void>? speakCompleter;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
  }

  @override
  Future<void> speak(String message) async {
    if (throwOnSpeak) {
      throw StateError('TTS failure');
    }

    spokenMessages.add(message);

    final completer = speakCompleter;
    if (completer != null) {
      await completer.future;
    }
  }

  @override
  Future<void> stop() async {
    stopCalls += 1;
  }
}
```

---

# Phase 12 — Coordinator TDD

## 상태

Coordinator는 다음을 세션 단위로 관리한다.

```text
previousSnapshot
consumedAnnouncementIds
currentlySpeaking
pendingAnnouncement
stopped
```

## Interface

```dart
class RunVoiceCoachingCoordinator {
  RunVoiceCoachingCoordinator({
    required RunVoiceAnnouncementPolicy policy,
    required RunVoiceAnnouncementSelector selector,
    required RunVoiceMessageFormatter formatter,
    required RunSpeechOutput speechOutput,
    required RunVoiceSessionConfig config,
  });

  Future<void> start();
  Future<void> onSnapshot(RunVoiceSnapshot snapshot);
  Future<void> stop();
}
```

## 테스트 1 — 정확히 한 번 출력

```dart
test('speaks once when crossing first kilometre', () async {
  final speech = FakeRunSpeechOutput();
  final coordinator = buildCoordinator(
    speechOutput: speech,
  );

  await coordinator.start();

  await coordinator.onSnapshot(
    activeSnapshot(distanceMeters: 980),
  );
  await coordinator.onSnapshot(
    activeSnapshot(distanceMeters: 1020),
  );
  await coordinator.onSnapshot(
    activeSnapshot(distanceMeters: 1050),
  );

  expect(speech.spokenMessages, hasLength(1));
});
```

## 테스트 2 — feature disabled

```dart
test('does not initialize or speak when disabled', () async {
  final speech = FakeRunSpeechOutput();

  final coordinator = buildCoordinator(
    speechOutput: speech,
    config: disabledConfig(),
  );

  await coordinator.start();
  await coordinator.onSnapshot(
    activeSnapshot(distanceMeters: 1020),
  );

  expect(speech.initializeCalls, 0);
  expect(speech.spokenMessages, isEmpty);
});
```

## 테스트 3 — TTS 실패 격리

```dart
test('swallows speech output failure', () async {
  final speech = FakeRunSpeechOutput()
    ..throwOnSpeak = true;

  final coordinator = buildCoordinator(
    speechOutput: speech,
  );

  await coordinator.start();

  await expectLater(
    coordinator.onSnapshot(
      activeSnapshot(distanceMeters: 1020),
    ),
    completes,
  );
});
```

실패한 milestone을 다시 시도할지 결정해야 한다.

추천 정책:

```text
TTS speak 호출 전 → milestone consumed
TTS 실패 → 같은 milestone 재시도하지 않음
```

이유는 TTS 장애가 반복될 경우 매 GPS update마다 speak 호출이 재시도되는 것을 막기 위해서다.

## 테스트 4 — Pause 후 중복 없음

```dart
test('pause and resume do not reset consumed milestones', () async {
  final speech = FakeRunSpeechOutput();
  final coordinator = buildCoordinator(
    speechOutput: speech,
  );

  await coordinator.start();

  await coordinator.onSnapshot(
    activeSnapshot(distanceMeters: 980),
  );
  await coordinator.onSnapshot(
    activeSnapshot(distanceMeters: 1020),
  );
  await coordinator.onSnapshot(
    pausedSnapshot(distanceMeters: 1020),
  );
  await coordinator.onSnapshot(
    activeSnapshot(distanceMeters: 1050),
  );

  expect(speech.spokenMessages, hasLength(1));
});
```

## 테스트 5 — Stop

```dart
test('stop clears current and pending speech', () async {
  final speech = FakeRunSpeechOutput();
  final coordinator = buildCoordinator(
    speechOutput: speech,
  );

  await coordinator.start();
  await coordinator.stop();

  expect(speech.stopCalls, 1);

  await coordinator.onSnapshot(
    activeSnapshot(distanceMeters: 1020),
  );

  expect(speech.spokenMessages, isEmpty);
});
```

## 테스트 6 — Stop idempotency

```dart
test('stop is idempotent', () async {
  final speech = FakeRunSpeechOutput();
  final coordinator = buildCoordinator(
    speechOutput: speech,
  );

  await coordinator.start();

  await coordinator.stop();
  await coordinator.stop();

  expect(speech.stopCalls, 1);
});
```

---

# Phase 13 — Queue TDD

기본 정책:

* 동시에 한 문장만 출력
* speaking 중 새 candidate가 발생하면 pending slot 하나만 유지
* pending에는 가장 높은 priority만 유지
* End 시 pending 제거
* 동일 announcement ID는 다시 추가하지 않음

무제한 queue를 사용하지 않는 것이 좋다.

러닝 중 밀린 음성을 나중에 연속 재생하면 정보가 오래되어 가치가 떨어진다.

## 테스트

```dart
test('keeps only highest priority pending announcement', () async {
  final speech = FakeRunSpeechOutput();
  final completer = Completer<void>();
  speech.speakCompleter = completer;

  final coordinator = buildCoordinator(
    speechOutput: speech,
  );

  await coordinator.start();

  final firstFuture = coordinator.onSnapshot(
    activeSnapshot(
      distanceMeters: 1000,
      elapsed: const Duration(minutes: 10),
    ),
  );

  await coordinator.onSnapshot(
    activeSnapshot(
      distanceMeters: 2500,
      elapsed: const Duration(minutes: 20),
    ),
  );

  expect(coordinator.pendingCount, 1);
  expect(
    coordinator.pendingAnnouncement?.type,
    RunVoiceAnnouncementType.targetHalfway,
  );

  completer.complete();
  await firstFuture;
});
```

실제 coordinator 구현에서 async race가 복잡해질 수 있으므로, `onSnapshot()`이 GPS pipeline을 기다리지 않도록 application layer에서는 `unawaited`로 호출한다.

그러나 coordinator 단위 테스트에서는 Future 완료를 기다릴 수 있어야 한다.

---

# Phase 14 — RunSessionController Integration TDD

Controller가 TTS를 직접 호출하지 않고 coordinator에 snapshot만 보낸다는 것을 검증한다.

## 테스트 1 — Start

```dart
test('starts voice coordinator with run session', () async {
  final voiceCoordinator =
      FakeRunVoiceCoachingCoordinator();

  final controller = buildController(
    voiceCoordinator: voiceCoordinator,
  );

  await controller.start();

  expect(voiceCoordinator.startCalls, 1);
});
```

## 테스트 2 — accepted distance 전달

```dart
test('publishes accepted distance to voice coordinator', () async {
  final voiceCoordinator =
      FakeRunVoiceCoachingCoordinator();

  final controller = buildController(
    voiceCoordinator: voiceCoordinator,
  );

  await controller.start();

  controller.acceptLocationSample(
    locationSampleForAcceptedDistance(1020),
  );

  expect(
    voiceCoordinator.snapshots.last.distanceMeters,
    1020,
  );
});
```

raw GPS 누적값을 사용하지 않는지 검증해야 한다.

## 테스트 3 — Pause

```dart
test('publishes paused snapshot after pause', () async {
  final voiceCoordinator =
      FakeRunVoiceCoachingCoordinator();

  final controller = buildController(
    voiceCoordinator: voiceCoordinator,
  );

  await controller.start();
  await controller.pause();

  expect(
    voiceCoordinator.snapshots.last.phase,
    RunPhase.paused,
  );
});
```

## 테스트 4 — End cleanup

```dart
test('stops voice coordinator when ending run', () async {
  final voiceCoordinator =
      FakeRunVoiceCoachingCoordinator();

  final controller = buildController(
    voiceCoordinator: voiceCoordinator,
  );

  await controller.start();
  await controller.end();

  expect(voiceCoordinator.stopCalls, 1);
});
```

## 테스트 5 — 음성 오류와 run completion 분리

```dart
test('voice failure does not prevent run completion', () async {
  final voiceCoordinator =
      FakeRunVoiceCoachingCoordinator()
        ..throwOnSnapshot = true;

  final runRepository = FakeRunRepository();

  final controller = buildController(
    voiceCoordinator: voiceCoordinator,
    runRepository: runRepository,
  );

  await controller.start();

  controller.acceptLocationSample(
    locationSampleForAcceptedDistance(1020),
  );

  await controller.end();

  expect(runRepository.completeRunCalls, 1);
  expect(
    controller.state.phase,
    RunPhase.completed,
  );
});
```

안전한 wrapper:

```dart
Future<void> _safePublishVoiceSnapshot(
  RunVoiceSnapshot snapshot,
) async {
  try {
    await _voiceCoordinator.onSnapshot(snapshot);
  } catch (error, stackTrace) {
    _errorReporter.recordNonFatal(
      error,
      stackTrace,
      context: 'run_voice_coaching',
    );
  }
}
```

Controller의 location processing에서는:

```dart
unawaited(
  _safePublishVoiceSnapshot(
    RunVoiceSnapshotMapper.fromState(state),
  ),
);
```

---

# Phase 15 — Flutter TTS Adapter TDD

Production adapter를 마지막에 구현한다.

```dart
class FlutterTtsRunSpeechOutput
    implements RunSpeechOutput {
  FlutterTtsRunSpeechOutput({
    required FlutterTts flutterTts,
  }) : _flutterTts = flutterTts;

  final FlutterTts _flutterTts;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.setSpeechRate(0.48);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);

    _initialized = true;
  }

  @override
  Future<void> speak(String message) async {
    await initialize();
    await _flutterTts.speak(message);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
```

패키지 API는 실제 도입 시 현재 버전에 맞춰 확인해야 한다.

## Adapter 테스트

```dart
test('initializes Korean voice only once', () async {
  final tts = FakeFlutterTts();
  final output = FlutterTtsRunSpeechOutput(
    flutterTts: tts,
  );

  await output.initialize();
  await output.initialize();

  expect(tts.setLanguageCalls, 1);
});

test('forwards formatted message to TTS', () async {
  final tts = FakeFlutterTts();
  final output = FlutterTtsRunSpeechOutput(
    flutterTts: tts,
  );

  await output.speak('1킬로미터를 완료했습니다.');

  expect(
    tts.spokenMessages,
    ['1킬로미터를 완료했습니다.'],
  );
});

test('forwards stop to TTS', () async {
  final tts = FakeFlutterTts();
  final output = FlutterTtsRunSpeechOutput(
    flutterTts: tts,
  );

  await output.stop();

  expect(tts.stopCalls, 1);
});
```

MethodChannel을 직접 mocking하는 것보다 plugin wrapper interface를 하나 두면 테스트가 더 단순하다.

---

# Phase 16 — End-to-End Flutter Integration Test

실제 음성을 검증하기보다는 fake speech adapter를 앱 dependency에 주입한다.

## Scenario 1 — 설정부터 안내까지

```dart
testWidgets(
  'saved voice setting is applied to a new run',
  (tester) async {
    final speech = FakeRunSpeechOutput();

    await tester.pumpWidget(
      buildTestApp(speechOutput: speech),
    );

    await tester.tap(
      find.byKey(const Key('run_settings_button')),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(
        const Key('voice_coaching_enabled_switch'),
      ),
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('start_run_button')),
    );
    await tester.pumpAndSettle();

    emitAcceptedDistance(980);
    emitAcceptedDistance(1020);
    await tester.pump();

    expect(speech.spokenMessages, hasLength(1));
  },
);
```

## Scenario 2 — Pause

```dart
testWidgets(
  'does not announce milestones while paused',
  (tester) async {
    final speech = FakeRunSpeechOutput();

    await startVoiceEnabledRun(
      tester,
      speechOutput: speech,
    );

    emitAcceptedDistance(950);

    await tester.tap(
      find.byKey(const Key('pause_run_button')),
    );
    await tester.pump();

    emitRawLocationDriftEquivalentTo(1050);
    await tester.pump();

    expect(speech.spokenMessages, isEmpty);
  },
);
```

## Scenario 3 — End

```dart
testWidgets(
  'does not speak after run end',
  (tester) async {
    final speech = FakeRunSpeechOutput();

    await startVoiceEnabledRun(
      tester,
      speechOutput: speech,
    );

    await tester.tap(
      find.byKey(const Key('end_run_button')),
    );
    await tester.pumpAndSettle();

    emitAcceptedDistance(1020);
    await tester.pump();

    expect(speech.spokenMessages, isEmpty);
    expect(speech.stopCalls, 1);
  },
);
```

---

# 17. 테스트 파일 구성

```text
test/
  features/
    run/
      voice/
        domain/
          run_voice_coaching_settings_test.dart
          distance_milestone_policy_test.dart
          time_milestone_policy_test.dart
          target_milestone_policy_test.dart
          announcement_priority_selector_test.dart
          korean_run_voice_message_formatter_test.dart

        data/
          local_run_voice_settings_repository_test.dart

        application/
          run_voice_coaching_coordinator_test.dart

        infrastructure/
          flutter_tts_run_speech_output_test.dart

        presentation/
          run_voice_settings_page_test.dart
          run_start_voice_settings_navigation_test.dart

        integration/
          run_session_voice_coaching_test.dart
          run_voice_coaching_flow_test.dart
```

기존 Runiac 테스트 경로 명명 규칙이 다르다면 해당 규칙을 따른다.

---

# 18. 커밋 단위

## Commit 1

```text
test(run): characterize lifecycle before voice coaching
```

* Start/Pause/Resume/End regression 고정
* duplicate End 고정
* accepted distance behavior 고정

## Commit 2

```text
feat(run): add voice coaching settings contracts
```

* settings
* session config
* validation
* tests

## Commit 3

```text
feat(run): persist local voice coaching settings
```

* repository port
* local adapter
* malformed storage fallback
* tests

## Commit 4

```text
feat(run): add voice settings to start-page gear flow
```

* settings navigation
* switch
* interval controls
* widget tests

## Commit 5

```text
feat(run): add voice announcement domain policies
```

* distance
* time
* target milestones
* lifecycle guard

## Commit 6

```text
feat(run): add Korean run voice formatter
```

* elapsed formatting
* pace formatting
* unavailable pace handling

## Commit 7

```text
feat(run): add voice coaching coordinator
```

* consumed IDs
* priority
* pending slot
* stop cleanup
* failure isolation

## Commit 8

```text
feat(run): integrate voice coaching with run session
```

* start config snapshot
* state projection
* lifecycle cleanup
* integration tests

## Commit 9

```text
feat(run): add Flutter TTS output adapter
```

* plugin dependency
* Korean locale
* speech rate
* stop behavior

## Commit 10

```text
test(run): add voice coaching regression and flow coverage
```

* full UI-to-session flow
* pause
* resume
* end
* TTS failure

## Commit 11

```text
test(qa): add voice coaching device matrix
```

* iPhone
* Android
* lock screen
* music
* Bluetooth
* interruption

---

# 19. CI Test Layers

## Fast Unit Test Layer

매 커밋마다 실행:

```text
settings model
policy
formatter
selector
coordinator
repository fake
```

## Flutter Widget Layer

```text
settings page
gear navigation
settings persistence
Start button session config
```

## Regression Layer

```text
existing RunSessionController tests
Summary tests
Cool Down tests
activity history tests
completion tests
```

## Device QA Layer

CI에서 완전 자동화하기 어려운 항목:

```text
실제 음성이 들리는지
Spotify 볼륨 ducking
Bluetooth routing
잠금 화면
전화 수신 interruption
OS 절전 상태
```

---

# 20. 실제 기기 QA Checklist

## 공통

* Voice Coaching OFF에서 아무 음성도 나오지 않음
* Voice Coaching ON에서 1 km 안내
* 같은 1 km 안내 중복 없음
* Pause 중 음성 없음
* Resume 후 다음 milestone 정상 안내
* End 직후 음성 중단
* 다음 러닝에서 milestone 상태 초기화
* 평균 페이스를 제외했을 때 pace를 읽지 않음
* 경과 시간을 제외했을 때 시간을 읽지 않음

## iPhone 16 Pro

* foreground
* background
* screen locked
* Apple Music 또는 Spotify 재생
* Bluetooth 이어폰
* Siri 호출 후 복귀
* 전화 수신 후 복귀
* silent mode
* volume 낮음 또는 음소거 상태

## POCO M7 Pro 5G

* foreground service 동작 중
* screen locked
* battery optimization 활성화
* Spotify 재생
* Bluetooth 이어폰
* 앱 background
* notification permission 거부 상태
* activity recognition permission 상태와 무관하게 음성 기능 동작

음성 기능은 cadence sensor permission과 독립적이어야 한다.

---

# 21. Definition of Done

다음 조건을 모두 만족해야 MVP가 완료된다.

* Running Start Page 톱니바퀴에서 설정 가능
* 설정이 로컬 저장됨
* Start 시 설정 snapshot 생성
* 현재 러닝 중 전역 설정 변경의 영향을 받지 않음
* Active 상태에서 1 km crossing 감지
* 동일 milestone 정확히 한 번
* Pause 중 음성 없음
* End 후 음성 없음
* TTS 오류가 러닝 추적을 중단시키지 않음
* 기존 completeRun payload 변경 없음
* 기존 Summary 및 Advanced Analysis 결과 변경 없음
* analyzer 통과
* 모든 기존 Flutter test 통과
* 신규 unit/widget/integration test 통과
* iPhone 16 Pro 실제 기기 QA 통과
* POCO M7 Pro 5G 실제 기기 QA 통과
* 음악 재생 중 음성 확인
* 화면 잠금 상태 음성 확인

---

# 22. 추천 첫 번째 구현 Slice

전체 기능을 한 번에 구현하지 않고 첫 번째 vertical slice는 다음만 포함한다.

```text
설정 Switch
→ 설정 저장
→ Start 시 snapshot
→ Active 1 km crossing
→ 고정 한국어 문장
→ Fake speech test
→ 실제 TTS adapter
→ End cleanup
```

첫 번째 Slice의 메시지:

```text
“1킬로미터를 완료했습니다.”
```

이 Slice가 안정된 후 다음 순서로 확장한다.

```text
경과 시간 포함
→ 평균 페이스 포함
→ 500 m 및 2 km interval
→ 시간 milestone
→ 목표 절반
→ 목표 완료
→ 음악 ducking 안정화
→ 후속 pace coaching
```

이렇게 진행하면 UI, domain logic, TTS platform 문제를 한꺼번에 디버깅하지 않고 각 계층별로 실패 원인을 분리할 수 있다.
