package com.bylivingart.plants.controllers;

import com.bylivingart.plants.DatabaseConnection;
import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.dataclasses.User;
import com.bylivingart.plants.statements.UserStatements;
import io.swagger.annotations.*;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.sql.Connection;
import java.util.ArrayList;

@Api(value = "User controller")
@RestController
@RequestMapping("/api/users")
public class UserController {
    @ApiOperation(value = "Get a list of users")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully retrieved list", response = User.class, responseContainer = "List"),
            @ApiResponse(code = 400, message = "Bad request", response = Error.class),
            @ApiResponse(code = 401, message = "Invalid credentials", response = Error.class),
            @ApiResponse(code = 404, message = "No data in database", response = Error.class)
    })
    @GetMapping
    private ResponseEntity<ArrayList<User>> getAllUsers() throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        ResponseEntity<ArrayList<User>> response = new ResponseEntity<>(UserStatements.getAllUsers(conn), HttpStatus.OK);
        conn.close();
        return response;
    }

    @ApiOperation(value = "Create a new User")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully retrieved list", response = User.class),
            @ApiResponse(code = 400, message = "Bad request", response = Error.class),
            @ApiResponse(code = 401, message = "Invalid credentials", response = Error.class),
            @ApiResponse(code = 404, message = "User not found", response = Error.class)
    })
    @PostMapping
    private ResponseEntity<User> createUser(@RequestBody User user) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        ResponseEntity<User> response = new ResponseEntity<>(UserStatements.createUser(user, conn), HttpStatus.OK);
        conn.close();
        return response;
    }

    // Update a certain object
    @ApiOperation(value = "Update an User object")
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully updated the User object", response = User.class),
            @ApiResponse(code = 400, message = "Bad request", response = Error.class),
            @ApiResponse(code = 401, message = "Bad credentials", response = Error.class),
            @ApiResponse(code = 404, message = "User not found", response = Error.class)
    })
    @PutMapping("/{id}")
    private ResponseEntity<User> updateUser(
            @ApiParam(value = "Id of the User that you want to update", required = true) @PathVariable Integer id,
            @ApiParam(value = "The object with the User that you want to update", required = true) @RequestBody User user
    ) throws Exception {
        if (id.equals(user.getId())) {
            Connection conn = new DatabaseConnection().getConnection();
            User result = UserStatements.updateUser(user, conn);
            conn.close();
            return new ResponseEntity<>(result, HttpStatus.OK);
        } else {
            throw new BadRequestException("ID's are different");
        }
    }

    // Delete a certain address object.
    @ApiOperation(value = "Delete a user", response = User.class)
    @ApiResponses(value = {
            @ApiResponse(code = 200, message = "Successfully deleted the user", response = User.class),
            @ApiResponse(code = 400, message = "Bad request", response = Error.class),
            @ApiResponse(code = 401, message = "Bad credentials", response = Error.class),
            @ApiResponse(code = 404, message = "User not found", response = Error.class)
    })
    @DeleteMapping("/{id}")
    private ResponseEntity<User> deleteUser(
            @ApiParam(value = "Id for the object you want to delete", required = true) @PathVariable Integer id
    ) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        ResponseEntity<User> response = new ResponseEntity<>(UserStatements.deleteUser(id, conn), HttpStatus.OK);
        conn.close();
        return response;
    }
}
