# resume_builder_app

Resume builder Flutter project.
The project is a Flutter application that integrates with Firebase Authentication to allow users to log in using their GitHub accounts. Once authenticated, users can view all their repositories, both private and public

### Technical Implementation

**Build steps**
https://developers.google.com/android/guides/client-auth ```keytool -list -v \
-alias androiddebugkey -keystore ~/.android/debug.keystore```![image](https://github.com/user-attachments/assets/aac7528a-fb52-4131-8d0f-64782b5d6af9)

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

## Current App screenshots

<img src="https://github.com/user-attachments/assets/140fa0de-9df7-4e14-bad7-0d3e2d72fe06" width="300" alt="App Screenshot 1" />
<img src="https://github.com/user-attachments/assets/97de7cdb-2367-425e-bd2c-ed0fd892fc7d" width="300" alt="App Screenshot 2" />
<img src="https://github.com/user-attachments/assets/4639e28b-f4eb-4989-97d6-04c381b69e7b" width="300" alt="App Screenshot 3" />
<img src="https://github.com/user-attachments/assets/6062ec05-199d-4887-9db5-5047b0837360" width="300" alt="Choose templates for the Resume" />


