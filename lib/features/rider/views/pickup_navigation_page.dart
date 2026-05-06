import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:food_delivery_app/core/firebase_providers.dart';

class PickupNavigationPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> order;
  const PickupNavigationPage({super.key, required this.order});

  @override
  ConsumerState<PickupNavigationPage> createState() => _PickupNavigationPageState();
}

class _PickupNavigationPageState extends ConsumerState<PickupNavigationPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  final Set<Marker> _markers = {};

  // Default restaurant location (will be replaced with real data)
  late LatLng _restaurantLocation;

  @override
  void initState() {
    super.initState();
    // Parse restaurant location from order data, or use a default
    final lat = widget.order['restaurantLat'] as double? ?? 23.8103;
    final lng = widget.order['restaurantLng'] as double? ?? 90.4125;
    _restaurantLocation = LatLng(lat, lng);
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // Get initial position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    _updatePosition(position);

    // Start listening for location updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(_updatePosition);
  }

  void _updatePosition(Position position) {
    if (!mounted) return;
    setState(() {
      _currentPosition = position;
      _markers.clear();

      // Rider marker
      _markers.add(Marker(
        markerId: const MarkerId('rider'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: const InfoWindow(title: 'You'),
      ));

      // Restaurant marker
      _markers.add(Marker(
        markerId: const MarkerId('restaurant'),
        position: _restaurantLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.order['restaurantName'] ?? 'Restaurant',
        ),
      ));
    });

    // Animate camera to show both markers
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            position.latitude < _restaurantLocation.latitude
                ? position.latitude
                : _restaurantLocation.latitude,
            position.longitude < _restaurantLocation.longitude
                ? position.longitude
                : _restaurantLocation.longitude,
          ),
          northeast: LatLng(
            position.latitude > _restaurantLocation.latitude
                ? position.latitude
                : _restaurantLocation.latitude,
            position.longitude > _restaurantLocation.longitude
                ? position.longitude
                : _restaurantLocation.longitude,
          ),
        ),
        80,
      ),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _markAsPickedUp() async {
    final firestore = ref.read(firestoreProvider);
    final orderId = widget.order['id'];
    await firestore.collection('orders').doc(orderId).update({
      'status': 'on_the_way',
      'pickedUpAt': DateTime.now().toIso8601String(),
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order picked up! Navigate to customer."), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _callRestaurant() async {
    final phone = widget.order['restaurantPhone'] ?? '';
    if (phone.isNotEmpty) {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) await launchUrl(uri);
    }
  }

  Future<void> _navigateToRestaurant() async {
    final lat = _restaurantLocation.latitude;
    final lng = _restaurantLocation.longitude;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final items = (widget.order['items'] as List<dynamic>?) ?? [];
    final restaurantName = widget.order['restaurantName'] ?? 'Le Bernardin';
    final restaurantAddress = widget.order['pickupAddress'] ?? '155 W 51st St, New York, NY 10019';
    final orderId = (widget.order['id'] as String?)?.substring(0, 7).toUpperCase() ?? 'LB-4921';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4F3),
      body: Column(
        children: [
          // ---- TOP SECTION: Header + Map + ETA ----
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _restaurantLocation,
                    zoom: 14,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) => _mapController = controller,
                ),

                // Header overlay
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF4A2C2A), size: 20),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "NazEats Express",
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFFD35400),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.help_outline_rounded, color: Color(0xFF4A2C2A), size: 20),
                        ),
                      ],
                    ),
                  ),
                ),

                // ETA Banner at bottom of map
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D6A4F),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delivery_dining_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "5 mins to Restaurant",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "0.8 mi • Moderate traffic",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ---- BOTTOM SECTION: Details ----
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF4F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup Location Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "PICKUP LOCATION",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFD35400),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurantName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF4A2C2A),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFD35400)),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            restaurantAddress,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF4A2C2A).withOpacity(0.6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Pickup at the dedicated delivery side-door on 51st.",
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF4A2C2A).withOpacity(0.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(Icons.restaurant_rounded, size: 50, color: const Color(0xFFD35400).withOpacity(0.15)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Call & Navigate Buttons
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _callRestaurant,
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: const Color(0xFFFFD1CC)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.phone_outlined, size: 18, color: Color(0xFF4A2C2A)),
                                        const SizedBox(width: 8),
                                        Text("Call", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _navigateToRestaurant,
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: const Color(0xFFFFD1CC)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.diamond_outlined, size: 18, color: Color(0xFF4A2C2A)),
                                        const SizedBox(width: 8),
                                        Text("Navigate", style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF4A2C2A))),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Order Items Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Order #$orderId",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4A2C2A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD1CC).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${items.length} Items",
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD35400),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Items list
                    if (items.isNotEmpty)
                      ...items.map((item) => _buildOrderItem(item))
                    else
                      ...[
                        _buildOrderItem({'name': 'Truffle Risotto', 'quantity': 1, 'notes': 'Extra parmesan on the side.'}),
                        _buildOrderItem({'name': 'Wagyu Beef Tartare', 'quantity': 1, 'notes': 'Keep cold.'}),
                        _buildOrderItem({'name': 'San Pellegrino (Large)', 'quantity': 1, 'notes': 'Chilled.'}),
                      ],

                    const SizedBox(height: 30),

                    // Mark as Picked Up Button
                    GestureDetector(
                      onTap: _markAsPickedUp,
                      child: Container(
                        width: double.infinity,
                        height: 65,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD35400), Color(0xFFE67E22)],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD35400).withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 22),
                            const SizedBox(width: 12),
                            Text(
                              "Mark as Picked Up",
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Item';
    final notes = item['notes'] ?? item['specialInstructions'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFFFD1CC), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A2C2A),
                  ),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notes is String ? notes : notes.toString(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4A2C2A).withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
