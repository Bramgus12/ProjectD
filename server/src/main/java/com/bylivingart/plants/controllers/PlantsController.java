package com.bylivingart.plants.controllers;

import java.io.IOException;
import java.sql.Connection;
import java.util.ArrayList;

import javax.servlet.http.HttpServletResponse;

import com.bylivingart.plants.DatabaseConnection;
import com.bylivingart.plants.PlantsApplication;
import com.bylivingart.plants.dataclasses.Plants;
import com.bylivingart.plants.statements.PlantStatements;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.annotations.*;

@Api(value = "Plants controller")
@RestController
@RequestMapping("/api")
public class PlantsController {

    @ApiOperation(value = "Get all the plants")
    @ApiResponses(value = {
            @ApiResponse(code=200, message="Successfully gotten all the plants", response = Plants.class, responseContainer = "List"),
            @ApiResponse(code=400, message = "Failed to get the plants", response = Error.class)
    })
    @GetMapping("/plants")
    private ResponseEntity<ArrayList<Plants>> getAllPlants() throws IllegalArgumentException {
        try {
            Connection conn = new DatabaseConnection().getConnection();
            ResponseEntity<ArrayList<Plants>> response = new ResponseEntity<>(PlantStatements.getAllPlants(conn), HttpStatus.OK);
            conn.close();
            return response;
        } catch (Exception e) {
            throw new IllegalArgumentException(e.getMessage());
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
    private ResponseEntity<Plants> createPlant(@RequestBody Plants plant){
        try {
            Connection conn = new DatabaseConnection().getConnection();
            Plants newPlant = PlantStatements.createPlant(plant, conn);
            conn.close();
            return new ResponseEntity<>(newPlant, HttpStatus.CREATED);
        } catch (Exception e){
            throw new IllegalArgumentException(e.getMessage());
        }
    }
    @ApiOperation(value = "Deleted plant")
    @ApiResponses(value = {
        @ApiResponse(code = 204, message = "Deleted plant succesfully"),
        @ApiResponse(code = 400, message = "Failed to delete plant", response = Error.class),
        @ApiResponse(code = 401, message = "Unauthorized", response = Error.class),
        @ApiResponse(code = 404, message = "Can't find the plant to delete")
    })
    @ResponseStatus(HttpStatus.NO_CONTENT)
    @DeleteMapping("/admin/plants/{id}")
    private ResponseEntity<Void> deletePlant(@PathVariable int id) throws IllegalArgumentException{
        try {
            Connection conn = new DatabaseConnection().getConnection();
            if (PlantStatements.deletePlant(id, conn)) {
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

    @ExceptionHandler
    void handleIllegalArgumentException(IllegalArgumentException e, HttpServletResponse response) throws IOException {
        PlantsApplication.printErrorInConsole(e.getMessage());
        response.sendError(HttpStatus.BAD_REQUEST.value());
    }
}