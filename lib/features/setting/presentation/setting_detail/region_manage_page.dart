import 'package:flutter/material.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/notifications/notification_service.dart';
import 'package:musahi/core/widgets/base_scaffold.dart';
import 'package:musahi/core/widgets/custom_app_bar.dart';
import 'package:musahi/core/widgets/custom_elevated_button.dart';
import 'package:musahi/core/widgets/custom_text_field.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/setting/model/region_model.dart';
import 'package:musahi/features/setting/model/region_store.dart';
import 'package:musahi/features/setting/repository/region_repository.dart';

class RegionManagePage extends StatefulWidget {
  const RegionManagePage({super.key});

  @override
  State<RegionManagePage> createState() => _RegionManagePageState();
}

class _RegionManagePageState extends State<RegionManagePage> {
  final TextEditingController _textEditingController = TextEditingController();

  final RegionRepository _regionRepository = RegionRepository(
    consumerKey: const String.fromEnvironment('SGIS_CONSUMER_KEY'),
    consumerSecret: const String.fromEnvironment('SGIS_CONSUMER_SECRET'),
  );

  List<RegionItem> _regions = [];
  final List<RegionItem> _selectionPath = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// true면 지역 검색/선택 화면, false면 등록된 관심지역 목록 화면.
  bool _isAdding = false;

  // 더 내려갈 하위 목록 없이 확정된 상태인지.
  // 읍면동(8자리) 끝까지 드릴다운했거나, "선택"으로 중간 단계에서 바로 확정한 경우 모두 해당.
  bool get _reachedFinalLevel => _selectionPath.isNotEmpty && _regions.isEmpty;

  List<RegionItem> get _filteredRegions {
    final query = _textEditingController.text.trim();
    if (query.isEmpty) return _regions;
    return _regions.where((r) => r.addrName.contains(query)).toList();
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
      final result = await _regionRepository.fetchRegions(cd: cd);
      setState(() {
        _regions = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        debugPrint('지역 조회 에러: $e');
        _errorMessage = '지역 정보를 불러오지 못했습니다';
        _isLoading = false;
      });
    }
  }

  void _startAdding() {
    setState(() {
      _isAdding = true;
      _selectionPath.clear();
      _regions = [];
      _errorMessage = null;
      _textEditingController.clear();
    });
    _loadRegions();
  }

  void _cancelAdding() {
    setState(() {
      _isAdding = false;
      _selectionPath.clear();
      _regions = [];
      _errorMessage = null;
      _textEditingController.clear();
    });
  }

  /// 행을 탭하면 하위 단계로 "들어감" (읍면동 8자리 도달 시 더 이상 안 내려감)
  void _onDrillDown(RegionItem region) {
    _textEditingController.clear();
    setState(() {
      _selectionPath.add(region);
    });
    if (region.cd.length < 8) {
      _loadRegions(cd: region.cd);
    } else {
      // 읍면동까지 도달 → 하위 목록 비우고 종료 상태로 표시
      setState(() {
        _regions = [];
      });
    }
  }

  /// "선택" 버튼을 누르면 하위로 안 내려가고 바로 이 단계로 확정
  void _onPickHere(RegionItem region) {
    _textEditingController.clear();
    setState(() {
      _selectionPath.add(region);
      _regions = []; // 더 이상 하위 조회 안 하고 종료 상태로 표시
    });
  }

  void _onBack() {
    if (_selectionPath.isEmpty) {
      _cancelAdding();
      return;
    }
    setState(() {
      _selectionPath.removeLast();
    });
    final parentCd = _selectionPath.isEmpty ? null : _selectionPath.last.cd;
    _loadRegions(cd: parentCd);
  }

  void _onComplete() {
    if (_selectionPath.isEmpty) return;
    final region = _selectionPath.last;
    InterestRegionStore.instance.add(region);
    NotificationService.subscribeToRegion(region.cd);
    _cancelAdding();
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
        const SizedBox(height: 20),
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
                          label: region.displayName,
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
                                  NotificationService.unsubscribeFromRegion(
                                    region.cd,
                                  );
                                },
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
          _selectionPath.isEmpty
              ? '재난 알림을 받을 지역을 선택하세요'
              : _selectionPath.map((r) => r.addrName).join(' > '),
          style: AppTextStyles.label.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            IconButton(onPressed: _onBack, icon: const Icon(Icons.arrow_back)),
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
              ? Center(child: Text(_errorMessage!))
              : _reachedFinalLevel
              ? Center(
                  child: Text(
                    '${_selectionPath.last.addrName}(으)로 선택됨',
                    style: AppTextStyles.label,
                  ),
                )
              : ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final region = _filteredRegions[index];
                    return ListTile(
                      title: Text(region.addrName),
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
                onPressed: _selectionPath.isEmpty ? null : _onComplete,
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
