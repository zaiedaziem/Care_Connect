class Doctor {
  final int id;
  final String name;
  final String specialty;
  final String imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });

  // For Firestore deserialization
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialty: json['specialty'],
      imageUrl: json['imageUrl'],
    );
  }

  // For Firestore serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'imageUrl': imageUrl,
    };
  }

  // Optional: create a copy with new values
  Doctor copyWith({
    int? id,
    String? name,
    String? specialty,
    String? imageUrl,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
