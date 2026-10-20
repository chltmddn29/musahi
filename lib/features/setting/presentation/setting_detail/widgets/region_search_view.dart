part of '../region_manage_page.dart';

extension _RegionSearchView on _RegionManagePageState {
  Widget _buildSearchView() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(l10n.regionSearchTitle, style: AppTextStyles.titleMedium),
        const SizedBox(height: 5),
        Text(
          _selectedRegion == null
              ? l10n.regionSearchSubtitle
              : l10n.regionSelected(_selectedRegion!.displayName),
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
                hintText: l10n.regionSearchHint,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadFailed
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.regionLoadFailed),
                      TextButton(
                        onPressed: () => _loadRegions(
                          cd: _selectionPath.isEmpty
                              ? null
                              : _selectionPath.last.cd,
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _selectedRegion != null
              ? Center(
                  child: Text(
                    l10n.regionSelected(_selectedRegion!.displayName),
                    style: AppTextStyles.label,
                  ),
                )
              : _filteredRegions.isEmpty
              ? Center(
                  child: Text(
                    _regions.isEmpty
                        ? l10n.regionNoChildren
                        : l10n.regionNoResults,
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
                            l10n.select,
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
                child: l10n.add,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
