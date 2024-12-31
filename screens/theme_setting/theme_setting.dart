import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class ThemeSetting extends StatefulWidget {
  const ThemeSetting({Key? key}) : super(key: key);

  @override
  State<ThemeSetting> createState() {
    return _ThemeSettingState();
  }
}

class _ThemeSettingState extends State<ThemeSetting> {
  ThemeModel? _currentTheme;
  bool _custom = false;
  Color? _primaryColor;
  Color? _secondaryColor;

  @override
  void initState() {
    super.initState();
    ApplicationState state = AppBloc.applicationCubit.state;
    if (state is ApplicationStateSuccess) {
      _currentTheme = state.theme.theme;
    }
    if (_currentTheme?.name == 'custom') _custom = true;
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On Change Theme
  void onChange() {
    ThemeModel? theme = _currentTheme;
    if (_custom) {
      theme = ThemeModel(
        name: 'custom',
        primary: _primaryColor ?? Theme.of(context).colorScheme.primary,
        secondary: _secondaryColor ?? Theme.of(context).colorScheme.secondary,
      );
    }
    AppBloc.applicationCubit.onChangeTheme(theme: theme);
  }

  ///On Switch
  void onSwitchMode(bool value) {
    setState(() {
      _custom = value;
    });
  }

  ///On Select Color
  Future<Color?> onSelectColor(Color current) async {
    return await showDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        Color? selected;
        return AlertDialog(
          title: Text(Translate.of(context).translate('choose_color')),
          content: ColorPicker(
            pickerColor: current,
            onColorChanged: (color) {
              selected = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('close'),
              onPressed: () {
                Navigator.pop(context);
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('apply'),
              onPressed: () {
                Navigator.pop(context, selected);
              },
            ),
          ],
        );
      },
    );
  }

  ///On Choose Primary
  void onChoosePrimary() async {
    final result = await onSelectColor(
      _primaryColor ?? Theme.of(context).colorScheme.primary,
    );
    if (result != null) {
      setState(() {
        _primaryColor = result;
      });
    }
  }

  ///On Choose Secondary
  void onChooseSecondary() async {
    final result = await onSelectColor(
      _secondaryColor ?? Theme.of(context).colorScheme.secondary,
    );
    if (result != null) {
      setState(() {
        _secondaryColor = result;
      });
    }
  }

  ///Build content
  Widget _buildContent() {
    Widget content = ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        Widget trailing = Container();
        final item = AppTheme.themeSupport[index];
        if (item.name == _currentTheme?.name) {
          trailing = Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.primary,
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: AppListTitle(
            title: Translate.of(context).translate(item.name),
            leading: Container(
              width: 24,
              height: 24,
              color: item.primary,
            ),
            trailing: trailing,
            onPressed: () {
              setState(() {
                _currentTheme = item;
              });
            },
          ),
        );
      },
      itemCount: AppTheme.themeSupport.length,
    );
    if (_custom) {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translate.of(context).translate('primary_color'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppPickerItem(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _primaryColor ??
                            Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Translate.of(context).translate('choose_color'),
                    onPressed: onChoosePrimary,
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Translate.of(context).translate('secondary_color'),
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AppPickerItem(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _secondaryColor ??
                            Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Translate.of(context).translate('choose_color'),
                    onPressed: onChooseSecondary,
                  )
                ],
              ),
            )
          ],
        ),
      );
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('theme'),
        ),
        elevation: 0,
        actions: [
          AppButton(
            Translate.of(context).translate('apply'),
            onPressed: onChange,
            type: ButtonType.text,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor.withAlpha(15),
                      spreadRadius: 4,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AppListTitle(
                  leading: Icon(
                    Icons.color_lens_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Translate.of(context).translate('custom_color'),
                  trailing: CupertinoSwitch(
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: _custom,
                    onChanged: onSwitchMode,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).shadowColor.withAlpha(15),
                        spreadRadius: 4,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildContent(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
