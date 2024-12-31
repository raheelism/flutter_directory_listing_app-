import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/configs/config.dart';

class AppListTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;

  const AppListTitle({
    Key? key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget subTitle = Container();
    Widget leadingWidget = const SizedBox(width: 16);
    Widget trailingWidget = RotatedBox(
      quarterTurns: AppLanguage.isRTL() ? 2 : 0,
      child: const Icon(
        Icons.keyboard_arrow_right,
        textDirection: TextDirection.ltr,
      ),
    );
    if (leading != null) {
      leadingWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: leading,
      );
    }
    if (subtitle != null) {
      subTitle = Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          subtitle!,
          style: Theme.of(context)
              .textTheme
              .labelSmall!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          leadingWidget,
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  subTitle
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: trailing ?? trailingWidget,
          )
        ],
      ),
    );
  }
}
