import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class SearchHeader extends StatelessWidget {
  final String location;
  final ValueChanged<String> onLocationChanged;
  final VoidCallback onSearch;
  final VoidCallback onFilterPressed;
  final VoidCallback onSortPressed;
  final List<dynamic> searchResults;
  final bool showLocationDropdown;
  final bool isSearchingLocation;
  final Function(dynamic) onLocationSelected;

  const SearchHeader({
    super.key,
    required this.location,
    required this.onLocationChanged,
    required this.onSearch,
    required this.onFilterPressed,
    required this.onSortPressed,
    required this.searchResults,
    required this.showLocationDropdown,
    required this.isSearchingLocation,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Ionicons.search,
                          size: 20,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: "Tìm kiếm",
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 17),
                          onChanged: onLocationChanged,
                          onSubmitted: (_) => onSearch(),
                        ),
                      ),
                      if (isSearchingLocation)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      TextButton(
                        onPressed: onSearch,
                        child: const Text(
                          "Tìm",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Ionicons.options_outline,
                  color: Color(0xFFFF385C),
                ),
                onPressed: onFilterPressed,
              ),
              IconButton(
                icon: const Icon(
                  Ionicons.swap_vertical,
                  color: Color(0xFFFF385C),
                ),
                onPressed: onSortPressed,
              ),
            ],
          ),
          if (showLocationDropdown && searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: searchResults.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = searchResults[index];
                  return ListTile(
                    title: Text(item['name']),
                    onTap: () => onLocationSelected(item),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
