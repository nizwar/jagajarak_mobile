import 'package:geolocator/geolocator.dart';

import 'model.dart';

class LocationData extends Model {
  String name;
  String longAddress;

  LocationData({this.name, this.longAddress});

  static Future<LocationData> currentLocation() async {
    Geolocator geo = Geolocator();
    var resp = await geo.getCurrentPosition();
    if (resp == null) return null;

    var address = await geo.placemarkFromCoordinates(resp.latitude, resp.longitude);
    var knownAddress = address.first;
    return LocationData(
      longAddress:
          "${knownAddress?.name ?? "Tidak Diketahui"}, ${knownAddress?.subLocality ?? " - "}, ${knownAddress?.locality ?? " - "},${knownAddress?.subAdministrativeArea ?? " - "},${knownAddress?.administrativeArea ?? " - "}",
      name: knownAddress?.name ?? "Tidak diketahui",
    );
  }

  @override
  Map<String, dynamic> toJson() => {};
}
