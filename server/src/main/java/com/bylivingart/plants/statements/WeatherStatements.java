package com.bylivingart.plants.statements;

import com.bylivingart.plants.DatabaseConnection;
import com.bylivingart.plants.buienradar.BuienradarnlType;
import com.bylivingart.plants.buienradar.IcoonactueelType;
import com.bylivingart.plants.buienradar.StationnaamType;
import com.bylivingart.plants.buienradar.WeerstationType;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;
import javax.xml.crypto.Data;
import java.io.StringReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class WeatherStatements {

    public static BuienradarnlType getWeather() throws Exception {
        final CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpGet request = new HttpGet("https://data.buienradar.nl/1.0/feed/xml");
        JAXBContext jaxbContext;

        try (CloseableHttpResponse response = httpClient.execute(request)) {
            System.out.println(response.getStatusLine().toString());

            HttpEntity entity = response.getEntity();

            String result = EntityUtils.toString(entity);

            jaxbContext = JAXBContext.newInstance(BuienradarnlType.class);
            Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();

            return (BuienradarnlType) jaxbUnmarshaller.unmarshal(new StringReader(result));
        }
    }

    public static ArrayList<WeerstationType> getWeerStationByRegio(String regio) throws Exception {
        BuienradarnlType buienradarnlType = getWeather();
        List<WeerstationType> Weerstations = buienradarnlType.getWeergegevens().getActueelWeer().getWeerstations().getWeerstation();
        ArrayList<WeerstationType> SearchedWeerStation = new ArrayList<>();

        for (WeerstationType weerstationType : Weerstations) {
            if (weerstationType.getStationnaam().getRegio().contains(regio)) {
                SearchedWeerStation.add(weerstationType);
            }
        }
        return SearchedWeerStation;
    }

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

    public static void storeWeerstation(WeerstationType weerstation, int stationnaamId, String icoonactueelId) throws Exception {
        Connection conn = new DatabaseConnection().getConnection();
        PreparedStatement preparedStatement = conn.prepareStatement("INSERT INTO weerstation VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
        preparedStatement.setString(1, weerstation.getStationcode());
        preparedStatement.setInt(2, stationnaamId);
        preparedStatement.setString(3, weerstation.getLat());
        preparedStatement.setString(4, weerstation.getLon());
        preparedStatement.setString(5, weerstation.getDatum());
        preparedStatement.setString(6, weerstation.getLuchtvochtigheid());
        preparedStatement.setString(7, weerstation.getTemperatuurGC());
        preparedStatement.setString(8, weerstation.getWindsnelheidMS());
        preparedStatement.setString(9, weerstation.getWindsnelheidBF());
        preparedStatement.setString(10, weerstation.getWindrichtingGR());
        preparedStatement.setString(11, weerstation.getWindrichting());
        preparedStatement.setString(12, weerstation.getLuchtdruk());
        preparedStatement.setString(13, weerstation.getZichtmeters());
        preparedStatement.setString(14, weerstation.getWindstotenMS());
        preparedStatement.setString(15, weerstation.getRegenMMPU());
        preparedStatement.setString(16, weerstation.getZonintensiteitWM2());
        preparedStatement.setString(17, icoonactueelId);
        preparedStatement.setString(18, weerstation.getTemperatuur10Cm());
        preparedStatement.setString(19, weerstation.getUrl());
        preparedStatement.setString(20, weerstation.getLatGraden());
        preparedStatement.setString(21, weerstation.getLonGraden());
        preparedStatement.setString(22, weerstation.getId());
        preparedStatement.execute();
        conn.close();
    }
}
