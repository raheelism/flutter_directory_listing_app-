import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class AppCommentItem extends StatelessWidget {
  final CommentModel? item;
  final bool? showPostName;
  final VoidCallback? onPressUser;

  const AppCommentItem({
    Key? key,
    this.item,
    this.onPressUser,
    this.showPostName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item == null) {
      return AppPlaceholder(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                height: 10,
                                width: 100,
                                color: Colors.white,
                              ),
                              Container(
                                height: 10,
                                width: 50,
                                color: Colors.white,
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 10,
                            width: 50,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                width: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Container(
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Container(
                height: 10,
                color: Colors.white,
              )
            ],
          ),
        ),
      );
    }
    Widget postName = Container();
    Widget rating = Text(
      item!.user.email,
      style: Theme.of(context).textTheme.labelSmall,
    );
    if (showPostName == true) {
      postName = Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          item!.postName,
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );
    }
    if (item!.rate > 0) {
      rating = RatingBar.builder(
        initialRating: item!.rate,
        minRating: 1,
        allowHalfRating: true,
        unratedColor: Colors.amber.withAlpha(100),
        itemCount: 5,
        itemSize: 12.0,
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rate) {},
        ignoreGestures: true,
      );
    }
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withAlpha(15),
            spreadRadius: 4,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: onPressUser,
                child: CachedNetworkImage(
                  imageUrl: item!.user.image,
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
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
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(Icons.error),
                    );
                  },
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              item!.user.name,
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            item!.createDate.dateView,
                            style: Theme.of(context).textTheme.labelSmall,
                          )
                        ],
                      ),
                      rating,
                    ],
                  ),
                ),
              )
            ],
          ),
          postName,
          const SizedBox(height: 8),
          Text(
            item!.comment,
            maxLines: 5,
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
  }
}
