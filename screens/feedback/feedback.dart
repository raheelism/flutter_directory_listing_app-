import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class WriteReview extends StatefulWidget {
  final dynamic item;

  const WriteReview({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<WriteReview> createState() {
    return _WriteReviewState();
  }
}

class _WriteReviewState extends State<WriteReview> {
  final _textReviewController = TextEditingController();
  final _focusReview = FocusNode();

  String? _errorReview;
  double _rate = 0;

  @override
  void initState() {
    super.initState();
    if (widget.item is ProductModel) {
      _rate = widget.item.rate;
    }
  }

  @override
  void dispose() {
    _textReviewController.dispose();
    _focusReview.dispose();
    super.dispose();
  }

  ///On send
  void _onSave() async {
    Utils.hiddenKeyboard(context);
    setState(() {
      _errorReview = UtilValidator.validate(_textReviewController.text);
    });
    if (_errorReview == null) {
      final result = await AppBloc.reviewCubit.onSave(
        id: widget.item.id,
        content: _textReviewController.text,
        rate: _rate > 0 ? _rate : null,
      );
      if (result) {
        if (!mounted) return;
        Navigator.pop(context);
      }
    }
  }

  Widget _buildRate() {
    if (widget.item is ProductModel) {
      return Column(
        children: [
          RatingBar.builder(
            initialRating: _rate,
            minRating: 1,
            allowHalfRating: true,
            unratedColor: Colors.amber.withAlpha(100),
            itemCount: 5,
            itemSize: 24.0,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (rate) {
              setState(() {
                _rate = rate;
              });
            },
          ),
          Text(
            Translate.of(context).translate('tap_rate'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('feedback'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CachedNetworkImage(
                          imageUrl: widget.item.author.image,
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                          placeholder: (context, url) {
                            return AppPlaceholder(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.error),
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildRate(),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            Translate.of(context).translate('description'),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        AppTextInput(
                          hintText: Translate.of(context).translate(
                            'input_feedback',
                          ),
                          errorText: _errorReview,
                          focusNode: _focusReview,
                          maxLines: 5,
                          onSubmitted: (text) {
                            _onSave();
                          },
                          onChanged: (text) {
                            setState(() {
                              _errorReview = UtilValidator.validate(
                                _textReviewController.text,
                              );
                            });
                          },
                          controller: _textReviewController,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AppButton(
                Translate.of(context).translate('send'),
                onPressed: _onSave,
                mainAxisSize: MainAxisSize.max,
              ),
            )
          ],
        ),
      ),
    );
  }
}
