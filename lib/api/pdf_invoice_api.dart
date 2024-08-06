import 'package:flutter/services.dart';
import 'package:inventory_management/api/pdf_api.dart';
import 'package:inventory_management/db/data_models.dart';
import 'package:inventory_management/exports/exports.dart';
import 'package:inventory_management/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceApi {
  static Future<void> generate(Invoice invoice) async {
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(
        await rootBundle.load("fonts/OpenSans-Regular.ttf"),
      ),
      bold: pw.Font.ttf(
        await rootBundle.load("fonts/OpenSans-Bold.ttf"),
      ),
      italic: pw.Font.ttf(
        await rootBundle.load("fonts/OpenSans-Italic.ttf"),
      ),
      boldItalic: pw.Font.ttf(
        await rootBundle.load("fonts/OpenSans-BoldItalic.ttf"),
      ),
    );

    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
          build: (context) => [
                buildHeader(invoice),
                pw.SizedBox(height: 3 * PdfPageFormat.cm),
                buildTitle(),
                buildInvoice(invoice),
                pw.Divider(),
                buildTotal(invoice),
              ],
          footer: (context) => buildFooter(invoice)),
    );

    final pdfBytes = await pdf.save();
    final pdfApi = PdfApi();
    await pdfApi.savePDF(
      name: 'new_invoice.pdf',
      bytes: pdfBytes,
    );
  }

  static pw.Widget buildTitle() => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INVOICE',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
          pw.Text('new text'),
          pw.SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  static pw.Widget buildInvoice(Invoice invoice) {
    final headers = [
      'Description',
      'Date',
      'Quantity',
      'Unit Price',
      'VAT',
      'Total'
    ];

    final data = invoice.items.map((item) {
      final total = item.unitPrice * item.quantity * (1 + item.vat);

      return [
        item.description,
        Utils.formatDate(item.date),
        '${item.quantity}',
        '\$ ${item.unitPrice}',
        '${item.vat} %',
        '\$ ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      data: data,
      headers: headers,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.center,
        5: pw.Alignment.center,
      },
    );
  }

  static pw.Widget buildTotal(Invoice invoice) {
    final netTotal =
        invoice.items.map((item) => item.unitPrice * item.quantity).reduce(
              (item1, item2) => item1 + item2,
            );
    final vatPercent = invoice.items.first.vat;
    final vat = netTotal * vatPercent;
    final total = netTotal + vat;

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: double.infinity,
                  height: 10,
                ),
                buildText(
                  title: 'Net Total',
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                buildText(
                  title: 'Vat ${vatPercent * 100}%',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                pw.Divider(),
                buildText(
                  title: 'Total Amount Due',
                  titleStyle: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
                pw.SizedBox(height: 2 * PdfPageFormat.mm),
                pw.Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          )
        ],
      ),
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    pw.TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Container(
      width: width,
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(title, style: style)),
          pw.Text(value, style: unite ? style : null),
        ],
      ),
    );
  }

  static pw.Widget buildFooter(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Divider(),
          pw.SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(value: OUR_ADDRESS, title: 'Address'),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          buildSimpleText(value: OUR_WEBSITE, title: 'Website'),
        ],
      );

  static pw.Widget buildSimpleText({
    required String value,
    required String title,
  }) {
    final style = pw.TextStyle(fontWeight: pw.FontWeight.bold);

    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(title, style: style),
        pw.SizedBox(width: 2 * PdfPageFormat.mm),
        pw.Text(value),
      ],
    );
  }

  static pw.Widget buildHeader(Invoice invoice) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              buildSupplierAddress(invoice.supplier),
            ],
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.cm),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(invoice.customer),
              buildInvoiceInfo(invoice.info),
            ],
          ),
        ],
      );

  static pw.Widget buildSupplierAddress(Supplier supplier) => pw.Column(
        children: [
          pw.Text(
            supplier.name,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 1 * PdfPageFormat.mm),
          pw.Text(supplier.address),
        ],
        crossAxisAlignment: pw.CrossAxisAlignment.start,
      );

  static pw.Widget buildCustomerAddress(Customer customer) => pw.Column(
        children: [
          pw.Text(
            customer.name,
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(customer.address),
        ],
      );

  static pw.Widget buildInvoiceInfo(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Terms:',
      'Due Date:'
    ];
    final data = <String>[
      '${info.number}',
      Utils.formatDate(info.date),
      paymentTerms,
      Utils.formatDate(info.dueDate),
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: List.generate(
        titles.length,
        (index) {
          final title = titles[index];
          final value = data[index];

          return buildText(title: title, value: value, width: 200);
        },
      ),
    );
  }
}
