import 'dart:async';

import 'package:assistive_touch/assistive_touch.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/screens/screen.dart';
import 'package:listar_flutter_pro/utils/utils.dart';

class AppContainer extends StatefulWidget {
  const AppContainer({Key? key}) : super(key: key);

  @override
  State<AppContainer> createState() {
    return _AppContainerState();
  }
}

class _AppContainerState extends State<AppContainer> {
  int _selectedIndex = 0;
  StreamSubscription? _connectivity;
  StreamSubscription? _message;
  StreamSubscription? _messageOpenedApp;
  String? _lastConnectivity;
  bool readyConnectivity = false;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 1), () {
      readyConnectivity = true;
      final state = AppBloc.applicationCubit.state;
      if (state is ApplicationStateSuccess && state.onboarding == true) {
        Navigator.pushNamed(context, Routes.onboarding);
      }
    });

    _connectivity = Connectivity().onConnectivityChanged.listen((result) {
      if (readyConnectivity && result.isNotEmpty) {
        if (_lastConnectivity == result.last.toString()) {
          return;
        }
        _lastConnectivity = result.last.toString();
        String title = 'no_internet_connection';
        IconData icon = Icons.wifi_off;
        Color color = Colors.red;
        if (result.last != ConnectivityResult.none) {
          title = 'internet_connected';
          icon = Icons.wifi;
          color = Colors.green;
        }
        AppBloc.messageBloc.add(
          MessageEvent(
            message: title,
            icon: Icon(
              icon,
              color: color,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });

    _message = FirebaseMessaging.onMessage.listen((message) {
      _notificationHandle(message);
    });
    _messageOpenedApp = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _notificationHandle(message);
    });
  }

  @override
  void dispose() {
    _message?.cancel();
    _messageOpenedApp?.cancel();
    _connectivity?.cancel();
    super.dispose();
  }

  ///check route need auth
  bool _requireAuth(int index) {
    switch (index) {
      case 0:
      case 1:
      case 2:
        return false;
      default:
        return true;
    }
  }

  ///Handle When Press Notification
  void _notificationHandle(RemoteMessage message) {
    final notification = NotificationModel.fromJson(message);
    if (notification.target != null) {
      Navigator.pushNamed(
        context,
        notification.target!,
        arguments: notification.item,
      );
    }
  }

  ///Force switch home when authentication state change
  void _listenAuthenticateChange(AuthenticationState authentication) async {
    if (authentication == AuthenticationState.fail &&
        _requireAuth(_selectedIndex)) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: _selectedIndex,
      );
      if (result != null) {
        setState(() {
          _selectedIndex = result as int;
        });
      } else {
        setState(() {
          _selectedIndex = 0;
        });
      }
    }
  }

  ///On change tab bottom menu and handle when not yet authenticate
  void _onItemTapped(int index) async {
    if (AppBloc.userCubit.state == null && _requireAuth(index)) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: index,
      );
      if (result == null) return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onShowCase() async {
    Widget? buildSelect(String domain) {
      if (domain == Application.domain) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      }
      return null;
    }

    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Showcase",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context,
                                            "https://demo.listarapp.com");
                                      },
                                      child: Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: const DecorationImage(
                                            image: AssetImage(Images.intro1),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: buildSelect(
                                          "https://demo.listarapp.com",
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Default",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(
                                        context, "https://food.listarapp.com");
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: const DecorationImage(
                                            image: AssetImage(Images.intro2),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: buildSelect(
                                          "https://food.listarapp.com",
                                        ),
                                      ),
                                      Text(
                                        "Food",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context,
                                        "https://realestate.listarapp.com");
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: const DecorationImage(
                                            image: AssetImage(Images.intro3),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: buildSelect(
                                          "https://realestate.listarapp.com",
                                        ),
                                      ),
                                      Text(
                                        "Real Estate",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(
                                        context, "https://event.listarapp.com");
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          image: const DecorationImage(
                                            image: AssetImage(Images.intro4),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: buildSelect(
                                          "https://event.listarapp.com",
                                        ),
                                      ),
                                      Text(
                                        "Event",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        AppBloc.applicationCubit.onChangeDomain(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget home = const Home();
    if (Application.setting.useLayoutWidget) {
      home = const HomeWidget();
    }
    return Scaffold(
      body: BlocListener<AuthenticationCubit, AuthenticationState>(
        listener: (context, authentication) async {
          _listenAuthenticateChange(authentication);
        },
        child: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: [
                home,
                const Discovery(),
                const BlogList(),
                const WishList(),
                const Account()
              ],
            ),
            AssistiveTouch(
              initialOffset: const Offset(12, 300),
              onTap: _onShowCase,
              margin: const EdgeInsets.all(12),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: Translate.of(context).translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on_outlined),
            label: Translate.of(context).translate('discovery'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.featured_play_list_outlined),
            label: Translate.of(context).translate('blog'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bookmark_outline),
            label: Translate.of(context).translate('wish_list'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_circle_outlined),
            label: Translate.of(context).translate('account'),
          ),
        ],
        selectedFontSize: 12,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
