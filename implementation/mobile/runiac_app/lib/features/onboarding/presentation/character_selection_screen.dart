import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/characters/runner_character.dart';
import '../../../core/theme/runiac_colors.dart';

/// Warm, playful screen where a new user picks one of four guide characters
/// before the onboarding question flow begins.
///
/// The selection is display-only personalization. Confirming calls [onConfirm]
/// with the chosen character; the caller persists it locally. This screen never
/// writes to Firestore and never affects XP, level, rank, streak, or
/// leaderboard values.
class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({
    required this.onConfirm,
    this.initialSelection,
    super.key,
  });

  final ValueChanged<RunnerCharacter> onConfirm;
  final RunnerCharacter? initialSelection;

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen>
    with SingleTickerProviderStateMixin {
  RunnerCharacter? _selected;
  late final AnimationController _bobController;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection;
    // Finite, decaying celebration bob for the chosen character. It runs once
    // per selection and then stops, so the screen always settles when idle
    // (important for pumpAndSettle-based tests passing through this screen).
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  void _select(RunnerCharacter character) {
    _bobController.forward(from: 0);
    setState(() {
      _selected = character;
    });
  }

  void _confirm() {
    final selected = _selected;
    if (selected == null) {
      return;
    }
    widget.onConfirm(selected);
  }

  Widget _buildCardRow(
    RunnerCharacter? selected,
    RunnerCharacter left,
    RunnerCharacter right,
  ) {
    return Row(
      children: [
        for (final character in [left, right]) ...[
          if (character == right) const SizedBox(width: 16),
          Expanded(
            child: _CharacterCard(
              character: character,
              isSelected: character == selected,
              isDimmed: selected != null && character != selected,
              bob: _bobController,
              onTap: () => _select(character),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFF3FF), Color(0xFFFDF3EC)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose your running buddy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: RuniacColors.textPrimary,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Pick a friendly guide to cheer you on. They'll pop in "
                      'with gentle tips while you set things up. You can enjoy '
                      'any of them — this is just for fun.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: RuniacColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  // All four buddies always fit on screen at once (no
                  // scrolling), so nothing hides below the fold.
                  child: Column(
                    children: [
                      Expanded(
                        child: _buildCardRow(
                          selected,
                          RunnerCharacter.blue,
                          RunnerCharacter.cap,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildCardRow(
                          selected,
                          RunnerCharacter.pink,
                          RunnerCharacter.purple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: selected == null ? 0 : 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          selected == null
                              ? ''
                              : '${selected.displayName} is ready to run with '
                                    'you!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: RuniacColors.primaryBlue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: selected == null ? null : _confirm,
                        style: FilledButton.styleFrom(
                          backgroundColor: RuniacColors.primaryBlue,
                          disabledBackgroundColor:
                              RuniacColors.disabledButtonBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          selected == null
                              ? 'Pick a buddy to continue'
                              : "Let's go with ${selected.displayName}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.isSelected,
    required this.isDimmed,
    required this.bob,
    required this.onTap,
  });

  final RunnerCharacter character;
  final bool isSelected;
  final bool isDimmed;
  final Animation<double> bob;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Choose ${character.displayName}',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          scale: isSelected ? 1.04 : (isDimmed ? 0.96 : 1),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: isDimmed ? 0.55 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              decoration: BoxDecoration(
                color: RuniacColors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? RuniacColors.primaryBlue
                      : RuniacColors.cardBorder,
                  width: isSelected ? 2.4 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? RuniacColors.primaryButtonShadow
                        : RuniacColors.softCardShadow,
                    blurRadius: isSelected ? 22 : 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: bob,
                            builder: (context, child) {
                              // Decaying bounce: a few hops that fade out.
                              final t = bob.value;
                              final offset = isSelected && t > 0 && t < 1
                                  ? -math.sin(t * math.pi * 4).abs() *
                                        10 *
                                        (1 - t)
                                  : 0.0;
                              return Transform.translate(
                                offset: Offset(0, offset),
                                child: child,
                              );
                            },
                            child: Image.asset(
                              character.assetPath(RunnerCharacterFacing.front),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: RuniacColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: RuniacColors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    character.displayName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? RuniacColors.primaryBlue
                          : RuniacColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
