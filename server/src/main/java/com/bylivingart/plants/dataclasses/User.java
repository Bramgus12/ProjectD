package com.bylivingart.plants.dataclasses;

import com.bylivingart.plants.Exceptions.BadRequestException;
import io.swagger.annotations.ApiModelProperty;
import org.apache.commons.validator.routines.EmailValidator;
import org.springframework.stereotype.Controller;

import javax.validation.constraints.*;
import java.sql.Date;

@Controller
public class User {
    private int id;


    private String user_name;


    private String password;

    @NotBlank
    @Pattern(regexp = "(ROLE_)((ADMIN)|(USER))")
    private String authority;

    @NotNull
    private Boolean enabled;

    @NotBlank
    private String name;

    @Email(message = "Email not valid")
    private String email;

    @Past
    private Date dateOfBirth;
    private String streetName;
    private int houseNumber;
    private String addition;
    private String city;
    private String postalCode;

    public User(int id, String user_name, String password, String authority, Boolean enabled, String name, String email, Date dateOfBirth, String streetName, int houseNumber, String addition, String city, String postalCode) {
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

    public Date getDateOfBirth() {
        return dateOfBirth;
    }

    public void setDateOfBirth(Date dateOfBirth) {
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
