# resume_builder_app

## Screenshots

Below are screenshots demonstrating key features and UI flows of the app.
| App Login Screen | Repository List | Resume Template Selection | Resume Preview |
|:----------------:|:--------------:|:------------------------:|:--------------:|
| **Login with GitHub** | **View Repositories** | **Choose Resume Template** | **Preview Resume** |
| <img src="https://github.com/user-attachments/assets/61eec3c3-1b11-4880-87d5-d3f999076e09" width="250" alt="App Screenshot 1" /> | <img src="https://github.com/user-attachments/assets/53dd1a3d-0e46-4a48-abee-660682083793" width="250" alt="App Screenshot 2" /> | <img src="https://github.com/user-attachments/assets/6062ec05-199d-4887-9db5-5047b0837360" width="250" alt="Choose templates for the Resume" /> | <img src="https://github.com/user-attachments/assets/01a984d5-9959-4381-9933-96ebf027ae29" width="250" alt="App Screenshot 5" /> |

| Resume Edit | Export Options | Settings | Error Example |
|:-----------:|:--------------:|:--------:|:-------------:|
| **Edit Resume** | **Export/Download** | **App Settings** | **Error Message** |
| <img src="https://github.com/user-attachments/assets/e622e3cb-d47b-4abf-a85c-31c28953372c" width="250" alt="App Screenshot 6" /> | <img src="https://github.com/user-attachments/assets/4c10abd2-4291-4ac5-b6c9-560522954274" width="250" alt="App Screenshot 7" /> | <img src="https://github.com/user-attachments/assets/0505c5e7-4fbe-402c-ac5d-3f60e5bfc77e" width="250" alt="App Screenshot 8" /> | <img src="https://github.com/user-attachments/assets/4639e28b-f4eb-4989-97d6-04c381b69e7b" width="250" alt="App Screenshot 3" /> |


| App Login Screen | Repository List | Resume Template Selection | Resume Preview |
|:----------------:|:--------------:|:------------------------:|:--------------:|
| **Login with GitHub** | **View Repositories** | **Choose Resume Template** | **Preview Resume** |
| <img src="https://github.com/user-attachments/assets/140fa0de-9df7-4e14-bad7-0d3e2d72fe06" width="250" alt="App Screenshot 1" /> | <img src="https://github.com/user-attachments/assets/97de7cdb-2367-425e-bd2c-ed0fd892fc7d" width="250" alt="App Screenshot 2" /> | <img src="https://github.com/user-attachments/assets/6062ec05-199d-4887-9db5-5047b0837360" width="250" alt="Choose templates for the Resume" /> | <img src="https://github.com/user-attachments/assets/01a984d5-9959-4381-9933-96ebf027ae29" width="250" alt="App Screenshot 5" /> |

| Resume Edit | Export Options | Settings | Error Example |
|:-----------:|:--------------:|:--------:|:-------------:|
| **Edit Resume** | **Export/Download** | **App Settings** | **Error Message** |
| <img src="https://github.com/user-attachments/assets/e622e3cb-d47b-4abf-a85c-31c28953372c" width="250" alt="App Screenshot 6" /> | <img src="https://github.com/user-attachments/assets/4c10abd2-4291-4ac5-b6c9-560522954274" width="250" alt="App Screenshot 7" /> | <img src="https://github.com/user-attachments/assets/0505c5e7-4fbe-402c-ac5d-3f60e5bfc77e" width="250" alt="App Screenshot 8" /> | <img src="https://github.com/user-attachments/assets/4639e28b-f4eb-4989-97d6-04c381b69e7b" width="250" alt="App Screenshot 3" /> |

> **Note:** For every new feature or bug fix, please add relevant screenshots to the `screenshots/` folder and update this table.

---

## Project Description

resume_builder_app is a Flutter application that helps users create professional resumes by integrating their GitHub repositories and personal information. The app uses Firebase Authentication for secure login via GitHub and allows users to view, select, and incorporate their repositories into customizable resume templates.

## Features

- **GitHub Authentication:** Secure login using GitHub via Firebase.
- **Repository Integration:** Fetch and display both public and private repositories.
- **Resume Templates:** Choose from multiple professionally designed templates.
- **Resume Editing:** Add, edit, and organize resume sections.
- **Export Options:** Download or share resumes in PDF format.
- **Mobile Friendly:** Responsive UI for Android and iOS devices.

## Getting Started

