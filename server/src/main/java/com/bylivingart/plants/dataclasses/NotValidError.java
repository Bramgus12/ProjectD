package com.bylivingart.plants.dataclasses;

import java.util.HashMap;

public class NotValidError extends Error {
    private HashMap<String, String> errors;

    public NotValidError(int status, String error, HashMap<String, String> errors, String path) {
        super(status, error, "A field is not valid", path);
        this.errors = errors;
    }

    public HashMap<String, String> getErrors() {
        return errors;
    }

    public void setErrors(HashMap<String, String> errors) {
        this.errors = errors;
    }
}
