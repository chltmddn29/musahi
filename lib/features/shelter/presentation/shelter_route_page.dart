import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:musahi/core/constants/color.dart';
import 'package:musahi/features/shelter/model/shelter_route.dart';
import 'package:musahi/features/shelter/repository/route_repository.dart';
import 'package:musahi/features/shelter/widgets/route_guidance_panel.dart';
import 'package:musahi/features/shelter/widgets/shelter_error_view.dart';
import 'package:musahi/features/shelter/widgets/route_summary_chip.dart';
import 'package:musahi/features/shelter/widgets/shelter_map.dart';

class ShelterRoutePage extends StatefulWidget {
  final RouteTarget target;

  const ShelterRoutePage({super.key, required this.target});

  @override
  State<ShelterRoutePage> createState() => _ShelterRoutePageState();
}

class _ShelterRoutePageState extends State<ShelterRoutePage> {
  /// 상단 칩·하단 패널에 가리지 않도록 지도에 주는 여백.
  static const _mapPadding = EdgeInsets.only(top: 110, bottom: 180);

  late Stream<ShelterRoute> _route = _watchRoute();

  Stream<ShelterRoute> _watchRoute() =>
      RouteRepository.instance.watchWalkingRoute(widget.target);

  void _retry() => setState(() {
    _route = _watchRoute();
  });

  @override
  Widget build(BuildContext context) {
    final (:origin, :destination) = widget.target;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<ShelterRoute>(
        stream: _route,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return ShelterErrorView(
              message: '경로를 불러오지 못했습니다.',
              onRetry: _retry,
            );
          }
          final route = snapshot.data!;

          return Stack(
            children: [
              Positioned.fill(
                child: ShelterMap(
                  origin: origin,
                  pins: [destination.location],
                  route: route.path,
                  padding: _mapPadding,
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: RouteSummaryChip(
                      remainingTime: route.remainingTime,
                      remainingMeters: route.remainingMeters,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: RouteGuidancePanel(
                  nextStep: route.nextStep,
                  destinationName: destination.name,
                  remainingMeters: route.remainingMeters,
                  onEnd: () => context.pop(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
