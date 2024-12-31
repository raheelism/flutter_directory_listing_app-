import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class ClaimDetail extends StatefulWidget {
  const ClaimDetail({Key? key, required this.item}) : super(key: key);

  final ClaimModel item;

  @override
  State<ClaimDetail> createState() {
    return _ClaimDetailState();
  }
}

class _ClaimDetailState extends State<ClaimDetail> {
  final _claimDetailCubit = ClaimDetailCubit();
  final _textPassController = TextEditingController();
  final _textRePassController = TextEditingController();
  final _focusPass = FocusNode();
  final _focusRePass = FocusNode();

  @override
  void initState() {
    super.initState();
    _claimDetailCubit.onLoad(widget.item.id);
  }

  @override
  void dispose() {
    _textPassController.dispose();
    _textRePassController.dispose();
    _focusPass.dispose();
    _focusRePass.dispose();
    _claimDetailCubit.close();
    super.dispose();
  }

  ///Booking cancel
  void _cancelClaim() {
    _claimDetailCubit.onCancel(widget.item.id);
  }

  ///On pay
  Future<String?> _onPay(PaymentModel payment) async {
    return await _claimDetailCubit.onPayment(
      widget.item.id,
      payment.method!.id,
    );
  }

  ///Booking payment
  void _paymentClaim() async {
    final payment = await _claimDetailCubit.getClaimPayment();
    if (payment != null) {
      if (!mounted) return;
      payment.onPayment = () async {
        return await _onPay(payment);
      };
      await Navigator.pushNamed(
        context,
        Routes.payment,
        arguments: payment,
      );
      _claimDetailCubit.onLoad(widget.item.id);
    }
  }

  ///Build item info
  Widget _buildItemInfo({
    required String title,
    String? value,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
              ),
        ),
      ],
    );
  }

  ///Build action
  List<Widget>? _buildAction(ClaimModel item) {
    List<Widget> actions = [];
    if (item.allowCancel == true) {
      actions.add(
        Expanded(
          child: AppButton(
            Translate.of(context).translate('cancel'),
            onPressed: _cancelClaim,
            mainAxisSize: MainAxisSize.max,
            type: ButtonType.outline,
          ),
        ),
      );
    }
    if (item.allowPayment == true) {
      if (actions.isNotEmpty) actions.add(const SizedBox(width: 12));
      actions.add(
        Expanded(
          child: AppButton(
            Translate.of(context).translate('payment'),
            onPressed: _paymentClaim,
            mainAxisSize: MainAxisSize.max,
          ),
        ),
      );
    }

    if (actions.isNotEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(children: actions),
        )
      ];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClaimDetailCubit, ClaimDetailState>(
      bloc: _claimDetailCubit,
      builder: (context, state) {
        Widget content = Container();
        List<Widget>? actions;

        if (state is ClaimDetailSuccess) {
          content = SafeArea(
            child: SingleChildScrollView(
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
                      children: <Widget>[
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          widget.item.address,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      Translate.of(context).translate('payment_information'),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Translate.of(context).translate(
                                  'first_name',
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.item.billFirstName ?? '',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Translate.of(context).translate(
                                  'last_name',
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.item.billLastName ?? '',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Translate.of(context).translate('phone'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.item.billPhone ?? '',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Translate.of(context).translate('email'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.item.billEmail ?? '',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translate.of(context).translate('address'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.item.billAddress ?? '',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildItemInfo(
                            title: Translate.of(context).translate(
                              'payment',
                            ),
                            value: Translate.of(context).translate(
                              state.item.payment,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildItemInfo(
                            title: Translate.of(context).translate(
                              'payment_method',
                            ),
                            value: Translate.of(context).translate(
                              state.item.paymentName,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildItemInfo(
                            title: Translate.of(context).translate(
                              'transaction_id',
                            ),
                            value: Translate.of(context).translate(
                              state.item.transactionID,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildItemInfo(
                            title: Translate.of(context).translate(
                              'created_on',
                            ),
                            value: state.item.createdOn,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildItemInfo(
                            title: Translate.of(context).translate(
                              'payment_total',
                            ),
                            value: '${state.item.totalDisplay}',
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildItemInfo(
                            title: Translate.of(context).translate(
                              'paid_on',
                            ),
                            value: state.item.paidOn,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildItemInfo(
                            title: Translate.of(context).translate('status'),
                            value: state.item.status,
                            color: state.item.statusColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildItemInfo(
                            title: Translate.of(context).translate(
                              'created_via',
                            ),
                            value: state.item.createdVia,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
          actions = _buildAction(state.item);
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              Translate.of(context).translate('claim_detail'),
            ),
          ),
          body: content,
          persistentFooterButtons: actions,
        );
      },
    );
  }
}
