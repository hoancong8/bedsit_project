import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // 1. Kiểm tra xem dịch vụ GPS có bật chưa
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Dịch vụ định vị chưa bật.');
  }

  // 2. Kiểm tra quyền truy cập vị trí
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Bạn đã từ chối quyền truy cập vị trí.');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Quyền bị từ chối vĩnh viễn
    return Future.error('Không thể truy cập vị trí do quyền bị từ chối vĩnh viễn.');
  }

  // 3. Lấy vị trí hiện tại
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}
void _getLocation() async {
  try {
    Position position = await _determinePosition();
    print("Vĩ độ: ${position.latitude}, Kinh độ: ${position.longitude}");
  } catch (e) {
    print("Lỗi: $e");
  }
}
Future<void> getAddressFromLatLong(Position position) async {
  List<Placemark> placemarks =
  await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark place = placemarks[0];
  String address =
      '${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}';
  print("Địa chỉ: $address");
}

void _getFullAddress() async {
  Position pos = await _determinePosition();
  await getAddressFromLatLong(pos);
}
