package com.bylivingart.plants.dataclasses;

import com.bylivingart.plants.Exceptions.BadRequestException;
import io.swagger.annotations.ApiModelProperty;
import org.apache.commons.validator.routines.EmailValidator;
import org.springframework.stereotype.Controller;

import javax.validation.constraints.*;
import java.sql.Date;
import java.time.LocalDate;

@Controller
public class User {
    private int id;

    @NotBlank
    private String user_name;

    @Pattern(
            regexp = "((?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%!;]).{8,64})",
            message = "Password needs to have at least 1 uppercase character, 1 lowercase character, 1 number and 1 of the following symbols: @, #, $, %, ! and ;"
    )
    private String password;

    @NotBlank
    @Pattern(regexp = "(ROLE_)((ADMIN)|(USER))", message = "String should be either 'ROLE_ADMIN' or 'ROLE_USER'")
    private String authority;

    @NotNull
    private Boolean enabled;

    @NotBlank
    private String name;

    @Email(message = "Has to be a valid email")
    private String email;

    @PastOrPresent
    private LocalDate dateOfBirth;

    @NotBlank
    private String streetName;

    @NotNull
    private int houseNumber;

    private String addition;

    @NotBlank
    private String city;

    @Pattern(regexp = "\\A[1-9][0-9]{3}[ ]?([A-RT-Za-rt-z][A-Za-z]|[sS][BCbcE-Re-rT-Zt-z])\\z", message = "Postal code must match 1234AB")
    private String postalCode;

    public User(int id, String user_name, String password, String authority, Boolean enabled, String name, String email, LocalDate dateOfBirth, String streetName, int houseNumber, String addition, String city, String postalCode) {
        this.id = id;
        this.user_name = user_name;
        this.password = password;
        this.authority = authority;
        this.enabled = enabled;
        this.name = name;
        this.email = email;
        this.dateOfBirth = dateOfBirth;
        this.streetName = streetName;
        this.houseNumber = houseNumber;
        this.addition = addition;
        this.city = city;
        this.postalCode = postalCode;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public LocalDate getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(LocalDate dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
    }

    public String getStreetName() {
        return streetName;
    }

    public void setStreetName(String streetName) {
        this.streetName = streetName;
    }

    public int getHouseNumber() {
        return houseNumber;
    }

    public void setHouseNumber(int houseNumber) {
        this.houseNumber = houseNumber;
    }

    public String getAddition() {
        return addition;
    }

    public void setAddition(String addition) {
        this.addition = addition;
    }

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getPostalCode() {
        return postalCode;
    }

    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }

    public User() {
    }

    public Boolean getEnabled() {
        return enabled;
    }

    public void setEnabled(Boolean enabled) {
        this.enabled = enabled;
    }

    public String getAuthority() {
        return authority;
    }

    public void setAuthority(String authority) {
        this.authority = authority;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUser_name() {
        return user_name;
    }

    public void setUser_name(String user_name) {
        this.user_name = user_name;
    }
}
