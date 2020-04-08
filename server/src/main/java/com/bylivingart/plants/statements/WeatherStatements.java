package com.bylivingart.plants.statements;

import com.bylivingart.plants.buienradar.BuienradarnlType;
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

            BuienradarnlType buienradarnlType = (BuienradarnlType) jaxbUnmarshaller.unmarshal(new StringReader(result));
            return buienradarnlType;
        }
    }
}
