import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FileViewerScreen extends StatelessWidget {
  final String fileUrl;
  final String fileName;

  FileViewerScreen({super.key, required this.fileUrl, required this.fileName});

  final RxString fileContent = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  Widget build(BuildContext context) {
    _fetchFileContent();

    return Scaffold(
      appBar: AppBar(title: Text(fileName), actions: [
        IconButton(
          icon: Icon(Icons.copy),
          onPressed: () {
            Get.snackbar("Copied", "File content copied to clipboard");
          },
        )
      ]),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: SelectableText(fileContent.value),
        );
      }),
    );
  }

  void _fetchFileContent() async {
    try {
      final response = await http.get(Uri.parse(fileUrl));
      if (response.statusCode == 200) {
        fileContent.value = response.body;
      } else {
        fileContent.value = "Error loading file.";
      }
    } catch (e) {
      fileContent.value = "Failed to load file.";
    }
    isLoading.value = false;
  }
}
