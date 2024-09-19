import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:testing/utils/permission_services.dart';
import 'package:testing/utils/value_transitioned_builder.dart';

import 'globe_view.dart';
import 'map_view.dart';

const String mapboxToken = String.fromEnvironment("mapbox_token");

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken(mapboxToken);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    PermissionServices.requestPermission(RequestResource.locationWhenInUse);
  }

  @override
  Widget build(BuildContext context) {
    const views = {
      0: MapView(),
      1: GlobeView(),
    };
    return ValueTransitionedBuilder<int>(
      initialValue: 0,
      builder: (context, index, __, update, _) {
        return Scaffold(
          body: views[index]!,
          bottomNavigationBar: BottomNavigationBar(
            onTap: update,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
              BottomNavigationBarItem(icon: Icon(Icons.circle), label: "Globe"),
            ],
          ),
        );
      },
    );
  }
}
