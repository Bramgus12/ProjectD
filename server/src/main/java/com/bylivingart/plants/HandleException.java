package com.bylivingart.plants;

import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.InternalServerException;
import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.Exceptions.UnauthorizedException;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@ControllerAdvice
public class HandleException extends ResponseEntityExceptionHandler {

    @ExceptionHandler(UnauthorizedException.class)
    public static void handleUnauthorizedException(Exception e, HttpServletResponse response) throws IOException {
        response.sendError(HttpStatus.UNAUTHORIZED.value(), e.getMessage());
    }

    @ExceptionHandler(NotFoundException.class)
    private void handleNotFoundExceptions(NotFoundException e, HttpServletResponse response) throws IOException {
        response.sendError(HttpStatus.NOT_FOUND.value(), e.getMessage());
    }

    @ExceptionHandler(BadRequestException.class)
    private void handleBadRequestException(BadRequestException e, HttpServletResponse response) throws IOException {
        response.sendError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
    }

    @ExceptionHandler(InternalServerException.class)
    private void handleInternalServerException(InternalServerException e, HttpServletResponse response) throws IOException {
        response.sendError(HttpStatus.INTERNAL_SERVER_ERROR.value(), e.getMessage());
    }

    @ExceptionHandler(SQLException.class)
    private void handleSQLException(SQLException e, HttpServletResponse response) throws IOException {
        response.sendError(HttpStatus.BAD_REQUEST.value(), e.getMessage());
    }
}
