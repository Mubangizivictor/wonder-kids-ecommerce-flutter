import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:ecom/features/domain/models/cart_item_model.dart';

class WhatsAppHelper {
  static const String phoneNumber = '+256740116746';

  static Future<void> launchWhatsAppOrder({
    required List<CartItemModel> items,
    required double total,
    required double delivery,
    String? address,
  }) async {
    String message = "Hello Wonder Kids! I'd like to place an order:\n\n";
    
    for (var item in items) {
      String variantInfo = "";
      if (item.selectedColor != null || item.selectedSize != null) {
        variantInfo = " (";
        if (item.selectedColor != null) variantInfo += "${item.selectedColor}";
        if (item.selectedColor != null && item.selectedSize != null) variantInfo += ", ";
        if (item.selectedSize != null) variantInfo += "${item.selectedSize}";
        variantInfo += ")";
      }
      message += "• ${item.product.title}$variantInfo (x${item.quantity}) - UGX ${item.product.discountedPrice.toInt()}\n";
    }

    message += "\nSubtotal: UGX ${(total - delivery).toInt()}";
    message += "\nDelivery: UGX ${delivery.toInt()}";
    message += "\n*Total Amount: UGX ${total.toInt()}*";

    if (address != null) {
      message += "\n\n*Shipping Address:* $address";
    }
    
    final encodedMessage = Uri.encodeComponent(message);
    Uri url;
    
    if (Platform.isAndroid) {
      url = Uri.parse("whatsapp://send?phone=$phoneNumber&text=$encodedMessage");
    } else {
      url = Uri.parse("https://wa.me/$phoneNumber?text=$encodedMessage");
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      // Fallback to web link if app isn't installed
      final webUrl = Uri.parse("https://wa.me/$phoneNumber?text=$encodedMessage");
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
