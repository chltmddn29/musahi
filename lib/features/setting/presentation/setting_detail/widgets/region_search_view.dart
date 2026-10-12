part of '../region_manage_page.dart';

extension _RegionSearchView on _RegionManagePageState {
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
                        onPressed: () => _loadRegions(
                          cd: _selectionPath.isEmpty
                              ? null
                              : _selectionPath.last.cd,
                        ),
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
