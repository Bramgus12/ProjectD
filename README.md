# ProjectD - By Living Art

This project wil contain an Android client and Server.  

## Running the android Application

This Application is made in Flutter. There are multiple editors that work with this application. We recommend Visual Studio Code.

1. Download VSCode from [this](https://code.visualstudio.com/) website.
2. Download Flutter from [this](https://flutter.dev/docs/get-started/install) website.
3. Download and install Android studio from [this](https://developer.android.com/studio) website.
4. You can then follow the instructions on the website of Flutter. If you work on MacOS or Linux please update your path. This is an optional function for flutter but this would help you a lot.
5. Open the folder `~/ProjectD/client/` in VSCode. If you open a Dart file you should get a message from VSCode that you have to install some extensions to run that language. If you don't see this message you can try to find the extension in the store. The extension is called flutter.
6. You should see a terminal in VSCode. If you don't see one please go to `Terminal > New Terminal`.
7. Please run the command `$ flutter doctor`. This will tell you if everything is installed correctly or not.
8. After you have fixed all issues with flutter open the terminal and run the command `$ flutter pub get`.
9. You have to change a line of code in the application. This is the IP-Address that the API is running on. If you are debugging this should be different for everyone. This line is in the file `~/ProjectD/client/assets/cfg/debug.json`. Change the IP-Address in that file.
10. You should be ready to run the application now. See below on how to run it on an android emulator and on an Android device.

### Android Device

1. Connect your phone via a cable to the computer. Make sure Android Debugging is turned on in the developer options.\
2. If you want to see if your pc can find your phone run `$ adb devices` in a terminal. If this doesn't work you have to either set adb in your path or you have to install it via a package manager. (apt on linux)
3. You should have an option in VSCode in de bottom right cornor to change the device you are about to run the application on. Change this to your phone.
4. Press F5 and have fun.

### Android Emulator

1. Open android studio and in the opening screen press the configure button and go to AVD Manager. This is the place where you can install and download android emulators.
2. Create an emulator to your liking, but use an updated version of android. This application is tested on android 10 (Q) so we recommend you to download that version.
3. Now go to VSCode and change the device to the emulator in the bottom right corner.
4. Now press F5 and the app will install on the emulator.

## Running the Server

The server will be running on Java. This means that you need an IDE that works with Java. I am going to write the instructions for Intellij IDEA and Visual Studio Code. Please note that Intellij IDEA is a full fledged IDE where Visual Studio code is just text editor with some IDE functions.

### Intellij IDEA

1. Go to the website of Jetbrains and download the IDEA version of your choice. Both will work. If you are on Linux you can download [jetbrains toolbox](https://www.jetbrains.com/toolbox-app/) where you can easily install IDEA. Unpack the .tar.gz and run the file that is in the folder by running the command `./jetbrains-toolbox`. This will install the toolbox. (If you are a student you can get a license for the ultimate edition [here](https://www.jetbrains.com/community/education/#students)) [Jetbrains IDEA Download](https://www.jetbrains.com/idea/download/#section=windows).
2. After installing IDEA you can open the server folder in this project. Let the IDE do it's thing, this can take awhile.
3. You need to make sure that the application will run on Java version 11. It doesn's matter which version of Java 11 it is but it must be 11 (At the time of writing 11.0.7). Please check if Java version 11 is installed by going to: `File > Project Structure > Project > Project SDK`. Change this to the newest version of 11 that you have installed. If 11 is not there or you have errors that the IDE can't find Java. Please download and install JDK 11 from [here](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html). Yes, you need an Oracle account. Ubuntu users can install OpenJDK from the package manager by running `sudo apt update` and then `sudo apt install openjdk-11-jdk`.
4. Make sure that Gradle uses the right version of Java by going to `File > Settings > Build, Execution, Deployment > Gradle > Gradle JVM` and change this to the newest version available of Java 11.
5. Add a file to the Resources folder with name `Database_config.properties` which is located at the following path: `~/server/src/main/resources`. Make sure that the variable `[url]` is a url that looks like `www.google.com`. The file needs to have the following layout:

    ```properties
    # Database connection information;
    db_url=jdbc:postgresql://[url]:[port]/[database name]
    db_username=[username]
    db_password=[password]
    db_url_short=[url]
    db_name=[database name]
    ```

6. Go to the file `PlantsApplication.java` in the IDE and press on the green triangle to start the project. The project will run and you can go the website [localhost:8080/swagger-ui.html](localhost:8080/swagger-ui.html). This is the interactive API documentation.

### Visual Studio Code

1. Download Visual Studio Code from [here](https://code.visualstudio.com/).
2. Install VSCode and open it.
3. Open the folder server by going to `File > Open folder`.
4. Visual studio code will open the folder and now you can choose from the left bar what file to open in the folder. Please open a java folder. VSCode will now bombard you with messages of things you have to install on the bottom right. Please install all of it.
5. If you haven't installed JDK 11 yet. Please do so by going [here](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html). If you use Ubuntu you can also install it by using the commands `sudo apt update` and `sudo apt install openjdk-11-jdk`.
6. Add a file to the Resources folder with name `Database_config.properties` which is located at the following path: `~/server/src/main/resources`. Make sure that the variable `[url]` is a url that looks like `www.google.com`. The file needs to have the following layout:

    ```properties
    # Database connection information;
    db_url=jdbc:postgresql://[url]:[port]/[database name]
    db_username=[username]
    db_password=[password]
    db_url_short=[url]
    db_name=[database name]
    ```

7. Install the extension for Spring Boot in VSCode from the extension store that is located in the left bar.
8. Press F5 and the project will run and you can go the link [localhost:8080/swagger-ui.html](localhost:8080/swagger-ui.html) for an interactive API documentation.
