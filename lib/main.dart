import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ivorek_machine_test/app.dart';
import 'package:ivorek_machine_test/app/utils/resources.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(AppResources().mapBoxKey);
  runApp(const IvorekMachineTest());
}
