import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class Discovery extends StatefulWidget {
  const Discovery({Key? key}) : super(key: key);

  @override
  State<Discovery> createState() {
    return _DiscoveryState();
  }
}

class _DiscoveryState extends State<Discovery> {
  final _discoveryCubit = DiscoveryCubit();
  StreamSubscription? _submitSubscription;

  @override
  void initState() {
    super.initState();
    _discoveryCubit.onLoad();
  }

  @override
  void dispose() {
    _submitSubscription?.cancel();
    _discoveryCubit.close();
    super.dispose();
  }

  ///On refresh
  Future<void> _onRefresh() async {
    await _discoveryCubit.onLoad();
  }

  ///On search
  void _onSearch() {
    Navigator.pushNamed(context, Routes.searchHistory);
  }

  ///On navigate list product
  void _onProductList(CategoryModel item) {
    Navigator.pushNamed(
      context,
      Routes.listProduct,
      arguments: item,
    );
  }

  ///On navigate product detail
  void _onProductDetail(ProductModel item) {
    Navigator.pushNamed(context, Routes.productDetail, arguments: item);
  }

  ///On scan
  void _onScan() async {
    final result = await Navigator.pushNamed(context, Routes.scanQR);
    if (result != null) {
      final deeplink = DeepLinkModel.fromString(result as String);
      if (deeplink.target.isNotEmpty) {
        if (!mounted) return;
        Navigator.pushNamed(
          context,
          Routes.deepLink,
          arguments: deeplink,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              bottom: 8,
              top: 4,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                AppSearchBar(
                  onSearch: _onSearch,
                  onScan: _onScan,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<DiscoveryCubit, DiscoveryState>(
              bloc: _discoveryCubit,
              builder: (context, discovery) {
                ///Loading

                Widget content = ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: (context, index) {
                    return const AppDiscoveryItem();
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 12);
                  },
                  itemCount: 15,
                );

                ///Success
                if (discovery is DiscoverySuccess) {
                  if (discovery.list.isEmpty) {
                    content = Center(
                      child: Text(
                        Translate.of(context).translate(
                          'can_not_found_data',
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  } else {
                    content = ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemBuilder: (context, index) {
                        final item = discovery.list[index];
                        return AppDiscoveryItem(
                          item: item,
                          onSeeMore: _onProductList,
                          onProductDetail: _onProductDetail,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 12);
                      },
                      itemCount: discovery.list.length,
                    );
                  }
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: content,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
