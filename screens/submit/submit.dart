import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/repository/repository.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class Submit extends StatefulWidget {
  final ProductModel? item;
  const Submit({
    Key? key,
    this.item,
  }) : super(key: key);

  @override
  State<Submit> createState() {
    return _SubmitState();
  }
}

class _SubmitState extends State<Submit> {
  final _submitCubit = SubmitCubit();
  final regInt = RegExp('[^0-9]');
  final _textTitleController = TextEditingController();
  final _textContentController = TextEditingController();
  final _textTagsController = TextEditingController();
  final _textAddressController = TextEditingController();
  final _textZipCodeController = TextEditingController();
  final _textPhoneController = TextEditingController();
  final _textFaxController = TextEditingController();
  final _textEmailController = TextEditingController();
  final _textWebsiteController = TextEditingController();
  final _textStatusController = TextEditingController();
  final _textPriceController = TextEditingController();
  final _textPriceMinController = TextEditingController();
  final _textPriceMaxController = TextEditingController();

  final _focusTitle = FocusNode();
  final _focusContent = FocusNode();
  final _focusAddress = FocusNode();
  final _focusZipCode = FocusNode();
  final _focusPhone = FocusNode();
  final _focusFax = FocusNode();
  final _focusEmail = FocusNode();
  final _focusWebsite = FocusNode();
  final _focusPrice = FocusNode();
  final _focusPriceMin = FocusNode();
  final _focusPriceMax = FocusNode();

  String? _errorTitle;
  String? _errorContent;
  String? _errorAddress;
  String? _errorZipCode;
  String? _errorPhone;
  String? _errorFax;
  String? _errorEmail;
  String? _errorWebsite;
  String? _errorStatus;
  String? _errorPrice;
  String? _errorPriceMin;
  String? _errorPriceMax;
  String? _errorCategory;
  String? _errorLocation;
  String? _errorGps;

  /// Data
  SubmitSettingModel? _setting;
  ImageModel? _featureImage;
  List<ImageModel> _galleryImage = [];
  List<CategoryModel> _categories = [];
  List<CategoryModel> _facilities = [];
  List<String> _tags = [];
  CategoryModel? _country;
  CategoryModel? _state;
  CategoryModel? _city;
  GPSModel? _gps;
  Color? _color;
  IconModel? _icon;
  String? _date;
  String? _bookingStyle;
  List<OpenTimeModel>? _time;
  Map<String, dynamic>? _socials;

  @override
  void initState() {
    super.initState();
    _submitCubit.setup(widget.item?.id);
  }

  @override
  void dispose() {
    _textTitleController.dispose();
    _textContentController.dispose();
    _textTagsController.dispose();
    _textAddressController.dispose();
    _textZipCodeController.dispose();
    _textPhoneController.dispose();
    _textFaxController.dispose();
    _textEmailController.dispose();
    _textWebsiteController.dispose();
    _textStatusController.dispose();
    _textPriceController.dispose();
    _textPriceMinController.dispose();
    _textPriceMaxController.dispose();
    _focusTitle.dispose();
    _focusContent.dispose();
    _focusAddress.dispose();
    _focusZipCode.dispose();
    _focusPhone.dispose();
    _focusFax.dispose();
    _focusEmail.dispose();
    _focusWebsite.dispose();
    _focusPrice.dispose();
    _focusPriceMin.dispose();
    _focusPriceMax.dispose();
    _submitCubit.close();
    super.dispose();
  }

