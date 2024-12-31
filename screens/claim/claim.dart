import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/repository/repository.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class Claim extends StatefulWidget {
  const Claim({Key? key, required this.item}) : super(key: key);

  final ProductModel item;

  @override
  State<Claim> createState() {
    return _ClaimState();
  }
}

class _ClaimState extends State<Claim> {
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
  final _textMessageController = TextEditingController();

  final _focusFirstName = FocusNode();
  final _focusLastName = FocusNode();
  final _focusPhone = FocusNode();
  final _focusEmail = FocusNode();
  final _focusMessage = FocusNode();

  String? _errorFirstName;
  String? _errorLastName;
  String? _errorPhone;
  String? _errorEmail;

  bool _success = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textFirstNameController.dispose();
    _textLastNameController.dispose();
    _focusFirstName.dispose();
    _focusLastName.dispose();
    super.dispose();
  }

  ///On Submit Claim
  void _onSubmit() async {
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

    ///Validate form
    final valid = _errorFirstName == null &&
        _errorLastName == null &&
        _errorPhone == null &&
        _errorEmail == null;
    if (!valid) {
      setState(() {});
    }
    if (valid) {
      final result = await ClaimRepository.submit(
        id: widget.item.id,
        firstName: _textFirstNameController.text,
        lastName: _textLastNameController.text,
        phone: _textPhoneController.text,
        email: _textEmailController.text,
        message: _textMessageController.text,
      );
      setState(() {
        _success = result;
      });
    }
  }

  ///On management
  void _onManagement() {
    Navigator.pushNamed(context, Routes.claimManagement);
  }

  Widget _buildContent() {
    if (_success) {
      return Column(
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
            Translate.of(context).translate('claim_success_title'),
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            Translate.of(context).translate(
              'claim_success_message',
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 12,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 2),
                Text(
                  widget.item.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              Translate.of(context).translate('your_information'),
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
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
                Icons.mail_outline,
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
              hintText: Translate.of(context).translate('input_message'),
              controller: _textMessageController,
              focusNode: _focusMessage,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 12),
            Text(
              Translate.of(context).translate('claim_request_msg'),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction() {
    if (_success) {
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
              Translate.of(context).translate('management'),
              onPressed: _onManagement,
              mainAxisSize: MainAxisSize.max,
            ),
          )
        ],
      );
    }

    return AppButton(
      Translate.of(context).translate('submit'),
      onPressed: _onSubmit,
      mainAxisSize: MainAxisSize.max,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('claim'),
        ),
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
      persistentFooterButtons: [_buildAction()],
    );
  }
}
