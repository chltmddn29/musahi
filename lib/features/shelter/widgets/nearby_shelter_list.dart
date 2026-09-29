import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:musahi/core/constants/font.dart';
import 'package:musahi/core/widgets/info_card.dart';
import 'package:musahi/features/shelter/model/shelter.dart';

/// "[title] N곳" 헤더와 대피소 카드 목록. 카드를 누르면 [onSelect]로 알리고,
/// 지도 등 밖에서 선택이 바뀌면 선택된 카드가 보이도록 스크롤한다.
class NearbyShelterList extends StatefulWidget {
  final String title;
  final List<Shelter> shelters;
  final Shelter? selected;
  final ValueChanged<Shelter> onSelect;

  const NearbyShelterList({
    super.key,
    required this.title,
    required this.shelters,
    required this.selected,
    required this.onSelect,
  });

  @override
  State<NearbyShelterList> createState() => _NearbyShelterListState();
}

class _NearbyShelterListState extends State<NearbyShelterList> {
  final _cardKeys = <String, GlobalKey>{};

  @override
  void didUpdateWidget(NearbyShelterList oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedId = widget.selected?.id;
    if (selectedId != null && selectedId != oldWidget.selected?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal(selectedId));
    }
  }

  /// 카드가 완전히 보이도록 필요한 만큼만 스크롤한다. 이미 보이면 움직이지 않는다.
  void _reveal(String shelterId) {
    final cardContext = _cardKeys[shelterId]?.currentContext;
    final card = cardContext?.findRenderObject();
    if (cardContext == null || card == null) return;

    final viewport = RenderAbstractViewport.of(card);
    final position = Scrollable.of(cardContext).position;
    final cardAtTop = viewport.getOffsetToReveal(card, 0).offset;
    final cardAtBottom = viewport.getOffsetToReveal(card, 1).offset;
    // 카드가 화면보다 크면 윗부분이 보이도록 맞춘다.
    final target = cardAtBottom > cardAtTop
        ? cardAtTop
        : position.pixels.clamp(cardAtBottom, cardAtTop);
    if (target == position.pixels) return;

    position.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 최대 몇 곳뿐이라 한 번에 그려, 화면 밖 카드로도 스크롤할 수 있게 한다.
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _Header(title: widget.title, count: widget.shelters.length),
          ),
          for (final shelter in widget.shelters)
            InfoCard.shelter(
              key: _cardKeys.putIfAbsent(shelter.id, GlobalKey.new),
              name: shelter.name,
              address: shelter.address,
              distanceMeters: shelter.distanceMeters,
              selected: shelter.id == widget.selected?.id,
              onTap: () => widget.onSelect(shelter),
            ),
        ],
      ),
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
