package com.bylivingart.plants.dataclasses;

import java.util.HashMap;

public class NotValidError extends Error {
    private HashMap<String, String> ValidationErrors;

    public NotValidError(int status, String error, HashMap<String, String> ValidationErrors, String path) {
        super(status, error, "A field is not valid", path);
        this.ValidationErrors = ValidationErrors;
    }

    public HashMap<String, String> getValidationErrors() {
        return ValidationErrors;
    }

    public void setValidationErrors(HashMap<String, String> ValidationErrors) {
        this.ValidationErrors = ValidationErrors;
    }
}
