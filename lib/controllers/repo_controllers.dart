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

  Future<void> getRepos(String username) async {
    if (username.isEmpty) return;
    isLoading(true);
    page.value = 1;
    isMoreDataAvailable(true);
    repositories.clear();

    final url =
        'https://api.github.com/users/$username/repos?page=1&per_page=10';
    final userUrl = 'https://api.github.com/users/$username';
    try {
      final response = await http.get(Uri.parse(url));
      final userResponse = await http.get(Uri.parse(userUrl));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        repositories.addAll(decodedData);
      }

      if (userResponse.statusCode == 200) {
        userProfile.value = json.decode(userResponse.body);
      }
    } catch (e) {
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
    final url =
        'https://api.github.com/users/$username/repos?page=${page.value}&per_page=10';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var newRepos = json.decode(response.body);
        if (newRepos.isNotEmpty) {
          repositories.addAll(newRepos);
        } else {
          isMoreDataAvailable(false);
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  Future<void> getRepoContents(String username, String repoName, String path) async {
    isLoading.value = true;
    currentRepoPath.value = path; // ✅ Ensure path is updated first
    repoContents.clear(); // ✅ Clear old contents before fetching new data

    try {
      final url = Uri.parse("https://api.github.com/repos/$username/$repoName/contents/$path");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        repoContents.assignAll(data.map((item) {
          return {
            'name': item['name'],
            'type': item['type'],
            'download_url': item['download_url'] ?? '',
          };
        }).toList());
      } else {
        print("API Error: ${response.statusCode}");
        repoContents.clear();
      }
    } catch (e) {
      print("Error fetching repo contents: $e");
      repoContents.clear();
    } finally {
      isLoading.value = false;
    }
  }




}
