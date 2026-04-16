// lib/models/service_request.dart
class ServiceRequest {
  final String serviceType;
  final String vehicleType;
  final String description;
  final String? imagePath; // optional, if user uploads an image

  ServiceRequest({
    required this.serviceType,
    required this.vehicleType,
    required this.description,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
        "serviceType": serviceType,
        "vehicleType": vehicleType,
        "description": description,
        "imagePath": imagePath,
      };
}
