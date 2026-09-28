import 'package:flutter/material.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/shelter/model/shelter.dart';

/// "[title] N곳" 헤더와 대피소 카드 목록.
class NearbyShelterList extends StatelessWidget {
  final String title;
  final List<Shelter> shelters;

  const NearbyShelterList({
    super.key,
    required this.title,
    required this.shelters,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: shelters.length + 1,
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 16 : 12),
      itemBuilder: (_, index) {
        if (index == 0) {
          return _Header(title: title, count: shelters.length);
        }
        final shelter = shelters[index - 1];
        return InfoCard.shelter(
          key: ValueKey(shelter.id),
          name: shelter.name,
          address: shelter.address,
          distanceMeters: shelter.distanceMeters,
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final int count;

  const _Header({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
            ),
          ),
        ),
        CaptionText('$count곳'),
      ],
    );
  }
}
