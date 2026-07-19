part of 'home_stage_map.dart';

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.streakCount, required this.loading});

  final int streakCount;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: _homeStageControlDecoration(
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Color(0xFFFF8A34),
            size: 22,
          ),
          const SizedBox(width: 4),
          Text(
            loading ? '…' : '$streakCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingProfileBadge extends StatelessWidget {
  const _LoadingProfileBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Runner profile loading',
      child: Container(
        width: 54,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: RuniacColors.primaryBlue.withValues(alpha: 0.24),
          shape: BoxShape.circle,
          border: Border.all(color: RuniacColors.white, width: 2),
        ),
        child: const Text(
          '…',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.unreadNotificationCount,
    required this.onNotifications,
  });

  final int unreadNotificationCount;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Notifications',
      button: true,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onNotifications,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: _homeStageControlDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (unreadNotificationCount > 0)
                Positioned(
                  right: -1,
                  top: -1,
                  child: _UnreadBadge(count: unreadNotificationCount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _homeStageControlDecoration({
  BorderRadius? borderRadius,
  BoxShape shape = BoxShape.rectangle,
}) {
  return BoxDecoration(
    color: RuniacColors.textPrimary.withValues(alpha: 0.92),
    borderRadius: borderRadius,
    shape: shape,
    border: Border.all(color: RuniacColors.white.withValues(alpha: 0.42)),
    boxShadow: [
      BoxShadow(
        color: RuniacColors.textPrimary.withValues(alpha: 0.42),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}
