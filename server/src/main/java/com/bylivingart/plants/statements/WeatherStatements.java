package com.bylivingart.plants.statements;

import com.bylivingart.plants.buienradar.BuienradarnlType;
import com.bylivingart.plants.buienradar.WeerstationType;
import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Unmarshaller;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.List;

public class WeatherStatements {

    public static BuienradarnlType getWeather() throws Exception{
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

    public static ArrayList<WeerstationType> getWeerStationByRegio(String regio) throws Exception{
       BuienradarnlType buienradarnlType = getWeather();
       List<WeerstationType> Weerstations = buienradarnlType.getWeergegevens().getActueelWeer().getWeerstations().getWeerstation();
       ArrayList<WeerstationType> SearchedWeerStation = new ArrayList<>();

        for (WeerstationType weerstationType : Weerstations) {
            if (weerstationType.getStationnaam().getRegio().contains(regio)){
                SearchedWeerStation.add(weerstationType);
            }
        }
        return SearchedWeerStation;
    }
}
