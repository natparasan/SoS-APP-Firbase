/// Represents a single emergency contact that should receive
/// an SOS alert when the user triggers it.
class EmergencyContact {
  final String name;
  final String phoneNumber;

  const EmergencyContact({
    required this.name,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );
  }

  @override
  String toString() => '$name ($phoneNumber)';
}
