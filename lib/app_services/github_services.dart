import 'package:dio/dio.dart';

class GitHubService {
  final Dio _dio = Dio();

  Future<List<dynamic>> fetchPublicRepos(String username) async {
    try {
      final response = await _dio.get('https://api.github.com/users/$username/repos');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch repositories');
    }
  }
}
