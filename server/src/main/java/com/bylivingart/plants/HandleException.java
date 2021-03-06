package com.bylivingart.plants;

import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.InternalServerException;
import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.Exceptions.UnauthorizedException;
import com.bylivingart.plants.dataclasses.Error;
import com.bylivingart.plants.dataclasses.NotValidError;
import com.fasterxml.jackson.core.io.JsonStringEncoder;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.util.JSONPObject;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageConversionException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@ControllerAdvice
public class HandleException {

    @ExceptionHandler(UnauthorizedException.class)
    public static void handleUnauthorizedException(Exception e, HttpServletResponse response) throws IOException {
        PlantsApplication.printErrorInConsole(e.getLocalizedMessage());
        response.sendError(HttpStatus.UNAUTHORIZED.value(), e.getMessage());
    }

    @ExceptionHandler(NotFoundException.class)
    private void handleNotFoundExceptions(NotFoundException e, HttpServletResponse response) throws IOException {
        PlantsApplication.printErrorInConsole(e.getLocalizedMessage());
        response.sendError(HttpStatus.NOT_FOUND.value(), e.getMessage());
    }

    @ExceptionHandler(BadRequestException.class)
    private ResponseEntity<NotValidError> handleBadRequestException(BadRequestException e, HttpServletRequest request) {
        PlantsApplication.printErrorInConsole(e.getLocalizedMessage());
        return new ResponseEntity<>(new NotValidError(400, "Bad request", e.getMessage(), new HashMap<>(), request.getServletPath()), HttpStatus.BAD_REQUEST);

    }

    @ExceptionHandler(InternalServerException.class)
    private void handleInternalServerException(InternalServerException e, HttpServletResponse response) throws IOException {
        e.printStackTrace();
        response.sendError(HttpStatus.INTERNAL_SERVER_ERROR.value(), e.getMessage());
    }

    @ExceptionHandler(SQLException.class)
    private ResponseEntity<NotValidError> handleSQLException(SQLException e, HttpServletRequest request) {
        PlantsApplication.printErrorInConsole(e.getLocalizedMessage());
        return new ResponseEntity<>(new NotValidError(400, "Bad request", e.getMessage(), new HashMap<>(), request.getServletPath()), HttpStatus.BAD_REQUEST);

    }

    @ExceptionHandler(FileNotFoundException.class)
    private void handleFileNotFoundExceptions(FileNotFoundException e, HttpServletResponse response) throws IOException {
        PlantsApplication.printErrorInConsole(e.getLocalizedMessage());
        response.sendError(HttpStatus.NOT_FOUND.value(), e.getMessage());
    }


    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    private ResponseEntity<Error> handleMethodArgumentNotValidException(MethodArgumentNotValidException e, HttpServletRequest request) {
        HashMap<String, String> ValidationErrors = new HashMap<>();
        e.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            ValidationErrors.put(fieldName, errorMessage);
        });
        return new ResponseEntity<>(new NotValidError(400, "Bad request","A field doesn't match the validation", ValidationErrors, request.getServletPath()), HttpStatus.BAD_REQUEST);
    }
}
