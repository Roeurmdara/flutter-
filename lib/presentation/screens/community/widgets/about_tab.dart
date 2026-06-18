import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/community_model.dart';
import '../../../../data/providers/community_provider.dart';
// import '../../../../data/services/community_service.dart'; // not used
import '../../profile/other_user_profile_screen.dart';
import 'creator_preview_widget.dart';

class AboutTab extends ConsumerWidget {
  final Community community;

  const AboutTab({
    super.key,
    required this.community,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    // Fetch creator profile
    final creatorAsync =
        ref.watch(userProfileByIdProvider(community.createdBy));

    final membersAsync = ref.watch(communityMembersProvider(
      CommunityMembersPaginationParams(
          communityId: community.id, page: 1, perPage: 10),
    ));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
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
              color: isDark
                  ? Colors.black12
                  : Colors.black.withValues(alpha: 0.02),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: creatorAsync.when(
                  data: (response) {
                    final profile = response.data;
                    final displayName = creatorDisplayName(profile, community);
                    final avatarUrl =
                        profile?.avatarUrl ?? community.creatorAvatar;
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
                      style:
                          AppTypography.bodySmall(sub).copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _showMembersBottomSheet(context, ref),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            // Show up to 3 member previews (avatar + short name)
                            Row(
                              children: members.take(3).map((member) {
                                final avatarUrl = member.avatar;
                                final name = member.username.isEmpty
                                    ? (member.userId.isNotEmpty
                                        ? member.userId
                                        : 'Member')
                                    : member.username;
                                return GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OtherUserProfileScreen(
                                          userId: member.userId),
                                    ),
                                  ),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(right: 12.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ClipOval(
                                          child: SizedBox(
                                            width: 36,
                                            height: 36,
                                            child: avatarUrl == null ||
                                                    avatarUrl.trim().isEmpty
                                                ? Container(
                                                    color: AppColors
                                                        .primaryPurple
                                                        .withValues(
                                                            alpha: 0.12),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      name[0].toUpperCase(),
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .primaryPurple,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  )
                                                : Image.network(
                                                    avatarUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (_, __, ___) =>
                                                            Container(
                                                      color: AppColors
                                                          .primaryPurple
                                                          .withValues(
                                                              alpha: 0.12),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        name[0].toUpperCase(),
                                                        style:
                                                            const TextStyle(
                                                          color: AppColors
                                                              .primaryPurple,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                        ),
                                        ),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          width: 64,
                                          child: Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: sub,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: const [
                                Text(
                                  'See all members',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryPurple,
                                  ),
                                ),
                                SizedBox(height: 3),
                              ],
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
    );
  }

  // members description helper removed; showing explicit previews instead

  void _showMembersBottomSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, refInSheet, child) {
            final membersAsyncInSheet =
                refInSheet.watch(communityMembersProvider(
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
                            final isCreator =
                                member.userId == community.createdBy;

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OtherUserProfileScreen(
                                        userId: member.userId),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: SizedBox(
                                        width: 38,
                                        height: 38,
                                        child: avatarUrl == null ||
                                                avatarUrl.trim().isEmpty
                                            ? Container(
                                                color: AppColors.primaryPurple
                                                    .withValues(alpha: 0.12),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  displayName.isEmpty
                                                      ? '?'
                                                      : displayName[0]
                                                          .toUpperCase(),
                                                  style: const TextStyle(
                                                    color: AppColors
                                                        .primaryPurple,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : Image.network(
                                                avatarUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Container(
                                                  color: AppColors
                                                      .primaryPurple
                                                      .withValues(alpha: 0.12),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    displayName.isEmpty
                                                        ? '?'
                                                        : displayName[0]
                                                            .toUpperCase(),
                                                    style: const TextStyle(
                                                      color: AppColors
                                                          .primaryPurple,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: text,
                                            ),
                                          ),
                                          if (member.role == 'admin' ||
                                              isCreator) ...[
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
          final isDark = Theme.of(context).brightness == Brightness.dark;
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
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OtherUserProfileScreen(userId: creatorId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('View Full Profile'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
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
