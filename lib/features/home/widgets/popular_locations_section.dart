import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/popular_location_card.dart';

class PopularLocationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> locations;

  const PopularLocationsSection({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: ValueKey('popular-locations-${locations.length}'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
          child: Row(
            children: const [
              Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
              SizedBox(width: 8),
              Text(
                'Địa điểm có nhiều sân nhất',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                  color: Color(0xFFFFD700),
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.black26,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (locations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const Text(
                  'Không có dữ liệu để hiển thị',
                  style: TextStyle(fontSize: 16, color: Colors.lightBlueAccent),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: locations.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final loc = locations[index];

                return PopularLocationCard(
                  location: loc,
                  onTap: () {
                    context.push('/search?locationId=${loc['id']}');
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
