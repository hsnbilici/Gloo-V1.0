import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/color_constants.dart';
import '../../core/constants/color_constants_light.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/layout/responsive.dart';
import '../../core/layout/rtl_helpers.dart';
import '../../data/remote/friend_repository.dart';
import '../../providers/friend_provider.dart';
import '../../providers/locale_provider.dart';
import 'friends_widgets.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  List<FriendInfo> _searchResults = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    final l = ref.read(stringsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.friendCodeCopied),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCode(String code) {
    final l = ref.read(stringsProvider);
    Share.share(l.friendShareText(code));
  }

  Future<bool> _followByCode(String code) async {
    final repo = ref.read(friendRepositoryProvider);
    final info = await repo.searchByCode(code);
    if (info == null) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(stringsProvider).friendUserNotFound)),
      );
      return false;
    }
    final success = await repo.follow(info.userId);
    if (success) {
      ref.invalidate(friendsProvider);
    }
    return success;
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    if (query.length < 3) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final repo = ref.read(friendRepositoryProvider);
      final results = await repo.searchByUsername(query);
      if (!mounted) return;
      setState(() => _searchResults = results);
    });
  }

  Future<void> _followUser(String userId) async {
    final repo = ref.read(friendRepositoryProvider);
    await repo.follow(userId);
    ref.invalidate(friendsProvider);
  }

  Future<void> _unfollowUser(String userId) async {
    final repo = ref.read(friendRepositoryProvider);
    await repo.unfollow(userId);
    ref.invalidate(friendsProvider);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = ref.watch(stringsProvider);
    final friendsAsync = ref.watch(friendsProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);
    final dir = Directionality.of(context);
    final brightness = Theme.of(context).brightness;

    final bgColor = resolveColor(brightness, dark: kBgDark, light: kBgLight);
    final textColor = resolveColor(
      brightness,
      dark: Colors.white,
      light: kTextPrimaryLight,
    );
    final surfaceColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.06),
      light: kCardBgLight,
    );
    final borderColor = resolveColor(
      brightness,
      dark: Colors.white.withValues(alpha: 0.1),
      light: kCardBorderLight,
    );

    return ResponsiveScaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Semantics(
          label: l.backLabel,
          button: true,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Center(
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsetsDirectional.only(start: 12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(UIConstants.radiusSm),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(
                  directionalBackIcon(dir),
                  color: textColor,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          l.friendsTitle,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: friendsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: kCyan, strokeWidth: 2),
        ),
        error: (_, __) => const Center(
          child: Text(
            '---',
            style: TextStyle(color: kMuted, fontSize: 14),
          ),
        ),
        data: (state) => ListView(
          padding: EdgeInsets.symmetric(
            horizontal: hPadding,
            vertical: Spacing.lg,
          ),
          children: [
            // Friend code card
            FriendCodeCard(
              code: state.myCode,
              strings: l,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textColor: textColor,
              onCopy: () => _copyCode(state.myCode),
              onShare: () => _shareCode(state.myCode),
            ),
            const SizedBox(height: Spacing.xl),

            // Add friend section
            AddFriendSection(
              strings: l,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textColor: textColor,
              brightness: brightness,
              onFollowByCode: _followByCode,
              onSearch: _onSearch,
              searchResults: _searchResults,
              onFollowUser: _followUser,
              initialCode: widget.initialCode,
            ),

            // Mutual friends
            if (state.mutualFriends.isNotEmpty) ...[
              FriendSectionHeader(
                title: l.friendMutual,
                count: state.mutualFriends.length,
                textColor: textColor,
              ),
              ...state.mutualFriends.map(
                (f) => FriendTile(
                  info: f,
                  strings: l,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  actionLabel: l.friendUnfollow,
                  actionColor: kMuted,
                  onAction: () => _unfollowUser(f.userId),
                ),
              ),
            ],

            // Following (one-way)
            if (state.onlyFollowing.isNotEmpty) ...[
              FriendSectionHeader(
                title: l.friendFollowing,
                count: state.onlyFollowing.length,
                textColor: textColor,
              ),
              ...state.onlyFollowing.map(
                (f) => FriendTile(
                  info: f,
                  strings: l,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  actionLabel: l.friendUnfollow,
                  actionColor: kMuted,
                  onAction: () => _unfollowUser(f.userId),
                ),
              ),
            ],

            // Followers (not followed back)
            if (state.onlyFollowers.isNotEmpty) ...[
              FriendSectionHeader(
                title: l.friendFollowers,
                count: state.onlyFollowers.length,
                textColor: textColor,
              ),
              ...state.onlyFollowers.map(
                (f) => FriendTile(
                  info: f,
                  strings: l,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  textColor: textColor,
                  showFollowBack: true,
                  actionLabel: l.friendFollow,
                  actionColor: kCyan,
                  onAction: () => _followUser(f.userId),
                ),
              ),
            ],

            const SizedBox(height: Spacing.xxxl),
          ],
        ),
      ),
    );
  }
}
