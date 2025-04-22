// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/repo_controllers.dart';
import 'fileview_screen.dart';

class RepoContentsScreen extends StatefulWidget {
  final String username;
  final String repoName;
  final String path;

  const RepoContentsScreen({
    super.key,
    required this.username,
    required this.repoName,
    this.path = '',
  });

  @override
  _RepoContentsScreenState createState() => _RepoContentsScreenState();
}

class _RepoContentsScreenState extends State<RepoContentsScreen> {
  final GitHubController controller = Get.find();
  String? errorMessage;

  bool isCodeFile(String fileName) {
    final codeExtensions = [
      '.dart', '.js', '.ts', '.py', '.java', '.cpp', '.c', '.h', '.hpp',
      '.cs', '.go', '.rb', '.php', '.swift', '.kt', '.kts', '.rs', '.sh',
      '.html', '.css', '.scss', '.json', '.xml', '.yaml', '.yml', '.md'
    ];
    return codeExtensions.any((ext) => fileName.toLowerCase().endsWith(ext));
  }

  Future<void> openInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Get.snackbar('Error', 'Could not open the file in browser');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.username.isEmpty) {
      errorMessage = 'Username is required';
      return;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.repoContents.clear();
      _fetchContents();
    });
  }

  Future<void> _fetchContents() async {
    try {
      await controller.getRepoContents(widget.username, widget.repoName, widget.path);
      if (controller.repoContents.isEmpty && !controller.isLoading.value) {
        errorMessage = 'No files found in this directory';
      }
    } catch (e) {
      errorMessage = 'Failed to load repository contents: ${e.toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.repoName),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Obx(() {
          if (errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red[300]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      errorMessage = null;
                      _fetchContents();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading repository contents...'),
                ],
              ),
            );
          }

          if (controller.repoContents.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No files found in this directory'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.repoContents.length,
            itemBuilder: (context, index) {
              final item = controller.repoContents[index];

              return ListTile(
                leading: Icon(item['type'] == 'dir'
                    ? Icons.folder
                    : Icons.insert_drive_file),
                title: Text(item['name']),
                onTap: () {
                  if (item['type'] == 'file') {
                    final url = item['download_url'];
                    if (url.isNotEmpty) {
                      if (isCodeFile(item['name'])) {
                        Get.to(() => FileViewerScreen(
                            fileUrl: url, fileName: item['name']));
                      } else {
                        openInBrowser(url);
                      }
                    }
                  } else if (item['type'] == 'dir') {
                    String newPath = item['path'] ?? 
                        (widget.path.isEmpty ? item['name'] : '${widget.path}/${item['name']}');

                    if (kDebugMode) {
                      print("Navigating to path: $newPath");
                    }

                    Get.to(() => RepoContentsScreen(
                          username: widget.username,
                          repoName: widget.repoName,
                          path: newPath,
                        ));

                    controller.getRepoContents(
                        widget.username, widget.repoName, newPath);
                  }
                },
              );
            },
          );
        }),
      ),
    );
  }
}
