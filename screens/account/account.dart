import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';
import 'package:url_launcher/url_launcher.dart';

class Account extends StatefulWidget {
  const Account({Key? key}) : super(key: key);

  @override
  State<Account> createState() {
    return _AccountState();
  }
}

class _AccountState extends State<Account> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On logout
  void _onLogout() async {
    AppBloc.authenticateCubit.onLogout();
  }

  ///On logout
  void _onDeactivate() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translate.of(context).translate('deactivate')),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Text(
                Translate.of(context).translate('would_you_like_deactivate'),
                style: Theme.of(context).textTheme.bodyMedium,
              );
            },
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('close'),
              onPressed: () {
                Navigator.pop(context, false);
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('yes'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
    if (result == true) {
      AppBloc.authenticateCubit.onDeactivate();
    }
  }

  ///On navigation
  void _onNavigate(String route) {
    Navigator.pushNamed(context, route);
  }

  ///On Preview Profile
  void _onProfile(UserModel user) {
    Navigator.pushNamed(context, Routes.profile, arguments: user);
  }

  ///On Get Support
  void _onGetSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'service@passionui.com',
      queryParameters: {'subject': '[PassionUI][Support]'},
    );
    try {
      launchUrl(uri);
    } catch (error) {
      UtilLogger.log("ERROR", error);
    }
  }

  ///On Rate App
  void _rateApp() {
    final inAppReview = InAppReview.instance;
    inAppReview.openStoreListing(appStoreId: '1515149819');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('account'),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<UserCubit, UserModel?>(
          builder: (context, user) {
            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
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
                      child: AppUserInfo(
                        user: user,
                        type: UserViewType.information,
                        onPressed: () {
                          _onProfile(user);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      child: Column(
                        children: <Widget>[
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.calendar_month,
                                color: Colors.blue,
                              ),
                            ),
                            title: Translate.of(context).translate(
                              'booking_management',
                            ),
                            onPressed: () {
                              _onNavigate(Routes.bookingManagement);
                            },
                          ),
                          const SizedBox(height: 12),
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green.withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: Colors.green,
                              ),
                            ),
                            title: Translate.of(context).translate(
                              'claim_management',
                            ),
                            onPressed: () {
                              _onNavigate(Routes.claimManagement);
                            },
                          ),
                          const SizedBox(height: 12),
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF9A825).withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.account_circle_outlined,
                                color: Color(0xFFF9A825),
                              ),
                            ),
                            title: Translate.of(context).translate(
                              'edit_profile',
                            ),
                            onPressed: () {
                              _onNavigate(Routes.editProfile);
                            },
                          ),
                          const SizedBox(height: 12),
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.purple.withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.lock_outline,
                                color: Colors.purple,
                              ),
                            ),
                            title: Translate.of(context).translate(
                              'change_password',
                            ),
                            onPressed: () {
                              _onNavigate(Routes.changePassword);
                            },
                          ),
                          const SizedBox(height: 12),
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.indigo.withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: Colors.indigo,
                              ),
                            ),
                            title: Translate.of(context).translate('setting'),
                            onPressed: () {
                              _onNavigate(Routes.setting);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      child: Column(
                        children: <Widget>[
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF9A825).withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.star_border,
                                color: Color(0xFFF9A825),
                              ),
                            ),
                            title: Translate.of(context).translate(
                              'rate_for_us',
                            ),
                            onPressed: _rateApp,
                          ),
                          const SizedBox(height: 12),
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue.withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.calendar_month_outlined,
                                color: Colors.blue,
                              ),
                            ),
                            title: Translate.of(context).translate(
                              'help_feedback',
                            ),
                            onPressed: _onGetSupport,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
                      child: Column(
                        children: <Widget>[
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.no_accounts_outlined,
                                color: Colors.red,
                              ),
                            ),
                            title:
                                Translate.of(context).translate('deactivate'),
                            onPressed: _onDeactivate,
                          ),
                          const SizedBox(height: 12),
                          AppListTitle(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withAlpha(50),
                              ),
                              child: const Icon(
                                Icons.output_outlined,
                                color: Colors.red,
                              ),
                            ),
                            title: Translate.of(context).translate(
                              'sign_out',
                            ),
                            onPressed: _onLogout,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
