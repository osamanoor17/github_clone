# GitHub Clone

A Flutter application that allows users to explore GitHub repositories, view repository contents, and browse code files.

## Features

- 🔍 Search repositories by name and description
- 📂 Browse repository contents and files
- 📝 View code files with syntax highlighting
- ⭐ Sort repositories by last updated date
- 🌙 Dark/Light theme support
- 📱 Responsive design for all screen sizes


## Getting Started

### Prerequisites

- Flutter SDK (version >=3.2.3)
- Dart SDK (version >=3.2.3)
- GitHub Personal Access Token

### Installation

1. Clone the repository:
```bash
git clone https://github.com/osamanoor17/github-clone.git
cd github-clone
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure GitHub Token:
   - Create a GitHub Personal Access Token at https://github.com/settings/tokens
   - Required scopes: `repo`, `user`
   - Replace `YOUR_GITHUB_TOKEN_HERE` in `lib/controllers/repo_controllers.dart` with your token

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── controllers/
│   └── repo_controllers.dart    # GitHub API and data management
├── screens/
│   ├── RepoListScreen.dart      # Repository list view
│   ├── repo_contents_screen.dart # Repository contents view
│   └── fileview_screen.dart     # Code file viewer
└── main.dart                    # App entry point
```

## Dependencies

- `get`: State management and navigation
- `http`: API requests
- `shimmer`: Loading animations
- `url_launcher`: Opening URLs in browser
- `font_awesome_flutter`: Icons

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- GitHub API
- Flutter team
- All contributors and supporters
