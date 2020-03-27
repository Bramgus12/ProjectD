package com.bylivingart.plants.statements;

import org.apache.http.Header;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class WeatherStatements {

    public static void getWeather() throws Exception{
        final CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpGet request = new HttpGet("https://data.buienradar.nl/1.0/feed/xml");

        try (CloseableHttpResponse response = httpClient.execute(request)) {
            System.out.println(response.getStatusLine().toString());

            HttpEntity entity = response.getEntity();
            Header headers = entity.getContentType();
            System.out.println(headers);

            String result = EntityUtils.toString(entity);
            System.out.println(result);
        }
    }
}
