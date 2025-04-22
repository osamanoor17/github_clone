import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_clone/screens/repo_contents_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/repo_controllers.dart';

class RepoListScreen extends StatefulWidget {
  final String username;
  final GitHubController controller = Get.put(GitHubController());

  RepoListScreen({super.key, required this.username});

  @override
  _RepoListScreenState createState() => _RepoListScreenState();
}

class _RepoListScreenState extends State<RepoListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    widget.controller.getRepos(widget.username);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!widget.controller.isLoading.value) {
        widget.controller.loadMoreRepos(widget.username);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Repositories',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search repositories...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  widget.controller.filterRepositories(value);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Obx(() {
                  if (widget.controller.errorMessage.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                          const SizedBox(height: 16),
                          Text(
                            widget.controller.errorMessage.value,
                            style: TextStyle(color: Colors.red[300]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (widget.controller.isLoading.value &&
                      widget.controller.repositories.isEmpty) {
                    return _shimmerLoading();
                  }
          
                  if (widget.controller.filteredRepositories.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            widget.controller.searchQuery.isEmpty
                                ? 'No repositories found.'
                                : 'No repositories match your search.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }
          
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: widget.controller.filteredRepositories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == widget.controller.filteredRepositories.length) {
                        return widget.controller.isLoading.value
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              )
                            : const SizedBox.shrink();
                      }
          
                      final repo = widget.controller.filteredRepositories[index];
                      return GestureDetector(
                        onTap: () async {
                          final url = repo['html_url'];
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                        child: GestureDetector(
                          onTap: () {
                            Get.to(() => RepoContentsScreen(
                                  username: widget.username,
                                  repoName: repo['name'],
                                ));
                          },
                          child: Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            shadowColor: Colors.black26,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              title: Text(
                                repo['name'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Text(
                                repo['description'] ?? 'No description',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  Text(
                                    ' ${repo['stargazers_count']}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerLoading() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          shadowColor: Colors.black12,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: ListTile(
              leading: Container(height: 40, width: 40, color: Colors.white),
              title: Container(height: 10, width: 100, color: Colors.white),
              subtitle: Container(height: 10, width: 150, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
