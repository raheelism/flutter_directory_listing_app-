import 'package:flutter/material.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class Payment extends StatefulWidget {
  final PaymentModel payment;

  const Payment({
    Key? key,
    required this.payment,
  }) : super(key: key);

  @override
  State<Payment> createState() {
    return _PaymentState();
  }
}

class _PaymentState extends State<Payment> {
  bool _agree = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On Open Term
  void _onTerm() {
    Navigator.pushNamed(
      context,
      Routes.webView,
      arguments: WebViewModel(
        title: Translate.of(context).translate('term_condition'),
        url: widget.payment.term,
      ),
    );
  }

  ///On Open Term
  void _onPayment() async {
    final result = await widget.payment.onPayment!();

    if (result != null) {
      if (result.isNotEmpty) {
        if (!mounted) return;
        final url = await Navigator.pushNamed(
          context,
          Routes.webView,
          arguments: WebViewModel(
            title: Translate.of(context).translate('payment'),
            url: result,
            callbackUrl: [widget.payment.urlSuccess, widget.payment.urlCancel],
          ),
        );
        final cancel = url is String && url.contains(widget.payment.urlCancel);
        if (url == null || cancel) {
          AppBloc.messageBloc.add(
            MessageEvent(message: 'payment_not_completed'),
          );
        }
      }
    }
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    Widget bankAccountList = Container();
    Widget paymentInfo = Container();

    if (widget.payment.method?.id == 'bank') {
      bankAccountList = Column(
        children: widget.payment.listAccount.map((item) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.bankName,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translate.of(context).translate('account_name'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Translate.of(context).translate('iban'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.bankIban,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Translate.of(context).translate('account_number'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.number,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Translate.of(context).translate('swift_code'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.bankSwift,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          );
        }).toList(),
      );
    }
    if (widget.payment.method != null) {
      paymentInfo = Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).focusColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.payment.method?.title ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.payment.method?.description ?? '',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.payment.method?.instruction ?? '',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('payment'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Column(
                  children: widget.payment.listMethod.map((item) {
                    if (item != widget.payment.listMethod.last) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Radio<String>(
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                                value: item.id,
                                groupValue: widget.payment.method?.id,
                                onChanged: (value) {
                                  setState(() {
                                    widget.payment.method = item;
                                  });
                                },
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge,
                                    ),
                                    Text(
                                      item.instruction!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const Divider(),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Radio<String>(
                          activeColor: Theme.of(context).colorScheme.primary,
                          value: item.id,
                          groupValue: widget.payment.method?.id,
                          onChanged: (value) {
                            setState(() {
                              widget.payment.method = item;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title!,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              Text(
                                item.instruction!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                paymentInfo,
                const SizedBox(height: 12),
                bankAccountList,
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      activeColor: Theme.of(context).colorScheme.primary,
                      value: _agree,
                      onChanged: (value) {
                        setState(() {
                          _agree = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Translate.of(context).translate('i_agree'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(width: 2),
                  InkWell(
                    onTap: _onTerm,
                    child: Text(
                      Translate.of(context).translate('term_condition'),
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      Translate.of(context).translate('confirm'),
                      onPressed: _onPayment,
                      disabled: !_agree,
                      mainAxisSize: MainAxisSize.max,
                    ),
                  )
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
