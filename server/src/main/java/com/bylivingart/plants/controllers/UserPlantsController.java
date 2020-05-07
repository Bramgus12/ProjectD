package com.bylivingart.plants.controllers;

import java.io.IOException;
import java.io.InputStream;

import javax.servlet.http.HttpServletResponse;

import com.bylivingart.plants.PlantsApplication;

import org.apache.commons.io.IOUtils;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import io.swagger.annotations.Api;

@Api(value = "User Plants controller")
@RestController
@RequestMapping("/api")
public class UserPlantsController {

    @GetMapping(value = "/userplants", produces = MediaType.IMAGE_JPEG_VALUE)
    private ResponseEntity<byte[]> getImage() throws IllegalArgumentException {
        try {
            InputStream in = getClass().getResourceAsStream("/photos/TestId1/test.jpg");
            ResponseEntity<byte[]> response = new ResponseEntity<>(IOUtils.toByteArray(in), HttpStatus.OK);
            return response;
        } catch (final Exception e) {
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