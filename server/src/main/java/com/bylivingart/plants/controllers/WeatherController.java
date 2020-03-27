package com.bylivingart.plants.controllers;

import com.bylivingart.plants.PlantsApplication;
import com.bylivingart.plants.statements.UserStatements;
import com.bylivingart.plants.statements.WeatherStatements;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@RestController
@RequestMapping("/api/weather")
public class WeatherController {

    @GetMapping
    private static ResponseEntity getWeather() throws Exception{
        try {
            WeatherStatements.getWeather();
        } catch (Exception e) {
            throw new IllegalArgumentException(e.getMessage());
        }
        return ResponseEntity.status(HttpStatus.OK).build();
    }


    @ExceptionHandler
    void handleIllegalArgumentException(IllegalArgumentException e, HttpServletResponse response) throws IOException {
        PlantsApplication.printErrorInConsole(e.getMessage());
        response.sendError(HttpStatus.BAD_REQUEST.value());
    }
}