Follow these steps to set up the project locally:

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-org/flutter_resume_builder.git
   cd flutter_resume_builder
   ```

2. **Install Flutter & Dependencies**
   - Ensure [Flutter](https://flutter.dev/docs/get-started/install) is installed.
   - Run:
     ```bash
     flutter pub get
     ```

3. **Firebase Setup**
   - Obtain your SHA1 key:
     ```bash
     keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
     ```
   - Send your SHA1 key to the repo author to add your device to the Firebase project.
   - (Optional) To use your own Firebase project:
     - Enable authentication and GitHub provider in Firebase Console.
     - Create a GitHub OAuth App and add its credentials to Firebase.
     - Use `flutterfire configure` to connect your Flutter project.

4. **Run the App**
   ```bash
   flutter run
   ```

## Roadmap

- [ ] Add more resume templates
- [ ] Support for LinkedIn integration
- [ ] Enhanced export options (DOCX, HTML)
- [ ] Localization and multi-language support
- [ ] Improved accessibility features

## Contributing

We welcome contributions! Please read the guidelines below before submitting a pull request.

---

## Project Overview for New Contributors

This project follows a standard Flutter app structure, with integration to Firebase for authentication and backend services.

### Major Folders & Files

- **lib/**: Main source code for the Flutter app.
  - `main.dart`: App entry point.
  - `screens/`: UI screens (login, dashboard, resume editor, etc.).
  - `widgets/`: Reusable UI components.
  - `services/`: Logic for authentication, GitHub API, and Firebase interactions.
  - `models/`: Data models (e.g., User, Repository, Resume).
- **assets/**: Images, fonts, and other static resources.
- **screenshots/**: Screenshots for documentation and PRs.
- **android/**, **ios/**: Platform-specific configuration.
- **pubspec.yaml**: Project dependencies and assets.

### Architecture

- **Frontend:** Built with Flutter, using widgets and state management for UI and logic.
- **Backend:** Firebase Authentication for user login; GitHub API for fetching repositories.
- **Database:** Firebase Firestore (if used) for storing user data and resumes.
- **Interaction:** The app authenticates users via Firebase, fetches GitHub data, and allows resume creation and export.

### How Components Interact

- User logs in via GitHub (handled by Firebase Auth).
- App fetches repositories using the GitHub API.
- User selects repositories and fills in resume details.
- Resume is generated using selected data and templates.
- User can export or share the resume.

---

## Getting Started for New Developers

1. **Set up Flutter**: Install Flutter SDK and add it to your PATH.
2. **Clone the repo**: `git clone ...`
3. **Install dependencies**: `flutter pub get`
4. **Configure Firebase**: See "Getting Started" above.
5. **Run the app**: `flutter run`
6. **Explore the codebase**: Start with `lib/main.dart` and follow the navigation to understand app flow.

---

## Contributing Guidelines

- **Pull Requests:** Every PR must include relevant app screenshots showing the changes made.
- **Screenshots:** Add screenshots to the `screenshots/` folder. Name them clearly (e.g., `feature-login.png`, `fix-navbar-bug.png`).
- **README Updates:** Update the Screenshots section in the README to include new screenshots with captions/context.
- **Code Style:** Follow Dart and Flutter best practices.
- **Issues:** Open an issue for bugs or feature requests before starting major work.

---

### Technical Implementation

**Build steps**
  * https://developers.google.com/android/guides/client-auth ```keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore```![image](https://github.com/user-attachments/assets/aac7528a-fb52-4131-8d0f-64782b5d6af9)
  * send your SHA1 key in whatsapp to repo author to add your device to company firebase account for debugging.

**Auth Setup - Optional**
  * Enable authentication in your firebase project
  * Enable GitHub provider in Sign-in method
  * It requires clientId and client secret of your github developer OAuth app.
  * For that go to [https://github.com/settings/developers](https://github.com/settings/developers) and create a new OAuth App (or use existing if already exists)
  * Copy clientId and client secret of the OAuth app and paste them in the GitHub provider section of firebase
  * You will see a callback url in the github section of firebase. Use it as Authorization callback URL in GitHub
  * Use flutterfire to connect the flutter project to your firebase project ```flutterfire configure```

**Trouble Shooting**
SHA error - send your SHA key in whatsapp to repo author. ![image](https://github.com/user-attachments/assets/787091fe-f850-4db4-b77c-778921923595)


