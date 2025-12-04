class CourtModel {
  final String id;
  final String name;
  final String type; // 'indoor' or 'outdoor'
  final String size; // 'single' or 'double'
  final String status;
  final String? description;
  final String? imageUrl;
  final int displayOrder;

  CourtModel({
    required this.id,
    required this.name,
    required this.type,
    required this.size,
    required this.status,
    this.description,
    this.imageUrl,
    required this.displayOrder,
  });

  factory CourtModel.fromJson(Map<String, dynamic> json) {
    // Handle size field - may not exist in database yet or be null
    final sizeValue = json['size'];
    final size = sizeValue != null && sizeValue is String 
        ? sizeValue 
        : 'double'; // Default to 'double' if null or missing
    
    return CourtModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      size: size,
      status: json['status'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  bool get isIndoor => type == 'indoor';
  bool get isOutdoor => type == 'outdoor';
  bool get isSingle => size == 'single';
  bool get isDouble => size == 'double';
  bool get isActive => status == 'active';
}

