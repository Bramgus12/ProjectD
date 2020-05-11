package com.bylivingart.plants.controllers;

import com.bylivingart.plants.DatabaseConnection;
import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.FileService;
import com.bylivingart.plants.GetPropertyValues;
import com.bylivingart.plants.dataclasses.Plants;
import com.bylivingart.plants.statements.PlantsStatements;
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

@Api(value = "Plants controller")
@RestController
@RequestMapping("/api")
public class PlantsController {
    @ApiOperation(value = "Get all the plants")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten all the plants", response = Plants.class, responseContainer = "List"),
            @ApiResponse(code = 400, message = "Failed to get the plants", response = Error.class),
            @ApiResponse(code = 404, message = "No data in database", response = Error.class)
    })
    @GetMapping("/plants")
    private ResponseEntity<ArrayList<Plants>> getAllPlants() throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        ResponseEntity<ArrayList<Plants>> response = new ResponseEntity<>(PlantsStatements.getAllPlants(conn), HttpStatus.OK);
        conn.close();
        return response;
    }

    @ApiOperation("Get an image")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the image"),
            @ApiResponse(code = 400, message = "failed to get the image", response = Error.class),
            @ApiResponse(code = 404, message = "Image not found", response = Error.class)
    })
    @GetMapping(value = "/plants/{plantName}/{imageName}", produces = MediaType.IMAGE_JPEG_VALUE)
    private ResponseEntity<byte[]> getImage(
            @PathVariable String plantName,
            @PathVariable String imageName
    ) throws Exception {
        File file = GetPropertyValues.getResourcePath(plantName, imageName, false);
        InputStream in = new FileInputStream(file);
        if (in.available() != 0) {
            ResponseEntity<byte[]> response = new ResponseEntity<>(IOUtils.toByteArray(in), HttpStatus.OK);
            in.close();
            return response;
        } else {
            in.close();
            throw new NotFoundException("Not found");
        }
    }

    @ApiOperation("Upload image")
    @ApiResponses(value = {
            @ApiResponse(code = 201, message = "Image has been uploaded"),
            @ApiResponse(code = 400, message = "Image could not be uploaded", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 500, message = "Internal server error", response = Error.class)
    })
    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping("/admin/plants/image")
    private ResponseEntity<Void> uploadPlantImage(
            @RequestParam MultipartFile file,
            @RequestParam String plantName,
            @RequestParam String imageName
    ) throws Exception {
        if (FileService.uploadImage(file, plantName, imageName, false)) {
            return new ResponseEntity<>(HttpStatus.CREATED);
        } else {
            throw new BadRequestException("Couldn't upload file");
        }
    }


    @ApiOperation(value = "Get a plant by id")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the plant", response = Plants.class),
            @ApiResponse(code = 400, message = "Something went wrong", response = Error.class),
            @ApiResponse(code = 404, message = "Can't find the plant", response = Error.class)
    })
    @GetMapping("/plants/{id}")
    private ResponseEntity<Plants> getPlant(@PathVariable int id) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        ResponseEntity<Plants> response = new ResponseEntity<>(PlantsStatements.getPlant(id, conn), HttpStatus.OK);
        conn.close();
        return response;
    }


    @ApiOperation(value = "Create a new plant in database")
    @ApiResponses(value = {
            @ApiResponse(code = 201, message = "Successfully created plant", response = Plants.class),
            @ApiResponse(code = 400, message = "Failed to create plant", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "plant not found", response = Error.class)
    })
    @ResponseStatus(HttpStatus.CREATED)
    @PostMapping("/admin/plants")
    private ResponseEntity<Plants> createPlant(
            @ApiParam(value = "The plant you want to create in the database", required = true) @RequestBody Plants plant
    ) throws Exception {
            Connection conn = new DatabaseConnection().getConnection();
            Plants newPlant = PlantsStatements.createPlant(plant, conn);
            conn.close();
            return new ResponseEntity<>(newPlant, HttpStatus.CREATED);
    }

    @ApiOperation(value = "Delete a plant")
    @ApiResponses(value = {
            @ApiResponse(code = 204, message = "Deleted plant succesfully"),
            @ApiResponse(code = 400, message = "Failed to delete plant", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "Can't find the plant to delete", response = Error.class)
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @DeleteMapping("/admin/plants/{id}")
    private ResponseEntity<Void> deletePlant(
            @ApiParam(value = "The id of the plant you want to delete", required = true) @PathVariable int id
    ) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        if (PlantsStatements.deletePlant(id, conn)) {
            ResponseEntity<Void> response = new ResponseEntity<>(HttpStatus.NO_CONTENT);
            conn.close();
            return response;
        } else {
            conn.close();
            throw new NotFoundException("Plant not found");
        }
    }

    @ApiOperation(value = "update a plant")
    @ApiResponses(value = {
            @ApiResponse(code = 204, message = "Updated plant succesfully"),
            @ApiResponse(code = 400, message = "Failed to update plant", response = Error.class),
            @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
            @ApiResponse(code = 404, message = "Can't find the plant to update", response = Error.class)
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @PutMapping("/admin/plants/{id}")
    private ResponseEntity<Void> updatePlant(
            @ApiParam(value = "The id of the plant you want to update", required = true) @PathVariable int id,
            @ApiParam(value = "The new values of the plant (You can't change the id and id has to be the same as in the path)", required = true) @RequestBody Plants plant
    ) throws Exception {
        if (plant.getId() != id) {
            throw new BadRequestException("Id's can't be changed");
        } else {
            Connection conn = new DatabaseConnection().getConnection();
            if (PlantsStatements.updatePlant(plant, conn)) {
                ResponseEntity<Void> response = new ResponseEntity<>(HttpStatus.NO_CONTENT);
                conn.close();
                return response;
            } else {
                conn.close();
                throw new NotFoundException("Can't find the plant");
            }
        }
    }
}