  ///On Upload Gallery
  void _onUploadGallery() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.galleryUpload,
      arguments: List<ImageModel>.from(_galleryImage).map((item) {
        return ImageModel(
          id: item.id,
          thumb: item.thumb,
          full: item.full,
        );
      }).toList(),
    );

    if (result != null && result is List<ImageModel>) {
      setState(() {
        _galleryImage = result;
      });
    }
  }

  ///On Select Category
  void _onSelectCategory() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await Navigator.pushNamed(
      context,
      Routes.categoryPicker,
      arguments: PickerModel(
        title: Translate.of(context).translate('choose_category'),
        selected: _categories,
        data: _setting?.categories ?? [],
      ),
    );
    if (result != null && result is List<CategoryModel>) {
      setState(() {
        _categories = result;
      });
    }
  }

  ///On Select Facilities
  void _onSelectFacilities() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.categoryPicker,
      arguments: PickerModel(
        title: Translate.of(context).translate('choose_facilities'),
        selected: _facilities,
        data: _setting?.features ?? [],
      ),
    );
    if (result != null && result is List<CategoryModel>) {
      setState(() {
        _facilities = result;
      });
    }
  }

  ///On Input Tag
  void _onChooseTag() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.tagsPicker,
      arguments: _tags,
    );
    if (result != null && result is List<String>) {
      setState(() {
        _tags = result;
      });
    }
  }

  ///On Select Country
  void _onSelectCountry() async {
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        title: Translate.of(context).translate('choose_country'),
        selected: [_country],
        data: _setting?.countries ?? [],
      ),
    );
    if (selected != null && selected is CategoryModel) {
      setState(() {
        _country = selected;
        _setting!.states = null;
        _state = null;
        _city = null;
      });
      final result = await CategoryRepository.loadLocation(selected.id);
      if (result != null) {
        setState(() {
          _setting!.states = result;
        });
      }
    }
  }

  ///On Select state
  void _onSelectState() async {
    if (_country == null) {
      AppBloc.messageBloc.add(MessageEvent(message: "choose_country"));
      return;
    }
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        title: Translate.of(context).translate('choose_state'),
        selected: [_state],
        data: _setting!.states ?? [],
      ),
    );
    if (selected != null && selected is CategoryModel) {
      setState(() {
        _state = selected;
        _setting!.cities = null;
        _city = null;
      });
      final result = await CategoryRepository.loadLocation(selected.id);
      if (result != null) {
        setState(() {
          _setting!.cities = result;
        });
      }
    }
  }

  ///On Select city
  void _onSelectCity() async {
    if (_state == null) {
      AppBloc.messageBloc.add(MessageEvent(message: "choose_state"));

      return;
    }
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: PickerModel(
        title: Translate.of(context).translate('choose_city'),
        selected: [_city],
        data: _setting!.cities ?? [],
      ),
    );
    if (selected != null && selected is CategoryModel) {
      setState(() {
        _city = selected;
      });
    }
  }

  ///On Select Address
  void _onSelectAddress() async {
    GPSModel? gps;
    if (_gps != null) {
      gps = GPSModel(
        longitude: _gps!.longitude,
        latitude: _gps!.latitude,
        editable: true,
      );
    }
    final selected = await Navigator.pushNamed(
      context,
      Routes.gpsPicker,
      arguments: gps,
    );
    if (selected != null && selected is GPSModel) {
      setState(() {
        _gps = selected;
      });
    }
  }

  ///On Select Color
  void _onSelectColor() async {
    final result = await showDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        Color? selected;
        return AlertDialog(
          title: Text(Translate.of(context).translate('choose_color')),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: Theme.of(context).colorScheme.primary,
              onColorChanged: (color) {
                selected = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
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
    if (result != null) {
      setState(() {
        _color = result;
      });
    }
  }

  ///On Select Icon
  void _onSelectIcon() async {
    final data = [];
    UtilIcon.faIconNameMapping.forEach(
      (k, v) => data.add(IconModel(
        title: UtilIcon.getWebName(k),
        value: UtilIcon.getWebName(k),
        icon: Icon(v),
      )),
    );
    final picker = PickerModel(
      title: Translate.of(context).translate('choose_icon'),
      data: data,
      selected: [_icon],
    );
    final selected = await Navigator.pushNamed(
      context,
      Routes.picker,
      arguments: picker,
    );
    if (selected != null && selected is IconModel) {
      setState(() {
        _icon = selected;
      });
    }
  }

  ///Show Picker Time
  void _onShowDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      initialDate: now,
      firstDate: DateTime(now.year),
      context: context,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _date = picked.dateView;
      });
    }
  }

  ///Show booking style picker
  void _onBookingStylePicker() async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [_bookingStyle],
            data: ['daily', 'hourly', 'slot', 'standard', 'table'],
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _bookingStyle = result;
      });
    }
  }

  ///On Select Open Time
  void _onOpenTime() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.openTime,
      arguments: _time,
    );
    if (result != null && result is List<OpenTimeModel>) {
      _time = result;
    }
  }

  ///Select social network
  void _onSocialNetwork() async {
    final result = await Navigator.pushNamed(
      context,
      Routes.socialNetwork,
      arguments: _socials,
    );
    if (result != null && result is Map<String, dynamic>) {
      _socials = result;
    }
  }

  ///On Ready
  void _onReady(ReadySubmit state) {
    final product = state.product;
    setState(() {
      _setting = state.setting;
      if (product != null) {
        _featureImage = product.image;
        _galleryImage = product.galleries;
        _textTitleController.text = product.title;
        _textContentController.text = product.description;
        _categories = List<CategoryModel>.from([product.category]);
        _facilities = product.features;
        _tags = product.tags.map((e) => e.title).toList();
        _country = product.country;
        _state = product.state;
        _city = product.city;
        _gps = product.gps;
        _textAddressController.text = product.address;
        _textZipCodeController.text = product.zipCode;
        _textPhoneController.text = product.phone;
        _textFaxController.text = product.fax;
        _textEmailController.text = product.email;
        _textWebsiteController.text = product.website;
        _color = UtilColor.getColorFromHex(product.color);
        _icon = IconModel(
          title: product.icon,
          value: product.icon,
          icon: FaIcon(
            UtilIcon.getIconFromCss(product.icon),
            color: Colors.grey,
          ),
        );
        _textStatusController.text = product.status;
        _date = product.dateEstablish;
        _textPriceController.text = product.priceDisplay.replaceAll(regInt, '');
        _textPriceMinController.text = product.priceMin.replaceAll(regInt, '');
        _textPriceMaxController.text = product.priceMax.replaceAll(regInt, '');
        _bookingStyle = product.bookingStyle;
        _time = product.openHours;
        _socials = product.socials;
      }
    });
  }

  ///On Submit
  void _onSubmit() async {
    final success = _validData();
    if (success) {
      _submitCubit.onSubmit(
        id: widget.item?.id,
        title: _textTitleController.text,
        content: _textContentController.text,
        country: _country,
        state: _state,
        city: _city,
        address: _textAddressController.text,
        zipcode: _textZipCodeController.text,
        phone: _textPhoneController.text,
        fax: _textFaxController.text,
        email: _textEmailController.text,
        website: _textWebsiteController.text,
        color: _color,
        icon: _icon,
        status: _textStatusController.text,
        date: _date,
        featureImage: _featureImage?.id,
        galleryImage: _galleryImage.map((e) => e.id).toList(),
        price: _textPriceController.text,
        priceMin: _textPriceMinController.text,
        priceMax: _textPriceMaxController.text,
        gps: _gps,
        tags: _tags,
        categories: _categories,
        facilities: _facilities,
        bookingStyle: _bookingStyle,
        time: _time,
        socials: _socials,
      );
    }
  }

  ///On Success
  void _onSuccess() {
    Navigator.pushReplacementNamed(context, Routes.submitSuccess);
  }

  ///valid data
  bool _validData() {
    ///Title
    _errorTitle = UtilValidator.validate(
      _textTitleController.text,
    );

    ///Content
    _errorContent = UtilValidator.validate(
      _textContentController.text,
    );

    ///Address
    _errorAddress = UtilValidator.validate(
      _textAddressController.text,
    );

    ///ZipCode
    _errorZipCode = UtilValidator.validate(
      _textZipCodeController.text,
      type: ValidateType.number,
      allowEmpty: true,
    );

    ///Phone
    _errorPhone = UtilValidator.validate(
      _textPhoneController.text,
      type: ValidateType.phone,
      allowEmpty: true,
    );
    if (_textPhoneController.text.isEmpty) {
      _errorPhone = "phone_require";
    } else {
      _errorPhone = null;
    }

    ///Fax
    _errorFax = UtilValidator.validate(
      _textFaxController.text,
      type: ValidateType.phone,
      allowEmpty: true,
    );

    ///Email
    _errorEmail = UtilValidator.validate(
      _textEmailController.text,
      type: ValidateType.email,
      allowEmpty: true,
    );

    ///Website
    _errorWebsite = UtilValidator.validate(
      _textWebsiteController.text,
      allowEmpty: true,
    );

    ///Status
    _errorStatus = UtilValidator.validate(
      _textStatusController.text,
      allowEmpty: true,
    );

    ///Price
    if (_textPriceController.text.isEmpty) {
      _errorPrice = "price_require";
    } else {
      _errorPrice = null;
    }

    ///Price Min
    _errorPriceMin = UtilValidator.validate(
      _textPriceMinController.text,
      type: ValidateType.number,
      allowEmpty: true,
    );
    if (_textPriceMinController.text.isEmpty) {
      _errorPriceMin = "price_require";
    } else {
      _errorPriceMin = null;
    }

    ///Price Max
    _errorPriceMax = UtilValidator.validate(
      _textPriceMaxController.text,
      type: ValidateType.number,
      allowEmpty: true,
    );
    if (_textPriceMaxController.text.isEmpty) {
      _errorPriceMax = "price_require";
    } else {
      _errorPriceMax = null;
    }

    ///Category
    if (_categories.isEmpty) {
      _errorCategory = "category_require";
    } else {
      _errorCategory = null;
    }

    ///Location
    if (_state?.title == null || _country?.title == null) {
      _errorLocation = "location_require";
    } else {
      _errorLocation = null;
    }

    ///Gps
    if (_gps == null) {
      _errorGps = "gps_require";
    } else {
      _errorGps = null;
    }

    final min = num.tryParse(_textPriceMinController.text) ?? 0;
    final max = num.tryParse(_textPriceMaxController.text) ?? 0;
    if (min > max) {
      _errorPriceMax = Translate.of(context).translate('min_value_not_valid');
    }

    if (_errorTitle != null ||
        _errorContent != null ||
        _errorAddress != null ||
        _errorAddress != null ||
        _errorPhone != null ||
        _errorFax != null ||
        _errorEmail != null ||
        _errorWebsite != null ||
        _errorStatus != null ||
        _errorPriceMin != null ||
        _errorPriceMax != null ||
        _errorCategory != null ||
        _errorLocation != null ||
        _errorGps!= null) {
      setState(() {});
      return false;
    }

    ///Feature image
    if (_featureImage == null) {
      AppBloc.messageBloc.add(MessageEvent(message: "feature_image_require"));
      return false;
    }

    ///Facilities
    if (_facilities.isEmpty) {
      AppBloc.messageBloc.add(MessageEvent(message: "facilities_require"));
      return false;
    }

    ///Country
    if (_country == null) {
      AppBloc.messageBloc.add(MessageEvent(message: "country_require"));
      return false;
    }

    return true;
  }

  ///Build gallery
  Widget _buildGallery() {
    DecorationImage? decorationImage;
    IconData icon = Icons.add;
    if (_galleryImage.isNotEmpty) {
      icon = Icons.dashboard_customize_outlined;
      decorationImage = DecorationImage(
        image: NetworkImage(
          _galleryImage.first.full,
        ),
        fit: BoxFit.cover,
      );
    }
    return InkWell(
      onTap: _onUploadGallery,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        color: Theme.of(context).colorScheme.primary,
        child: Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: decorationImage,
          ),
          alignment: Alignment.center,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    String textActionOpenTime = Translate.of(context).translate('add');
    Widget icon = Icon(
      Icons.help_outline,
      color: Theme.of(context).hintColor,
    );
    if (_time != null) {
      textActionOpenTime = Translate.of(context).translate('edit');
    }
    return BlocBuilder<SubmitCubit, SubmitState>(
      builder: (context, state) {
        if (state is SubmitLoading) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          );
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 180,
                  child: AppUploadImage(
                    image: _featureImage,
                    onChange: (result) {
                      setState(() {
                        _featureImage = result;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildGallery(),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('title'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_title'),
                  errorText: _errorTitle,
                  controller: _textTitleController,
                  focusNode: _focusTitle,
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    setState(() {
                      _errorTitle = UtilValidator.validate(
                        _textTitleController.text,
                      );
                    });
                  },
                  onSubmitted: (text) {
                    Utils.fieldFocusChange(
                      context,
                      _focusTitle,
                      _focusContent,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('content'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  maxLines: 6,
                  hintText: Translate.of(context).translate('input_content'),
                  errorText: _errorContent,
                  controller: _textContentController,
                  focusNode: _focusContent,
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      _errorContent = UtilValidator.validate(
                        _textContentController.text,
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('category'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppPickerItem(
                  title: Translate.of(context).translate('choose_category'),
                  value: _categories.map((e) => e.title).join(", "),
                  onPressed: _onSelectCategory,
                  errorText: _errorCategory,
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('facilities'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppPickerItem(
                  title: Translate.of(context).translate('choose_facilities'),
                  value: _facilities.map((e) => e.title).join(", "),
                  onPressed: _onSelectFacilities,
                ),
                const SizedBox(height: 16),
                Text(
                  Translate.of(context).translate('tags'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppPickerItem(
                  title: Translate.of(context).translate('choose_tags'),
                  value: _tags.isEmpty ? null : _tags.join(","),
                  onPressed: _onChooseTag,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                AppPickerItem(
                  title: Translate.of(context).translate('choose_country'),
                  value: _country?.title,
                  onPressed: _onSelectCountry,
                  errorText: _errorLocation,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppPickerItem(
                        title: Translate.of(context).translate('choose_state'),
                        value: _state?.title,
                        loading: _country != null && _setting!.states == null,
                        onPressed: _onSelectState,
                        errorText: _errorLocation,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppPickerItem(
                        title: Translate.of(context).translate('choose_city'),
                        value: _city?.title,
                        loading: _state != null && _setting!.cities == null,
                        onPressed: _onSelectCity,
                        errorText: _errorLocation,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                AppPickerItem(
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Translate.of(context).translate('choose_gps_location'),
                  value: _gps != null
                      ? '${_gps!.latitude.toStringAsFixed(3)},${_gps!.longitude.toStringAsFixed(3)}'
                      : null,
                  onPressed: _onSelectAddress,
                  errorText: _errorGps,
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_address'),
                  errorText: _errorAddress,
                  controller: _textAddressController,
                  focusNode: _focusAddress,
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    setState(() {
                      _errorAddress = UtilValidator.validate(
                        _textAddressController.text,
                      );
                    });
                  },
                  onSubmitted: (text) {
                    Utils.fieldFocusChange(
                      context,
                      _focusAddress,
                      _focusZipCode,
                    );
                  },
                  leading: Icon(
                    Icons.home_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_zipcode'),
                  errorText: _errorZipCode,
                  controller: _textZipCodeController,
                  focusNode: _focusZipCode,
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    setState(() {
                      _errorZipCode = UtilValidator.validate(
                        _textZipCodeController.text,
                        type: ValidateType.number,
                        allowEmpty: true,
                      );
                    });
                  },
                  onSubmitted: (text) {
                    Utils.fieldFocusChange(
                      context,
                      _focusZipCode,
                      _focusPhone,
                    );
                  },
                  leading: Icon(
                    Icons.wallet_travel_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_phone'),
                  errorText: _errorPhone,
                  controller: _textPhoneController,
                  focusNode: _focusPhone,
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    setState(() {
                      _errorPhone = UtilValidator.validate(
                        _textPhoneController.text,
                        type: ValidateType.phone,
                        allowEmpty: true,
                      );
                    });
                  },
                  onSubmitted: (text) {
                    Utils.fieldFocusChange(
                      context,
                      _focusPhone,
                      _focusFax,
                    );
                  },
                  leading: Icon(
                    Icons.phone_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_fax'),
                  errorText: _errorFax,
                  controller: _textFaxController,
                  focusNode: _focusFax,
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    setState(() {
                      _errorFax = UtilValidator.validate(
                        _textFaxController.text,
                        type: ValidateType.phone,
                        allowEmpty: true,
                      );
                    });
                  },
                  onSubmitted: (text) {
                    Utils.fieldFocusChange(
                      context,
                      _focusFax,
                      _focusEmail,
                    );
                  },
                  leading: Icon(
                    Icons.phone_callback_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_email'),
                  errorText: _errorEmail,
                  controller: _textEmailController,
                  focusNode: _focusEmail,
                  textInputAction: TextInputAction.next,
                  onChanged: (text) {
                    setState(() {
                      _errorEmail = UtilValidator.validate(
                        _textEmailController.text,
                        type: ValidateType.email,
                        allowEmpty: true,
                      );
                    });
                  },
                  onSubmitted: (text) {
                    Utils.fieldFocusChange(
                      context,
                      _focusEmail,
                      _focusWebsite,
                    );
                  },
                  leading: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_website'),
                  errorText: _errorWebsite,
                  controller: _textWebsiteController,
                  focusNode: _focusWebsite,
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      _errorWebsite = UtilValidator.validate(
                        _textWebsiteController.text,
                        allowEmpty: true,
                      );
                    });
                  },
                  leading: Icon(
                    Icons.language_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translate.of(context).translate('color'),
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
                                color: _color ??
                                    Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            value: _color?.value.toRadixString(16),
                            title: Translate.of(context).translate(
                              'choose_color',
                            ),
                            onPressed: _onSelectColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translate.of(context).translate('icon'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          AppPickerItem(
                            leading: _icon?.icon ?? icon,
                            value: _icon?.value,
                            title:
                                Translate.of(context).translate('choose_icon'),
                            onPressed: _onSelectIcon,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  Translate.of(context).translate('status'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppTextInput(
                  hintText: Translate.of(context).translate('input_status'),
                  errorText: _errorStatus,
                  controller: _textStatusController,
                  textInputAction: TextInputAction.done,
                  onChanged: (text) {
                    setState(() {
                      _errorStatus = UtilValidator.validate(
                        _textStatusController.text,
                        allowEmpty: true,
                      );
                    });
                  },
                  leading: Icon(
                    Icons.alternate_email,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Translate.of(context).translate('date_established'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                AppPickerItem(
                  leading: Icon(
                    Icons.calendar_today_outlined,
                    color: Theme.of(context).hintColor,
                  ),
                  value: _date,
                  title: Translate.of(context).translate('choose_date'),
                  onPressed: _onShowDatePicker,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translate.of(context).translate('price_min'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          AppTextInput(
                            hintText: Translate.of(context).translate(
                              'input_price',
                            ),
                            errorText: _errorPriceMin,
                            controller: _textPriceMinController,
                            focusNode: _focusPriceMin,
                            textInputAction: TextInputAction.next,
                            onChanged: (text) {
                              setState(() {
                                _errorPriceMin = UtilValidator.validate(
                                  _textPriceMinController.text,
                                  type: ValidateType.number,
                                  allowEmpty: true,
                                );
                              });
                            },
                            onSubmitted: (text) {
                              Utils.fieldFocusChange(
                                context,
                                _focusPriceMin,
                                _focusPriceMax,
                              );
                            },
                            trailing: Text(
                              Application.setting.unit,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translate.of(context).translate('price_max'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          AppTextInput(
                            hintText:
                                Translate.of(context).translate('input_price'),
                            errorText: _errorPriceMax,
                            controller: _textPriceMaxController,
                            focusNode: _focusPriceMax,
                            textInputAction: TextInputAction.next,
                            onChanged: (text) {
                              setState(() {
                                _errorPriceMax = UtilValidator.validate(
                                  _textPriceMaxController.text,
                                  type: ValidateType.number,
                                  allowEmpty: true,
                                );
                              });
                            },
                            onSubmitted: (text) {
                              Utils.hiddenKeyboard(context);
                              _onBookingStylePicker();
                            },
                            trailing: Text(
                              Application.setting.unit,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translate.of(context).translate('booking_style'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          AppPickerItem(
                            value: Translate.of(context).translate(
                              _bookingStyle,
                            ),
                            title: Translate.of(context).translate(
                              'choose_booking_style',
                            ),
                            onPressed: _onBookingStylePicker,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translate.of(context).translate('price'),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          AppTextInput(
                            hintText: Translate.of(context).translate(
                              'input_price',
                            ),
                            errorText: _errorPrice,
                            controller: _textPriceController,
                            focusNode: _focusPrice,
                            textInputAction: TextInputAction.done,
                            onChanged: (text) {
                              setState(() {
                                _errorPrice = UtilValidator.validate(
                                  _textPriceController.text,
                                  type: ValidateType.number,
                                  allowEmpty: true,
                                );
                              });
                            },
                            trailing: Text(
                              Application.setting.unit,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Translate.of(context).translate('open_time'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _onOpenTime,
                      child: Text(
                        textActionOpenTime,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Translate.of(context).translate('social_network'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: _onSocialNetwork,
                      child: Text(
                        textActionOpenTime,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String textTitle = Translate.of(context).translate('add_new_listing');
    String textAction = Translate.of(context).translate('add');
    if (widget.item != null) {
      textTitle = Translate.of(context).translate('update_listing');
      textAction = Translate.of(context).translate('update');
    }

    return BlocProvider(
      create: (context) => _submitCubit,
      child: BlocListener<SubmitCubit, SubmitState>(
        listener: (context, state) {
          if (state is ReadySubmit) {
            _onReady(state);
          }
          if (state is Submitted) {
            _onSuccess();
          }
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(textTitle),
              actions: [
                AppButton(
                  textAction,
                  onPressed: _onSubmit,
                  type: ButtonType.text,
                )
              ],
            ),
            body: SafeArea(
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }
}
