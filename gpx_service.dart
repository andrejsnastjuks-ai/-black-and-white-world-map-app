import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/track_point.dart';
import '../models/trip.dart';

class GpxService {
  static Future<File> buildFile(Trip trip, List<TrackPoint> points) async {
    final dir = await getTemporaryDirectory();
    final safeName = trip.name.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    final file = File('${dir.path}/$safeName.gpx');
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<gpx version="1.1" creator="Black World Map">')
      ..writeln('<trk><name>${_escape(trip.name)}</name><trkseg>');
    for (final p in points) {
      buffer.writeln('<trkpt lat="${p.latitude}" lon="${p.longitude}"><time>${p.recordedAt.toUtc().toIso8601String()}</time></trkpt>');
    }
    buffer.writeln('</trkseg></trk></gpx>');
    return file.writeAsString(buffer.toString());
  }

  static Future<void> share(Trip trip, List<TrackPoint> points) async {
    final file = await buildFile(trip, points);
    await Share.shareXFiles([XFile(file.path)], subject: 'GPX: ${trip.name}');
  }

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
