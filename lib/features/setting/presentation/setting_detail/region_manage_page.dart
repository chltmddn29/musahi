import 'package:firebase_core/firebase_core.dart';
import 'package:dio/dio.dart';
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
  String? _selectionError;
  bool _isLoading = false;
  String? _errorMessage;

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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _regionRepository.fetchRegions(cd: cd),
        if (cd == null) _regionRepository.fetchNotificationRegions(),
      ]);
      if (!mounted || !_isAdding) return;
      setState(() {
        _regions = results.first;
        if (cd == null) _notificationRegions = results[1];
        _isLoading = false;
      });
    } on FirebaseException catch (error) {
      _showLoadError(error);
    } on DioException catch (error) {
      _showLoadError(error);
    } on FormatException catch (error) {
      _showLoadError(error);
    }
  }

  void _showLoadError(Object error) {
    debugPrint('지역 조회 에러: $error');
    if (!mounted || !_isAdding) return;
    setState(() {
      _errorMessage = '지역 정보를 불러오지 못했습니다';
      _isLoading = false;
    });
  }

  void _startAdding() {
    setState(() {
      _isAdding = true;
      _selectedRegion = null;
      _selectionError = null;
      _selectionPath.clear();
      _notificationRegions = [];
      _regions = [];
      _errorMessage = null;
      _textEditingController.clear();
    });
    _loadRegions();
  }

  void _cancelAdding() {
    setState(() {
      _isAdding = false;
      _selectedRegion = null;
      _selectionError = null;
      _selectionPath.clear();
      _notificationRegions = [];
      _regions = [];
      _errorMessage = null;
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
      _selectionError = null;
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
      _selectionError = null;
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
      _selectionError = notificationCode == null
          ? '선택한 지역의 재난문자 수신지역 코드를 찾지 못했습니다.'
          : null;
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
      _selectionError = null;
    });
    _loadRegions(cd: _selectionPath.isEmpty ? null : _selectionPath.last.cd);
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: const CustomAppBar(title: '관심지역 관리', icon: true),
      child: _isAdding ? _buildSearchView() : _buildListView(),
    );
  }

  Widget _buildListView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('관심지역을 관리하세요', style: AppTextStyles.titleMedium),
        const SizedBox(height: 5),
        Text(
          '재난 알림을 받을 지역을 추가하거나 삭제하세요',
          style: AppTextStyles.label.copyWith(color: AppColors.muted),
        ),
        if (_selectionError != null) ...[
          const SizedBox(height: 5),
          Text(
            _selectionError!,
            style: AppTextStyles.label.copyWith(color: AppColors.muted),
          ),
        ],
        const SizedBox(height: 20),
        const NotificationSyncStatus(),
        Expanded(
          child: ValueListenableBuilder<List<RegionItem>>(
            valueListenable: InterestRegionStore.instance.regions,
            builder: (context, regions, _) {
              if (regions.isEmpty) {
                return Center(
                  child: Text(
                    '등록된 관심지역이 없습니다',
                    style: AppTextStyles.label.copyWith(color: AppColors.muted),
                  ),
                );
              }
              return ValueListenableBuilder<String?>(
                valueListenable: InterestRegionStore.instance.primaryCd,
                builder: (context, primaryCd, _) => SingleChildScrollView(
                  child: SettingsGroup(
                    children: [
                      for (final region in regions)
                        InfoCard.settingsTile(
                          label: region.notificationCode == null
                              ? '${region.displayName}\n자동 전환하지 못했습니다. 삭제 후 다시 추가해주세요'
                              : region.displayName,
                          onTap: region.cd == primaryCd
                              ? null
                              : () => InterestRegionStore.instance.setPrimary(
                                  region,
                                ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (region.cd == primaryCd) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '대표',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              IconButton(
                                onPressed: () {
                                  InterestRegionStore.instance.remove(region);
                                },
                                tooltip: '${region.displayName} 삭제',
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.muted,
                                ),
                                padding: const EdgeInsets.all(8),
                                constraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: CustomElevatedButton(
            onPressed: _startAdding,
            child: '관심지역 추가',
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSearchView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text('관심지역을 설정해주세요', style: AppTextStyles.titleMedium),
        const SizedBox(height: 5),
        Text(
          _selectedRegion == null
              ? '재난 알림을 받을 지역을 선택하세요'
              : '${_selectedRegion!.displayName}(으)로 선택됨',
          style: AppTextStyles.label.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            IconButton(
              onPressed: _onBack,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: CustomTextField(
                controller: _textEditingController,
                hintText: '지역을 입력하세요',
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!),
                      TextButton(
                        onPressed: _loadRegions,
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : _selectedRegion != null
              ? Center(
                  child: Text(
                    '${_selectedRegion!.displayName}(으)로 선택됨',
                    style: AppTextStyles.label,
                  ),
                )
              : _filteredRegions.isEmpty
              ? Center(
                  child: Text(
                    _regions.isEmpty ? '하위 지역이 없습니다' : '검색 결과가 없습니다',
                    style: AppTextStyles.label,
                  ),
                )
              : ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final region = _filteredRegions[index];
                    return Semantics(
                      selected: _selectedRegion?.cd == region.cd,
                      child: ListTile(
                        title: Text(region.displayName),
                        onTap: () => _onDrillDown(region),
                        trailing: TextButton(
                          onPressed: () => _onPickHere(region),
                          child: Text(
                            '선택',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider(height: 2);
                  },
                  itemCount: _filteredRegions.length,
                ),
        ),
        Row(
          children: [
            Expanded(
              child: CustomElevatedButton(
                onPressed: _selectedRegion == null ? null : _onComplete,
                child: '추가',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
