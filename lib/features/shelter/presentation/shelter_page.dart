import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/features/shelter/model/shelter.dart';
import 'package:musahi/features/shelter/repository/shelter_repository.dart';
import 'package:musahi/features/shelter/widgets/nearby_shelter_list.dart';
import 'package:musahi/features/shelter/widgets/route_start_button.dart';
import 'package:musahi/features/shelter/widgets/shelter_map.dart';

class ShelterPage extends StatefulWidget {
  const ShelterPage({super.key});

  @override
  State<ShelterPage> createState() => _ShelterPageState();
}

class _ShelterPageState extends State<ShelterPage> {
  static const double _mapHeight = 340;
  static const double _sheetOverlap = 20;

  final Future<NearbyShelters> _nearby = ShelterRepository.instance
      .fetchNearby();

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
          if (snapshot.hasError) {
            return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
