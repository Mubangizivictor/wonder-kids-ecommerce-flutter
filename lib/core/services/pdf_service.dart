import 'dart:typed_data';
import 'package:ecom/features/domain/models/order_model.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndPrintReceipt(OrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('WONDER KIDS', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                        pw.Text('Uganda\'s Premium Kids Store'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Order #${order.id.substring(0, 8)}'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),
                
                // Details
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(order.shippingAddress),
                          pw.Text('Payment: ${order.paymentMethod}'),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Date:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(DateFormat('MMM dd, yyyy').format(order.orderDate)),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 32),

                // Table
                pw.TableHelper.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headers: ['Item', 'Quantity', 'Unit Price', 'Total'],
                  data: order.items.map((item) {
                    return [
                      item.product.title,
                      item.quantity.toString(),
                      'UGX ${NumberFormat('#,###').format(item.product.discountedPrice)}',
                      'UGX ${NumberFormat('#,###').format(item.product.discountedPrice * item.quantity)}',
                    ];
                  }).toList(),
                ),
                
                pw.Divider(),
                
                // Totals
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisSize: pw.MainAxisSize.min,
                        children: [
                          pw.Text('Total Amount: ', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text('UGX ${NumberFormat('#,###').format(order.totalAmount)}', 
                              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue700)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                pw.Spacer(),
                
                // Footer
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('Thank you for shopping with Wonder Kids!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                      pw.Text('For inquiries, contact: +256 700 000000'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'receipt_${order.id.substring(0, 8)}.pdf',
    );
  }
}
