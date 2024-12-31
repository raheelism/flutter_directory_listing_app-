import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class ClaimList extends StatefulWidget {
  const ClaimList({Key? key}) : super(key: key);

  @override
  State<ClaimList> createState() {
    return _ClaimListState();
  }
}

class _ClaimListState extends State<ClaimList> {
  final _claimListCubit = ClaimListCubit();
  final _textSearchController = TextEditingController();
  final _scrollController = ScrollController();
  final _endReachedThreshold = 500;

  SortModel? _sort;
  SortModel? _status;
  Timer? _timer;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _claimListCubit.onLoad();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textSearchController.dispose();
    _claimListCubit.close();
    _timer?.cancel();
    super.dispose();
  }

  ///On Refresh
  Future<void> _onRefresh() async {
    _claimListCubit.page = 1;
    await _claimListCubit.onLoad(
      keyword: _textSearchController.text,
      status: _status,
      sort: _sort,
    );
  }

  ///On Search
  void _onSearch(String text) {
    if (text.isNotEmpty) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 500), () async {
        _claimListCubit.page = 1;
        _claimListCubit.onLoad(keyword: text, status: _status, sort: _sort);
      });
    } else {
      _claimListCubit.page = 1;
      _claimListCubit.onLoad(keyword: text, status: _status, sort: _sort);
    }
  }

  ///Handle load more
  void _onScroll() async {
    if (_scrollController.position.extentAfter > _endReachedThreshold) return;
    final state = _claimListCubit.state;
    if (state is ClaimListSuccess && state.canLoadMore && !_loadingMore) {
      _loadingMore = true;
      _claimListCubit.page += 1;
      await _claimListCubit.onLoad(
        keyword: _textSearchController.text,
        status: _status,
        sort: _sort,
      );
      Future.delayed(const Duration(milliseconds: 250), () {
        _loadingMore = false;
      });
    }
  }

  ///On Filter
  void _onFilter() async {
    if (_claimListCubit.statusOptions.isEmpty) return;
    final result = await showModalBottomSheet<SortModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [_status],
            data: _claimListCubit.statusOptions,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _status = result;
      });
      _onRefresh();
    }
  }

  ///On Sort
  void _onSort() async {
    if (_claimListCubit.sortOptions.isEmpty) return;
    final result = await showModalBottomSheet<SortModel?>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AppBottomPicker(
          picker: PickerModel(
            selected: [_sort],
            data: _claimListCubit.sortOptions,
          ),
        );
      },
    );
    if (result != null) {
      setState(() {
        _sort = result;
      });
      _onRefresh();
    }
  }

  ///On Detail Claim
  void _onDetail(ClaimModel item) {
    Navigator.pushNamed(context, Routes.claimDetail, arguments: item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('claim_list'),
        ),
      ),
      body: BlocBuilder<ClaimListCubit, ClaimListState>(
        bloc: _claimListCubit,
        builder: (context, state) {
          Widget content = ListView.builder(
            itemCount: 15,
            itemBuilder: (context, index) {
              return const AppClaimItem(item: null);
            },
          );

          if (state is ClaimListSuccess) {
            List list = List.from(state.list);
            if (state.canLoadMore) {
              list.add(null);
            }
            if (list.isEmpty) {
              content = Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.sentiment_satisfied),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        Translate.of(context).translate(
                          'data_not_found',
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              content = RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return AppClaimItem(
                      item: item,
                      onPressed: () {
                        _onDetail(item);
                      },
                    );
                  },
                ),
              );
            }
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppTextInput(
                    hintText: Translate.of(context).translate('search'),
                    controller: _textSearchController,
                    onChanged: _onSearch,
                    onSubmitted: _onSearch,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      InkWell(
                        onTap: _onFilter,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                Translate.of(context).translate('filter'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _onSort,
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              Text(
                                Translate.of(context).translate('sort'),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: content)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
