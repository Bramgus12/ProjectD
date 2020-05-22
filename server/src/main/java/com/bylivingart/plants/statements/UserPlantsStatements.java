package com.bylivingart.plants.statements;

import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.FileService;
import com.bylivingart.plants.SecurityConfig;
import com.bylivingart.plants.dataclasses.UserPlants;

import javax.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;

public class UserPlantsStatements {

    public static ArrayList<UserPlants> getAllUserPlants(Connection conn) throws Exception {
        ResultSet rs = conn.createStatement().executeQuery("SELECT * FROM user_plants");
        ArrayList<UserPlants> list = new ArrayList<>();
        if (!rs.next()) {
            throw new NotFoundException("No data in database");
        } else {
            do {
                list.add(getAllFromResultSet(rs));
            } while (rs.next());
            return list;
        }
    }

    public static ArrayList<UserPlants> getUserPlants(Connection conn, HttpServletRequest request) throws Exception {
        int userId = SecurityConfig.getUserIdFromBase64(request);
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM user_plants WHERE user_id=?");
        ps.setInt(1, userId);
        ResultSet rs = ps.executeQuery();
        ArrayList<UserPlants> list = new ArrayList<>();
        if (!rs.next()) {
            throw new NotFoundException("No data in database");
        } else {
            do {
                list.add(getAllFromResultSet(rs));
            } while (rs.next());
        }
        return list;
    }

    public static UserPlants createUserPlants(UserPlants userPlants, Connection conn, HttpServletRequest request) throws Exception {
        int userId = SecurityConfig.getUserIdFromBase64(request);
        PreparedStatement ps = conn.prepareStatement("INSERT INTO user_plants VALUES (DEFAULT, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);");
        PreparedStatement filledPs = fillPreparedStatement(ps, userPlants, userId, 1);
        filledPs.execute();

        PreparedStatement ps2 = conn.prepareStatement(
                "SELECT * FROM user_plants WHERE user_id=? AND nickname=? AND pot_volume=? " +
                        "AND lat=? AND lon=? AND image_name=? AND last_water_date=? AND distance_to_window=? AND max_temp=? AND min_temp=? AND plant_id=?;"
        );
        PreparedStatement filledPs2 = fillPreparedStatement(ps2, userPlants, userId, 1);
        ResultSet rs = filledPs2.executeQuery();

        if (!rs.next()) {
            throw new NotFoundException("Can't find the plant");
        } else {
            return getAllFromResultSet(rs);
        }
    }

    public static boolean updateUserPlant(UserPlants userPlants, Connection conn, HttpServletRequest request) throws Exception {
        int userId = SecurityConfig.getUserIdFromBase64(request);
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM user_plants WHERE id=? AND user_id=?;");
        ps.setInt(1, userPlants.getId());
        ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) {
            PreparedStatement ps2 = conn.prepareStatement(
                    "UPDATE user_plants SET user_id=?, nickname=?, pot_volume=?, lat=?, lon=?, image_name=?, " +
                            "last_water_date=?, distance_to_window=?, max_temp=?, min_temp=?, plant_id=? WHERE id=?"
            );
            PreparedStatement filledPs2 = fillPreparedStatement(ps2, userPlants, userId, 1);
            filledPs2.setInt(12, userPlants.getId());
            filledPs2.execute();
            return true;
        } else {
            return false;
        }
    }

    public static void deleteUserPlant(int id, Connection conn, HttpServletRequest request) throws Exception {
        int userId = SecurityConfig.getUserIdFromBase64(request);
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM user_plants WHERE id=? AND user_id=?;");
        ps.setInt(1, id);
        ps.setInt(2, userId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            PreparedStatement ps2 = conn.prepareStatement("DELETE FROM user_plants WHERE id=? AND user_id=?");
            ps2.setInt(1, id);
            ps2.setInt(2, userId);
            ps2.execute();
            UserPlants userPlants = getAllFromResultSet(rs);
            FileService.deleteImage(String.valueOf(userId), userPlants.getImageName(), String.valueOf(userPlants.getId()), true);
        } else {
            throw new NotFoundException("UserPlant not found.");
        }
    }

    private static PreparedStatement fillPreparedStatement(PreparedStatement ps, UserPlants userPlants, int userId, int startingIndex) throws Exception {
        ps.setInt(startingIndex, userId);
        ps.setString(startingIndex + 1, userPlants.getNickname());
        ps.setDouble(startingIndex + 2, userPlants.getPotVolume());
        ps.setDouble(startingIndex + 3, userPlants.getLat());
        ps.setDouble(startingIndex + 4, userPlants.getLon());
        ps.setString(startingIndex + 5, userPlants.getImageName());
        ps.setTimestamp(startingIndex + 6, Timestamp.valueOf(userPlants.getLastWaterDate()));
        ps.setDouble(startingIndex + 7, userPlants.getDistanceToWindow());
        ps.setInt(startingIndex + 8, userPlants.getMaxTemp());
        ps.setInt(startingIndex + 9, userPlants.getMinTemp());
        ps.setInt(startingIndex + 10, userPlants.getPlantId());
        return ps;
    }

    private static UserPlants getAllFromResultSet(ResultSet rs) throws Exception {
        int id = rs.getInt("id");
        int userId = rs.getInt("user_id");
        String nickname = rs.getString("nickname");
        double potVolume = rs.getDouble("pot_volume");
        double lat = rs.getDouble("lat");
        double lon = rs.getDouble("lon");
        String imageName = rs.getString("image_name");
        LocalDateTime lastWaterDate = rs.getTimestamp("last_water_date").toLocalDateTime();
        double distanceToWindow = rs.getDouble("distance_to_window");
        int maxTemp = rs.getInt("max_temp");
        int minTemp = rs.getInt("min_temp");
        int plantId = rs.getInt("plant_id");
        return new UserPlants(id, userId, nickname, potVolume, lat, lon, imageName, lastWaterDate, distanceToWindow, maxTemp, minTemp, plantId);
    }

}