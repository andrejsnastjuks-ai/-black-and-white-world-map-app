import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../models/discovered_cell.dart';
import '../services/fog_grid_service.dart';

class FogOverlay extends StatelessWidget {
  const FogOverlay({super.key, required this.cells});

  final List<DiscoveredCell> cells;

  @override
  Widget build(BuildContext context) {
    return PolygonLayer(
      polygons: [
        Polygon(
          points: const [],
          color: Colors.transparent,
        ),
        ...cells.map(
          (cell) => Polygon(
            points: FogGridService.polygonForCell(cell),
            color: Colors.transparent,
            borderColor: Colors.greenAccent.withOpacity(0.18),
            borderStrokeWidth: 0.4,
          ),
        ),
      ],
    );
  }
}
