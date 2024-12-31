import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({Key? key, required this.item}) : super(key: key);

  final ProductModel item;

  @override
  State<ProductDetail> createState() {
    return _ProductDetailState();
  }
}

class _ProductDetailState extends State<ProductDetail> {
  final _scrollController = ScrollController();
  final _productDetailCubit = ProductDetailCubit();
  StreamSubscription? _reviewSubscription;

  Color? _iconColor = Colors.white;
  bool _showCategoryLocation = true;
  bool _showVideo = true;
  bool _showHour = true;
  bool _showFile = true;
  bool _showSocial = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _productDetailCubit.onLoad(widget.item.id);
    _reviewSubscription = AppBloc.reviewCubit.stream.listen((state) {
      if (state is ReviewSuccess &&
          state.id != null &&
          state.id == widget.item.id) {
        _productDetailCubit.onLoad(widget.item.id);
      }
    });
  }

  @override
  void dispose() {
    _reviewSubscription?.cancel();
    _productDetailCubit.close();
    _scrollController.dispose();
    super.dispose();
  }

  ///Handle icon theme
  void _onScroll() {
    Color? color;
    if (_scrollController.position.extentBefore < 110) {
      color = Colors.white;
    }
    if (color != _iconColor) {
      setState(() {
        _iconColor = color;
      });
    }
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) {
    Navigator.pushNamed(context, Routes.productDetail, arguments: item);
  }

  ///On Preview Profile
  void _onProfile(UserModel user) {
    Navigator.pushNamed(context, Routes.profile, arguments: user);
  }

  ///On navigate map
  void _onLocation(ProductModel item) {
    Navigator.pushNamed(
      context,
      Routes.gpsPicker,
      arguments: item.gps,
    );
  }

  ///On show message fail
  void _showMessage(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            Translate.of(context).translate('explore_product'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
          ],
        );
      },
    );
  }

  void _onCopy(ProductModel item) {
    Clipboard.setData(
      ClipboardData(text: item.link),
    );
    AppBloc.messageBloc.add(MessageEvent(message: "listing_link_copied"));
  }

  ///On Scan QR
  void _onShare(ProductModel item) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final id = '${item.id}';
        final link = 'listar://qrcode?type=listing&action=view&id=$id';
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: IntrinsicHeight(
              child: Container(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  left: 16,
                  right: 16,
                ),
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
                    Column(
                      children: [
                        Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: item.image.thumb,
                              placeholder: (context, url) {
                                return AppPlaceholder(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                              imageBuilder: (context, imageProvider) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              },
                              errorWidget: (context, url, error) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.error),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  Translate.of(context).translate(
                                    'share_qr_listing',
                                  ),
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  AppButton(
                                    Translate.of(context).translate('share'),
                                    mainAxisSize: MainAxisSize.max,
                                    size: ButtonSize.small,
                                    type: ButtonType.outline,
                                    onPressed: () {
                                      Navigator.pop(context, "share");
                                    },
                                  ),
                                  AppButton(
                                    Translate.of(context).translate('copy'),
                                    mainAxisSize: MainAxisSize.max,
                                    size: ButtonSize.small,
                                    onPressed: () {
                                      Navigator.pop(context, "copy");
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              alignment: Alignment.center,
                              width: 150,
                              height: 150,
                              child: QrImageView(
                                data: link,
                                size: 150,
                                backgroundColor: Colors.white,
                                errorStateBuilder: (cxt, err) {
                                  return const Text(
                                    "Uh oh! Something went wrong...",
                                    textAlign: TextAlign.center,
                                  );
                                },
                                padding: EdgeInsets.zero,
                                embeddedImage: NetworkImage(item.image.thumb),
                                embeddedImageStyle: const QrEmbeddedImageStyle(
                                  size: Size(24, 24),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (result == 'share') {
      Share.share(
        'Check out my item ${item.link}',
        subject: 'PassionUI',
      );
    } else if (result == 'copy') {
      _onCopy(item);
    }
  }

  ///On navigate gallery
  void _onPhotoPreview(ProductModel item) {
    Navigator.pushNamed(
      context,
      Routes.gallery,
      arguments: item,
    );
  }

  ///On navigate review
  void _onReview(ProductModel product) {
    Navigator.pushNamed(
      context,
      Routes.review,
      arguments: product,
    );
  }

  ///On like product
  void _onFavorite() async {
    if (AppBloc.userCubit.state == null) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.productDetail,
      );
      if (result != Routes.productDetail) return;
    }
    _productDetailCubit.onFavorite();
  }

  ///On Booking
  void _onBooking() async {
    if (AppBloc.userCubit.state == null) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.productDetail,
      );
      if (result != Routes.productDetail) return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      Routes.booking,
      arguments: widget.item.id,
    );
  }

  ///On Claim
  void _onClaim() async {
    if (AppBloc.userCubit.state == null) {
      final result = await Navigator.pushNamed(
        context,
        Routes.signIn,
        arguments: Routes.claim,
      );
      if (result != Routes.claim) return;
    }
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      Routes.claim,
      arguments: widget.item,
    );
  }

  ///Phone action
  void _phoneAction(String phone) async {
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
                    Column(
                      children: [
                        AppListTitle(
                          title: '${Translate.of(context).translate('call')} $phone',
                          leading: SizedBox(
                            height: 32,
                            width: 32,
                            child: Icon(Icons.phone),
                          ),
                          onPressed: () {
                            _makeAction('tel:$phone');
                          },
                        ),
                        AppListTitle(
                          title: 'WhatsApp',
                          leading: SizedBox(
                            height: 32,
                            width: 32,
                            child: Image.asset(Images.whatsapp),
                          ),
                          onPressed: () {
                            Navigator.pop(context, "WhatsApp");
                          },
                        ),
                        AppListTitle(
                          title: 'Viber',
                          leading: SizedBox(
                            height: 32,
                            width: 32,
                            child: Image.asset(Images.viber),
                          ),
                          onPressed: () {
                            Navigator.pop(context, "Viber");
                          },
                        ),
                        AppListTitle(
                          title: 'Telegram',
                          leading: SizedBox(
                            height: 32,
                            width: 32,
                            child: Image.asset(Images.telegram),
                          ),
                          onPressed: () {
                            Navigator.pop(context, "Telegram");
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != null) {
      String url = '';
      String storeId = '';
      phone = phone.replaceAll(RegExp(r'-'), '');

      switch (result) {
        case "WhatsApp":
          url = "whatsapp://send?phone=$phone";
          if (Platform.isAndroid) {
            storeId = "com.whatsapp";
          } else {
            storeId = "whatsapp-messenger/id310633997";
          }
          break;
        case "Viber":
          url = "viber://contact?number=${Uri.encodeComponent(phone)}";

          if (Platform.isAndroid) {
            storeId = "com.viber.voip";
          } else {
            storeId = "viber-messenger-chats-calls/id382617920";
          }
          break;
        case "Telegram":
          url = "tg://resolve?phone=$phone";
          if (Platform.isAndroid) {
            storeId = "org.telegram.messenger";
          } else {
            storeId = "telegram-messenger/id686449807";
          }
          break;
        default:
          break;
      }

      launchUrl(Uri.parse(url)).then((value) {
        if (!value) {
          _showMessageInstall(result, storeId);
        }
      }).catchError((error) {
        _showMessageInstall(result, storeId);
      });
    }
  }

  ///On show message install
  void _showMessageInstall(String appName, String storeId) async {
    final storeUrl = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=$storeId'
        : 'https://apps.apple.com/us/app/$storeId';
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Translate.of(context).translate('app_not_found')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${Translate.of(context).translate('install')} $appName ?',
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
          actions: <Widget>[
            AppButton(
              Translate.of(context).translate('cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
              type: ButtonType.text,
            ),
            AppButton(
              Translate.of(context).translate('install'),
              onPressed: () async {
                Navigator.of(context).pop();
                final Uri appStoreUri = Uri.parse(storeUrl);
                if (await canLaunchUrl(appStoreUri)) {
                  await launchUrl(appStoreUri,
                      mode: LaunchMode.externalApplication);
                }
              },
              type: ButtonType.text,
            ),
          ],
        );
      },
    );
  }

  ///Make action
  void _makeAction(String url) async {
    final canLaunch = await canLaunchUrl(Uri.parse(url));
    if (canLaunch) {
      launchUrl(Uri.parse(url));
    } else {
      _showMessage(Translate.of(context).translate('cannot_make_action'));
    }
  }

  ///Build social image
  String _exportSocial(String type) {
    switch (type) {
      case "telegram":
        return Images.telegram;
      case "twitter":
        return Images.twitter;
      case "flickr":
        return Images.flickr;
      case "google_plus":
        return Images.google;
      case "tumblr":
        return Images.tumblr;
      case "linkedin":
        return Images.linkedin;
      case "pinterest":
        return Images.pinterest;
      case "youtube":
        return Images.youtube;
      case "instagram":
        return Images.instagram;
      default:
        return Images.facebook;
    }
  }

  ///Build content UI
  Widget _buildContent(ProductModel? product) {
    ///Build UI loading
    List<Widget> action = [];
    Widget actionGalleries = Container();
    Widget actionMapView = Container();
    Widget banner = AppPlaceholder(
      child: Container(
        color: Colors.white,
      ),
    );
    Widget video = Container();
    Widget status = Container();
    Widget title = AppPlaceholder(
      child: Container(
        height: 18,
        width: 150,
        color: Colors.white,
      ),
    );
    Widget favorite = Container(height: 40);
    Widget claim = Container();
    Widget rating = AppPlaceholder(
      child: Column(
        children: [
          Container(
            height: 10,
            width: 100,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            height: 24,
            width: 100,
            color: Colors.white,
          )
        ],
      ),
    );
    Widget address = Container();
    Widget phone = Container();
    Widget fax = Container();
    Widget email = Container();
    Widget website = Container();
    Widget openHours = Container();
    Widget attachments = Container();
    Widget socials = Container();
    Widget description = AppPlaceholder(
      child: Column(
        children: [
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                height: 20,
                color: Colors.white,
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 8);
            },
            itemCount: 10,
          ),
        ],
      ),
    );
    Widget tags = Container();
    Widget latest = Container();
    Widget feature = Container();
    Widget related = Container();
    Widget dateEstablish = Container();
    Widget priceRange = Container();

    Color? backgroundAction;

    /// Build Detail
    if (product != null) {
      ///background action

      if (_iconColor == Colors.white) {
        backgroundAction = Colors.grey.withOpacity(0.3);
      }

      ///Action Galleries
      if (product.galleries.isNotEmpty) {
        actionGalleries = Row(
          children: [
            const SizedBox(width: 8),
            Container(
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundAction,
              ),
              child: IconButton(
                enableFeedback: true,
                icon: const Icon(Icons.photo_library_outlined),
                onPressed: () {
                  _onPhotoPreview(product);
                },
              ),
            ),
          ],
        );
      }

      ///Action Map View
      if (product.gps != null) {
        actionMapView = Row(
          children: [
            const SizedBox(width: 8),
            Container(
              width: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundAction,
              ),
              child: IconButton(
                enableFeedback: true,
                icon: const Icon(Icons.map_outlined),
                onPressed: () {
                  _onLocation(product);
                },
              ),
            ),
          ],
        );
      }

      ///Status
      if (product.status.isNotEmpty) {
        status = AppTag(
          product.status,
          type: TagType.status,
        );
      }

      ///Latest
      if (product.latest.isNotEmpty) {
        latest = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                Translate.of(context).translate('latest'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final ProductModel item = product.latest[index];
                  return Container(
                    width: MediaQuery.of(context).size.width / 2,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: AppProductItem(
                      onPressed: () {
                        _onProductDetail(item);
                      },
                      item: item,
                      type: ProductViewType.grid,
                    ),
                  );
                },
                itemCount: product.latest.length,
              ),
            )
          ],
        );
      }

      ///Related list
      if (product.related.isNotEmpty) {
        related = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                Translate.of(context).translate('related'),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final item = product.related[index];
                  return AppProductItem(
                    onPressed: () {
                      _onProductDetail(item);
                    },
                    item: item,
                    type: ProductViewType.small,
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
                itemCount: product.related.length,
              ),
            ],
          ),
        );
      }

      ///Video
      if (product.videoURL.isNotEmpty) {
        video = Positioned(
          bottom: 8,
          right: 8,
          child: InkWell(
            onTap: () {
              setState(() {
                _showVideo = true;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.3),
              ),
              child: const Icon(
                Icons.videocam_outlined,
                color: Colors.white,
              ),
            ),
          ),
        );
        if (_showVideo) {
          video = Positioned.fill(
            child: AppVideo(
              url: product.videoURL,
              actions: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _showVideo = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                    child: const Icon(
                      Icons.photo_size_select_actual_outlined,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          );
        }
      }

      ///Address
      if (product.address.isNotEmpty) {
        final locations = [];
        if (product.country != null && product.country!.title.isNotEmpty) {
          locations.add(product.country?.title);
        }
        if (product.city != null && product.city!.title.isNotEmpty) {
          locations.add(product.city?.title);
        }
        if (product.state != null && product.state!.title.isNotEmpty) {
          locations.add(product.state?.title);
        }
        address = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: () {
                      _makeAction(
                        'https://www.google.com/maps/search/?api=1&query=${product.gps!.latitude},${product.gps!.longitude}',
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                Translate.of(context).translate('address'),
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                              Text(
                                product.address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showCategoryLocation = !_showCategoryLocation;
                    });
                  },
                  child: Icon(
                    _showCategoryLocation
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                )
              ],
            ),
            Visibility(
              visible: _showCategoryLocation,
              child: Container(
                margin: const EdgeInsets.only(left: 42),
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  locations.join(", "),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ],
        );
      }

      ///Phone
      if (product.phone.isNotEmpty) {
        phone = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                _phoneAction(product.phone);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).dividerColor,
                    ),
                    child: const Icon(
                      Icons.phone_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate('phone'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          product.phone,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }

      ///Fax
      if (product.fax.isNotEmpty) {
        fax = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                _makeAction('tel:${product.fax}');
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).dividerColor,
                    ),
                    child: const Icon(
                      Icons.perm_phone_msg_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate('fax'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          product.fax,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }

      ///Email
      if (product.email.isNotEmpty) {
        email = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                _makeAction('mailto:${product.email}');
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).dividerColor,
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate('email'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          product.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }

      ///Website
      if (product.website.isNotEmpty) {
        website = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                _makeAction(product.website);
              },
              child: Row(
                children: <Widget>[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).dividerColor,
                    ),
                    child: const Icon(
                      Icons.language_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate('website'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        Text(
                          product.website,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }

      ///Open hours
      if (product.openHours.isNotEmpty) {
        openHours = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _showHour = !_showHour;
                });
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                          child: const Icon(
                            Icons.access_time_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Translate.of(context).translate('open_time'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showHour
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),
            Visibility(
              visible: _showHour,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: product.openHours.map((item) {
                  final hour = item.schedule
                      .map((e) {
                        return '${e.start.viewTime}-${e.end.viewTime}';
                      })
                      .toList()
                      .join(",");
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerColor,
                          width: 1,
                        ),
                      ),
                    ),
                    margin: const EdgeInsets.only(left: 42),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          Translate.of(context).translate(item.key),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            hour,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }

      ///File attachments
      if (product.attachments.isNotEmpty) {
        attachments = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _showFile = !_showFile;
                });
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                          child: const Icon(
                            Icons.file_copy_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Translate.of(context).translate('attachments'),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            Text(
                              '${product.attachments.length} ${Translate.of(context).translate('files')}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showFile
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),
            Visibility(
              visible: _showFile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: product.attachments.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(left: 42),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${item.name}.${item.type}',
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Text(
                              item.size,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            AppDownloadFile(file: item),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }

      ///Date established
      if (product.dateEstablish.isNotEmpty) {
        dateEstablish = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Translate.of(context).translate(
                'date_established',
              ),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              product.dateEstablish,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        );
      }

      ///Price range
      if (product.priceMin.isNotEmpty || product.priceMax.isNotEmpty) {
        priceRange = Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              Translate.of(context).translate('price_range'),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            Text(
              "${product.priceMin} - ${product.priceMax}",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            )
          ],
        );
      }

      ///Feature
      if (product.features.isNotEmpty) {
        feature = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('featured'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.features.map((item) {
                return IntrinsicWidth(
                  child: AppTag(
                    item.title,
                    type: TagType.chip,
                    icon: Icon(
                      item.icon,
                      size: 10,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }

      ///Tags
      if (product.tags.isNotEmpty) {
        tags = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              Translate.of(context).translate('tags'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.tags.map((item) {
                return IntrinsicWidth(
                  child: AppTag(
                    item.title,
                    type: TagType.chip,
                  ),
                );
              }).toList(),
            ),
          ],
        );
      }

      ///socials
      if (product.socials.isNotEmpty) {
        socials = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                setState(() {
                  _showSocial = !_showSocial;
                });
              },
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).dividerColor,
                          ),
                          child: const Icon(
                            Icons.link,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Translate.of(context).translate('social_network'),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _showSocial
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  )
                ],
              ),
            ),
            Visibility(
              visible: _showSocial,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.socials.entries.map((entry) {
                    return InkWell(
                      onTap: () {
                        _makeAction(entry.value ?? '');
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                              _exportSocial(entry.key),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      }

      ///Claim
      if (product.useClaim) {
        claim = InkWell(
          onTap: _onClaim,
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            child: Text(
              Translate.of(context).translate('claim'),
              style: Theme.of(context)
                  .textTheme
                  .labelLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        );
      }

      ///Title
      title = Expanded(
        child: Text(
          product.title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );

      ///Favorite
      favorite = IconButton(
        enableFeedback: true,
        icon: Icon(
          product.favorite ? Icons.favorite : Icons.favorite_border,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: _onFavorite,
      );

      ///Action
      action = [
        Container(
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundAction,
          ),
          child: IconButton(
            enableFeedback: true,
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              _onShare(product);
            },
          ),
        ),
        actionMapView,
        actionGalleries,
        const SizedBox(width: 8),
      ];

      ///Banner
      banner = Stack(
        children: [
          CachedNetworkImage(
            imageUrl: product.image.full,
            placeholder: (context, url) {
              return AppPlaceholder(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              );
            },
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
            errorWidget: (context, url, error) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: const Icon(Icons.error),
              );
            },
          ),
          video,
        ],
      );

      ///Rating
      rating = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            product.category?.title ?? '',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              _onReview(product);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AppTag(
                  "${product.rate}",
                  type: TagType.rate,
                ),
                const SizedBox(width: 4),
                RatingBar.builder(
                  initialRating: product.rate,
                  unratedColor: Colors.amber.withAlpha(100),
                  itemCount: 5,
                  itemSize: 14.0,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rate) {},
                  ignoreGestures: true,
                ),
                const SizedBox(width: 4),
                Text(
                  "(${product.numRate})",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          )
        ],
      );

      ///Description
      description = Text(
        product.description,
        style: Theme.of(context).textTheme.labelLarge,
      );
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      controller: _scrollController,
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.height * 0.25,
          pinned: true,
          actions: action,
          iconTheme: Theme.of(context).iconTheme.copyWith(color: _iconColor),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.none,
            background: banner,
          ),
        ),
        SliverToBoxAdapter(
          child: SafeArea(
            top: false,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppUserInfo(
                            user: product?.author,
                            type: UserViewType.basic,
                            onPressed: () {
                              _onProfile(product!.author!);
                            },
                          ),
                          status
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          title,
                          favorite,
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          rating,
                          claim,
                        ],
                      ),
                      address,
                      phone,
                      fax,
                      email,
                      website,
                      openHours,
                      attachments,
                      socials,
                      const SizedBox(height: 12),
                      description,
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          dateEstablish,
                          priceRange,
                        ],
                      ),
                      feature,
                      tags,
                    ],
                  ),
                ),
                latest,
                related,
              ],
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      bloc: _productDetailCubit,
      builder: (context, state) {
        ProductModel? product;
        List<Widget>? footerButtons;
        if (state is ProductDetailSuccess) {
          product = state.product;
          if (product.priceDisplay.isNotEmpty) {
            footerButtons = [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          Translate.of(context).translate('total_price'),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                        Text(
                          product.priceDisplay,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        )
                      ],
                    ),
                    AppButton(
                      Translate.of(context).translate('book_now'),
                      onPressed: _onBooking,
                    )
                  ],
                ),
              )
            ];
          }
        }
        return Scaffold(
          body: _buildContent(product),
          persistentFooterButtons: footerButtons,
        );
      },
    );
  }
}
