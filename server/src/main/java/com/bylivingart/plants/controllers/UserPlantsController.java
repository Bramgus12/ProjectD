package com.bylivingart.plants.controllers;

import com.bylivingart.plants.DatabaseConnection;
import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.FileService;
import com.bylivingart.plants.GetPropertyValues;
import com.bylivingart.plants.dataclasses.UserPlants;
import com.bylivingart.plants.statements.UserPlantsStatements;
import io.swagger.annotations.*;
import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.util.ArrayList;

@Api(value = "User Plants controller")
@RestController
@RequestMapping("/api")
public class UserPlantsController {


    @ApiOperation("Get an image")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the image"),
            @ApiResponse(code = 400, message = "failed to get the image", response = Error.class),
            @ApiResponse(code = 404, message = "Image not found", response = Error.class)
    })
    @GetMapping(value = "/userplants/{deviceId}/{imageName}", produces = MediaType.IMAGE_JPEG_VALUE)
    private ResponseEntity<byte[]> getImage(
            @PathVariable String deviceId,
            @PathVariable String imageName
    ) throws Exception {
        File file = GetPropertyValues.getResourcePath(deviceId, imageName, true);
        InputStream in = new FileInputStream(file);
        if (in.available() != 0) {
            ResponseEntity<byte[]> response = new ResponseEntity<>(IOUtils.toByteArray(in), HttpStatus.OK);
            in.close();
            return response;
        } else {
            in.close();
            throw new NotFoundException("Image not found");
        }
    }

    @ApiOperation("Get all the userPlants from the database")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the userPlants", response = UserPlants.class, responseContainer = "List"),
            @ApiResponse(code = 400, message = "Couldn't get the date from the database", response = Error.class),
            @ApiResponse(code = 404, message = "Resource not found", response = Error.class)
    })
    @GetMapping("/userplants")
    private ResponseEntity<ArrayList<UserPlants>> getAllUserPlants() throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        ResponseEntity<ArrayList<UserPlants>> response = new ResponseEntity<>(UserPlantsStatements.getAllUserPlants(conn), HttpStatus.OK);
        conn.close();
        return response;
    }

    @ApiOperation("Create a new UserPlants resource in database")
    @ApiResponses(value = {
            @ApiResponse(code = 201, message = "Created the userPlant successfully in database", response = UserPlants.class),
            @ApiResponse(code = 400, message = "Failed to create userPlant", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "UserPlant not found", response = Error.class)
    })
    @PostMapping("/admin/userplants")
    @ResponseStatus(HttpStatus.CREATED)
    private ResponseEntity<UserPlants> createUserPlant(
            @ApiParam(value = "The userPlant you want to create", required = true) @RequestBody UserPlants userPlants
    ) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        ResponseEntity<UserPlants> response = new ResponseEntity<>(UserPlantsStatements.createUserPlants(userPlants, conn), HttpStatus.CREATED);
        conn.close();
        return response;
    }

    @ApiOperation("Update a userPlants resource")
    @ApiResponses(value = {
            @ApiResponse(code = 204, message = "Updated the userPlants resource in database"),
            @ApiResponse(code = 400, message = "Failed to update userPlants resource", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "Resource not found", response = Error.class)
    })
    @ResponseStatus(HttpStatus.CREATED)
    @PutMapping("/admin/userplants")
    private ResponseEntity<Void> updateUserPlant(@RequestBody UserPlants userPlants, @RequestParam int id) throws Exception {
        if (userPlants.getId() != id) {
            throw new BadRequestException("Id can't be changed and the id's have to be the same");
        } else {
            Connection conn = new DatabaseConnection().getConnection();
            if (UserPlantsStatements.updateUserPlant(userPlants, conn)) {
                conn.close();
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            } else {
                throw new NotFoundException("UserPlant could not be found");
            }
        }
    }

    @ApiOperation("Delete a UserPlants resource")
    @ApiResponses(value = {
            @ApiResponse(code = 204, message = "Successfully deleted userPlants resource"),
            @ApiResponse(code = 400, message = "Failed to delete resource", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "Resource not found", response = Error.class)
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @DeleteMapping("/admin/userplants")
    private ResponseEntity<Void> deleteUserPlant(int id) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        if (UserPlantsStatements.deleteUserPlant(id, conn)) {
            conn.close();
            return new ResponseEntity<>(HttpStatus.NO_CONTENT);
        } else {
            conn.close();
            throw new NotFoundException("UserPlant not found");
        }
    }

    @ApiOperation("Upload image")
    @ApiResponses(value = {
            @ApiResponse(code = 201, message = "Image has been uploaded"),
            @ApiResponse(code = 400, message = "Image could not be uploaded", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "Image not found", response = Error.class)
    })
    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping("/admin/userplants/image")
    private ResponseEntity<Void> uploadPlantImage(
            @RequestParam MultipartFile file,
            @RequestParam String deviceId,
            @RequestParam String imageName
    ) throws Exception {
        if (FileService.uploadImage(file, deviceId, imageName, true)) {
            return new ResponseEntity<>(HttpStatus.CREATED);
        } else {
            throw new BadRequestException("Couldn't upload file");
        }
    }
}