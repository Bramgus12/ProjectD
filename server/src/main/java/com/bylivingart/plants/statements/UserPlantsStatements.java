package com.bylivingart.plants.statements;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import com.bylivingart.plants.dataclasses.UserPlants;

public class UserPlantsStatements {

    public static ArrayList<UserPlants> getAllUserPlants(Connection conn) throws Exception {
        ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM user_plants");
        ArrayList<UserPlants> list = new ArrayList<>();
        if (!rs.next()) {
            throw new Exception("No data in database");
        } else {
            do {
                list.add(getAllFromResultSet(rs));
            } while (rs.next());
            return list;
        }
    }

    private static UserPlants getAllFromResultSet(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        String deviceId = rs.getString("device_id");
        String nickname = rs.getString("nickname");
        double potVolume = rs.getDouble("pot_volume");
        double lat = rs.getDouble("lat");
        double lon = rs.getDouble("lon");
        String imageName = rs.getString("image_name");
        String lastWaterDate = rs.getString("last_water_date");
        double distanceToWindow = rs.getDouble("distance_to_window");
        int maxTemp = rs.getInt("max_temp");
        int minTemp = rs.getInt("min_temp");
        int plantId = rs.getInt("plant_id");
        return new UserPlants(id, deviceId, nickname, potVolume, lat, lon, imageName, lastWaterDate, distanceToWindow, maxTemp, minTemp, plantId);
    }
    
}