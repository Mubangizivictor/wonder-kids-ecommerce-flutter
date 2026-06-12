import 'package:ecom/features/domain/models/address_model.dart';
import 'package:ecom/features/presentation/providers/address_provider.dart';
import 'package:ecom/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:ecom/shared_widgets/custom_outline_button.dart';
import 'widgets/address_card.dart';

class ShippingAddressesScreen extends StatefulWidget {
  const ShippingAddressesScreen({super.key});

  @override
  State<ShippingAddressesScreen> createState() =>
      _ShippingAddressesScreenState();
}

class _ShippingAddressesScreenState extends State<ShippingAddressesScreen> {
  Future<void> _getCurrentLocation(
    TextEditingController addressController,
    TextEditingController cityController,
    Function(bool) setModalState,
  ) async {
    setModalState(true);
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        addressController.text =
            '${place.street ?? ''}, ${place.subLocality ?? ''}';
        cityController.text = '${place.locality ?? ''}, ${place.country ?? ''}';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setModalState(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.shippingAddresses),
      ),
      body: addressProvider.addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.mapPin,
                    size: 64,
                    color: Colors.grey.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noAddressesSaved,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: CustomOutlineButton(
                      onPressed: () => _showAddressSheet(context),
                      text: AppLocalizations.of(context)!.addNewAddress,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addressProvider.addresses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final address = addressProvider.addresses[index];
                      return AddressCard(
                        label: address.label,
                        name: address.name,
                        address: address.address,
                        city: address.city,
                        phone: address.phone,
                        isDefault: address.isDefault,
                        onEdit: () =>
                            _showAddressSheet(context, address: address),
                        onDelete: () =>
                            _showDeleteConfirmation(context, address.id),
                        onTap: () {
                          if (!address.isDefault) {
                            addressProvider.setDefaultAddress(address.id);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  CustomOutlineButton(
                    onPressed: () => _showAddressSheet(context),
                    text: AppLocalizations.of(context)!.addNewAddress,
                  ),
                ],
              ),
            ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String addressId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAddress),
        content: Text(l10n.deleteAddressConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<AddressProvider>().deleteAddress(addressId);
              Navigator.pop(context);
            },
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddressSheet(BuildContext context, {AddressModel? address}) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = address != null;
    final labelController = TextEditingController(text: address?.label);
    final nameController = TextEditingController(text: address?.name);
    final addressController = TextEditingController(text: address?.address);
    final cityController = TextEditingController(text: address?.city);
    final phoneController = TextEditingController(text: address?.phone);
    bool isDefault = address?.isDefault ?? false;
    bool modalLocating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsetsDirectional.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            start: 24,
            end: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? l10n.editAddress : l10n.addNewAddress,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isEditing)
                      TextButton.icon(
                        onPressed: modalLocating
                            ? null
                            : () => _getCurrentLocation(
                                addressController,
                                cityController,
                                (val) =>
                                    setModalState(() => modalLocating = val),
                              ),
                        icon: modalLocating
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(LucideIcons.locateFixed, size: 16),
                        label: Text(
                          l10n.locateMe,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(l10n.addressLabelHint, labelController),
                const SizedBox(height: 16),
                _buildTextField(l10n.fullName, nameController),
                const SizedBox(height: 16),
                _buildTextField(l10n.address, addressController),
                const SizedBox(height: 16),
                _buildTextField(l10n.city, cityController),
                const SizedBox(height: 16),
                _buildTextField(l10n.phoneNumber, phoneController),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: isDefault,
                      onChanged: (v) =>
                          setModalState(() => isDefault = v ?? false),
                    ),
                    Text(l10n.setAsDefaultAddress),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (labelController.text.isEmpty ||
                        nameController.text.isEmpty) {
                      return;
                    }

                    final newAddress = AddressModel(
                      id: isEditing
                          ? address.id
                          : DateTime.now().millisecondsSinceEpoch.toString(),
                      label: labelController.text,
                      name: nameController.text,
                      address: addressController.text,
                      city: cityController.text,
                      phone: phoneController.text,
                      isDefault: isDefault,
                    );

                    if (isEditing) {
                      context.read<AddressProvider>().updateAddress(newAddress);
                    } else {
                      context.read<AddressProvider>().addAddress(newAddress);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(isEditing ? l10n.saveChanges : l10n.addAddress),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
