import 'package:flutter/material.dart';
import 'package:ivorek_machine_test/app/presentation/feature_basic_level/feature_q1_q2_q3/basic_map_with_marker.dart';
import 'package:ivorek_machine_test/app/presentation/feature_basic_level/feature_q4/highlighted_area_map.dart';
import 'package:ivorek_machine_test/app/presentation/feature_advance_level/feature_q2/interactive_higlight_area_map.dart';
import 'package:ivorek_machine_test/app/presentation/feature_advance_level/feature_q3/map_with_interactive_gif_marker.dart';
import 'package:ivorek_machine_test/app/presentation/feature_advance_level/feature_q2/map_with_interactive_line_marker.dart';
import 'package:ivorek_machine_test/app/presentation/feature_advance_level/feature_q1/map_with_interactive_markers.dart';
import 'package:ivorek_machine_test/app/presentation/feature_basic_level/feature_q4/map_with_polylines.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const BasicMapWithMarker(),
                  )),
              child: const Text(
                  "Question 1 - 1,2,3: Add a Mapbox Map and Add a marker to the map created.")),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const HighlightedAreaMap(),
                  )),
              child: const Text("Question 1 - 4:Add Area Highlight,")),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MapWithPolyLines(),
                  )),
              child: const Text("Question 1 - 4: Add Lines")),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MapWithInteractiveMarkers(),
                  )),
              child:
                  const Text("Question 2 - 1: Interactive Marker Placement")),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MapWithInteractiveLineMarker(),
                  )),
              child: const Text("Question 2 - 2: Interactively Draw Lines,")),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const InteractiveHiglightAreaMap(),
                  )),
              child: const Text("Question 2-4: Interactively Highlight area")),
          const SizedBox(
            height: 20,
          ),
          TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const MapWithInteractiveGifMarker(),
                  )),
              child: const Text("Question 2-3: Gif Marker")),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    ));
  }
}
