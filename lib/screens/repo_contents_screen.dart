import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/repo_controllers.dart';
import 'fileview_screen.dart';

class RepoContentsScreen extends StatefulWidget {
  final String username;
  final String repoName;
  final String path;

  const RepoContentsScreen({
    Key? key,
    required this.username,
    required this.repoName,
    this.path = '',
  }) : super(key: key);

  @override
  _RepoContentsScreenState createState() => _RepoContentsScreenState();
}

class _RepoContentsScreenState extends State<RepoContentsScreen> {
  final GitHubController controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.repoContents.clear();  // ✅ Clear old contents first
      controller.getRepoContents(widget.username, widget.repoName, widget.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.repoName),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.back(); // ✅ Proper back navigation
            },
          ),
        ),
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
                  leading: Icon(item['type'] == 'dir'
                      ? Icons.folder
                      : Icons.insert_drive_file),
                  title: Text(item['name']),
                    onTap: () {
                      if (item['type'] == 'file') {
                        final url = item['download_url'];
                        if (url.isNotEmpty) {
                          Get.to(() => FileViewerScreen(fileUrl: url, fileName: item['name']));
                        }
                      } else if (item['type'] == 'dir') {
                        String newPath = widget.path.isEmpty ? item['name'] : '${widget.path}/${item['name']}';

                        // ✅ Clear contents & fetch new folder data
                        controller.repoContents.clear();
                        controller.getRepoContents(widget.username, widget.repoName, newPath);

                        // ✅ Navigate to new RepoContentsScreen
                        Get.to(() => RepoContentsScreen(
                          username: widget.username,
                          repoName: widget.repoName,
                          path: newPath,
                        ));
                      }
                    }

                );
              });
        } ),
    ));
  }
}
