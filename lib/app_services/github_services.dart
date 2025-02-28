import 'package:http/http.dart' as http;
import 'dart:convert';

class GitHubService {
  Future<List<dynamic>> fetchPublicRepos(String username) async {
    try {
      final response = await http
          .get(Uri.parse('https://api.github.com/users/$username/repos'));
      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Failed to fetch repositories');
    }
  }
  
}
