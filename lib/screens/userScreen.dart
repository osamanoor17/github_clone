import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/repo_controllers.dart';
import 'RepoListScreen.dart';

class Userscreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final GitHubController controller = Get.put(GitHubController(), permanent: true);

  final RxString textFieldValue = ''.obs;
  Userscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text('GitHub Explorer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
              const SizedBox(width: 8),
              FaIcon(
                FontAwesomeIcons.github,
                size: 28,
              ), // FontAwesome Icon
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                  Get.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
              onPressed: () {
                Get.changeThemeMode(
                    Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: usernameController,
                onChanged: (value) {
                  textFieldValue.value = value;
                },
                decoration: InputDecoration(
                  labelText: 'Enter GitHub Username',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(() => textFieldValue.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            usernameController.clear();
                            textFieldValue.value = '';
                            controller.userProfile.clear();
                          },
                        )
                      : const SizedBox()),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.teal, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  hintText: 'Search for a user...',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  controller.getRepos(usernameController.text);
                },
                icon: const Icon(Icons.search, color: Colors.white),
                label:
                    const Text('Search', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 150),
              Obx(() {
                if (controller.userProfile.isEmpty) {
                  if (usernameController.text.isEmpty) {
                    return _initialState();
                  } else {
                    return _noUserFound();
                  }
                }
                return GestureDetector(
                  onTap: () {
                    Get.to(() =>
                        RepoListScreen(username: usernameController.text));
                  },
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    shadowColor: Colors.black45,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                controller.userProfile['avatar_url']),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.userProfile['name'] ?? 'No Name',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(controller.userProfile['login']),
                                const SizedBox(height: 8),
                                Text(controller.userProfile['bio'] ?? 'No Bio',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 14)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Followers: ${controller.userProfile['followers']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Following: ${controller.userProfile['following']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ).paddingOnly(bottom: 5),
                                  ],
                                ).paddingOnly(bottom: 5),
                                Center(
                                  child: Text(
                                    "Repositories: ${controller.userProfile['public_repos']}",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _initialState() {
    return Column(
      children: [
        Icon(Icons.search, size: 50, color: Colors.grey[400])
            .paddingOnly(bottom: 10),
        Text(
          'Enter a username to search for a user.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _noUserFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 15),
          Text(
            'User Not Found',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Please try again with a valid username.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
