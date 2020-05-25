package com.bylivingart.plants.statements;

import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.buienradar.*;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;
import java.io.StringReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class WeatherStatements {

    public static BuienradarnlType getWeather() throws Exception {
        final CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpGet request = new HttpGet("https://data.buienradar.nl/1.0/feed/xml");
        JAXBContext jaxbContext;

        CloseableHttpResponse response = httpClient.execute(request);
        HttpEntity entity = response.getEntity();
        String result = EntityUtils.toString(entity);
        jaxbContext = JAXBContext.newInstance(BuienradarnlType.class);
        Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
        return (BuienradarnlType) jaxbUnmarshaller.unmarshal(new StringReader(result));
    }

    public static ArrayList<WeerstationType> getWeerStationByRegio(String regio, Connection conn) throws Exception {
        String regioEdit = "%" + regio + "%";
        PreparedStatement snStatement = conn.prepareStatement("SELECT * FROM stationnaam WHERE regio LIKE ?");
        snStatement.setString(1, regioEdit);
        ResultSet stationnaamResult = snStatement.executeQuery();

        ArrayList<StationnaamType> stationnaamTypes = getStationnaamFromResultSet(stationnaamResult);

        ArrayList<WeerstationType> weerstationsNew = new ArrayList<>();

        for (StationnaamType stationnaamType : stationnaamTypes) {
            int id = stationnaamType.getId();
            PreparedStatement wsStatement = conn.prepareStatement("SELECT * FROM weerstation WHERE stationnaam=?");
            wsStatement.setInt(1, id);
            ResultSet resultSet = wsStatement.executeQuery();
            ArrayList<WeerstationType> weerstations = getWeerstationsFromResultSet(resultSet, conn);
            WeerstationType lastWeerstation = weerstations.get(weerstations.size() - 1);
            weerstationsNew.add(lastWeerstation);
        }
        return weerstationsNew;
    }

    public static WeerstationType getWeerstationByLatLon(Double lat, Double lon) throws Exception {
        if (lat > 50.841774 && lat < 53.670272 && lon > 2.649452 && lon < 7.232709) {
            Double shortestDistance = null;
            WeerstationType weerstationResult = null;
            List<WeerstationType> weerstations = getWeather().getWeergegevens().getActueelWeer().getWeerstations().getWeerstation();
            for (WeerstationType weerstationType : weerstations) {
                Double latStation = Double.parseDouble(weerstationType.getLat());
                Double lonStation = Double.parseDouble(weerstationType.getLon());

                double distance = Math.sqrt(Math.pow(lat - latStation, 2) + Math.pow(lon - lonStation, 2));
                if (shortestDistance == null) {
                    shortestDistance = distance;
                    weerstationResult = weerstationType;
                } else {
                    if (shortestDistance > distance) {
                        shortestDistance = distance;
                        weerstationResult = weerstationType;
                    } else {
                    }
                }
            }
            return weerstationResult;
        } else {
            throw new BadRequestException("Coordinates are not from The Netherlands");
        }
    }

    private static ArrayList<WeerstationType> getWeerstationsFromResultSet(ResultSet resultSet, Connection conn) throws Exception {
        ArrayList<WeerstationType> weerstations = new ArrayList<>();
        if (!resultSet.next()) {
            throw new NotFoundException("Database is empty");
        } else {
            do {
                String stationCode = resultSet.getString(1);
                int stationnaamId = resultSet.getInt(2);
                String lat = resultSet.getString(3);
                String lon = resultSet.getString(4);
                String datum = resultSet.getString(5);
                String luchtvochtigheid = resultSet.getString(6);
                String temperatuurGC = resultSet.getString(7);
                String windsnelheidMS = resultSet.getString(8);
                String windsnelheidBF = resultSet.getString(9);
                String windrichtingGR = resultSet.getString(10);
                String windrichting = resultSet.getString(11);
                String luchtdruk = resultSet.getString(12);
                String zichtmeters = resultSet.getString(13);
                String windstotenMS = resultSet.getString(14);
                String regenMMPU = resultSet.getString(15);
                String zonintensiteitWM2 = resultSet.getString(16);
                String icoonactueelID = resultSet.getString(17);
                String temperatuur10Cm = resultSet.getString(18);
                String url = resultSet.getString(19);
                String latGraden = resultSet.getString(20);
                String lonGraden = resultSet.getString(21);
                String id = resultSet.getString(22);

                StationnaamType stationnaamObj = getStationnaamByID(stationnaamId, conn);

                IcoonactueelType icoonactueelObj = getIcoonactueelById(icoonactueelID, conn);

                WeerstationType weerstation = new WeerstationType(
                        stationCode,
                        stationnaamObj,
                        lat,
                        lon,
                        datum,
                        luchtvochtigheid,
                        temperatuurGC,
                        windsnelheidMS,
                        windsnelheidBF,
                        windrichtingGR,
                        windrichting,
                        luchtdruk,
                        zichtmeters,
                        windstotenMS,
                        regenMMPU,
                        zonintensiteitWM2,
                        icoonactueelObj,
                        temperatuur10Cm,
                        url,
                        latGraden,
                        lonGraden,
                        id
                );

                weerstations.add(weerstation);
            } while (resultSet.next());
            return weerstations;
        }
    }

    private static ArrayList<StationnaamType> getStationnaamFromResultSet(ResultSet resultSet) throws Exception {
        ArrayList<StationnaamType> stationnamen = new ArrayList<>();
        if (!resultSet.next()) {
            throw new NotFoundException("No data in result");
        } else {
            do {
                String value = resultSet.getString("value");
                String regio = resultSet.getString("regio");
                int id = resultSet.getInt("id");
                stationnamen.add(new StationnaamType(value, regio, id));
            } while (resultSet.next());
        }
        return stationnamen;
    }

    public static VerwachtingMeerdaagsType getForecast() throws Exception{
        return getWeather().getWeergegevens().getVerwachtingMeerdaags();
    }


    private static IcoonactueelType getIcoonactueelById(String id, Connection conn) throws Exception {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM icoonactueel WHERE id=?");
        ps.setString(1, id);
        ResultSet rs = ps.executeQuery();

        if (!rs.next()) {
            throw new NotFoundException("Can't find and entry on id: " + id);
        } else {
            String value = rs.getString("value");
            String zin = rs.getString("zin");
            return new IcoonactueelType(value, zin, id);
        }
    }


    private static StationnaamType getStationnaamByID(int id, Connection conn) throws Exception {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM stationnaam WHERE id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();

        if (!rs.next()) {
            throw new NotFoundException("Can't find an entry on id: " + id);
        } else {
            String value = rs.getString("value");
            String regio = rs.getString("regio");
            return new StationnaamType(value, regio, id);
        }
    }
}
