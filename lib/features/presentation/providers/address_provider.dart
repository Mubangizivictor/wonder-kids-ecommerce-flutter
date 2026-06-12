import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  final Box<AddressModel> _addressBox = Hive.box<AddressModel>('addresses_box');

  List<AddressModel> get addresses => _addressBox.values.toList();

  void addAddress(AddressModel address) {
    if (address.isDefault) {
      _clearDefaults();
    }
    _addressBox.put(address.id, address);
    notifyListeners();
  }

  void deleteAddress(String id) {
    _addressBox.delete(id);
    notifyListeners();
  }

  void updateAddress(AddressModel updatedAddress) {
    if (updatedAddress.isDefault) {
      _clearDefaults();
    }
    _addressBox.put(updatedAddress.id, updatedAddress);
    notifyListeners();
  }

  void setDefaultAddress(String id) {
    _clearDefaults();
    final address = _addressBox.get(id);
    if (address != null) {
      _addressBox.put(id, address.copyWith(isDefault: true));
    }
    notifyListeners();
  }

  void _clearDefaults() {
    for (var key in _addressBox.keys) {
      final address = _addressBox.get(key);
      if (address != null && address.isDefault) {
        _addressBox.put(key, address.copyWith(isDefault: false));
      }
    }
  }
}
