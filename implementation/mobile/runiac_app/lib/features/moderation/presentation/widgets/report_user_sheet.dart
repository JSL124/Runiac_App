import 'package:flutter/material.dart';

import '../../../you/presentation/widgets/you_surface_primitives.dart';
import '../../domain/models/report_user_reason.dart';

/// Opens [ReportUserSheet] as a modal bottom sheet, matching how the feed's
/// report-a-post affordance is launched in feed_sheets.dart.
Future<void> showReportUserSheet(
  BuildContext context, {
  required String targetDisplayName,
  required Future<void> Function(ReportUserReason reason, String description)
  onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ReportUserSheet(
      targetDisplayName: targetDisplayName,
      onSubmit: onSubmit,
    ),
  );
}

/// Bottom sheet for reporting another runner from their profile or from a
/// Friends row. Reuses the submit / submitting / terminal-state idiom
/// already established by `FeedPostOptionsSheet` in feed_sheets.dart.
///
/// Display-only: no XP, streak, level, rank, leaderboard score, or
/// subscription value is read, calculated, or written here — [onSubmit]
/// writes only the fixed `reports` fields the security rules allow (see
/// `report_user_writer.dart`).
///
/// The success copy ("Report submitted") is shown whether this is the first
/// report of this target or a duplicate: the Firestore rules silently deny a
/// duplicate create, and [onSubmit] is expected to silently swallow that
/// specific denial, so this widget cannot tell the two cases apart and must
/// not try to.
class ReportUserSheet extends StatefulWidget {
  const ReportUserSheet({
    required this.targetDisplayName,
    required this.onSubmit,
    super.key,
  });

  final String targetDisplayName;
  final Future<void> Function(ReportUserReason reason, String description)
  onSubmit;

  @override
  State<ReportUserSheet> createState() => _ReportUserSheetState();
}

class _ReportUserSheetState extends State<ReportUserSheet> {
  ReportUserReason _reason = ReportUserReason.harassmentOrAbuse;
  final _descriptionController = TextEditingController();
  var _isSubmitting = false;
  var _submitted = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.onSubmit(_reason, _descriptionController.text.trim());
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitted = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = 'Report could not be sent. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: _submitted
          ? const Text('Report submitted', style: YouTextStyles.bodyStrong)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Report ${widget.targetDisplayName}',
                  style: YouTextStyles.bodyStrong,
                ),
                const SizedBox(height: 8),
                for (final reason in ReportUserReason.values)
                  ListTile(
                    key: ValueKey('report-user-reason-${reason.name}'),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: Icon(
                      reason == _reason
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(reason.label),
                    onTap: _isSubmitting
                        ? null
                        : () => setState(() => _reason = reason),
                  ),
                const SizedBox(height: 8),
                TextField(
                  key: const Key('report-user-description-field'),
                  controller: _descriptionController,
                  enabled: !_isSubmitting,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Additional details (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: const Icon(Icons.flag_outlined),
                  label: Text(_isSubmitting ? 'Reporting…' : 'Report'),
                ),
                if (_error != null) Text(_error!),
              ],
            ),
    ),
  );
}
