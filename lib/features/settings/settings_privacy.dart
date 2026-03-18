import 'package:flutter/material.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';

// ─── Veri silme satırı ───────────────────────────────────────────────────────

class ExportDataTile extends StatelessWidget {
  const ExportDataTile({
    super.key,
    required this.label,
    required this.onExport,
  });

  final String label;
  final Future<void> Function() onExport;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onExport,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kCyan.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(UIConstants.radiusTile),
            border: Border.all(color: kCyan.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              const Icon(Icons.download_rounded, color: kCyan, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: kCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteDataTile extends StatelessWidget {
  const DeleteDataTile({
    super.key,
    required this.label,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.confirmAction,
    required this.cancelLabel,
    required this.onDelete,
  });

  final String label;
  final String confirmTitle;
  final String confirmMessage;
  final String confirmAction;
  final String cancelLabel;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: () => _showConfirm(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kColorClassic.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(UIConstants.radiusTile),
            border: Border.all(color: kColorClassic.withValues(alpha: 0.28)),
          ),
          child: Row(
            children: [
              const Icon(Icons.delete_outline_rounded,
                  color: kColorClassic, size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: kColorClassic,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) => _DeleteConfirmDialog(
        title: confirmTitle,
        message: confirmMessage,
        confirmAction: confirmAction,
        cancelLabel: cancelLabel,
      ),
    );
    if (confirmed == true && context.mounted) {
      await onDelete();
    }
  }
}

// ─── Veri silme onay diyalogu ────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmAction,
    required this.cancelLabel,
  });

  final String title;
  final String message;
  final String confirmAction;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dialogBg = resolveColor(brightness, dark: kSurfaceDark, light: kSurfaceLight);
    final titleColor = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final messageColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.65),
      light: kTextSecondaryLight,
    );
    final cancelBg = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.07),
      light: kCardBgLight,
    );
    final cancelBorder = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.12),
      light: kCardBorderLight,
    );
    final cancelText = resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        side: BorderSide(color: kColorClassic.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: kColorClassic, size: 36),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: messageColor,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: cancelBg,
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusMd),
                        border: Border.all(color: cancelBorder),
                      ),
                      child: Text(
                        cancelLabel,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cancelText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: kColorClassic.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusMd),
                        border: Border.all(
                            color: kColorClassic.withValues(alpha: 0.55)),
                      ),
                      child: Text(
                        confirmAction,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: kColorClassic,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
