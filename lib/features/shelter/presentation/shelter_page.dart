import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/repository/shelter_repository.dart';
import 'package:musahi/features/shelter/service/location_service.dart';
import 'package:musahi/features/shelter/widgets/nearby_shelter_list.dart';
import 'package:musahi/features/shelter/widgets/route_start_button.dart';
import 'package:musahi/features/shelter/widgets/shelter_error_view.dart';
import 'package:musahi/features/shelter/widgets/shelter_map.dart';

class ShelterPage extends StatefulWidget {
  const ShelterPage({super.key});

  @override
  State<ShelterPage> createState() => _ShelterPageState();
}

class _ShelterPageState extends State<ShelterPage> {
  static const double _mapHeight = 340;
  static const double _sheetOverlap = 20;

  Future<NearbyShelters> _nearby = ShelterRepository.instance.fetchNearby();

  void _retry() {
    setState(() {
      _nearby = ShelterRepository.instance.fetchNearby();
    });
  }

  static String _errorMessage(Object? error) => error is LocationException
      ? error.message
      : '대피소 정보를 불러오지 못했습니다.\n네트워크 상태를 확인해 주세요.';

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
      body: FutureBuilder<NearbyShelters>(
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
          final (:origin, :shelters) = snapshot.data!;

          return Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: _mapHeight,
                child: ShelterMap(
                  origin: origin,
                  pins: [for (final shelter in shelters) shelter.location],
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
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(child: NearbyShelterList(shelters: shelters)),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: RouteStartButton(
                          onPressed: shelters.isEmpty
                              ? null
                              : () => _startRoute(origin, shelters.first),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
