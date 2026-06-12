import 'package:hive/hive.dart';

part 'address_model.g.dart';

@HiveType(typeId: 6)
class AddressModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String label;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String address;
  @HiveField(4)
  final String city;
  @HiveField(5)
  final String phone;
  @HiveField(6)
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.label,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? label,
    String? name,
    String? address,
    String? city,
    String? phone,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
