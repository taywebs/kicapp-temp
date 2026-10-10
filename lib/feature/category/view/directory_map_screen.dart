import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:demandium/utils/core_export.dart';
import 'package:demandium/common/widgets/dir_ui.dart';
import 'package:demandium/feature/category/model/directory_model.dart';

/// Map view of the Explore tab.
///
/// Every listing that has coordinates becomes a marker showing its own photo.
/// Tapping a marker hands the user over to Google Maps for directions.
class DirectoryMapView extends StatefulWidget {
  const DirectoryMapView({super.key, required this.listings});

  final List<DirectoryModel> listings;

  @override
  State<DirectoryMapView> createState() => _DirectoryMapViewState();
}

class _DirectoryMapViewState extends State<DirectoryMapView> {
  /// Downloading and painting one bitmap per listing is not free, so cap it.
  static const int _maxMarkers = 40;
  static const double _markerSize = 132;

  GoogleMapController? _mapController;
  final Set<Marker> _markers = <Marker>{};
  bool _building = true;

  @override
  void initState() {
    super.initState();
    _buildMarkers();
  }

  @override
  void didUpdateWidget(covariant DirectoryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listings.length != widget.listings.length) {
      _buildMarkers();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  List<DirectoryModel> get _located => widget.listings
      .where((DirectoryModel d) =>
          double.tryParse(d.latitude ?? '') != null &&
          double.tryParse(d.longitude ?? '') != null)
      .take(_maxMarkers)
      .toList();

  Future<void> _buildMarkers() async {
    final List<DirectoryModel> located = _located;
    final Set<Marker> built = <Marker>{};

    for (final DirectoryModel listing in located) {
      final double lat = double.parse(listing.latitude!);
      final double lng = double.parse(listing.longitude!);
      final BitmapDescriptor icon = await _photoMarker(listing.bannerUrl);

      built.add(
        Marker(
          markerId: MarkerId(listing.id ?? '$lat,$lng'),
          position: LatLng(lat, lng),
          icon: icon,
          anchor: const Offset(0.5, 1),
          consumeTapEvents: true,
          onTap: () => _openInGoogleMaps(listing, lat, lng),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _markers
        ..clear()
        ..addAll(built);
      _building = false;
    });
    _fitBounds(located);
  }

  /// Paints the listing photo into a rounded card with a pointer beneath it.
  Future<BitmapDescriptor> _photoMarker(String? imageUrl) async {
    ui.Image? photo;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final http.Response response = await http
            .get(Uri.parse(imageUrl))
            .timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) {
          final ui.Codec codec = await ui.instantiateImageCodec(
            response.bodyBytes,
            targetWidth: 160,
          );
          photo = (await codec.getNextFrame()).image;
        }
      } catch (_) {
        // Falls back to the placeholder card below.
      }
    }

    const double w = _markerSize;
    const double h = _markerSize * 1.16;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    const double pad = 5;
    final RRect card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(pad, pad, w - pad * 2, w - pad * 2),
      const Radius.circular(16),
    );

    canvas.drawRRect(
      card.shift(const Offset(0, 2)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawRRect(card, Paint()..color = Colors.white);

    final RRect inner = RRect.fromRectAndRadius(
      Rect.fromLTWH(pad + 3, pad + 3, w - (pad + 3) * 2, w - (pad + 3) * 2),
      const Radius.circular(13),
    );
    canvas.save();
    canvas.clipRRect(inner);
    if (photo != null) {
      canvas.drawImageRect(
        photo,
        Rect.fromLTWH(0, 0, photo.width.toDouble(), photo.height.toDouble()),
        inner.outerRect,
        Paint(),
      );
    } else {
      canvas.drawRect(inner.outerRect, Paint()..color = DirTokens.surfaceHigh);
    }
    canvas.restore();

    // Pointer
    final Path pointer = Path()
      ..moveTo(w / 2 - 9, w - pad - 1)
      ..lineTo(w / 2 + 9, w - pad - 1)
      ..lineTo(w / 2, h - 2)
      ..close();
    canvas.drawPath(pointer, Paint()..color = Colors.white);

    final ui.Image rendered =
        await recorder.endRecording().toImage(w.toInt(), h.toInt());
    final ByteData? bytes =
        await rendered.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return BitmapDescriptor.defaultMarker;
    return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
  }

  Future<void> _fitBounds(List<DirectoryModel> located) async {
    if (_mapController == null || located.isEmpty) return;
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final DirectoryModel d in located) {
      final double lat = double.parse(d.latitude!);
      final double lng = double.parse(d.longitude!);
      minLat = lat < minLat ? lat : minLat;
      maxLat = lat > maxLat ? lat : maxLat;
      minLng = lng < minLng ? lng : minLng;
      maxLng = lng > maxLng ? lng : maxLng;
    }
    if (located.length == 1) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 14),
      );
      return;
    }
    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }

  Future<void> _openInGoogleMaps(DirectoryModel listing, double lat, double lng) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        customSnackBar('could_not_open_maps'.tr);
      }
    } catch (_) {
      customSnackBar('could_not_open_maps'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DirectoryModel> located = _located;

    if (!_building && located.isEmpty) {
      return DirEmptyState(
        icon: Icons.map_outlined,
        title: 'no_listings_on_map'.tr,
        message: 'no_listings_on_map_desc'.tr,
      );
    }

    final LatLng initial = located.isEmpty
        ? const LatLng(25.2048, 55.2708) // Dubai, until listings arrive
        : LatLng(double.parse(located.first.latitude!),
            double.parse(located.first.longitude!));

    return Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition: CameraPosition(target: initial, zoom: 12),
          markers: _markers,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _fitBounds(located);
          },
        ),
        if (_building)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x66FFFFFF),
              child: Center(child: CircularProgressIndicator(color: DirTokens.primary)),
            ),
          ),
        PositionedDirectional(
          bottom: 16,
          start: 16,
          end: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: DirTokens.surface,
              borderRadius: BorderRadius.circular(DirTokens.radius),
              border: Border.all(color: DirTokens.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.touch_app_outlined, size: 18, color: DirTokens.secondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'tap_marker_for_directions'.tr,
                      style: const TextStyle(fontSize: 12, color: DirTokens.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
