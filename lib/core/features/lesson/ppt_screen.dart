import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PPTScreen extends StatefulWidget {
  const PPTScreen({super.key});

  @override
  State<PPTScreen> createState() => _PPTScreenState();
}

class _PPTScreenState extends State<PPTScreen> {
  String? localPath;
  int totalPages = 0;
  int currentPage = 0;
  PDFViewController? controller;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  /// 🔥 LOAD PDF DARI ASSETS KE FILE
  Future<void> loadPdf() async {
    final bytes = await rootBundle.load('assets/ppt/materi.pdf');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/materi.pdf');

    await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Materi PPT"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),

      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [

                /// 📄 PDF VIEW
                PDFView(
                  filePath: localPath!,
                  enableSwipe: true,
                  swipeHorizontal: true,
                  autoSpacing: true,
                  pageFling: true,

                  onRender: (pages) {
                    setState(() {
                      totalPages = pages ?? 0;
                    });
                  },

                  onViewCreated: (PDFViewController vc) {
                    controller = vc;
                  },

                  onPageChanged: (page, total) {
                    setState(() {
                      currentPage = page ?? 0;
                    });
                  },
                ),

                /// 🔢 PAGE INDICATOR
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${currentPage + 1} / $totalPages",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                /// ⬅️➡️ NAV BUTTON
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      /// PREV
                      FloatingActionButton(
                        heroTag: "prev",
                        backgroundColor: Colors.deepPurple,
                        onPressed: () async {
                          if (controller != null && currentPage > 0) {
                            controller!.setPage(currentPage - 1);
                          }
                        },
                        child: const Icon(Icons.arrow_back),
                      ),

                      /// NEXT
                      FloatingActionButton(
                        heroTag: "next",
                        backgroundColor: Colors.deepPurple,
                        onPressed: () async {
                          if (controller != null &&
                              currentPage < totalPages - 1) {
                            controller!.setPage(currentPage + 1);
                          }
                        },
                        child: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}