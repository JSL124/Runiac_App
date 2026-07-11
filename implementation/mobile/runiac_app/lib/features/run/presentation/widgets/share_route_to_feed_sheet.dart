import 'package:flutter/material.dart';

import '../../domain/models/run_summary_snapshot.dart';
import '../../../feed/data/feed_publish/feed_thumbnail_artifact.dart';
import 'share_route_feed_preview.dart';

const _rBlue = Color(0xFF2F51C8);
const _rWhite = Color(0xFFFFFFFF);
const _rBlue60 = Color(0x992F51C8);
const _rBlue30 = Color(0x4D2F51C8);
const _rBlue18 = Color(0x2E2F51C8);

class ShareRouteToFeedSheet extends StatefulWidget {
  const ShareRouteToFeedSheet({
    required this.summary,
    required this.onCancel,
    required this.onConfirm,
    this.artifact,
    super.key,
  });

  final RunSummarySnapshot summary;
  final VoidCallback onCancel;
  final Future<void> Function() onConfirm;
  final FeedThumbnailArtifact? artifact;

  @override
  State<ShareRouteToFeedSheet> createState() => _ShareRouteToFeedSheetState();
}

class _ShareRouteToFeedSheetState extends State<ShareRouteToFeedSheet> {
  var _isPosting = false;
  String? _errorMessage;

  Future<void> _confirm() async {
    setState(() {
      _isPosting = true;
      _errorMessage = null;
    });
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPosting = false;
          _errorMessage =
              'Posting is temporarily unavailable. Your run is still saved.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 12,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _rWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: _rBlue18,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Share route to Feed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _rBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.summary.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _rBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.summary.dateTimeLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _rBlue60,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                ShareRouteFeedPreview(
                  artifact: widget.artifact,
                  routeName: widget.summary.routeName,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.summary.routeName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _rBlue60,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                ShareRouteMetrics(summary: widget.summary),
                const SizedBox(height: 22),
                OutlinedButton(
                  onPressed: _isPosting ? null : widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _rBlue,
                    side: const BorderSide(color: _rBlue30, width: 1.5),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (widget.artifact == null) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Your private route preview is unavailable. Your run is still saved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _rBlue60, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _isPosting || widget.artifact == null
                      ? null
                      : _confirm,
                  icon: const Icon(Icons.send_outlined, size: 18),
                  style: FilledButton.styleFrom(
                    backgroundColor: _rBlue,
                    foregroundColor: _rWhite,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  label: Text(_isPosting ? 'Posting to Feed…' : 'Post to Feed'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
