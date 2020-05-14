package com.bylivingart.plants.statements;

import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.dataclasses.Plants;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class PlantsStatements {
    public static ArrayList<Plants> getAllPlants(Connection conn) throws Exception {
        ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM plants");
        ArrayList<Plants> plantsList = new ArrayList<>();
        if (!rs.next()) {
            throw new NotFoundException("No data in database");
        } else {
            do {
                Plants newPlant = createObjectFromResultSet(rs);
                plantsList.add(newPlant);
            } while (rs.next());
            return plantsList;
        }
    }

    public static Plants getPlant(int id, Connection conn) throws Exception {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM plants WHERE id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            throw new NotFoundException("No data in database");
        } else {
            return createObjectFromResultSet(rs);
        }
    }

    public static Plants createPlant(Plants plant, Connection conn) throws Exception {
        PreparedStatement ps = conn.prepareStatement("INSERT INTO plants VALUES (DEFAULT, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        PreparedStatement filledPs = fillPreparedStatement(ps, plant, 1);
        filledPs.execute();

        PreparedStatement ps2 = conn.prepareStatement(
                "SELECT * FROM plants WHERE name=? AND water_scale=? AND water_number=? AND water_text=? AND sun_scale=? AND sun_number=? AND sun_text=? AND description=? AND optimum_temp=? AND image_name=?"
        );
        PreparedStatement filledPs2 = fillPreparedStatement(ps2, plant, 1);

        ResultSet rs = filledPs2.executeQuery();
        if (!rs.next()) {
            throw new NotFoundException("Cant find the plant");
        } else {
            return createObjectFromResultSet(rs);
        }
    }

    public static boolean deletePlant(int id, Connection conn) throws Exception {
        PreparedStatement ps2 = conn.prepareStatement("SELECT * FROM plants WHERE id=?");
        ps2.setInt(1, id);
        ResultSet rs = ps2.executeQuery();

        PreparedStatement ps = conn.prepareStatement("DELETE FROM plants WHERE id=?;");
        ps.setInt(1, id);
        ps.execute();


        return rs.next();
    }

    public static boolean updatePlant(Plants plant, Connection conn) throws Exception {
        PreparedStatement ps2 = conn.prepareStatement("SELECT * FROM plants WHERE id=?");
        ps2.setInt(1, plant.getId());
        ResultSet rs = ps2.executeQuery();

        if (rs.next()) {
            PreparedStatement ps = conn.prepareStatement(
                    "UPDATE plants SET name=?, water_scale=?, water_number=?, water_text=?, sun_scale=?, sun_number=?, sun_text=?, description=?, optimum_temp=?, image_name=? WHERE id=?"
            );
            ps.setInt(10, plant.getId());
            fillPreparedStatement(ps, plant, 1).execute();
            return true;
        } else {
            return false;
        }
    }

    private static PreparedStatement fillPreparedStatement(PreparedStatement ps, Plants plant, int startingNumber) throws Exception {
        ps.setString(startingNumber, plant.getName());
        ps.setDouble(startingNumber + 1, plant.getWaterScale());
        ps.setDouble(startingNumber + 2, plant.getWaterNumber());
        ps.setString(startingNumber + 3, plant.getWaterText());
        ps.setDouble(startingNumber + 4, plant.getSunScale());
        ps.setDouble(startingNumber + 5, plant.getSunNumber());
        ps.setString(startingNumber + 6, plant.getSunText());
        ps.setString(startingNumber + 7, plant.getDescription());
        ps.setInt(startingNumber + 8, plant.getOptimumTemp());
        ps.setString(startingNumber + 9, plant.getImageName());
        return ps;
    }


    private static Plants createObjectFromResultSet(ResultSet rs) throws Exception {
        int id = rs.getInt(1);
        String name = rs.getString(2);
        double waterScale = rs.getDouble(3);
        double waterNumber = rs.getDouble(4);
        String waterText = rs.getString(5);
        double sunScale = rs.getDouble(6);
        double sunNumber = rs.getDouble(7);
        String sunText = rs.getString(8);
        String description = rs.getString(9);
        int optimumTemp = rs.getInt(10);
        String imageName = rs.getString(11);
        return new Plants(id, name, waterScale, waterNumber, waterText, sunScale, sunNumber, sunText, description, optimumTemp, imageName);
    }
}