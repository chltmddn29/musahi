part of '../region_manage_page.dart';

extension _RegionListView on _RegionManagePageState {
  Widget _buildListView() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(l10n.regionListTitle, style: AppTextStyles.titleMedium),
        const SizedBox(height: 5),
        Text(
          l10n.regionListSubtitle,
          style: AppTextStyles.label.copyWith(color: AppColors.muted),
        ),
        if (_codeNotFound) ...[
          const SizedBox(height: 5),
          Text(
            l10n.regionCodeNotFound,
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
                    l10n.regionListEmpty,
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
                              ? l10n.regionMigrationFailed(region.displayName)
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
                                    l10n.regionPrimary,
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
                                tooltip: l10n.deleteTooltip(region.displayName),
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
            child: l10n.regionAdd,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
