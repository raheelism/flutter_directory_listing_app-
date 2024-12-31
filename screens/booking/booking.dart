import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

import 'detail_daily.dart';
import 'detail_hourly.dart';
import 'detail_slot.dart';
import 'detail_standard.dart';
import 'detail_table.dart';

class Booking extends StatefulWidget {
  final int id;

  const Booking({
    Key? key,
    required this.id,
  }) : super(key: key);

  @override
  State<Booking> createState() {
    return _BookingState();
  }
}

class _BookingState extends State<Booking> {
  final _bookingCubit = BookingCubit();
  final _textFirstNameController = TextEditingController(
    text: AppBloc.userCubit.state?.firstName,
  );
  final _textLastNameController = TextEditingController(
    text: AppBloc.userCubit.state?.lastName,
  );
  final _textPhoneController = TextEditingController();
  final _textEmailController = TextEditingController(
    text: AppBloc.userCubit.state?.email,
  );
  final _textAddressController = TextEditingController();
  final _textMessageController = TextEditingController();

  final _focusFirstName = FocusNode();
  final _focusLastName = FocusNode();
  final _focusPhone = FocusNode();
  final _focusEmail = FocusNode();
  final _focusAddress = FocusNode();
  final _focusMessage = FocusNode();

  int _active = 0;
  String? _errorFirstName;
  String? _errorLastName;
  String? _errorPhone;
  String? _errorEmail;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    SVProgressHUD.dismiss();
    _textFirstNameController.dispose();
    _textLastNameController.dispose();
    _textPhoneController.dispose();
    _textEmailController.dispose();
    _textAddressController.dispose();
    _textMessageController.dispose();
    _focusFirstName.dispose();
    _focusLastName.dispose();
    _focusPhone.dispose();
    _focusEmail.dispose();
    _focusAddress.dispose();
    _focusMessage.dispose();
    _bookingCubit.close();
    super.dispose();
  }

  ///Init data
  void _loadData() async {
    await _bookingCubit.initBooking(widget.id);
  }

  ///On booking
  Future<String?> _onOrder(FormSuccess form) async {
    return await _bookingCubit.order(
      id: widget.id,
      firstName: _textFirstNameController.text,
      lastName: _textLastNameController.text,
      phone: _textPhoneController.text,
      email: _textEmailController.text,
      address: _textAddressController.text,
      message: _textMessageController.text,
      form: form,
    );
  }

  ///On Calc Price
  Future<bool> _onCalcPrice(FormSuccess form) async {
    final price = await _bookingCubit.calcPrice(
      id: widget.id,
      form: form,
    );
    if (price != null) {
      setState(() {
        form.bookingStyle.price = price;
      });
    }
    return price != null;
  }

  ///On next
  void _onNext({
    required FormSuccess form,
    required int step,
  }) async {
    Utils.hiddenKeyboard(context);

    if (step == 0) {
      if (form.bookingStyle.adult == null) {
        AppBloc.messageBloc.add(
          MessageEvent(message: 'choose_adults_message'),
        );
        return;
      }
      if (form.bookingStyle is StandardBookingModel) {
        final style = form.bookingStyle as StandardBookingModel;
        if (style.startDate == null) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'choose_date_message'),
          );
          return;
        }
        if (style.startTime == null) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'choose_time_message'),
          );
          return;
        }
      } else if (form.bookingStyle is DailyBookingModel) {
        final style = form.bookingStyle as DailyBookingModel;
        if (style.startDate == null) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'choose_date_message'),
          );
          return;
        }
      } else if (form.bookingStyle is HourlyBookingModel) {
        final style = form.bookingStyle as HourlyBookingModel;
        if (style.startDate == null) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'choose_date_message'),
          );
          return;
        }
        if (style.schedule == null) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'choose_time_message'),
          );
          return;
        }
      } else if (form.bookingStyle is TableBookingModel) {
        final style = form.bookingStyle as TableBookingModel;
        if (style.startDate == null) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'choose_date_message'),
          );
          return;
        }
        if (style.startTime == null) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'choose_time_message'),
          );
          return;
        }
        if (style.selected.isEmpty) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'choose_table_message'),
          );
          return;
        }
      }

      if (await _onCalcPrice(form)) {
        setState(() {
          _active += 1;
        });
      }
    } else if (step == 1) {
      if (_textFirstNameController.text.isEmpty) {
        _errorFirstName = Translate.of(context).translate('first_name_message');
      }
      if (_textLastNameController.text.isEmpty) {
        _errorLastName = Translate.of(context).translate('last_name_message');
      }
      if (_textPhoneController.text.isEmpty) {
        _errorPhone = Translate.of(context).translate('phone_message');
      }
      if (_textEmailController.text.isEmpty) {
        _errorEmail = Translate.of(context).translate('email_message');
      }
      if (_errorFirstName == null &&
          _errorLastName == null &&
          _errorPhone == null &&
          _errorEmail == null) {
        Object? result;
        if (form.payment.use) {
          form.payment.onPayment = () async {
            return await _onOrder(form);
          };
          result = await Navigator.pushNamed(
            context,
            Routes.payment,
            arguments: form.payment,
          );
        } else {
          result = await _onOrder(form);
        }

        if (result != null) {
          _active = 3;
        }
      }
      setState(() {});
    }
  }

  ///Go my booking
  void _onMyBooking() {
    Navigator.pushReplacementNamed(context, Routes.bookingManagement);
  }

  ///On previous
  void _onPrevious() {
    Utils.hiddenKeyboard(context);
    setState(() {
      _active -= 1;
    });
  }

  ///Widget build detail
  Widget _buildDetail(FormSuccess form) {
    if (form.bookingStyle is StandardBookingModel) {
      return DetailStandard(
        bookingStyle: form.bookingStyle as StandardBookingModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else if (form.bookingStyle is DailyBookingModel) {
      return DetailDaily(
        bookingStyle: form.bookingStyle as DailyBookingModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else if (form.bookingStyle is HourlyBookingModel) {
      return DetailHourly(
        bookingStyle: form.bookingStyle as HourlyBookingModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else if (form.bookingStyle is TableBookingModel) {
      return DetailTable(
        bookingStyle: form.bookingStyle as TableBookingModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else if (form.bookingStyle is SlotBookingModel) {
      return DetailSlot(
        bookingStyle: form.bookingStyle as SlotBookingModel,
        onCalcPrice: () {
          _onCalcPrice(form);
        },
      );
    } else {
      return Container();
    }
  }

  ///build contact
  Widget _buildContact() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          AppTextInput(
            leading: Icon(
              Icons.person_outline,
              color: Theme.of(context).hintColor,
            ),
            hintText: Translate.of(context).translate('input_first_name'),
            errorText: _errorFirstName,
            controller: _textFirstNameController,
            focusNode: _focusFirstName,
            textInputAction: TextInputAction.next,
            onChanged: (text) {
              setState(() {
                _errorFirstName = UtilValidator.validate(
                  _textFirstNameController.text,
                );
              });
            },
            onSubmitted: (text) {
              Utils.fieldFocusChange(
                context,
                _focusFirstName,
                _focusLastName,
              );
            },
          ),
          const SizedBox(height: 12),
          AppTextInput(
            leading: Icon(
              Icons.person_outline,
              color: Theme.of(context).hintColor,
            ),
            hintText: Translate.of(context).translate('input_last_name'),
            errorText: _errorLastName,
            controller: _textLastNameController,
            focusNode: _focusLastName,
            textInputAction: TextInputAction.next,
            onChanged: (text) {
              setState(() {
                _errorLastName = UtilValidator.validate(
                  _textLastNameController.text,
                );
              });
            },
            onSubmitted: (text) {
              Utils.fieldFocusChange(
                context,
                _focusLastName,
                _focusPhone,
              );
            },
          ),
          const SizedBox(height: 12),
          AppTextInput(
            leading: Icon(
              Icons.phone_outlined,
              color: Theme.of(context).hintColor,
            ),
            hintText: Translate.of(context).translate('input_phone'),
            errorText: _errorPhone,
            controller: _textPhoneController,
            focusNode: _focusPhone,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.phone,
            onChanged: (text) {
              setState(() {
                _errorPhone = UtilValidator.validate(
                  _textPhoneController.text,
                  type: ValidateType.phone,
                );
              });
            },
            onSubmitted: (text) {
              Utils.fieldFocusChange(
                context,
                _focusPhone,
                _focusEmail,
              );
            },
          ),
          const SizedBox(height: 12),
          AppTextInput(
            leading: Icon(
              Icons.email_outlined,
              color: Theme.of(context).hintColor,
            ),
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
                );
              });
            },
            onSubmitted: (text) {
              Utils.fieldFocusChange(
                context,
                _focusEmail,
                _focusAddress,
              );
            },
          ),
          const SizedBox(height: 12),
          AppTextInput(
            leading: Icon(
              Icons.location_on_outlined,
              color: Theme.of(context).hintColor,
            ),
            hintText: Translate.of(context).translate('input_address'),
            controller: _textAddressController,
            focusNode: _focusAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (text) {
              Utils.fieldFocusChange(
                context,
                _focusAddress,
                _focusMessage,
              );
            },
          ),
          const SizedBox(height: 12),
          AppTextInput(
            leading: Icon(
              Icons.mark_email_unread_outlined,
              color: Theme.of(context).hintColor,
            ),
            maxLines: 6,
            hintText: Translate.of(context).translate('input_content'),
            controller: _textMessageController,
            focusNode: _focusMessage,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  ///Build completed
  Widget _buildCompleted() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Translate.of(context).translate('booking_success_title'),
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            Translate.of(context).translate(
              'booking_success_message',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
  }

  ///Widget build content
  Widget _buildContent(FormSuccess form) {
    switch (_active) {
      case 0:
        return _buildDetail(form);
      case 1:
        return _buildContact();
      case 3:
        return _buildCompleted();
      default:
        return Container();
    }
  }

  ///Build action
  Widget _buildAction(FormSuccess form) {
    switch (_active) {
      case 0:
        return AppButton(
          Translate.of(context).translate('next'),
          onPressed: () {
            _onNext(form: form, step: 0);
          },
          mainAxisSize: MainAxisSize.max,
        );
      case 1:
        return Row(
          children: [
            Expanded(
              child: AppButton(
                Translate.of(context).translate('previous'),
                onPressed: _onPrevious,
                mainAxisSize: MainAxisSize.max,
                type: ButtonType.outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                Translate.of(context).translate('next'),
                onPressed: () {
                  _onNext(form: form, step: 1);
                },
                mainAxisSize: MainAxisSize.max,
              ),
            )
          ],
        );
      case 3:
        return Row(
          children: [
            Expanded(
              child: AppButton(
                Translate.of(context).translate('back'),
                onPressed: () {
                  Navigator.pop(context);
                },
                mainAxisSize: MainAxisSize.max,
                type: ButtonType.outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                Translate.of(context).translate('my_booking'),
                onPressed: _onMyBooking,
                mainAxisSize: MainAxisSize.max,
              ),
            )
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingCubit, BookingState>(
      bloc: _bookingCubit,
      builder: (context, form) {
        Widget content = Container();
        List<Widget>? footerButtons;
        if (form is FormSuccess) {
          footerButtons = [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildAction(form),
            )
          ];
          List<StepModel> step = [
            StepModel(
              title: Translate.of(context).translate('details'),
              icon: Icons.calendar_today_outlined,
            ),
            StepModel(
              title: Translate.of(context).translate('contact'),
              icon: Icons.contact_mail_outlined,
            ),
            StepModel(
              title: Translate.of(context).translate('completed'),
              icon: Icons.check,
            )
          ];
          if (form.payment.use) {
            step = [
              StepModel(
                title: Translate.of(context).translate('details'),
                icon: Icons.calendar_today_outlined,
              ),
              StepModel(
                title: Translate.of(context).translate('contact'),
                icon: Icons.contact_mail_outlined,
              ),
              StepModel(
                title: Translate.of(context).translate('payment'),
                icon: Icons.payment_outlined,
              ),
              StepModel(
                title: Translate.of(context).translate('completed'),
                icon: Icons.check,
              )
            ];
          }
          content = Column(
            children: [
              const SizedBox(height: 16),
              AppStepper(
                active: _active,
                list: step,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildContent(form),
                ),
              ),
            ],
          );
        }
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              Translate.of(context).translate('booking'),
            ),
          ),
          body: SafeArea(
            child: content,
          ),
          persistentFooterButtons: footerButtons,
        );
      },
    );
  }
}
