part of 'home_stage_map.dart';

class _SocialMenuTrigger extends StatelessWidget {
  const _SocialMenuTrigger({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Social menu',
      button: true,
      child: ExcludeSemantics(
        child: GestureDetector(
          key: const ValueKey<String>('homeSocialMenuTrigger'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 7, 10, 7),
            decoration: _homeStageControlDecoration(
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Social',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  open
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact dropdown card below the Home header with the Social menu items.
/// Friends and Challenge each forward to the caller's navigation callback. No
/// social data is read or written here.
class _HomeSocialMenuPanel extends StatelessWidget {
  const _HomeSocialMenuPanel({
    required this.onFriends,
    required this.onChallenge,
  });

  final VoidCallback onFriends;
  final VoidCallback onChallenge;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('homeSocialMenuPanel'),
      width: 180,
      decoration: BoxDecoration(
        color: RuniacColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: RuniacColors.cardBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: RuniacColors.softCardShadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SocialMenuItem(
            icon: Icons.people_outline,
            label: 'Friends',
            onTap: onFriends,
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: RuniacColors.border,
            indent: 14,
            endIndent: 14,
          ),
          _SocialMenuItem(
            icon: Icons.emoji_events_outlined,
            label: 'Challenge',
            onTap: onChallenge,
          ),
        ],
      ),
    );
  }
}

class _SocialMenuItem extends StatelessWidget {
  const _SocialMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      button: true,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: RuniacColors.primaryBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
