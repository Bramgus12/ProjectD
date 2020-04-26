package com.bylivingart.plants.controllers;

import com.bylivingart.plants.DatabaseConnection;
import com.bylivingart.plants.PlantsApplication;
import com.bylivingart.plants.buienradar.BuienradarnlType;
import com.bylivingart.plants.buienradar.WeerstationType;
import com.bylivingart.plants.dataclasses.Error401;
import com.bylivingart.plants.statements.WeatherStatements;
import io.swagger.annotations.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.util.ArrayList;

@Api(value = "Weather controller")
@RestController
@RequestMapping("/api/weather")
public class WeatherController {

    @ApiOperation(value = "Get the full weather object")
    @ApiResponses(value = {
            @ApiResponse(code=200, message="Successfully gotten the weather", response = BuienradarnlType.class),
            @ApiResponse(code=400, message = "Failed to get the weather", response = Error401.class)
    })
    @GetMapping
    private ResponseEntity<BuienradarnlType> getWeather() throws IllegalArgumentException{
        try {
            return new ResponseEntity<>(WeatherStatements.getWeather(), HttpStatus.OK);
        } catch (Exception e) {
            throw new IllegalArgumentException(e.getMessage());
        }
    }

    @ApiOperation("Get the weather for a region.")
    @ApiResponses( value = {
            @ApiResponse(code=200, message = "Successfully gotten weather of the region.", response = WeerstationType.class, responseContainer = "List"),
            @ApiResponse(code=400, message = "Failed to get the weather of the region", response = Error401.class)
    })
    @GetMapping("/{regio}")
    private ResponseEntity<ArrayList<WeerstationType>> getWeatherByRegio(
            @ApiParam(value = "The region you want the weather of", required = true) @PathVariable String regio
    ) throws IllegalArgumentException {
        try {
            Connection conn = new DatabaseConnection().getConnection();
            ResponseEntity<ArrayList<WeerstationType>> response = new ResponseEntity<>(WeatherStatements.getWeerStationByRegio(regio, conn), HttpStatus.OK);
            return response;
        } catch (Exception e) {
            throw new IllegalArgumentException(e.getMessage());
        }
    }


    @ApiOperation("Get the weather station by latitute and longitude.")
    @ApiResponses(value = {
        @ApiResponse(code=200, message = "Successfully gotten the weather station", response = WeerstationType.class),
        @ApiResponse(code=400, message = "Failed to get the weather station", response = Error401.class)
    })
    @GetMapping("/distance")
    private ResponseEntity<WeerstationType> getDistanceBetweenPoints(
        @ApiParam(value = "Latitude of your location", required = true) @RequestParam Double lat, 
        @ApiParam(value = "Longitude of your location", required = true) @RequestParam Double lon
        ) throws IllegalArgumentException {
        try {
            ResponseEntity<WeerstationType> response = new ResponseEntity<>(WeatherStatements.getWeerstationByLatLon(lat, lon), HttpStatus.OK);
            return response;
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
