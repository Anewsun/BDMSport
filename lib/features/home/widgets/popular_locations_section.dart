import 'package:flutter/material.dart';
import '../../../core/widgets/popular_location_card.dart';

class PopularLocationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> popularLocations;

  const PopularLocationsSection({super.key, required this.popularLocations});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 25, 15, 10),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
              const SizedBox(width: 8),
              Text(
                'Địa điểm có nhiều sân nhất',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman',
                  color: Color(0xFFFFD700),
                  shadows: [
                    Shadow(
                      blurRadius: 6,
                      color: Colors.brown,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemCount: popularLocations.length,
            itemBuilder: (_, index) {
              final location = popularLocations[index];
              return PopularLocationCard(
                imageUrl: location['imageUrl'],
                name: location['name'],
                courtCount: location['courtCount'],
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }
}
