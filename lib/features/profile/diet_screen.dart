import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/ios.dart';
import '../../data/models/diet.dart';
import '../../state/diet_controller.dart';

/// Pick diets and allergens to avoid. Products are checked against these.
class DietScreen extends StatelessWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diet = context.watch<DietController>();
    final prefs = diet.prefs;

    return CupertinoPageScaffold(
      backgroundColor: context.groupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Dietary Preferences'),
        previousPageTitle: 'Profile',
      ),
      child: ListView(
        children: [
          CupertinoListSection.insetGrouped(
            header: const Text('I FOLLOW'),
            children: [
              for (final d in Diet.values)
                CupertinoListTile.notched(
                  title: Text(d.label),
                  trailing: CupertinoSwitch(
                    value: prefs.diets.contains(d),
                    onChanged: (_) {
                      HapticFeedback.selectionClick();
                      diet.toggleDiet(d);
                    },
                  ),
                ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            header: const Text('I AVOID'),
            footer: const Text(
              'Scanned products show a clear match or conflict banner. Product '
              'data is community-sourced, so always check the package if an '
              'allergy is serious.',
            ),
            children: [
              for (final a in Allergen.values)
                CupertinoListTile.notched(
                  title: Text(a.label),
                  trailing: CupertinoSwitch(
                    value: prefs.allergens.contains(a),
                    onChanged: (_) {
                      HapticFeedback.selectionClick();
                      diet.toggleAllergen(a);
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
