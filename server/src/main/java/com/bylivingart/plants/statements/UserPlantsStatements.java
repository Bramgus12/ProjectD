package com.bylivingart.plants.statements;

import java.io.File;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import com.bylivingart.plants.FileService;
import com.bylivingart.plants.GetPropertyValues;
import com.bylivingart.plants.dataclasses.UserPlants;
import org.springframework.web.multipart.MultipartFile;

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

    public static UserPlants createUserPlants(UserPlants userPlants, Connection conn) throws Exception {    
        PreparedStatement ps = conn.prepareStatement("INSERT INTO user_plants VALUES (DEFAULT, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);");
        PreparedStatement filledPs = fillPreparedStatement(ps, userPlants, 1);
        filledPs.execute();

        PreparedStatement ps2 = conn.prepareStatement(
            "SELECT * FROM user_plants WHERE device_id=? AND nickname=? AND pot_volume=? " +
            "AND lat=? AND lon=? AND image_name=? AND last_water_date=? AND distance_to_window=? AND max_temp=? AND min_temp=? AND plant_id=?;"
        );
        PreparedStatement filledPs2 = fillPreparedStatement(ps2, userPlants, 1);
        ResultSet rs = filledPs2.executeQuery();

        if (!rs.next()){
            throw new Exception("Can't find the plant");
        } else {
            UserPlants newUserPlant = getAllFromResultSet(rs);
            return newUserPlant;
        }
    }

    public static boolean updateUserPlant(UserPlants userPlants, Connection conn) throws Exception {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM user_plants WHERE id=?;");
        ps.setInt(1, userPlants.getId());
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            PreparedStatement ps2 = conn.prepareStatement(
                    "UPDATE user_plants SET device_id=?, nickname=?, pot_volume=?, lat=?, lon=?, image_name=?, " +
                            "last_water_date=?, distance_to_window=?, max_temp=?, min_temp=?, plant_id=? WHERE id=?"
            );
            PreparedStatement filledPs2 = fillPreparedStatement(ps2, userPlants, 1);
            filledPs2.setInt(12, userPlants.getId());
            filledPs2.execute();
            return true;
        } else {
            return false;
        }
    }

    public static boolean deleteUserPlant(int id, Connection conn) throws Exception {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM user_plants WHERE id=?;");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();

        PreparedStatement ps2 = conn.prepareStatement("DELETE FROM user_plants WHERE id=?");
        ps2.setInt(1, id);
        ps2.execute();

        return rs.next();
    }

    private static PreparedStatement fillPreparedStatement(PreparedStatement ps, UserPlants userPlants, int startingIndex) throws Exception{
        ps.setString(startingIndex, userPlants.getDeviceId());
        ps.setString(startingIndex + 1, userPlants.getNickname());
        ps.setDouble(startingIndex + 2, userPlants.getPotVolume());
        ps.setDouble(startingIndex + 3, userPlants.getLat());
        ps.setDouble(startingIndex + 4, userPlants.getLon());
        ps.setString(startingIndex + 5, userPlants.getImageName());
        ps.setString(startingIndex + 6, userPlants.getLastWaterDate());
        ps.setDouble(startingIndex + 7, userPlants.getDistanceToWindow());
        ps.setInt(startingIndex + 8, userPlants.getMaxTemp());
        ps.setInt(startingIndex + 9, userPlants.getMinTemp());
        ps.setInt(startingIndex + 10, userPlants.getPlantId());
        return ps;
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