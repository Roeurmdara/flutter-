import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/community_model.dart';
import '../../../../data/providers/community_provider.dart';
import '../../../../data/services/community_service.dart';
import 'community_card_stack.dart';
import 'creator_preview_widget.dart';

class AboutTab extends ConsumerWidget {
  final Community community;
  final bool isDark;
  final bool isJoined;
  final bool canJoin;
  final Color color;
  final VoidCallback onJoin;
  final VoidCallback onLeave;

  const AboutTab({
    super.key,
    required this.community,
    required this.isDark,
    required this.isJoined,
    required this.canJoin,
    required this.color,
    required this.onJoin,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    const forestGreen = Color(0xFF1B3D2F);
    final detailActionColor = isJoined
        ? const Color(0xFFD32F2F)
        : canJoin
            ? forestGreen
            : Colors.grey;

    // Fetch creator profile
    final creatorAsync = ref.watch(userProfileByIdProvider(community.createdBy));

    final membersAsync = ref.watch(communityMembersProvider(
      CommunityMembersPaginationParams(communityId: community.id, page: 1, perPage: 10),
    ));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: text,
                  size: 28,
                ),
                onPressed: () => _showCommunityOptions(context),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 2. Avatar Card Stack
          CommunityCardStack(
            community: community,
            color: color,
            isDark: isDark,
            onMembersTap: () => _showMembersBottomSheet(context, ref),
          ),

          const SizedBox(height: 24),

          // 3. Action Buttons Row
          _buildActionButtons(context, detailActionColor),

          const SizedBox(height: 32),

          // 4. Details Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black12 : Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  community.description,
                  style: AppTypography.bodySmall(sub).copyWith(
                    height: 1.6,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Created by',
                  style: AppTypography.bodySmall(sub).copyWith(fontSize: 11),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showCreatorProfile(context, community, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: creatorAsync.when(
                      data: (response) {
                        final profile = response.data;
                        final displayName = creatorDisplayName(profile, community);
                        final avatarUrl = profile?.avatarUrl ?? community.creatorAvatar;
                        final validAvatar = validCreatorImageUrl(avatarUrl);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: validAvatar == null
                                    ? CreatorInitial(displayName)
                                    : Image.network(
                                        validAvatar,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            CreatorInitial(displayName),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Loading',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      error: (_, __) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 32,
                              height: 32,
                              child: CreatorInitial(creatorFallbackName(community)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            creatorFallbackName(community),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                membersAsync.maybeWhen(
                  data: (membersResp) {
                    final members = membersResp.members;
                    if (members.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Text(
                          'Members',
                          style: AppTypography.bodySmall(sub).copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showMembersBottomSheet(context, ref),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                // Overlapping avatar pile
                                SizedBox(
                                  height: 32,
                                  width: 32.0 + (members.take(5).length - 1) * 20.0,
                                  child: Stack(
                                    children: List.generate(
                                      members.take(5).length,
                                      (index) {
                                        final member = members[index];
                                        final avatarUrl = member.avatar;
                                        final name = member.username;
                                        return Positioned(
                                          left: index * 20.0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isDark ? AppColors.darkSurface : Colors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: SizedBox(
                                                width: 28,
                                                height: 28,
                                                child: avatarUrl == null || avatarUrl.trim().isEmpty
                                                    ? Container(
                                                        color: AppColors.primaryPurple.withValues(alpha: 0.12),
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          name.isEmpty ? '?' : name[0].toUpperCase(),
                                                          style: const TextStyle(
                                                            color: AppColors.primaryPurple,
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      )
                                                    : Image.network(
                                                        avatarUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => Container(
                                                          color: AppColors.primaryPurple.withValues(alpha: 0.12),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            name.isEmpty ? '?' : name[0].toUpperCase(),
                                                            style: const TextStyle(
                                                              color: AppColors.primaryPurple,
                                                              fontSize: 11,
                                                              fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _membersDescription(members, community.memberCount),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: text,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Row(
                                        children: [
                                          Text(
                                            'See all members',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryPurple,
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 10,
                                            color: AppColors.primaryPurple,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Color detailActionColor) {
    return Row(
      children: [
        // Join / Leave community button
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: isJoined
                  ? onLeave
                  : canJoin
                      ? onJoin
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: detailActionColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isJoined
                    ? 'Leave community'
                    : canJoin
                        ? 'Join community'
                        : 'Community closed',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Secondary icon button (Share)
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.share_outlined,
              color: isDark ? AppColors.darkText : Colors.black.withValues(alpha: 0.7),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share link copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            padding: EdgeInsets.zero,
            splashRadius: 24,
          ),
        ),
      ],
    );
  }

  void _showCommunityOptions(BuildContext context) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Community Options',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: text,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('View Guidelines'),
                onTap: () {
                  Navigator.pop(context);
                  // Show guidelines snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Guidelines: Be respectful and post content related to the community topic.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              if (isJoined)
                ListTile(
                  leading: const Icon(Icons.exit_to_app_rounded, color: Colors.red),
                  title: const Text('Leave Community', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    onLeave();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  String _membersDescription(List<CommunityMember> members, int totalCount) {
    if (members.isEmpty) return 'No members joined yet';
    final names = members.take(2).map((m) => m.username).join(', ');
    if (totalCount <= 2) {
      return '$names joined';
    } else {
      final remaining = totalCount - 2;
      return '$names and $remaining others';
    }
  }

  void _showMembersBottomSheet(BuildContext context, WidgetRef ref) {
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, refInSheet, child) {
            final membersAsyncInSheet = refInSheet.watch(communityMembersProvider(
              CommunityMembersPaginationParams(
                communityId: community.id,
                page: 1,
                perPage: 100,
              ),
            ));

            return Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Members (${community.memberCount})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: membersAsyncInSheet.when(
                      data: (response) {
                        final list = response.members;
                        if (list.isEmpty) {
                          return const Center(child: Text('No members found'));
                        }
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => Divider(
                            color: isDark ? Colors.white10 : Colors.grey[200],
                            height: 1,
                          ),
                          itemBuilder: (context, idx) {
                            final member = list[idx];
                            final displayName = member.username;
                            final avatarUrl = member.avatar;
                            final isCreator = member.userId == community.createdBy;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: SizedBox(
                                      width: 38,
                                      height: 38,
                                      child: avatarUrl == null || avatarUrl.trim().isEmpty
                                          ? Container(
                                              color: AppColors.primaryPurple.withValues(alpha: 0.12),
                                              alignment: Alignment.center,
                                              child: Text(
                                                displayName.isEmpty ? '?' : displayName[0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: AppColors.primaryPurple,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                          : Image.network(
                                              avatarUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                color: AppColors.primaryPurple.withValues(alpha: 0.12),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  displayName.isEmpty ? '?' : displayName[0].toUpperCase(),
                                                  style: const TextStyle(
                                                    color: AppColors.primaryPurple,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: text,
                                          ),
                                        ),
                                        if (member.role == 'admin' || isCreator) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            isCreator ? 'Owner' : 'Admin',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primaryPurple,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (err, _) => Center(
                        child: Text(
                          'Error loading members: $err',
                          style: TextStyle(color: sub),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatorProfile(
      BuildContext context, Community community, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer(
        builder: (context, refInModal, child) {
          final creatorId = community.createdBy;
          final creatorAsync =
              refInModal.watch(userProfileByIdProvider(creatorId));
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creator',
                  style: AppTypography.headlineSmall(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 16),
                creatorAsync.when(
                  data: (response) {
                    final profile = response.data;
                    if (profile == null && community.creatorName == null) {
                      return CreatorIdFallback(
                        displayName: creatorFallbackName(community),
                        isDark: isDark,
                      );
                    }
                    return CreatorAccountPreview(
                      username: profile?.username ??
                          community.creatorName ??
                          'Creator',
                      avatarUrl: profile?.avatarUrl ?? community.creatorAvatar,
                      bio: profile?.bio,
                      isDark: isDark,
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, __) => CreatorIdFallback(
                    displayName: creatorFallbackName(community),
                    isDark: isDark,
                    message: 'Creator profile is unavailable right now.',
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
