import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:listar_flutter_pro/models/model.dart';
import 'package:listar_flutter_pro/repository/repository.dart';
import 'package:listar_flutter_pro/utils/utils.dart';
import 'package:listar_flutter_pro/widgets/widget.dart';

class GPSPicker extends StatefulWidget {
  final GPSModel? picked;

  const GPSPicker({Key? key, this.picked}) : super(key: key);

  @override
  State<GPSPicker> createState() {
    return _GPSPickerState();
  }
}

class _GPSPickerState extends State<GPSPicker> {
  CameraPosition _initPosition = const CameraPosition(
    target: LatLng(37.3325932, -121.9129757),
    zoom: 16,
  );
  Map<MarkerId, Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadGPS();
    if (widget.picked != null) {
      _onSetMarker(
        latitude: widget.picked!.latitude,
        longitude: widget.picked!.longitude,
        title: widget.picked!.name ?? '',
      );
    }
  }

  void _loadGPS() async {
    final GPSModel? gpsData = await GpsRepository.fetchGPSData();

    if (gpsData != null) {
      setState(() {
        _initPosition = CameraPosition(
          target: LatLng(gpsData.latitude, gpsData.longitude),
          zoom: gpsData.zoom ?? 0.0,
        );
        _onSetMarker(
          latitude: gpsData.latitude,
          longitude: gpsData.longitude,
          title: gpsData.name ?? '',
          zoom: gpsData.zoom
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  ///On Apply
  void _onApply() {
    if (_markers.values.isNotEmpty) {
      final position = _markers.values.first.position;
      final item = GPSModel(
        editable: true,
        longitude: position.longitude,
        latitude: position.latitude,
      );
      Navigator.pop(context, item);
    }
  }

  ///On set marker
  void _onSetMarker({
    required double latitude,
    required double longitude,
    required String title,
    double? zoom,
  }) async {
    Map<MarkerId, Marker> markers = {};
    final markerId = MarkerId('$latitude/$longitude');
    final position = LatLng(latitude, longitude);
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title),
    );

    markers[markerId] = marker;
    setState(() {
      _markers = markers;
    });
    await Future.delayed(const Duration(milliseconds: 250));
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          tilt: 30.0,
          zoom: zoom ?? 15.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    bool editable = widget.picked == null || widget.picked?.editable == true;

    if (editable) {
      actions = [
        AppButton(
          Translate.of(context).translate('apply'),
          onPressed: _onApply,
          type: ButtonType.text,
        )
      ];
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          Translate.of(context).translate('location'),
        ),
        actions: actions,
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: _initPosition,
        markers: Set<Marker>.of(_markers.values),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onTap: (item) {
          if (editable) {
            _onSetMarker(
              latitude: item.latitude,
              longitude: item.longitude,
              title: '${item.latitude}/${item.longitude}',
            );
          }
        },
      ),
    );
  }
}
