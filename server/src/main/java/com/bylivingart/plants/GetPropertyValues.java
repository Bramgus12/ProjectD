package com.bylivingart.plants;

import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.NotFoundException;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Properties;

public class GetPropertyValues {
    private static InputStream inputStream;

    /**
     * Get values from properties file
     * Resource: https://crunchify.com/java-properties-file-how-to-read-config-properties-values-in-java/
     */
    public static String[] getDatabasePropValues(String propFileName) throws Exception {
        String[] result = {"", "", "", "", ""};
        try {
            Properties prop = new Properties();
            inputStream = GetPropertyValues.class.getClassLoader().getResourceAsStream(propFileName);
            if (inputStream != null) {
                prop.load(inputStream);
            } else {
                throw new NotFoundException("Property file " + propFileName + " found.");
            }
            String db_url = prop.getProperty("db_url");
            String db_username = prop.getProperty("db_username");
            String db_password = prop.getProperty("db_password");
            String db_url_short = prop.getProperty("db_url_short");
            String db_name = prop.getProperty("db_name");
            result[0] = db_url;
            result[1] = db_username;
            result[2] = db_password;
            result[3] = db_url_short;
            result[4] = db_name;
        } catch (Exception e) {
            throw new BadRequestException(e.getMessage());
        } finally {
            try {
                if (inputStream != null) {
                    inputStream.close();
                }
            } catch (IOException e) {
                throw new BadRequestException(e.getMessage());
            }
        }
        return result;
    }

    public static File getResourcePath(String folderName, String fileName, boolean forUsers) throws Exception {
        return getResourcePath(folderName, fileName, null, forUsers);
    }

    public static File getResourcePath(String FolderName, String fileName, String userPlantId, boolean forUsers) throws Exception {
        Properties properties = new Properties();
        inputStream = GetPropertyValues.class.getClassLoader().getResourceAsStream("file_path.properties");
        if (inputStream != null) {
            properties.load(inputStream);
        } else {
            throw new NotFoundException("Property file file_path.properties not found");
        }
        Path path;
        if (forUsers && userPlantId != null) {
            path = Paths.get(properties.getProperty("file_path"), "photos", FolderName, userPlantId, fileName);
        } else {
            path = Paths.get(properties.getProperty("file_path"), "plants", FolderName, fileName);
        }
        return path.toFile();
    }
}
