import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/repo_controllers.dart';
import 'fileview_screen.dart';

class RepoContentsScreen extends StatelessWidget {
  final String username;
  final String repoName;
  final String path; // Folder path ko pass karenge
  final GitHubController controller = Get.find();

  // Constructor updated to handle path
  RepoContentsScreen({
    super.key,
    required this.username,
    required this.repoName,
    this.path = '', // Agar path empty hai toh root directory
  }) {
    controller.getRepoContents(username, repoName, path); // Path pass karein
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(repoName)),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
      
          if (controller.repoContents.isEmpty) {
            return const Center(child: Text('No files found.'));
          }
      
          return ListView.builder(
            itemCount: controller.repoContents.length,
            itemBuilder: (context, index) {
              final item = controller.repoContents[index];
              return ListTile(
                leading: Icon(
                    item['type'] == 'dir' ? Icons.folder : Icons.insert_drive_file),
                title: Text(item['name']),
                onTap: () async {
                  if (item['type'] == 'file') {
                    final url = item['download_url'];
                    if (url != null) {
                      Get.to(() => FileViewerScreen(fileUrl: url, fileName: item['name']));
                    }
                  } else if (item['type'] == 'dir') {
                    String newPath = path.isEmpty ? item['name'] : '$path/${item['name']}';
                    Get.to(() => RepoContentsScreen(
                      username: username,
                      repoName: repoName,
                      path: newPath,
                    ));
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
