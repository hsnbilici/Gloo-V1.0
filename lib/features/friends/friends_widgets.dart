import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../data/remote/friend_repository.dart';

// ─── FriendCodeCard ─────────────────────────────────────────────────────────

class FriendCodeCard extends StatelessWidget {
  const FriendCodeCard({
    super.key,
    required this.code,
    required this.strings,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.onCopy,
    required this.onShare,
  });

  final String code;
  final AppStrings strings;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.badge_outlined, color: kCyan, size: 20),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.friendCode,
                  style: AppTextStyles.caption.copyWith(color: kMuted),
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  code.isEmpty ? '---' : code,
                  style: const TextStyle(
                    color: kCyan,
                    fontFamily: 'monospace',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          _IconBtn(
            icon: Icons.copy_rounded,
            semanticsLabel: strings.friendCopyCode,
            onTap: onCopy,
            textColor: textColor,
          ),
          const SizedBox(width: Spacing.sm),
          _IconBtn(
            icon: Icons.share_rounded,
            semanticsLabel: strings.friendShareCode,
            onTap: onShare,
            textColor: textColor,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
    required this.textColor,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
          ),
          child: Icon(icon, color: textColor, size: 18),
        ),
      ),
    );
  }
}

// ─── AddFriendSection ───────────────────────────────────────────────────────

class AddFriendSection extends StatefulWidget {
  const AddFriendSection({
    super.key,
    required this.strings,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.brightness,
    required this.onFollowByCode,
    required this.onSearch,
    required this.searchResults,
    required this.onFollowUser,
    this.initialCode,
  });

  final AppStrings strings;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Brightness brightness;
  final Future<bool> Function(String code) onFollowByCode;
  final ValueChanged<String> onSearch;
  final List<FriendInfo> searchResults;
  final ValueChanged<String> onFollowUser;
  final String? initialCode;

  @override
  State<AddFriendSection> createState() => _AddFriendSectionState();
}

class _AddFriendSectionState extends State<AddFriendSection> {
  int _tabIndex = 0;
  late TextEditingController _codeCtrl;
  late TextEditingController _searchCtrl;
  bool _codeLoading = false;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: widget.initialCode ?? '');
    _searchCtrl = TextEditingController();
    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      _tabIndex = 0;
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _codeLoading = true);
    final success = await widget.onFollowByCode(code);
    if (!mounted) return;
    setState(() => _codeLoading = false);
    if (success) _codeCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.strings;
    final accentColor =
        _tabIndex == 0 ? kCyan : kGold;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab row
        Row(
          children: [
            _TabChip(
              label: l.friendAddByCode,
              selected: _tabIndex == 0,
              accentColor: kCyan,
              textColor: widget.textColor,
              onTap: () => setState(() => _tabIndex = 0),
            ),
            const SizedBox(width: Spacing.sm),
            _TabChip(
              label: l.friendSearch,
              selected: _tabIndex == 1,
              accentColor: kGold,
              textColor: widget.textColor,
              onTap: () => setState(() => _tabIndex = 1),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        // Content
        if (_tabIndex == 0) _buildCodeTab(accentColor),
        if (_tabIndex == 1) _buildSearchTab(accentColor),
      ],
    );
  }

  Widget _buildCodeTab(Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _StyledTextField(
            controller: _codeCtrl,
            hintText: 'GLO-XXXX',
            surfaceColor: widget.surfaceColor,
            borderColor: widget.borderColor,
            textColor: widget.textColor,
            onSubmitted: (_) => _submitCode(),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Semantics(
          label: widget.strings.friendFollow,
          button: true,
          child: GestureDetector(
            onTap: _codeLoading ? null : _submitCode,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusSm),
              ),
              alignment: Alignment.center,
              child: _codeLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      widget.strings.friendFollow,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTab(Color accentColor) {
    return Column(
      children: [
        _StyledTextField(
          controller: _searchCtrl,
          hintText: widget.strings.friendSearch,
          surfaceColor: widget.surfaceColor,
          borderColor: widget.borderColor,
          textColor: widget.textColor,
          onChanged: widget.onSearch,
        ),
        if (widget.searchResults.isNotEmpty) ...[
          const SizedBox(height: Spacing.sm),
          ...widget.searchResults.map(
            (info) => SearchResultTile(
              info: info,
              strings: widget.strings,
              surfaceColor: widget.surfaceColor,
              borderColor: widget.borderColor,
              textColor: widget.textColor,
              onFollow: () => widget.onFollowUser(info.userId),
            ),
          ),
        ],
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusSm),
          border: Border.all(
            color: selected ? accentColor : textColor.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: selected ? accentColor : textColor.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    this.onSubmitted,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        style: AppTextStyles.body.copyWith(color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(color: kMuted),
          filled: true,
          fillColor: surfaceColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusSm),
            borderSide: const BorderSide(color: kCyan),
          ),
        ),
      ),
    );
  }
}

// ─── SearchResultTile ───────────────────────────────────────────────────────

class SearchResultTile extends StatelessWidget {
  const SearchResultTile({
    super.key,
    required this.info,
    required this.strings,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.onFollow,
  });

  final FriendInfo info;
  final AppStrings strings;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusSm),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _AvatarCircle(username: info.username),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              info.username,
              style: AppTextStyles.body.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _SmallActionButton(
            label: strings.friendFollow,
            color: kCyan,
            onTap: onFollow,
          ),
        ],
      ),
    );
  }
}

// ─── FriendTile ─────────────────────────────────────────────────────────────

class FriendTile extends StatelessWidget {
  const FriendTile({
    super.key,
    required this.info,
    required this.strings,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    this.showFollowBack = false,
    this.onAction,
    required this.actionLabel,
    required this.actionColor,
  });

  final FriendInfo info;
  final AppStrings strings;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final bool showFollowBack;
  final VoidCallback? onAction;
  final String actionLabel;
  final Color actionColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${info.username}${info.isMutual ? ', ${strings.friendMutual}' : ''}',
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusSm),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            _AvatarCircle(username: info.username),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                info.username,
                style: AppTextStyles.body.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (info.isMutual)
              Container(
                margin: const EdgeInsetsDirectional.only(end: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(UIConstants.radiusXs),
                ),
                child: Text(
                  strings.friendMutual,
                  style: AppTextStyles.caption.copyWith(
                    color: kGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (onAction != null)
              _SmallActionButton(
                label: actionLabel,
                color: actionColor,
                onTap: onAction!,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────

class FriendSectionHeader extends StatelessWidget {
  const FriendSectionHeader({
    super.key,
    required this.title,
    required this.count,
    required this.textColor,
  });

  final String title;
  final int count;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xl, bottom: Spacing.sm),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            '($count)',
            style: AppTextStyles.caption.copyWith(color: kMuted),
          ),
        ],
      ),
    );
  }
}

// ─── Shared primitives ──────────────────────────────────────────────────────

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final letter =
        username.isNotEmpty ? username[0].toUpperCase() : '?';
    // Deterministic color from username hash
    final colors = [kCyan, kGold, kGreen, kOrange, kPink];
    final colorIdx = username.hashCode.abs() % colors.length;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colors[colorIdx].withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: colors[colorIdx],
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(UIConstants.radiusXs),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
