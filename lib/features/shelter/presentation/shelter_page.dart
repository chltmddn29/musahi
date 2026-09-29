import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/repository/shelter_repository.dart';
import 'package:musahi/features/shelter/service/location_service.dart';
import 'package:musahi/features/shelter/widgets/map_back_button.dart';
import 'package:musahi/features/shelter/widgets/nearby_shelter_list.dart';
import 'package:musahi/features/shelter/widgets/route_start_button.dart';
import 'package:musahi/features/shelter/widgets/shelter_error_view.dart';
import 'package:musahi/features/shelter/widgets/shelter_map.dart';

class ShelterPage extends StatefulWidget {
  /// 재난문자에서 들어온 경우의 수신지역명. 없으면 하단 탭의 내 주변 대피소.
  final String? disasterRegion;

  const ShelterPage({super.key, this.disasterRegion});

  @override
  State<ShelterPage> createState() => _ShelterPageState();
}

class _ShelterPageState extends State<ShelterPage> {
  static const double _mapHeight = 340;
  static const double _sheetOverlap = 20;

  late Future<NearbyShelters> _nearby = _fetch();

  /// 사용자가 고른 대피소 id. 없으면 가장 가까운 대피소를 선택한 것으로 본다.
  String? _selectedId;

  Future<NearbyShelters> _fetch() => ShelterRepository.instance.fetchNearby(
    disasterRegion: widget.disasterRegion,
  );

  void _retry() {
    setState(() {
      _nearby = _fetch();
      _selectedId = null;
    });
  }

  static String _errorMessage(Object? error) => error is LocationException
      ? error.message
      : '대피소 정보를 불러오지 못했습니다.\n네트워크 상태를 확인해 주세요.';

  void _select(Shelter shelter) => setState(() => _selectedId = shelter.id);

  Shelter? _selectedOf(List<Shelter> shelters) =>
      shelters.where((s) => s.id == _selectedId).firstOrNull ??
      shelters.firstOrNull;

  void _startRoute(Coordinate origin, Shelter shelter) {
    context.push(
      '/shelter/route',
      extra: (origin: origin, destination: shelter),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          FutureBuilder<NearbyShelters>(
            future: _nearby,
            builder: (context, snapshot) {
              // 다시 시도 중에는 이전 오류가 남아 있으므로 로딩 여부를 먼저 본다.
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ShelterErrorView(
                  message: _errorMessage(snapshot.error),
                  onRetry: _retry,
                );
              }
              return _buildContent(snapshot.data!);
            },
          ),
          if (context.canPop())
            const SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: MapBackButton(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(NearbyShelters result) {
    final (:origin, :shelters, :mode) = result;
    final isNearby = mode == ShelterSearchMode.nearby;
    final selected = _selectedOf(shelters);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _mapHeight,
          child: ShelterMap(
            currentLocation: isNearby ? origin : null,
            pins: [for (final shelter in shelters) shelter.location],
            selectedPin: selected == null ? null : shelters.indexOf(selected),
            onPinTap: (index) => _select(shelters[index]),
            // 상태바와 겹치는 시트 가장자리를 피해 카메라를 맞춘다.
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top,
              bottom: _sheetOverlap,
            ),
          ),
        ),
        Positioned.fill(
          top: _mapHeight - _sheetOverlap,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: NearbyShelterList(
                    title: isNearby ? '가까운 대피소' : '재난 지역 대피소',
                    shelters: shelters,
                    selected: selected,
                    onSelect: _select,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: isNearby
                      ? RouteStartButton(
                          onPressed: selected == null
                              ? null
                              : () => _startRoute(origin, selected),
                        )
                      : const CaptionText(
                          '현재 위치가 재난 지역 밖이라 지역 안의 대피소를 보여줍니다.',
                          align: TextAlign.center,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
