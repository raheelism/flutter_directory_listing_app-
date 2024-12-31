import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/screens/screen.dart';

class RouteArguments<T> {
  final T? item;
  final VoidCallback? callback;
  RouteArguments({this.item, this.callback});
}

class Routes {
  static const String onboarding = "/onboarding";
  static const String home = "/home";
  static const String discovery = "/discovery";
  static const String wishList = "/wishList";
  static const String account = "/account";
  static const String signIn = "/signIn";
  static const String signUp = "/signUp";
  static const String forgotPassword = "/forgotPassword";
  static const String productDetail = "/productDetail";
  static const String blogList = "/blogList";
  static const String blogDetail = "/blogDetail";
  static const String searchHistory = "/searchHistory";
  static const String category = "/category";
  static const String profile = "/profile";
  static const String submit = "/submit";
  static const String editProfile = "/editProfile";
  static const String changePassword = "/changePassword";
  static const String changeLanguage = "/changeLanguage";
  static const String gallery = "/gallery";
  static const String themeSetting = "/themeSetting";
  static const String listProduct = "/listProduct";
  static const String filter = "/filter";
  static const String review = "/review";
  static const String writeReview = "/writeReview";
  static const String setting = "/setting";
  static const String fontSetting = "/fontSetting";
  static const String picker = "/picker";
  static const String galleryUpload = "/galleryUpload";
  static const String categoryPicker = "/categoryPicker";
  static const String gpsPicker = "/gpsPicker";
  static const String payment = "/payment";
  static const String submitSuccess = "/submitSuccess";
  static const String openTime = "/openTime";
  static const String socialNetwork = "/socialNetwork";
  static const String tagsPicker = "/tagsPicker";
  static const String webView = "/webView";
  static const String booking = "/booking";
  static const String bookingManagement = "/bookingManagement";
  static const String claim = "/claim";
  static const String claimManagement = "/claimManagement";
  static const String claimDetail = "/claimDetail";
  static const String feedback = "/feedback";
  static const String bookingDetail = "/bookingDetail";
  static const String scanQR = "/scanQR";
  static const String deepLink = "/deepLink";
  static const String otpVerification = "/otpVerification";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          builder: (context) {
            return const Onboarding();
          },
          fullscreenDialog: true,
        );

      case signIn:
        return MaterialPageRoute(
          builder: (context) {
            return SignIn(from: settings.arguments);
          },
          fullscreenDialog: true,
        );

      case signUp:
        return MaterialPageRoute(
          builder: (context) {
            return const SignUp();
          },
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (context) {
            return const ForgotPassword();
          },
        );

      case productDetail:
        return MaterialPageRoute(
          builder: (context) {
            final item = settings.arguments as ProductModel;
            return Application.setting.businessFactory
                .createProductDetail(item);
          },
        );

      case blogDetail:
        return MaterialPageRoute(
          builder: (context) {
            final item = settings.arguments as BlogModel;
            return BlogDetail(blog: item);
          },
        );
      case searchHistory:
        return MaterialPageRoute(
          builder: (context) {
            return const SearchHistory();
          },
        );

      case category:
        return MaterialPageRoute(
          builder: (context) {
            return Category(item: settings.arguments as CategoryModel?);
          },
        );

      case profile:
        return MaterialPageRoute(
          builder: (context) {
            return Profile(user: settings.arguments as UserModel);
          },
        );

      case submit:
        return MaterialPageRoute(
          builder: (context) {
            return Submit(item: settings.arguments as ProductModel?);
          },
          fullscreenDialog: true,
        );

      case editProfile:
        return MaterialPageRoute(
          builder: (context) {
            return const EditProfile();
          },
        );

      case changePassword:
        return MaterialPageRoute(
          builder: (context) {
            return const ChangePassword();
          },
        );

      case changeLanguage:
        return MaterialPageRoute(
          builder: (context) {
            return const LanguageSetting();
          },
        );

      case themeSetting:
        return MaterialPageRoute(
          builder: (context) {
            return const ThemeSetting();
          },
        );

      case filter:
        return MaterialPageRoute(
          builder: (context) {
            return Filter(filter: settings.arguments as FilterModel);
          },
          fullscreenDialog: true,
        );

      case review:
        return MaterialPageRoute(
          builder: (context) {
            return Review(item: settings.arguments);
          },
        );

      case setting:
        return MaterialPageRoute(
          builder: (context) {
            return const Setting();
          },
        );

      case fontSetting:
        return MaterialPageRoute(
          builder: (context) {
            return const FontSetting();
          },
        );

      case writeReview:
        return MaterialPageRoute(
          builder: (context) => WriteReview(
            item: settings.arguments,
          ),
        );

      case listProduct:
        return MaterialPageRoute(
          builder: (context) {
            return ProductList(category: settings.arguments as CategoryModel);
          },
        );

      case gallery:
        return MaterialPageRoute(
          builder: (context) {
            return Gallery(product: settings.arguments as ProductModel);
          },
          fullscreenDialog: true,
        );

      case galleryUpload:
        return MaterialPageRoute(
          builder: (context) {
            return GalleryUpload(
              images: settings.arguments as List<ImageModel>,
            );
          },
          fullscreenDialog: true,
        );

      case categoryPicker:
        return MaterialPageRoute(
          builder: (context) {
            return CategoryPicker(
              picker: settings.arguments as PickerModel,
            );
          },
          fullscreenDialog: true,
        );

      case gpsPicker:
        return MaterialPageRoute(
          builder: (context) {
            return GPSPicker(
              picked: settings.arguments as GPSModel?,
            );
          },
          fullscreenDialog: true,
        );

      case picker:
        return MaterialPageRoute(
          builder: (context) {
            return Picker(
              picker: settings.arguments as PickerModel,
            );
          },
          fullscreenDialog: true,
        );

      case openTime:
        return MaterialPageRoute(
          builder: (context) {
            List<OpenTimeModel>? arguments;
            if (settings.arguments != null) {
              arguments = settings.arguments as List<OpenTimeModel>;
            }
            return OpenTime(
              selected: arguments,
            );
          },
          fullscreenDialog: true,
        );

      case socialNetwork:
        return MaterialPageRoute(
          builder: (context) {
            return SocialNetwork(
              socials: settings.arguments as Map<String, dynamic>?,
            );
          },
          fullscreenDialog: true,
        );

      case submitSuccess:
        return MaterialPageRoute(
          builder: (context) {
            return const SubmitSuccess();
          },
          fullscreenDialog: true,
        );

      case tagsPicker:
        return MaterialPageRoute(
          builder: (context) {
            return TagsPicker(
              selected: settings.arguments as List<String>,
            );
          },
          fullscreenDialog: true,
        );

      case webView:
        return MaterialPageRoute(
          builder: (context) {
            return Web(
              web: settings.arguments as WebViewModel,
            );
          },
          fullscreenDialog: true,
        );

      case payment:
        return MaterialPageRoute(
          builder: (context) {
            return Payment(payment: settings.arguments as PaymentModel);
          },
          fullscreenDialog: true,
        );

      case booking:
        return MaterialPageRoute(
          builder: (context) {
            return Booking(
              id: settings.arguments as int,
            );
          },
        );

      case claim:
        return MaterialPageRoute(
          builder: (context) {
            return Claim(item: settings.arguments as ProductModel);
          },
        );

      case claimManagement:
        return MaterialPageRoute(
          builder: (context) {
            return const ClaimList();
          },
        );

      case claimDetail:
        return MaterialPageRoute(
          builder: (context) {
            return ClaimDetail(item: settings.arguments as ClaimModel);
          },
        );

      case bookingManagement:
        return MaterialPageRoute(
          builder: (context) {
            return const BookingList();
          },
        );

      case bookingDetail:
        return MaterialPageRoute(
          builder: (context) {
            return BookingDetail(
              item: settings.arguments as BookingModel,
            );
          },
        );

      case scanQR:
        return MaterialPageRoute(
          builder: (context) {
            return const ScanQR();
          },
        );

      case deepLink:
        return MaterialPageRoute(
          builder: (context) {
            return DeepLink(
              deeplink: settings.arguments as DeepLinkModel,
            );
          },
        );

      case otpVerification:
        return MaterialPageRoute(
          builder: (context) {
            return OtpVerification(
              requestOTPModel: settings.arguments as RequestOTPModel,
            );
          },
        );

      default:
        if (settings.name != null && settings.name!.contains('?type=')) {
          final deeplink = DeepLinkModel.fromString(settings.name!);
          if (deeplink.target.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) {
                return DeepLink(deeplink: deeplink);
              },
            );
          }
        }

        return MaterialPageRoute(
          builder: (context) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          fullscreenDialog: true,
        );
    }
  }

  ///Singleton factory
  static final Routes _instance = Routes._internal();

  factory Routes() {
    return _instance;
  }

  Routes._internal();
}
