import 'package:app_petfinder/core/network/api_exception.dart';
import 'package:app_petfinder/core/utils/api_error_handler.dart';
import 'package:flutter/material.dart';

typedef ReactionResult = ({bool active, int count});

class ReactionButton extends StatefulWidget {
  final bool reacted;
  final int count;
  final Future<ReactionResult> Function(bool activate) onToggle;
  final ValueChanged<ReactionResult>? onResult;

  const ReactionButton({
    super.key,
    required this.reacted,
    required this.count,
    required this.onToggle,
    this.onResult,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  late bool _reacted = widget.reacted;
  late int _count = widget.count;
  bool _busy = false;

  @override
  void didUpdateWidget(ReactionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reacted = widget.reacted;
    _count = widget.count;
    _busy = false;
  }

  Future<void> _handleToggle() async {
    if (_busy) return;

    final previousReacted = _reacted;
    final previousCount = _count;

    setState(() {
      _busy = true;
      _reacted = !_reacted;
      _count += _reacted ? 1 : -1;
    });

    try {
      final result = await widget.onToggle(_reacted);
      if (!mounted) return;

      setState(() {
        _reacted = result.active;
        _count = result.count;
      });

      widget.onResult?.call(result);
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _reacted = previousReacted;
        _count = previousCount;
      });

      ApiErrorHandler.handle(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _reacted;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: _handleToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 22,
              color: active ? Colors.redAccent : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              '$_count',
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                color: active ? Colors.redAccent : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}