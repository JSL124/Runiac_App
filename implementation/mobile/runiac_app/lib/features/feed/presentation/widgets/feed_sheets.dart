import 'package:flutter/material.dart';

import '../../../you/presentation/widgets/you_surface_primitives.dart';

export '../comments/feed_comment_sheet.dart';
export '../comments/feed_comment_sheet_launcher.dart';

Future<void> showCurrentSessionFeedPostOptions(
  BuildContext context,
  FeedPostOptionsSheet sheet,
) => showModalBottomSheet<void>(context: context, builder: (_) => sheet);

class FeedPostOptionsSheet extends StatefulWidget {
  const FeedPostOptionsSheet._(this.showsOwnerMenu, this._action);
  factory FeedPostOptionsSheet.owner(Future<bool> Function() onDelete) =>
      FeedPostOptionsSheet._(true, onDelete);
  factory FeedPostOptionsSheet.reporter([Future<bool> Function()? onReport]) =>
      FeedPostOptionsSheet._(false, onReport);

  final bool showsOwnerMenu;
  final Future<bool> Function()? _action;

  @override
  State<FeedPostOptionsSheet> createState() => _FeedPostOptionsSheetState();
}

class _FeedPostOptionsSheetState extends State<FeedPostOptionsSheet> {
  var _reportSubmitted = false;
  var _isSubmitting = false;
  String? _error;

  Future<void> _submit(Future<bool> Function()? action) async {
    if (action == null) {
      setState(() => _reportSubmitted = true);
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final success = await action();
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSubmitting = false;
      _error = 'Post action could not finish.';
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: _reportSubmitted
          ? const Text('Report submitted', style: YouTextStyles.bodyStrong)
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Post options', style: YouTextStyles.bodyStrong),
                const SizedBox(height: 8),
                if (widget.showsOwnerMenu)
                  TextButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _submit(widget._action),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(_isSubmitting ? 'Deleting…' : 'Delete'),
                  )
                else
                  TextButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : () => _submit(widget._action),
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(_isSubmitting ? 'Reporting…' : 'Report'),
                  ),
                if (_error != null) Text(_error!),
              ],
            ),
    ),
  );
}
