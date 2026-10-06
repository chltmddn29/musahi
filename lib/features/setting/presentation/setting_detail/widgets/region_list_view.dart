part of '../region_manage_page.dart';

extension _RegionListView on _RegionManagePageState {
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
}
