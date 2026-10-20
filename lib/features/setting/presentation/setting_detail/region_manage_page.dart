import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/notifications/notification_sync_status.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/custom_text_field.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/setting/model/region_model.dart';
import 'package:musahi/features/setting/model/region_store.dart';
import 'package:musahi/features/setting/repository/region_repository.dart';
import 'package:musahi/l10n/app_localizations.dart';

part 'widgets/region_list_view.dart';
part 'widgets/region_search_view.dart';

class RegionManagePage extends StatefulWidget {
  const RegionManagePage({super.key, this.repository});

  final RegionRepository? repository;

  @override
  State<RegionManagePage> createState() => _RegionManagePageState();
}

class _RegionManagePageState extends State<RegionManagePage> {
  final TextEditingController _textEditingController = TextEditingController();

  late final RegionRepository _regionRepository =
      widget.repository ?? RegionRepository();

  List<RegionItem> _regions = [];
  List<RegionItem> _notificationRegions = [];
  final List<RegionItem> _selectionPath = [];
  RegionItem? _selectedRegion;
  bool _codeNotFound = false;
  bool _isLoading = false;
  bool _loadFailed = false;

  /// 가장 최근 [_loadRegions] 호출 번호. 이전 단계의 늦은 응답을 버리는 데 쓴다.
  int _loadRequestId = 0;

  /// true면 지역 검색/선택 화면, false면 등록된 관심지역 목록 화면.
  bool _isAdding = false;

  List<RegionItem> get _filteredRegions {
    final query = _textEditingController.text.trim();
    if (query.isEmpty) return _regions;
    return _regions.where((r) => r.displayName.contains(query)).toList();
  }

  @override
  void initState() {
    super.initState();
    _textEditingController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions({String? cd}) async {
    final requestId = ++_loadRequestId;
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });
    try {
      final results = await Future.wait([
        _regionRepository.fetchRegions(cd: cd),
        if (cd == null) _regionRepository.fetchNotificationRegions(),
      ]);
      if (!mounted || !_isAdding || requestId != _loadRequestId) return;
      setState(() {
        _regions = results.first;
        if (cd == null) _notificationRegions = results[1];
        _isLoading = false;
      });
    } catch (error) {
      _showLoadError(error, requestId);
    }
  }

  void _showLoadError(Object error, int requestId) {
    debugPrint('지역 조회 에러: $error');
    if (!mounted || !_isAdding || requestId != _loadRequestId) return;
    setState(() {
      _loadFailed = true;
      _isLoading = false;
    });
  }

  void _startAdding() {
    setState(() {
      _isAdding = true;
      _selectedRegion = null;
      _codeNotFound = false;
      _selectionPath.clear();
      _notificationRegions = [];
      _regions = [];
      _loadFailed = false;
      _textEditingController.clear();
    });
    _loadRegions();
  }

  void _cancelAdding() {
    setState(() {
      _isAdding = false;
      _selectedRegion = null;
      _codeNotFound = false;
      _selectionPath.clear();
      _notificationRegions = [];
      _regions = [];
      _loadFailed = false;
      _textEditingController.clear();
    });
  }

  void _onComplete() {
    InterestRegionStore.instance.add(_selectedRegion!);
    _cancelAdding();
  }

  void _onDrillDown(RegionItem region) {
    _textEditingController.clear();
    setState(() {
      _selectionPath.add(region);
      _selectedRegion = null;
      _codeNotFound = false;
    });
    if (region.cd.length < 8) {
      _loadRegions(cd: region.cd);
    } else {
      _selectRegion(region);
    }
  }

  void _onPickHere(RegionItem region) {
    _textEditingController.clear();
    setState(() {
      _selectionPath.add(region);
      _codeNotFound = false;
    });
    _selectRegion(region);
  }

  void _selectRegion(RegionItem region) {
    final notificationCode = resolveNotificationCode(
      _selectionPath,
      _notificationRegions,
    );
    setState(() {
      _selectedRegion = notificationCode == null
          ? null
          : region.withNotificationCode(notificationCode);
      _codeNotFound = notificationCode == null;
    });
  }

  void _onBack() {
    if (_selectionPath.isEmpty) {
      _cancelAdding();
      return;
    }
    setState(() {
      _selectionPath.removeLast();
      _selectedRegion = null;
      _codeNotFound = false;
    });
    _loadRegions(cd: _selectionPath.isEmpty ? null : _selectionPath.last.cd);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context).settingsRegions,
        icon: true,
      ),
      child: _isAdding ? _buildSearchView() : _buildListView(),
    );
  }
}
