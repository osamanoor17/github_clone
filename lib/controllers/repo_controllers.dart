import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GitHubController extends GetxController {
  var isLoading = false.obs;
  var repositories = [].obs;
  var userProfile = {}.obs;
  var page = 1.obs;
  var isMoreDataAvailable = true.obs;
  var repoContents = [].obs;
  var currentRepoPath = ''.obs;
  var errorMessage = ''.obs;
  var searchQuery = ''.obs;
  var filteredRepositories = [].obs;

  // Add your GitHub Personal Access Token here
  // You can create one at: https://github.com/settings/tokens
  // Required scopes: repo, user
  final String _githubToken = 'YOUR_GITHUB_TOKEN_HERE';

  @override
  void onInit() {
    super.onInit();
    if (_githubToken.isEmpty) {
      errorMessage.value = 'GitHub token not found. Please check your .env file.';
    }
  }

  Map<String, String> get _headers {
    return {
      'Authorization': 'token $_githubToken',
      'Accept': 'application/vnd.github.v3+json',
    };
  }

  void filterRepositories(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredRepositories.assignAll(repositories);
    } else {
      filteredRepositories.assignAll(
        repositories.where((repo) => 
          repo['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
          (repo['description']?.toString().toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList()
      );
    }
  }

  Future<void> getRepos(String username) async {
    if (username.isEmpty) {
      errorMessage.value = 'Username is required';
      return;
    }
    
    isLoading(true);
    page.value = 1;
    isMoreDataAvailable(true);
    repositories.clear();
    filteredRepositories.clear();
    errorMessage.value = '';

    final url = Uri.parse(
      'https://api.github.com/users/$username/repos?page=1&per_page=100&sort=updated&direction=desc'
    );
    final userUrl = Uri.parse('https://api.github.com/users/$username');
    
    try {
      final response = await http.get(url, headers: _headers);
      final userResponse = await http.get(userUrl, headers: _headers);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        List<dynamic> sortedData = List.from(decodedData);
        sortedData.sort((a, b) {
          return DateTime.parse(b['updated_at'] ?? '').compareTo(DateTime.parse(a['updated_at'] ?? ''));
        });
        repositories.addAll(sortedData);
        filteredRepositories.assignAll(repositories);
      } else if (response.statusCode == 403) {
        errorMessage.value = 'Rate limit exceeded. Please try again later.';
      } else {
        errorMessage.value = 'Failed to load repositories: ${response.statusCode}';
      }

      if (userResponse.statusCode == 200) {
        userProfile.value = json.decode(userResponse.body);
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print("Error: $e");
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadMoreRepos(String username) async {
    if (!isMoreDataAvailable.value) return;

    page.value++;
    final url = Uri.parse(
      'https://api.github.com/users/$username/repos?page=${page.value}&per_page=100&sort=updated&direction=desc'
    );
    
    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        var newRepos = json.decode(response.body);
        if (newRepos.isNotEmpty) {
          newRepos.sort((a, b) {
            return DateTime.parse(b['updated_at'] ?? '').compareTo(DateTime.parse(a['updated_at'] ?? ''));
          });
          repositories.addAll(newRepos);
          filterRepositories(searchQuery.value);
        } else {
          isMoreDataAvailable(false);
        }
      } else if (response.statusCode == 403) {
        errorMessage.value = 'Rate limit exceeded. Please try again later.';
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      print("Error: $e");
    }
  }

  Future<void> getRepoContents(String username, String repoName, String path) async {
    isLoading.value = true;
    currentRepoPath.value = path;
    repoContents.clear();
    errorMessage.value = '';

    try {
      String cleanPath = path.startsWith('/') ? path.substring(1) : path;
      final encodedPath = Uri.encodeComponent(cleanPath);
      final url = Uri.parse("https://api.github.com/repos/$username/$repoName/contents/$encodedPath");
      
      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        repoContents.assignAll(data.map((item) {
          return {
            'name': item['name'],
            'type': item['type'],
            'download_url': item['download_url'] ?? '',
            'path': item['path'] ?? cleanPath,
          };
        }).toList());
      } else if (response.statusCode == 403) {
        errorMessage.value = 'Rate limit exceeded. Please try again later.';
      } else {
        errorMessage.value = 'Failed to load contents: ${response.statusCode}';
        repoContents.clear();
      }
    } catch (e) {
      errorMessage.value = 'Error: ${e.toString()}';
      print("Error fetching repo contents: $e");
      repoContents.clear();
    } finally {
      isLoading.value = false;
    }
  }
}
