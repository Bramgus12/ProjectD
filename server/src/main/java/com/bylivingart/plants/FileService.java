package com.bylivingart.plants;

import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.InternalServerException;
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
        File f = GetPropertyValues.getResourcePath(folder, fileName, forUsers);
        Path copyLocation = Paths.get(String.valueOf(f));
        Files.copy(file.getInputStream(), copyLocation);
        OutputStream os = Files.newOutputStream(copyLocation);
        os.write(file.getBytes());
    }

    public static boolean uploadImage(MultipartFile file, String folderName, String imageName, boolean forUsers) throws Exception {
        File f = GetPropertyValues.getResourcePath(folderName, imageName, forUsers);
        File folder = GetPropertyValues.getResourcePath(folderName, "", forUsers);
        if (folder.mkdirs()) {
            String mimeType = Files.probeContentType(f.toPath());
            System.out.println(mimeType);
            System.out.println(f);
            if (mimeType != null && mimeType.equals("image/jpeg")) {
                if (!f.exists()) {
                    FileService.uploadFile(file, folderName, imageName, forUsers);
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
}
