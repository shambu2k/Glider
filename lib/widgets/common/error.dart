import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:glider/utils/text_style_extension.dart';

class Error extends StatelessWidget {
  const Error({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    final double? fontSize =
        Theme.of(context).textTheme.bodyText2?.scaledFontSize(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Column(
          children: <Widget>[
            Icon(
              FluentIcons.error_circle_24_regular,
              size: fontSize != null ? fontSize * 2 : null,
            ),
            const SizedBox(height: 12),
            Text(appLocalizations.wittyError),
          ],
        ),
      ),
    );
  }
}
