import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingDetail extends StatefulWidget {
  final BookingModel item;
  const BookingDetail({Key? key, required this.item}) : super(key: key);

  @override
  State<BookingDetail> createState() {
    return _BookingDetailState();
  }
}

class _BookingDetailState extends State<BookingDetail> {
  final _bookingDetail = BookingDetailCubit();

  @override
  void initState() {
    super.initState();
    _bookingDetail.onLoad(widget.item.id);
  }

  @override
  void dispose() {
    _bookingDetail.close();
    super.dispose();
  }

  ///Booking cancel
  void _cancelBooking() {
    _bookingDetail.onCancel(widget.item.id);
  }

  ///Booking payment
  void _acceptBooking() {
    _bookingDetail.onAccept(widget.item.id);
  }

  ///Build resource
  List<Widget> _buildResource(BookingModel booking) {
    return (booking.resource ?? []).map((item) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translate.of(context).translate('res_length'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                'x ${item.quantity}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Translate.of(context).translate('price'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${item.total}${booking.currency}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      );
    }).toList();
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
  List<Widget>? _buildAction(BookingModel item) {
    List<Widget> actions = [];
    if (item.allowCancel == true) {
      actions.add(
        Expanded(
          child: AppButton(
            Translate.of(context).translate('cancel'),
            onPressed: _cancelBooking,
            mainAxisSize: MainAxisSize.max,
            type: ButtonType.outline,
          ),
        ),
      );
    }
    if (item.allowAccept == true) {
      if (actions.isNotEmpty) actions.add(const SizedBox(width: 12));
      actions.add(
        Expanded(
          child: AppButton(
            Translate.of(context).translate('accept'),
            onPressed: _acceptBooking,
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
    return BlocBuilder<BookingDetailCubit, BookingDetailState>(
      bloc: _bookingDetail,
      builder: (context, state) {
        List<Widget>? actions;
        Widget body = Container();

        if (state is BookingDetailSuccess) {
          final id = '${state.item.id}';
          final link = 'listar://qrcode?type=booking&action=view&id=$id';
          body = Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        Translate.of(context).translate('booking_id'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        id,
                        style: Theme.of(context).textTheme.titleMedium,
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildItemInfo(
                          title: Translate.of(context).translate(
                            'status',
                          ),
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
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Container(
                    alignment: Alignment.center,
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
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: _buildResource(state.item),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    Translate.of(context).translate('billing').toUpperCase(),
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
          actions = _buildAction(state.item);
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              Translate.of(context).translate('booking_detail'),
            ),
          ),
          body: SafeArea(
            child: body,
          ),
          persistentFooterButtons: actions,
        );
      },
    );
  }
}
