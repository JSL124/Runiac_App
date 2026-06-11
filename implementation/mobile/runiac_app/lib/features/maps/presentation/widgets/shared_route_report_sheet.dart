import 'package:flutter/material.dart';

import '../../../../core/theme/runiac_colors.dart';
import '../../../../core/widgets/runiac_buttons.dart';

enum RouteReportReason {
  missing(
    label: 'Doesn’t exist',
    icon: Icons.wrong_location_outlined,
    placeholder: 'Tell us what looks wrong about this route location.',
  ),
  unsafe(
    label: 'Unsafe',
    icon: Icons.warning_amber_outlined,
    placeholder: 'Tell us what makes this route feel unsafe.',
  ),
  wrongInfo(
    label: 'Wrong info',
    icon: Icons.edit_location_alt_outlined,
    placeholder:
        'Tell us which distance, time, difficulty, or location detail seems wrong.',
  ),
  inappropriate(
    label: 'Inappropriate',
    icon: Icons.report_gmailerrorred_outlined,
    placeholder: 'Tell us what content seems inappropriate.',
  );

  const RouteReportReason({
    required this.label,
    required this.icon,
    required this.placeholder,
  });

  final String label;
  final IconData icon;
  final String placeholder;
}

class SharedRouteReportSheet extends StatefulWidget {
  const SharedRouteReportSheet({
    required this.routeTitle,
    required this.routeMeta,
    required this.onClose,
    super.key,
  });

  final String routeTitle;
  final String routeMeta;
  final VoidCallback onClose;

  @override
  State<SharedRouteReportSheet> createState() => _SharedRouteReportSheetState();
}

class _SharedRouteReportSheetState extends State<SharedRouteReportSheet> {
  final TextEditingController _whyController = TextEditingController();
  RouteReportReason? _selectedReason;
  bool _isSubmitted = false;

  bool get _canReport {
    return _selectedReason != null && _whyController.text.trim().isNotEmpty;
  }

  String get _whyPlaceholder {
    return _selectedReason?.placeholder ??
        'Add details to help us review this route.';
  }

  @override
  void dispose() {
    _whyController.dispose();
    super.dispose();
  }

  void _handleReasonSelected(RouteReportReason reason) {
    setState(() => _selectedReason = reason);
  }

  void _handleWhyChanged(String value) {
    setState(() {});
  }

  void _handleReport() {
    if (!_canReport) return;
    setState(() => _isSubmitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + bottomInset),
        child: _isSubmitted
            ? _ReportSuccess(onClose: widget.onClose)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Report Route',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: RuniacColors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ReportRouteSummary(
                    title: widget.routeTitle,
                    meta: widget.routeMeta,
                  ),
                  const SizedBox(height: 22),
                  const _ReportSectionTitle('Reason'),
                  const SizedBox(height: 12),
                  _ReportReasonChips(
                    selectedReason: _selectedReason,
                    onSelected: _handleReasonSelected,
                  ),
                  const SizedBox(height: 22),
                  const _ReportSectionTitle('Why'),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('route_report_why_field'),
                    controller: _whyController,
                    onChanged: _handleWhyChanged,
                    minLines: 4,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: _whyPlaceholder,
                      filled: true,
                      fillColor: const Color(0xFFF8FAFF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: RuniacColors.border,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: RuniacColors.primaryBlue,
                          width: 1.4,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton(
                    onPressed: _canReport ? _handleReport : null,
                    style: RuniacButtonStyles.primary(
                      disabledBackgroundColor:
                          RuniacColors.disabledButtonBackground,
                      disabledForegroundColor:
                          RuniacColors.disabledButtonForeground,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Report'),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ReportRouteSummary extends StatelessWidget {
  const _ReportRouteSummary({required this.title, required this.meta});

  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        border: Border.all(color: RuniacColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: RuniacColors.white,
              border: Border.all(color: RuniacColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.route_outlined,
              color: RuniacColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reporting',
                  style: TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: RuniacColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: const TextStyle(
                    color: RuniacColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportReasonChips extends StatelessWidget {
  const _ReportReasonChips({
    required this.selectedReason,
    required this.onSelected,
  });

  final RouteReportReason? selectedReason;
  final ValueChanged<RouteReportReason> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final reason in RouteReportReason.values)
          ChoiceChip(
            avatar: Icon(reason.icon, size: 18),
            label: Text(reason.label),
            selected: selectedReason == reason,
            onSelected: (_) => onSelected(reason),
            selectedColor: const Color(0xFFEFF3FF),
            side: BorderSide(
              color: selectedReason == reason
                  ? RuniacColors.primaryBlue
                  : RuniacColors.border,
            ),
            labelStyle: TextStyle(
              color: selectedReason == reason
                  ? RuniacColors.primaryBlue
                  : RuniacColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}

class _ReportSectionTitle extends StatelessWidget {
  const _ReportSectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: RuniacColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ReportSuccess extends StatelessWidget {
  const _ReportSuccess({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Report noted',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RuniacColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This preview keeps your report on this screen only.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: RuniacColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: onClose,
            style: RuniacButtonStyles.primary(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
