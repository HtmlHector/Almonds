import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../core/theme/ios.dart';

const _samples = <(String, String)>[
  ('Nutella', '3017620422003'),
  ('Coca-Cola', '5449000000996'),
  ('Kinder Bueno', '8000500310427'),
];

/// Native sheet asking for a barcode. Returns it, or null if dismissed.
Future<String?> showManualEntrySheet(BuildContext context) {
  return showCupertinoSheet<String>(
    context: context,
    scrollableBuilder: (context, scroll) => _ManualEntry(scroll: scroll),
  );
}

class _ManualEntry extends StatefulWidget {
  const _ManualEntry({required this.scroll});

  final ScrollController scroll;

  @override
  State<_ManualEntry> createState() => _ManualEntryState();
}

class _ManualEntryState extends State<_ManualEntry> {
  final _field = TextEditingController();

  bool get _valid => RegExp(r'^\d{6,14}$').hasMatch(_field.text.trim());

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _submit() {
    if (_valid) Navigator.pop(context, _field.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        middle: const Text('Enter Barcode'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _valid ? _submit : null,
          child: const Text(
            'Look Up',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      backgroundColor: context.groupedBackground,
      child: SafeArea(
        child: ListView(
          controller: widget.scroll,
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('BARCODE'),
              footer: const Text('The number printed under the barcode.'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _field,
                  autofocus: true,
                  placeholder: 'e.g. 3017620422003',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) => _submit(),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('TRY A SAMPLE'),
              children: [
                for (final (name, code) in _samples)
                  CupertinoListTile(
                    title: Text(name),
                    subtitle: Text(code),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => Navigator.pop(context, code),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
