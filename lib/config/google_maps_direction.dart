import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_parcial2/config/google_maps_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as locationA;

class GoogleMapsView extends StatefulWidget {
  final CameraPosition? ventaPosition;
  final Future<void> Function(
          double coordenadaX, double coordenadaY, String calle1, String calle2)
      getDatosGeograficosCallBack;
  final double height;
  final EdgeInsetsGeometry padding;
  const GoogleMapsView(
      {super.key,
      required this.getDatosGeograficosCallBack,
      this.height = 400,
      this.padding = const EdgeInsets.symmetric(horizontal: 10),
      this.ventaPosition});

  @override
  State<GoogleMapsView> createState() => _GoogleMapsViewState();
}

class _GoogleMapsViewState extends State<GoogleMapsView> {
  Future<bool>? _locationPermissionFuture;
  Marker? onPressedMarker;
  locationA.LocationData? currentLocation;
  // late DireccionProvider mapsProvidder;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static CameraPosition? initPosition;
  static const CameraPosition _asuncionPosition = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(-25.285216, -57.638537),
      // tilt: 59.440717697143555,
      zoom: 12.4746);
  Set<Polygon> _poligonos = {};

  @override
  void initState() {
    super.initState();
    // getPoligonos();
    // _locationPermissionFuture =
    //     GoogleMapsController().requestLocationPermission();

    initPosition = widget.ventaPosition ?? _asuncionPosition;
     _setInitPosition();

    // mapsProvidder = Provider.of<DireccionProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation != null) {
      initPosition = CameraPosition(
        target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        zoom: 12.4746,
      );
      setState(() {});
    }
    return SizedBox(
        height: widget.height,
        child: Container(
          padding: widget.padding,
          child: GoogleMap(
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            mapToolbarEnabled: true,
            // const LatLng(-25.343859,-57.581763 )
            onTap: (pressedLocation) {
              if (widget.ventaPosition != null) {
                return;
              }
              onPressed(pressedLocation);
            },
            markers: onPressedMarker != null ? {onPressedMarker!} : {},
            myLocationEnabled: true,
            mapType: MapType.normal,
            initialCameraPosition: initPosition!,
            onMapCreated: (controller) {
              _controller.complete(controller);
            },
            polygons: _poligonos,
            // onTap: (argument) => mapsProvidder.mapScrollingEnabled = true,
            // onCameraMove: (location) => onPressed(location.target),
            // habilitar map scrolling al arrastrar el mapa
          ),
        ));
  }

  void onPressed(LatLng pressedLocation) async {
    String calle1 = "";
    String calle2 = "";
    try {
      widget.getDatosGeograficosCallBack(
          pressedLocation.longitude, pressedLocation.latitude, calle1, calle2);
    } catch (e) {
      print("Error al formatear la direccion");
    }
    onPressedMarker = Marker(
      markerId: const MarkerId('onPressLocation'),
      position: pressedLocation,
      infoWindow: const InfoWindow(
        title: 'Marcador',
        snippet: 'Marcador de prueba',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    );
    setState(() {});
  }

  void _setInitPosition() async {
    try {
      final currentPositionDevice = await GoogleMapsController()
          .getCurrentLocation(); // ubicacion del dispositivo

      if (currentPositionDevice != null) {
        currentLocation = currentPositionDevice;
        initPosition = widget.ventaPosition ?? CameraPosition(
          target:
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 12.4746,
        );

        // se establece la ubicacion en el mapa simulando el evento de presionar
        onPressed( widget.ventaPosition?.target ?? LatLng(
            currentPositionDevice.latitude!, currentPositionDevice.longitude!));

        _controller.future.then((controller) {
          controller
              .animateCamera(CameraUpdate.newCameraPosition(initPosition!));
        });
      } else {
        initPosition = _asuncionPosition;
      }
    } catch (e) {
      print(e);
      initPosition = _asuncionPosition;
    }

    setState(() {});
  }

  void getPoligonos() async {
    String jsonString = await rootBundle.loadString('assets/data/geojson.json');

    // Decodificar la cadena JSON a un mapa
    Map<String, dynamic> data = jsonDecode(jsonString);

    Set<Polygon> poligonos = {};

    // Iterar sobre los polígonos
    for (var poligono in data['features']) {
      List<LatLng> puntos = [];
      if (poligono['geometry']['type'] == 'Polygon') {
        // Iterar sobre los puntos del polígono
        for (var punto in poligono['geometry']['coordinates'][0]) {
          puntos.add(LatLng((punto[1] as double), punto[0] as double));
        }
        if (puntos.isEmpty) {
          continue;
        }
        // Crear un polígono
        poligonos.add(Polygon(
          polygonId: PolygonId(poligono['properties']['name']),
          points: puntos,
          strokeWidth: 2,
          strokeColor: Colors.blue.withOpacity(0.5),
          fillColor: Colors.blue.withOpacity(0.2),
        ));
      }
    }
    setState(() {
      _poligonos = poligonos;
    });
  }
}
