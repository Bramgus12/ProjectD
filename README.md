# ProjectD - By Living

This project wil contain an Android client and Server.  

## Running the android Application

go to the folder `client` and execute the following commands:

### Android Device

### Android Emulator

## Running the Server

The server is run on Java. This means that you need an IDE that works with Java. I am going to write the instructions for Intellij IDEA and Visual Studio Code. Please note that Intellij IDEA is a full fledged IDE where Visual Studio code is just text editor with some IDE functions.

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
