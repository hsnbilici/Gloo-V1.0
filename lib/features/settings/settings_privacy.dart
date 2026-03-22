import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../data/local/data_models.dart';

// ─── Kullanıcı adı satırı ─────────────────────────────────────────────────────

class UsernameTile extends StatefulWidget {
  const UsernameTile({
    super.key,
    required this.label,
    required this.currentUsername,
    required this.dialogTitle,
    required this.dialogHint,
    required this.saveLabel,
    required this.errorEmpty,
    required this.errorTooLong,
    required this.errorInvalidChars,
    required this.onSave,
  });

  final String label;
  final String currentUsername;
  final String dialogTitle;
  final String dialogHint;
  final String saveLabel;
  final String errorEmpty;
  final String errorTooLong;
  final String errorInvalidChars;
  final Future<void> Function(String username) onSave;

  @override
  State<UsernameTile> createState() => _UsernameTileState();
}

class _UsernameTileState extends State<UsernameTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final surfaceBg = resolveColor(
      brightness,
      dark: kCyan.withValues(alpha: _hovered ? 0.09 : 0.05),
      light: kCardBgLight,
    );
    final borderColor = resolveColor(
      brightness,
      dark: kCyan.withValues(alpha: _hovered ? 0.35 : 0.22),
      light: kCardBorderLight,
    );
    final labelColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final valueColor =
        resolveColor(brightness, dark: kMuted, light: kTextSecondaryLight);
    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => _showEditDialog(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(UIConstants.radiusTile),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    color: kCyan, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: labelColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  widget.currentUsername.isEmpty
                      ? '—'
                      : widget.currentUsername,
                  style: TextStyle(color: valueColor, fontSize: 13),
                ),
                const SizedBox(width: 6),
                Icon(Icons.edit_rounded,
                    color: kCyan.withValues(alpha: 0.70), size: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) => _UsernameEditDialog(
        dialogTitle: widget.dialogTitle,
        dialogHint: widget.dialogHint,
        saveLabel: widget.saveLabel,
        initialValue: widget.currentUsername,
        errorEmpty: widget.errorEmpty,
        errorTooLong: widget.errorTooLong,
        errorInvalidChars: widget.errorInvalidChars,
        onSave: widget.onSave,
      ),
    );
  }
}

// ─── Kullanıcı adı düzenleme diyalogu ────────────────────────────────────────

class _UsernameEditDialog extends StatefulWidget {
  const _UsernameEditDialog({
    required this.dialogTitle,
    required this.dialogHint,
    required this.saveLabel,
    required this.initialValue,
    required this.errorEmpty,
    required this.errorTooLong,
    required this.errorInvalidChars,
    required this.onSave,
  });

  final String dialogTitle;
  final String dialogHint;
  final String saveLabel;
  final String initialValue;
  final String errorEmpty;
  final String errorTooLong;
  final String errorInvalidChars;
  final Future<void> Function(String) onSave;

  @override
  State<_UsernameEditDialog> createState() => _UsernameEditDialogState();
}

class _UsernameEditDialogState extends State<_UsernameEditDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String value) {
    final error = UserProfile.validateUsername(value);
    if (error == null) return null;
    return switch (error) {
      'empty' => widget.errorEmpty,
      'tooLong' => widget.errorTooLong,
      'invalidChars' => widget.errorInvalidChars,
      _ => widget.errorEmpty,
    };
  }

  Future<void> _submit() async {
    final errorMsg = _validate(_controller.text);
    if (errorMsg != null) {
      setState(() => _errorText = errorMsg);
      return;
    }
    await widget.onSave(_controller.text.trim());
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dialogBg =
        resolveColor(brightness, dark: kSurfaceDark, light: kSurfaceLight);
    final titleColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final inputBg = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.06),
      light: kCardBgLight,
    );
    final inputBorder = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.15),
      light: kCardBorderLight,
    );
    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusXl),
        side: BorderSide(color: kCyan.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.dialogTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLength: UserProfile.maxUsernameLength,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
              ],
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
              onSubmitted: (_) => _submit(),
              style: TextStyle(color: titleColor, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.dialogHint,
                hintStyle: TextStyle(
                  color: titleColor.withValues(alpha: 0.40),
                  fontSize: 14,
                ),
                errorText: _errorText,
                filled: true,
                fillColor: inputBg,
                counterStyle: TextStyle(
                  color: titleColor.withValues(alpha: 0.40),
                  fontSize: 11,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  borderSide: BorderSide(color: inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  borderSide: const BorderSide(color: kCyan),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  borderSide: const BorderSide(color: kColorClassic),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMd),
                  borderSide: const BorderSide(color: kColorClassic),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SaveButton(label: widget.saveLabel, onTap: _submit),
          ],
        ),
      ),
    );
  }
}

