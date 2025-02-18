import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'dart:convert';

class GitHubController extends GetxController {
  var isLoading = false.obs;
  var repositories = [].obs;
  var userProfile = {}.obs;
  var page = 1.obs;
  var isMoreDataAvailable = true.obs;
  var repoContents = [].obs;

  final Dio _dio = Dio();


  Future<void> getRepos(String username) async {
    if (username.isEmpty) return;
    isLoading(true);
    page.value = 1;
    isMoreDataAvailable(true);
    repositories.clear();

    try {
      final response = await _dio.get('https://api.github.com/users/$username/repos?page=1&per_page=10');
      final userResponse = await _dio.get('https://api.github.com/users/$username');

      if (response.statusCode == 200) {
        repositories.addAll(response.data);
      }

      if (userResponse.statusCode == 200) {
        userProfile.value = userResponse.data;
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoading(false);
    }
  }


  Future<void> loadMoreRepos(String username) async {
    if (!isMoreDataAvailable.value) return;

    page.value++;
    try {
      final response = await _dio.get('https://api.github.com/users/$username/repos?page=${page.value}&per_page=10');
      if (response.statusCode == 200) {
        var newRepos = response.data;
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
    isLoading(true);
    try {
      final response = await _dio.get(
        'https://api.github.com/repos/$username/$repoName/contents/${Uri.encodeComponent(path)}',
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200 && response.data is List) {
        repoContents.value = response.data;
      } else {
        repoContents.clear();
      }
    } on DioError catch (e) {
      print("DioError: ${e.response?.statusCode} - ${e.message}");
      repoContents.clear();
    } catch (e) {
      print("Unexpected Error: $e");
      repoContents.clear();
    } finally {
      isLoading(false);
    }
  }


}
