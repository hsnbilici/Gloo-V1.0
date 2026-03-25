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
import '../../providers/challenge_provider.dart';
import '../../providers/friend_provider.dart';
import '../../providers/locale_provider.dart';
import 'challenge_tab.dart';
import 'friends_widgets.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({
    super.key,
    this.initialCode,
    this.initialChallengeId,
    this.initialTab,
  });

  final String? initialCode;
  final String? initialChallengeId;
  final int? initialTab;

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen>
    with SingleTickerProviderStateMixin {
  List<FriendInfo> _searchResults = [];
  Timer? _debounce;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab?.clamp(0, 2) ?? 0,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onTabChanged() {
    // Trigger rebuild for indicator color change
    if (!_tabController.indexIsChanging) {
      setState(() {});
    }
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
    final pendingCount = ref.watch(pendingChallengeCountProvider);
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

    final indicatorColor = _tabController.index == 2
        ? kChallengePrimary
        : kCyan;

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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: indicatorColor,
          indicatorWeight: 2.5,
          labelColor: textColor,
          unselectedLabelColor: kMuted,
          labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: AppTextStyles.label,
          tabs: [
            Tab(text: l.friendTabCodeSearch),
            Tab(text: l.friendTabFriends),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.challengeTab),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: Spacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: kChallengePrimary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: AppTextStyles.micro.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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
        data: (state) => TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Code & Search
            _CodeSearchTab(
              state: state,
              strings: l,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textColor: textColor,
              brightness: brightness,
              initialCode: widget.initialCode,
              onCopyCode: () => _copyCode(state.myCode),
              onShareCode: () => _shareCode(state.myCode),
              onFollowByCode: _followByCode,
              onSearch: _onSearch,
              searchResults: _searchResults,
              onFollowUser: _followUser,
            ),
            // Tab 2: Friends
            _FriendsTab(
              state: state,
              strings: l,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textColor: textColor,
              onFollowUser: _followUser,
              onUnfollowUser: _unfollowUser,
            ),
            // Tab 3: Challenges
            const ChallengeTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Tab 1: Code & Search ──────────────────────────────────────────────────

class _CodeSearchTab extends StatelessWidget {
  const _CodeSearchTab({
    required this.state,
    required this.strings,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.brightness,
    required this.onCopyCode,
    required this.onShareCode,
    required this.onFollowByCode,
    required this.onSearch,
    required this.searchResults,
    required this.onFollowUser,
    this.initialCode,
  });

  final FriendsState state;
  final dynamic strings;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final Brightness brightness;
  final VoidCallback onCopyCode;
  final VoidCallback onShareCode;
  final Future<bool> Function(String code) onFollowByCode;
  final ValueChanged<String> onSearch;
  final List<FriendInfo> searchResults;
  final ValueChanged<String> onFollowUser;
  final String? initialCode;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: Spacing.lg,
      ),
      children: [
        FriendCodeCard(
          code: state.myCode,
          strings: strings,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          onCopy: onCopyCode,
          onShare: onShareCode,
        ),
        const SizedBox(height: Spacing.xl),
        AddFriendSection(
          strings: strings,
          surfaceColor: surfaceColor,
          borderColor: borderColor,
          textColor: textColor,
          brightness: brightness,
          onFollowByCode: onFollowByCode,
          onSearch: onSearch,
          searchResults: searchResults,
          onFollowUser: onFollowUser,
          initialCode: initialCode,
        ),
        const SizedBox(height: Spacing.xxxl),
      ],
    );
  }
}

// ─── Tab 2: Friends ────────────────────────────────────────────────────────

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({
    required this.state,
    required this.strings,
    required this.surfaceColor,
    required this.borderColor,
    required this.textColor,
    required this.onFollowUser,
    required this.onUnfollowUser,
  });

  final FriendsState state;
  final dynamic strings;
  final Color surfaceColor;
  final Color borderColor;
  final Color textColor;
  final ValueChanged<String> onFollowUser;
  final ValueChanged<String> onUnfollowUser;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = responsiveHPadding(screenWidth);

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding,
        vertical: Spacing.lg,
      ),
      children: [
        // Mutual friends
        if (state.mutualFriends.isNotEmpty) ...[
          FriendSectionHeader(
            title: strings.friendMutual,
            count: state.mutualFriends.length,
            textColor: textColor,
          ),
          ...state.mutualFriends.map(
            (f) => FriendTile(
              info: f,
              strings: strings,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textColor: textColor,
              actionLabel: strings.friendUnfollow,
              actionColor: kMuted,
              onAction: () => onUnfollowUser(f.userId),
            ),
          ),
        ],

        // Following (one-way)
        if (state.onlyFollowing.isNotEmpty) ...[
          FriendSectionHeader(
            title: strings.friendFollowing,
            count: state.onlyFollowing.length,
            textColor: textColor,
          ),
          ...state.onlyFollowing.map(
            (f) => FriendTile(
              info: f,
              strings: strings,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textColor: textColor,
              actionLabel: strings.friendUnfollow,
              actionColor: kMuted,
              onAction: () => onUnfollowUser(f.userId),
            ),
          ),
        ],

        // Followers (not followed back)
        if (state.onlyFollowers.isNotEmpty) ...[
          FriendSectionHeader(
            title: strings.friendFollowers,
            count: state.onlyFollowers.length,
            textColor: textColor,
          ),
          ...state.onlyFollowers.map(
            (f) => FriendTile(
              info: f,
              strings: strings,
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              textColor: textColor,
              showFollowBack: true,
              actionLabel: strings.friendFollow,
              actionColor: kCyan,
              onAction: () => onFollowUser(f.userId),
            ),
          ),
        ],

        const SizedBox(height: Spacing.xxxl),
      ],
    );
  }
}