// ─── Kaydet butonu (dialog içi, hover destekli) ────────────────────────────

class _SaveButton extends StatefulWidget {
  const _SaveButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: kCyan.withValues(alpha: _hovered ? 0.22 : 0.15),
            borderRadius: BorderRadius.circular(UIConstants.radiusMd),
            border: Border.all(
                color: kCyan.withValues(alpha: _hovered ? 0.75 : 0.55)),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: kCyan,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Veri silme satırı ───────────────────────────────────────────────────────

class ExportDataTile extends StatefulWidget {
  const ExportDataTile({
    super.key,
    required this.label,
    required this.onExport,
  });

  final String label;
  final Future<void> Function() onExport;

  @override
  State<ExportDataTile> createState() => _ExportDataTileState();
}

class _ExportDataTileState extends State<ExportDataTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onExport,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kCyan.withValues(alpha: _hovered ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(UIConstants.radiusTile),
              border: Border.all(
                  color: kCyan.withValues(alpha: _hovered ? 0.42 : 0.28)),
            ),
            child: Row(
              children: [
                const Icon(Icons.download_rounded, color: kCyan, size: 18),
                const SizedBox(width: 12),
                Text(
                  widget.label,
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
      ),
    );
  }
}

class DeleteDataTile extends StatefulWidget {
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
  State<DeleteDataTile> createState() => _DeleteDataTileState();
}

class _DeleteDataTileState extends State<DeleteDataTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      button: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => _showConfirm(context),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: kColorClassic.withValues(alpha: _hovered ? 0.12 : 0.07),
              borderRadius: BorderRadius.circular(UIConstants.radiusTile),
              border: Border.all(
                  color:
                      kColorClassic.withValues(alpha: _hovered ? 0.42 : 0.28)),
            ),
            child: Row(
              children: [
                const Icon(Icons.delete_outline_rounded,
                    color: kColorClassic, size: 18),
                const SizedBox(width: 12),
                Text(
                  widget.label,
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
      ),
    );
  }

  Future<void> _showConfirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.70),
      builder: (_) => _DeleteConfirmDialog(
        title: widget.confirmTitle,
        message: widget.confirmMessage,
        confirmAction: widget.confirmAction,
        cancelLabel: widget.cancelLabel,
      ),
    );
    if (confirmed == true && context.mounted) {
      await widget.onDelete();
    }
  }
}

// ─── Veri silme onay diyalogu ────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatefulWidget {
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
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  bool _cancelHovered = false;
  bool _confirmHovered = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dialogBg =
        resolveColor(brightness, dark: kSurfaceDark, light: kSurfaceLight);
    final titleColor =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
    final messageColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.65),
      light: kTextSecondaryLight,
    );
    final cancelBg = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: _cancelHovered ? 0.11 : 0.07),
      light: kCardBgLight,
    );
    final cancelBorder = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: _cancelHovered ? 0.20 : 0.12),
      light: kCardBorderLight,
    );
    final cancelText =
        resolveColor(brightness, dark: Colors.white, light: kTextPrimaryLight);
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
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.message,
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
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _cancelHovered = true),
                    onExit: (_) => setState(() => _cancelHovered = false),
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
                          widget.cancelLabel,
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _confirmHovered = true),
                    onExit: (_) => setState(() => _confirmHovered = false),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: kColorClassic.withValues(
                              alpha: _confirmHovered ? 0.22 : 0.15),
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusMd),
                          border: Border.all(
                              color: kColorClassic.withValues(
                                  alpha: _confirmHovered ? 0.75 : 0.55)),
                        ),
                        child: Text(
                          widget.confirmAction,
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
