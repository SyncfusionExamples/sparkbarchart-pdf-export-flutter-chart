/// Dart import
import 'dart:async';
import 'dart:io';
import 'dart:ui' as dart_ui;

/// Package imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

/// Pdf import
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// open file library import
import 'package:open_file/open_file.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExportSparkChart(),
    );
  }
}

final GlobalKey<_SparkBarChartState> chartKey = GlobalKey();

///Export spark chart class
class ExportSparkChart extends StatefulWidget {
  const ExportSparkChart({Key? key}) : super(key: key);

  @override
  _ExportSparkChartState createState() => _ExportSparkChartState();
}

class _ExportSparkChartState extends State<ExportSparkChart> {
  _ExportSparkChartState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Spark Chart Export'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: <
                  Widget>[
            Expanded(
                child: SparkBarChart(
              key: chartKey,
            )),
            const SizedBox(
              height: 50,
            ),
            Container(
                width: 110,
                color: Colors.green,
                child: IconButton(
                  onPressed: () {
                    /// Snackbar messanger to indicate that the spark chart is being exported as PDF
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(milliseconds: 2000),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      content:
                          Text('Spark Chart is being exported as PDF document'),
                    ));
                    _renderPdf();
                  },
                  icon: Row(
                    children: const <Widget>[
                      Icon(Icons.picture_as_pdf, color: Colors.black),
                      Text('Export to pdf'),
                    ],
                  ),
                )),
          ]),
        ));
  }

  Future<void> _renderPdf() async {
    // Create a new PDF document.
    final PdfDocument document = PdfDocument();
    // Create a pdf bitmap for the rendered spark chart image.
    final PdfBitmap bitmap = PdfBitmap(await _readImageData());
    // set the necessary page settings for the pdf document such as margin, size etc..
    document.pageSettings.margins.all = 0;
    document.pageSettings.size =
        Size(bitmap.width.toDouble(), bitmap.height.toDouble());
    // Create a PdfPage page object and assign the pdf document's pages to it.
    final PdfPage page = document.pages.add();
    // Retrieve the pdf page client size
    final Size pageSize = page.getClientSize();
    // Draw an image into graphics using the bitmap.
    page.graphics.drawImage(
        bitmap, Rect.fromLTWH(0, 0, pageSize.width, pageSize.height));

    // Snackbar indication for chart export operation
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5))),
      duration: Duration(milliseconds: 200),
      content: Text('Spark Chart has been exported as PDF document.'),
    ));
    //Save and dispose the document.
    final List<int> bytes = document.save();
    document.dispose();

    //Get the external storage directory.
    Directory directory = (await getApplicationDocumentsDirectory());
    //Get the directory path.
    String path = directory.path;
    //Create an empty file to write the PDF data.
    File file = File('$path/output.pdf');
    //Write the PDF data.
    await file.writeAsBytes(bytes, flush: true);
    //Open the PDF document on mobile.
    OpenFile.open('$path/output.pdf');
  }

  /// Method to read the rendered spark bar chart image and return the image data for processing.
  Future<List<int>> _readImageData() async {
    final dart_ui.Image data =
        await chartKey.currentState!.convertToImage(pixelRatio: 3.0);
    final ByteData? bytes =
        await data.toByteData(format: dart_ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
  }
}

class SparkBarChart extends StatefulWidget {
  const SparkBarChart({Key? key}) : super(key: key);

  @override
  _SparkBarChartState createState() => _SparkBarChartState();
}

class _SparkBarChartState extends State<SparkBarChart> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SfSparkBarChart(
        axisLineWidth: 0,
        data: const <double>[
          5,
          6,
          5,
          7,
          4,
          3,
          9,
          5,
          6,
          5,
          7,
          8,
          4,
          5,
          3,
          4,
          11,
          10,
          2,
          12,
          4,
          7,
          6,
          8
        ],
        highPointColor: Colors.red,
        lowPointColor: Colors.red,
        firstPointColor: Colors.orange,
        lastPointColor: Colors.orange,
      ),
    );
  }

  Future<dart_ui.Image> convertToImage({double pixelRatio = 1.0}) async {
    // Get the render object from context and store in the RenderRepaintBoundary onject.
    final RenderRepaintBoundary boundary =
        context.findRenderObject() as RenderRepaintBoundary;

    // Convert the repaint boundary as image
    final dart_ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);

    return image;
  }
}
