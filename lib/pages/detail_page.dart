import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/destination_model.dart';
import '../services/firestore/favorite_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DetailPage extends StatefulWidget {
final DestinationModel destination;

const DetailPage({
super.key,
required this.destination,
});

@override
State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {

final FavoriteService _favoriteService = FavoriteService();

bool _isFavorite = false;
final String userId = "dummyUserId";

@override
void initState() {
super.initState();
_checkFavorite();
}

Future<void> _checkFavorite() async {
final result = await _favoriteService.isFavorite(
userId,
widget.destination.id,
);

setState(() {
  _isFavorite = result;
});

}

Future<void> _toggleFavorite() async {

if (_isFavorite) {
  await _favoriteService.removeFavorite(
    userId,
    widget.destination.id,
  );
} else {
  await _favoriteService.addFavorite(
    userId,
    widget.destination.id,
  );
}

setState(() {
  _isFavorite = !_isFavorite;
});

}

Future<void> _openUrl(String url) async {
final Uri uri = Uri.parse(url);
await launchUrl(
uri,
mode: LaunchMode.externalApplication,
);
}

Widget _buildMapSection(DestinationModel item) {

final lat = item.latitude;
final lng = item.longitude;

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [

  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [

      const Text(
        "Location",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),

      GestureDetector(
        onTap: () {
          _openUrl(item.mapsUrl);
        },
        child: const Row(
          children: [
            Text(
              "Get Directions",
              style: TextStyle(
                color: Color(0xFF059669),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFF059669),
            )
          ],
        ),
      )
    ],
  ),

  const SizedBox(height: 12),

  SizedBox(
    height: 200,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(lat, lng),
          initialZoom: 14,
        ),
        children: [

          TileLayer(
            urlTemplate:
                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.aplikasi_wisata.app',
          ),

          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: LatLng(lat, lng),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
],

);
}

@override
Widget build(BuildContext context) {

final item = widget.destination;

return Scaffold(
  backgroundColor: Colors.grey[50],
  body: Stack(
    children: [

      SingleChildScrollView(
        child: Column(
          children: [

            Stack(
              children: [

                Image.network(
                  item.imageUrl,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),

                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black38,
                        Colors.transparent
                      ],
                    ),
                  ),
                ),

                if (item.hasVirtualTour)
                  Positioned.fill(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          _openUrl(item.maps360Url);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.view_in_ar,
                            size: 40,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(item.rating.toString()),
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.location,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "About Destination",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    item.description,
                    style: const TextStyle(
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildMapSection(item),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Entrance Fee",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Adult"),
                            Text("IDR ${item.priceAdult}"),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Child"),
                            Text("IDR ${item.priceChild}"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _toggleFavorite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          icon: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          label: const Text(
                            "Add to Favorites",
                            selectionColor: Color.fromARGB(0, 255, 255, 255),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 191, 191, 191),
                          ),
                        ),
                        child: const Icon(Icons.share),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),

      Positioned(
        top: 40,
        left: 16,
        child: CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    ],
  ),
);

}
}