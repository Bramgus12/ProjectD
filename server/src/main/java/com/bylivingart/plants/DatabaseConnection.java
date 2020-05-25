package com.bylivingart.plants;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DatabaseConnection {

    public Connection getConnection() throws Exception{
        String propFileName = "Database_config.properties";
        String[] values = GetPropertyValues.getDatabasePropValues(propFileName);
        return DriverManager.getConnection(values[0], values[1], values[2]);
    }
}