package com.bylivingart.plants.controllers;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.util.ArrayList;

import javax.servlet.http.HttpServletResponse;

import com.bylivingart.plants.DatabaseConnection;
import com.bylivingart.plants.FileService;
import com.bylivingart.plants.GetPropertyValues;
import com.bylivingart.plants.PlantsApplication;
import com.bylivingart.plants.dataclasses.UserPlants;
import com.bylivingart.plants.statements.PlantsStatements;
import com.bylivingart.plants.statements.UserPlantsStatements;

import io.swagger.annotations.*;
import io.swagger.models.Response;
import net.bytebuddy.pool.TypePool;
import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Api(value = "User Plants controller")
@RestController
@RequestMapping("/api")
public class UserPlantsController {


    @ApiOperation("Get an image")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the image"),
            @ApiResponse(code = 400, message = "failed to get the image", response = Error.class)
    })
    @GetMapping(value = "/{deviceid}/{imagename}", produces = MediaType.IMAGE_JPEG_VALUE)
    private ResponseEntity<byte[]> getImage(
            @PathVariable String deviceid,
            @PathVariable String imagename
    ) throws IllegalArgumentException {
        try {
//            InputStream in = getClass().getResourceAsStream("/photos/" + deviceid + "/" + imagename);
            File file = GetPropertyValues.getResourcePath(deviceid, imagename);
            InputStream in = new FileInputStream(file);
            if (in.available() != 0) {
                ResponseEntity<byte[]> response = new ResponseEntity<>(HttpStatus.OK);
                return response;
            } else {
                throw new Exception("Not found");
            }
        } catch (final Exception e) {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    @ApiOperation("Get all the userPlants from the database")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the userPlants", response = UserPlants.class, responseContainer = "List"),
            @ApiResponse(code = 400, message = "Couldn't get the date from the database", response = Error.class),
            @ApiResponse(code = 404, message = "Resource not found")
    })
    @GetMapping("/userplants/all")
    private ResponseEntity<ArrayList<UserPlants>> getAllUserPlants() throws IllegalArgumentException {
        try {
            Connection conn = new DatabaseConnection().getConnection();
            ResponseEntity<ArrayList<UserPlants>> response = new ResponseEntity<>(UserPlantsStatements.getAllUserPlants(conn), HttpStatus.OK);
            conn.close();
            return response;
        } catch (Exception e) {
            if (e.getMessage().equals("No data in database")) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            } else {
                throw new IllegalArgumentException(e.getMessage());
            }
        }
    }

    @ApiOperation("Create a new UserPlants resource in database")
    @ApiResponses(value = {
            @ApiResponse(code = 201, message = "Created the userPlant successfully in database", response = UserPlants.class),
            @ApiResponse(code = 400, message = "Failed to create userPlant", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class)
    })
    @PostMapping("/admin/userplants")
    @ResponseStatus(HttpStatus.CREATED)
    private ResponseEntity<UserPlants> createUserPlant(
            @ApiParam(value = "The userPlant you want to create", required = true) @RequestBody UserPlants userPlants
    ) throws IllegalArgumentException {
        try {
            Connection conn = new DatabaseConnection().getConnection();
            ResponseEntity<UserPlants> response = new ResponseEntity<>(UserPlantsStatements.createUserPlants(userPlants, conn), HttpStatus.CREATED);
            conn.close();
            return response;
        } catch (Exception e) {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    @ApiOperation("Update a userPlants resource")
    @ApiResponses(value = {
            @ApiResponse(code = 204, message = "Updated the userPlants resource in database"),
            @ApiResponse(code = 400, message = "Failed to update userPlants resource", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "Resource not found")
    })
    @ResponseStatus(HttpStatus.CREATED)
    @PutMapping("/admin/userplants")
    private ResponseEntity<Void> updateUserPlant(@RequestBody UserPlants userPlants, @RequestParam int id) throws IllegalArgumentException {
        try {
            if (userPlants.getId() != id) {
                throw new IllegalArgumentException("Id can't be changed and the id's have to be the same");
            } else {
                Connection conn = new DatabaseConnection().getConnection();
                if (UserPlantsStatements.updateUserPlant(userPlants, conn)) {
                    conn.close();
                    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
                } else {
                    return new ResponseEntity<>(HttpStatus.NOT_FOUND);
                }
            }
        } catch (Exception e) {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    @ApiOperation("Delete a UserPlants resource")
    @ApiResponses(value = {
            @ApiResponse(code = 204, message = "Successfully deleted userPlants resource"),
            @ApiResponse(code = 400, message = "Failed to delete resource", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "Resource not found")
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @DeleteMapping("/admin/userplants")
    private ResponseEntity<Void> deleteUserPlant(int id) throws IllegalArgumentException {
        try {
            Connection conn = new DatabaseConnection().getConnection();
            if (UserPlantsStatements.deleteUserPlant(id, conn)) {
                conn.close();
                return new ResponseEntity<>(HttpStatus.NO_CONTENT);
            } else {
                conn.close();
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            }
        } catch (Exception e) {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    @ApiOperation("Upload image")
    @ApiResponses(value = {
            @ApiResponse(code = 201, message = "Image has been uploaded"),
            @ApiResponse(code = 400, message = "Image could not be uploaded"),
            @ApiResponse(code = 401, message = "Unauthorized")
    })
    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping("/admin/userplants/image")
    private ResponseEntity<Void> uploadPlantImage(
            @RequestParam MultipartFile file,
            @RequestParam String deviceId,
            @RequestParam String imageName
    ) throws IllegalArgumentException {
        try {
            if (UserPlantsStatements.uploadImage(file, deviceId, imageName)) {
                return new ResponseEntity<>(HttpStatus.CREATED);
            } else {
                throw new IllegalArgumentException("Couldn't upload file");
            }
        } catch (Exception e){
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    

    @ExceptionHandler
    void handleIllegalArgumentException(final IllegalArgumentException e, final HttpServletResponse response)
            throws IOException {
        PlantsApplication.printErrorInConsole(e.getMessage());
        response.sendError(HttpStatus.BAD_REQUEST.value());
    }
}