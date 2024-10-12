# resume_builder_app

Resume builder Flutter project.
The project is a Flutter application that integrates with Firebase Authentication to allow users to log in using their GitHub accounts. Once authenticated, users can view all their repositories, both private and public

### Technical Implementation

**Auth Setup**
  * Enable authentication in your firebase project
  * Enable GitHub provider in Sign-in method
  * It requires clientId and client secret of your github developer OAuth app.
  * For that go to [https://github.com/settings/developers](https://github.com/settings/developers) and create a new OAuth App (or use existing if already exists)
  * Copy clientId and client secret of the OAuth app and paste them in the GitHub provider section of firebase
  * You will see a callback url in the github section of firebase. Use it as Authorization callback URL in GitHub
  * Use flutterfire to connect the flutter project to your firebase project

## Current App screenshots

![image](https://github.com/user-attachments/assets/140fa0de-9df7-4e14-bad7-0d3e2d72fe06)
![image](https://github.com/user-attachments/assets/97de7cdb-2367-425e-bd2c-ed0fd892fc7d)
![image](https://github.com/user-attachments/assets/4639e28b-f4eb-4989-97d6-04c381b69e7b)

