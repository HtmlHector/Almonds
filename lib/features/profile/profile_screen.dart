import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../core/theme/score_rating.dart';
import '../../core/widgets/dialogs.dart';
import '../../state/auth_controller.dart';
import '../../state/diet_controller.dart';
import 'diet_screen.dart';
import '../../state/history_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editName(BuildContext context) async {
    final auth = context.read<AuthController>();
    final controller = TextEditingController(text: auth.username);
    final name = await showCupertinoDialog<String>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Change Username'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            autofocus: true,
            maxLength: 24,
            placeholder: 'Username',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.length < 3 || name == auth.username) return;
    final ok = await auth.changeUsername(name);
    if (!ok && context.mounted) {
      showInfoDialog(
        context,
        title: "Couldn't Update Username",
        message: auth.error,
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final auth = context.read<AuthController>();
    final ok = await confirmDestructive(
      context,
      title: 'Delete Account?',
      message:
          'This permanently deletes your account, scan history and '
          "posts. This can't be undone.",
      actionLabel: 'Delete',
    );
    if (!ok) return;
    final done = await auth.deleteAccount();
    if (!done && context.mounted) {
      showInfoDialog(
        context,
        title: "Couldn't Delete Account",
        message: auth.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final history = context.watch<HistoryController>();
    final prefs = context.watch<DietController>().prefs;
    final prefCount = prefs.diets.length + prefs.allergens.length;

    final scans = history.entries;
    final avg = scans.isEmpty
        ? null
        : (scans.map((e) => e.score).reduce((a, b) => a + b) / scans.length)
              .round();
    final name = auth.username.isEmpty ? 'Almond Fan' : auth.username;

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('Profile')),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: IosCard(
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: context.tint.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: context.tint,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: IosText.title3),
                              Text(
                                auth.email,
                                style: IosText.subhead.copyWith(
                                  color: context.secondaryLabelColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _Stat(label: 'Scans', value: '${scans.length}'),
                      const SizedBox(width: 12),
                      _Stat(
                        label: 'Favourites',
                        value: '${history.favorites.length}',
                      ),
                      const SizedBox(width: 12),
                      _Stat(
                        label: 'Avg. Score',
                        value: avg == null ? '–' : '$avg',
                        color: avg == null
                            ? null
                            : ScoreRating.fromScore(avg).color,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile.notched(
                      leading: const _IconBadge(
                        CupertinoIcons.leaf_arrow_circlepath,
                        CupertinoColors.systemGreen,
                      ),
                      title: const Text('Dietary Preferences'),
                      additionalInfo: Text(
                        prefCount == 0 ? 'None' : '$prefCount on',
                      ),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute(builder: (_) => const DietScreen()),
                      ),
                    ),
                    CupertinoListTile.notched(
                      leading: const _IconBadge(
                        CupertinoIcons.pencil,
                        CupertinoColors.systemBlue,
                      ),
                      title: const Text('Change Username'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => _editName(context),
                    ),
                    CupertinoListTile.notched(
                      leading: const _IconBadge(
                        CupertinoIcons.info,
                        CupertinoColors.systemGrey,
                      ),
                      title: const Text('About Almonds'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => showInfoDialog(
                        context,
                        title: 'Almonds 1.0.0',
                        message:
                            'Product data comes from Open Food Facts. '
                            'Scores are informational and not medical advice.',
                      ),
                    ),
                  ],
                ),
                CupertinoListSection.insetGrouped(
                  children: [
                    CupertinoListTile.notched(
                      title: Text(
                        'Sign Out',
                        style: TextStyle(color: context.tint),
                      ),
                      onTap: auth.signOut,
                    ),
                    CupertinoListTile.notched(
                      title: Text(
                        'Delete Account',
                        style: TextStyle(color: context.destructive),
                      ),
                      onTap: auth.busy ? null : () => _confirmDelete(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge(this.icon, this.color);

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 18, color: CupertinoColors.white),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: IosCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value, style: IosText.title2.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(
              label,
              style: IosText.footnote.copyWith(
                color: context.secondaryLabelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
