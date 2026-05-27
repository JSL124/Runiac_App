import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/runiac_colors.dart';
import 'widgets/run_map_placeholder.dart';

const _blueBorder = Color(0xFFDCE6FF);
const _sportOrange = Color(0xFFFF7A1A);
const _orangeShadow = Color(0x33FF7A1A);
const _screenBackground = Color(0xFF3153C9);
const _softControlBlue = Color(0x667A91E5);
const _pressedControlBlue = Color(0x99A8B8FF);
const _controlSplash = Color(0x33FFFFFF);
const _controlHighlight = Color(0x24FFFFFF);
const _panelTextBlue = Color(0xFF3151C8);
const _mutedBlue = Color(0xFF8296E8);
const _controlPressHold = Duration(milliseconds: 90);

class RunLaunchScreen extends StatelessWidget {
  const RunLaunchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final bottomOffset = math.max(viewPadding.bottom + 20.0, 28.0);

    return Scaffold(
      backgroundColor: _screenBackground,
      body: Stack(
        children: [
          const Positioned.fill(child: RunMapPlaceholder()),
          Positioned(
            top: 0,
            left: 24,
            right: 24,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    _MapCircleButton(
                      tooltip: 'Close',
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Expanded(child: Center(child: _GpsReadyPill())),
                    _MapCircleButton(
                      tooltip: 'Run settings',
                      icon: Icons.settings_outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomOffset,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: const _RunBottomPanel(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapCircleButton extends StatefulWidget {
  const _MapCircleButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_MapCircleButton> createState() => _MapCircleButtonState();
}

class _MapCircleButtonState extends State<_MapCircleButton> {
  bool _pressed = false;
  bool _activating = false;

  bool get _visuallyPressed => _pressed || _activating;

  void _setPressed(bool pressed) {
    if (!mounted || _pressed == pressed) {
      return;
    }
    setState(() => _pressed = pressed);
  }

  Future<void> _handleTap() async {
    setState(() => _activating = true);
    await Future<void>.delayed(_controlPressHold);
    if (!mounted) {
      return;
    }
    setState(() {
      _activating = false;
      _pressed = false;
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: AnimatedScale(
        scale: _visuallyPressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        child: Material(
          color: _visuallyPressed ? _pressedControlBlue : _softControlBlue,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkResponse(
            onTap: _handleTap,
            onHighlightChanged: _setPressed,
            containedInkWell: true,
            customBorder: const CircleBorder(),
            radius: 34,
            splashColor: _controlSplash,
            highlightColor: _controlHighlight,
            child: SizedBox(
              width: 58,
              height: 58,
              child: Icon(widget.icon, color: RuniacColors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}

class _GpsReadyPill extends StatelessWidget {
  const _GpsReadyPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: _softControlBlue,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: _sportOrange, size: 14),
          SizedBox(width: 10),
          Text(
            'GPS ready',
            style: TextStyle(
              color: RuniacColors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _RunBottomPanel extends StatelessWidget {
  const _RunBottomPanel();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final panelPadding = compact
            ? const EdgeInsets.fromLTRB(22, 20, 22, 22)
            : const EdgeInsets.fromLTRB(28, 24, 28, 26);
        final startHeight = compact ? 56.0 : 66.0;

        return Container(
          padding: panelPadding,
          decoration: BoxDecoration(
            color: RuniacColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x26172033),
                blurRadius: 30,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'TODAY\'S PLAN',
                      style: TextStyle(
                        color: _sportOrange,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _panelTextBlue,
                      side: const BorderSide(color: _blueBorder),
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: const Text('Switch route'),
                  ),
                ],
              ),
              SizedBox(height: compact ? 16 : 22),
              const Wrap(
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                runSpacing: 2,
                children: [
                  Text(
                    '4.5',
                    style: TextStyle(
                      color: _panelTextBlue,
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      'km easy run',
                      style: TextStyle(
                        color: _mutedBlue,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Pace 7:10-7:40 / km · ~32 min',
                style: TextStyle(
                  color: _mutedBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: compact ? 18 : 24),
              SizedBox(
                width: double.infinity,
                height: startHeight,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow_rounded, size: 32),
                  label: const Text('Start run'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _sportOrange,
                    foregroundColor: RuniacColors.white,
                    elevation: 8,
                    shadowColor: _orangeShadow,
                    textStyle: TextStyle(
                      fontSize: compact ? 24 : 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
