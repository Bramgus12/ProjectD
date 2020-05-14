package com.bylivingart.plants.controllers;

import com.bylivingart.plants.DatabaseConnection;
import com.bylivingart.plants.buienradar.BuienradarnlType;
import com.bylivingart.plants.buienradar.WeerstationType;
import com.bylivingart.plants.dataclasses.Error;
import com.bylivingart.plants.statements.WeatherStatements;
import io.swagger.annotations.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.Connection;
import java.util.ArrayList;

@Api(value = "Weather controller")
@RestController
@RequestMapping("/weather")
public class WeatherController {

    @ApiOperation(value = "Get the full weather object")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the weather", response = BuienradarnlType.class),
            @ApiResponse(code = 400, message = "Failed to get the weather", response = Error.class),
            @ApiResponse(code = 404, message = "Weather not found", response = Error.class)
    })
    @GetMapping
    private ResponseEntity<BuienradarnlType> getWeather() throws Exception {
        return new ResponseEntity<>(WeatherStatements.getWeather(), HttpStatus.OK);
    }

    @ApiOperation("Get the weather for a region.")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten weather of the region.", response = WeerstationType.class, responseContainer = "List"),
            @ApiResponse(code = 400, message = "Failed to get the weather of the region", response = Error.class),
            @ApiResponse(code = 404, message = "Weather not found", response = Error.class)
    })
    @GetMapping("/{regio}/")
    private ResponseEntity<ArrayList<WeerstationType>> getWeatherByRegio(
            @ApiParam(value = "The region you want the weather of", required = true) @PathVariable String regio
    ) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        return new ResponseEntity<>(WeatherStatements.getWeerStationByRegio(regio, conn), HttpStatus.OK);
    }


    @ApiOperation("Get the weather station by latitude and longitude.")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully gotten the weather station", response = WeerstationType.class),
            @ApiResponse(code = 400, message = "Failed to get the weather station", response = Error.class),
            @ApiResponse(code = 404, message = "Weather not found", response = Error.class)
    })
    @GetMapping("/latlon/")
    private ResponseEntity<WeerstationType> getWeatherByLatLon(
            @ApiParam(value = "Latitude of your location", required = true) @RequestParam Double lat,
            @ApiParam(value = "Longitude of your location", required = true) @RequestParam Double lon
    ) throws Exception {
        return new ResponseEntity<>(WeatherStatements.getWeerstationByLatLon(lat, lon), HttpStatus.OK);
    }
}
