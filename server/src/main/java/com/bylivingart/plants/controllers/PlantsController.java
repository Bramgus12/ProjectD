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
import com.bylivingart.plants.dataclasses.Plants;
import com.bylivingart.plants.statements.PlantsStatements;

import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import io.swagger.annotations.*;
import org.springframework.web.multipart.MultipartFile;

@Api(value = "Plants controller")
@RestController
@RequestMapping("/api")
public class PlantsController {


    @ApiOperation(value = "Get all the plants")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten all the plants", response = Plants.class, responseContainer = "List"),
            @ApiResponse(code = 400, message = "Failed to get the plants", response = Error.class),
            @ApiResponse(code = 404, message = "No data in database")
    })
    @GetMapping("/plants")
    private ResponseEntity<ArrayList<Plants>> getAllPlants() throws IllegalArgumentException {
        try {
            Connection conn = new DatabaseConnection().getConnection();
            ResponseEntity<ArrayList<Plants>> response = new ResponseEntity<>(PlantsStatements.getAllPlants(conn), HttpStatus.OK);
            conn.close();
            return response;
        } catch (Exception e) {
            if (e.getMessage().equals("No data in databse")) {
                return new ResponseEntity<>(HttpStatus.NOT_FOUND);
            } else {
                throw new IllegalArgumentException(e.getMessage());
            }
        }
    }

    @ApiOperation("Get an image")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the image"),
            @ApiResponse(code = 400, message = "failed to get the image", response = Error.class)
    })
    @GetMapping(value = "/plants/{plantname}/{imagename}", produces = MediaType.IMAGE_JPEG_VALUE)
    private ResponseEntity<byte[]> getImage(
            @PathVariable String plantname,
            @PathVariable String imagename
    ) throws IllegalArgumentException {
        try {
            File file = GetPropertyValues.getResourcePath(plantname, imagename, false);
            InputStream in = new FileInputStream(file);
            if (in.available() != 0) {
                ResponseEntity<byte[]> response = new ResponseEntity<>(IOUtils.toByteArray(in), HttpStatus.OK);
                in.close();
                return response;
            } else {
                in.close();
                throw new Exception("Not found");
            }
        } catch (final Exception e) {
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
    @PostMapping("/admin/plants/image")
    private ResponseEntity<Void> uploadPlantImage(
            @RequestParam MultipartFile file,
            @RequestParam String plantName,
            @RequestParam String imageName
    ) throws IllegalArgumentException {
        try {
            if (FileService.uploadImage(file, plantName, imageName, false)) {
                return new ResponseEntity<>(HttpStatus.CREATED);
            } else {
                throw new IllegalArgumentException("Couldn't upload file");
            }
        } catch (Exception e){
            throw new IllegalArgumentException(e.getMessage());
        }
    }


    @ApiOperation(value = "Get a plant by id")
    @ApiResponses(value = {
        @ApiResponse(code = 200, message= "Successfully gotten the plant"),
        @ApiResponse(code = 400, message= "Something went wrong"),
        @ApiResponse(code = 404, message= "Can't find the plant")
    })
    @GetMapping("/plants/{id}")
    private ResponseEntity<Plants> getPlant(@PathVariable int id) throws IllegalArgumentException {
        try {
            Connection conn = new DatabaseConnection().getConnection();
            ResponseEntity<Plants> response = new ResponseEntity<>(PlantsStatements.getPlant(id, conn), HttpStatus.OK);
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


    @ApiOperation(value = "Create a new plant in database")
    @ApiResponses(value = {
        @ApiResponse(code = 201, message = "Successfully created plant", response = Plants.class),
        @ApiResponse(code = 400, message = "Failed to create plant", response = Error.class),
        @ApiResponse(code = 401, message = "Unauthorized", response = Error.class)
    })
    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping("/admin/plants")
    private ResponseEntity<Plants> createPlant(
        @ApiParam(value = "The plant you want to create in the database", required = true) @RequestBody Plants plant
    ){
        try {
            Connection conn = new DatabaseConnection().getConnection();
            Plants newPlant = PlantsStatements.createPlant(plant, conn);
            conn.close();
            return new ResponseEntity<>(newPlant, HttpStatus.CREATED);
        } catch (Exception e){
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    @ApiOperation(value = "Delete a plant")
    @ApiResponses(value = {
        @ApiResponse(code = 204, message = "Deleted plant succesfully"),
        @ApiResponse(code = 400, message = "Failed to delete plant", response = Error.class),
        @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
        @ApiResponse(code = 404, message = "Can't find the plant to delete")
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @DeleteMapping("/admin/plants/{id}")
    private ResponseEntity<Void> deletePlant(
        @ApiParam(value = "The id of the plant you want to delete", required = true) @PathVariable int id
    ) throws IllegalArgumentException{
        try {
            Connection conn = new DatabaseConnection().getConnection();
            if (PlantsStatements.deletePlant(id, conn)) {
                ResponseEntity<Void> response = new ResponseEntity<>(HttpStatus.NO_CONTENT);
                conn.close();
                return response;
            } else {
                ResponseEntity<Void> response = new ResponseEntity<>(HttpStatus.NOT_FOUND);
                conn.close();
                return response;
            }
        } catch (Exception e) {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    @ApiOperation(value = "update a plant")
    @ApiResponses(value = {
        @ApiResponse(code = 204, message = "Updated plant succesfully"),
        @ApiResponse(code = 400, message = "Failed to update plant", response = Error.class),
        @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
        @ApiResponse(code = 404, message = "Can't find the plant to update")
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PutMapping("/admin/plants/{id}")
    private ResponseEntity<Void> updatePlant(
        @ApiParam(value = "The id of the plant you want to update", required = true) @PathVariable int id, 
        @ApiParam(value = "The new values of the plant (You can't change the id and id has to be the same as in the path)", required = true) @RequestBody Plants plant
    ) throws IllegalArgumentException {
        if (plant.getId() != id) {
            throw new IllegalArgumentException("Id's can't be changed");
        } else {
            try {
                Connection conn = new DatabaseConnection().getConnection();
                if (PlantsStatements.updatePlant(plant, conn)) {
                    ResponseEntity<Void> response = new ResponseEntity<>(HttpStatus.NO_CONTENT);
                    conn.close();
                    return response;
                } else {
                    ResponseEntity<Void> response = new ResponseEntity<>(HttpStatus.NOT_FOUND);
                    conn.close();
                    return response;
                }
            } catch (Exception e) {
                throw new IllegalArgumentException(e.getMessage());
            }
        }
    }

    @ExceptionHandler
    void handleIllegalArgumentException(IllegalArgumentException e, HttpServletResponse response) throws IOException {
        PlantsApplication.printErrorInConsole(e.getMessage());
        response.sendError(HttpStatus.BAD_REQUEST.value());
    }
}