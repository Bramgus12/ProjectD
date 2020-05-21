package com.bylivingart.plants;

import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.InternalServerException;
import com.bylivingart.plants.Exceptions.NotFoundException;
import org.apache.tika.Tika;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Service
public class FileService {

    public static void uploadFile(MultipartFile file, String folder, String fileName, boolean forUsers) throws Exception {
        uploadFile(file, folder, fileName, null, forUsers);
    }
    public static void uploadFile(MultipartFile file, String folder, String fileName,String userPlantId, boolean forUsers) throws Exception {
        File f;
        if (userPlantId == null) {
            f = GetPropertyValues.getResourcePath(folder, fileName, forUsers);
        } else {
            f = GetPropertyValues.getResourcePath(folder, fileName, userPlantId, forUsers);
        }
        Path copyLocation = Paths.get(String.valueOf(f));
        Files.copy(file.getInputStream(), copyLocation);
        OutputStream os = Files.newOutputStream(copyLocation);
        os.write(file.getBytes());
    }

    public static boolean uploadImage(MultipartFile file, String folderName, String imageName, boolean forUsers) throws Exception {
        return uploadImage(file, folderName, imageName, null, forUsers);
    }

    public static boolean uploadImage(MultipartFile file, String folderName, String imageName, String userPlantId, boolean forUsers) throws Exception {
        File f;
        File folder;
        if (userPlantId == null ) {
            f = GetPropertyValues.getResourcePath(folderName, imageName, forUsers);
            folder = GetPropertyValues.getResourcePath(folderName, "", forUsers);
        } else {
            f = GetPropertyValues.getResourcePath(folderName, imageName, userPlantId, forUsers);
            folder = GetPropertyValues.getResourcePath(folderName, "", userPlantId, forUsers);
        }
        if (folder.exists() || folder.mkdirs()) {
            Tika tika = new Tika();
            String mimeType = tika.detect(file.getBytes());
            System.out.println(mimeType);
            if (mimeType != null && mimeType.equals("image/jpeg")) {
                if (!f.exists()) {
                    if (userPlantId == null) {
                        FileService.uploadFile(file, folderName, imageName, forUsers);
                    } else {
                        FileService.uploadFile(file, folderName, imageName, userPlantId, forUsers);
                    }
                    return f.exists();
                } else {
                    throw new BadRequestException("File already exists");
                }
            } else {
                throw new BadRequestException("This file is not in the right format");
            }
        } else {
            throw new InternalServerException("Folder could not be made");
        }
    }

    public static boolean deleteImage(String folderName, String fileName, boolean forUsers) throws Exception {
        return deleteImage(folderName, fileName, null, forUsers);
    }

    public static boolean deleteImage(String folderName, String fileName, String userPlantId, boolean forUsers) throws Exception {
        File f;
        if (userPlantId != null) {
            f = GetPropertyValues.getResourcePath(folderName, fileName, userPlantId, forUsers);
        } else {
            f = GetPropertyValues.getResourcePath(folderName, fileName, forUsers);
        }

        if (f.exists()) {
            return f.delete();
        } else {
            throw new NotFoundException("File not found");
        }
    }
}
