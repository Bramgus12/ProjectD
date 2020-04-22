package com.bylivingart.plants;

import com.bylivingart.plants.buienradar.BuienradarnlType;
import com.bylivingart.plants.buienradar.IcoonactueelType;
import com.bylivingart.plants.buienradar.StationnaamType;
import com.bylivingart.plants.buienradar.WeerstationType;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import static com.bylivingart.plants.statements.WeatherStatements.getWeather;

@Component
public class ScheduledTaks {


    @Scheduled(fixedRate = 1200000)
    public static void storeWeatherData() {
        Connection conn = new DatabaseConnection().getConnection();
        try {
            BuienradarnlType weather = getWeather();
            List<WeerstationType> weerStations = weather.getWeergegevens().getActueelWeer().getWeerstations().getWeerstation();
            for (WeerstationType weerstation : weerStations) {
                IcoonactueelType icoonactueel = weerstation.getIcoonactueel();
                StationnaamType stationnaam = weerstation.getStationnaam();
                String icoonactueelId;

                PreparedStatement preparedStatementIcoonactueel = conn.prepareStatement("SELECT * FROM icoonactueel WHERE id=?");
                preparedStatementIcoonactueel.setString(1, icoonactueel.getID());
                ResultSet resultIcoonactueel = preparedStatementIcoonactueel.executeQuery();

                if (!resultIcoonactueel.next()) {
                    storeIcoonActueel(icoonactueel);
                    icoonactueelId = icoonactueel.getID();
                } else {
                    icoonactueelId = resultIcoonactueel.getString("id");
                }

                PreparedStatement preparedStatementStationnaam = conn.prepareStatement("SELECT * FROM stationnaam WHERE value=?");
                preparedStatementStationnaam.setString(1, stationnaam.getValue());
                ResultSet resultStationnaam = preparedStatementStationnaam.executeQuery();
                int stationnaamId;

                if (!resultStationnaam.next()) {
                    storeStationnaam(stationnaam);
                }
                stationnaamId = getStationnaamId(stationnaam);

                storeWeerstation(weerstation, stationnaamId, icoonactueelId);
            }
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void storeIcoonActueel(IcoonactueelType icoonactueel) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        PreparedStatement preparedStatement = conn.prepareStatement("INSERT INTO icoonactueel VALUES (?, ?, ?)");
        preparedStatement.setString(1, icoonactueel.getID());
        preparedStatement.setString(2, icoonactueel.getValue());
        preparedStatement.setString(3, icoonactueel.getZin());
        preparedStatement.execute();
        conn.close();
    }

    public static void storeStationnaam(StationnaamType stationnaam) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        PreparedStatement preparedStatement = conn.prepareStatement("INSERT INTO stationnaam VALUES (DEFAULT, ?, ?)");
        preparedStatement.setString(1, stationnaam.getValue());
        preparedStatement.setString(2, stationnaam.getRegio());
        preparedStatement.execute();
        conn.close();
    }

    public static int getStationnaamId(StationnaamType stationnaam) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        PreparedStatement preparedStatementGetId = conn.prepareStatement("SELECT * FROM stationnaam WHERE value=? AND regio=?");
        preparedStatementGetId.setString(1, stationnaam.getValue());
        preparedStatementGetId.setString(2, stationnaam.getRegio());
        ResultSet resultSet = preparedStatementGetId.executeQuery();
        conn.close();

        if (resultSet.next()) {
            return resultSet.getInt("id");
        } else {
            throw new SQLException("Couldn't find id of object.");
        }
    }

    public static void storeWeerstation(WeerstationType ws, int stationnaamId, String icoonactueelId) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        PreparedStatement ps = conn.prepareStatement("INSERT INTO weerstation VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        ps.setString(1, ws.getStationcode());
        ps.setInt(2, stationnaamId);
        ps.setString(3, ws.getLat());
        ps.setString(4, ws.getLon());
        ps.setString(5, ws.getDatum());
        ps.setString(6, ws.getLuchtvochtigheid());
        ps.setString(7, ws.getTemperatuurGC());
        ps.setString(8, ws.getWindsnelheidMS());
        ps.setString(9, ws.getWindsnelheidBF());
        ps.setString(10, ws.getWindrichtingGR());
        ps.setString(11, ws.getWindrichting());
        ps.setString(12, ws.getLuchtdruk());
        ps.setString(13, ws.getZichtmeters());
        ps.setString(14, ws.getWindstotenMS());
        ps.setString(15, ws.getRegenMMPU());
        ps.setString(16, ws.getZonintensiteitWM2());
        ps.setString(17, icoonactueelId);
        ps.setString(18, ws.getTemperatuur10Cm());
        ps.setString(19, ws.getUrl());
        ps.setString(20, ws.getLatGraden());
        ps.setString(21, ws.getLonGraden());
        ps.setString(22, ws.getId());
        ps.execute();
        conn.close();
    }
}
