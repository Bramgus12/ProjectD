package com.bylivingart.plants.controllers;

import com.bylivingart.plants.buienradar.BuienradarType;
import com.bylivingart.plants.buienradar.VerwachtingMeerdaagsType;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.hamcrest.Matchers.*;

@RunWith(SpringRunner.class)
@ContextConfiguration(classes = {com.bylivingart.plants.SecurityConfig.class, com.bylivingart.plants.AuthenticationEntryPoint.class, com.bylivingart.plants.PlantsApplication.class})
@WebMvcTest(WeatherController.class)
public class WeatherControllerTests {

    @Autowired
    private MockMvc mvc;

    @Test
    public void whenGetWeatherData_ReturnJsonObject() throws Exception {
        mvc.perform(get("/weather")
                .contentType(MediaType.APPLICATION_JSON)).andDo(print())
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON));
    }
// groningen: 53.670272, 7.232709
// Brugge: 50.841774, 2.649452
    @Test
    public void getWeatherByLatLon() throws Exception {
        mvc.perform(get("/weather/latlon?lat=51.945928&lon=4.464898/")
                .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.stationnaam.regio",hasToString("Rotterdam")));

        
    }
    @Test
    public void getErrorFromWeatherByLatLon() throws Exception{
        mvc.perform(get("/weather/latlon?lat=61.269172&lon=55.927234/")
                .contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isBadRequest())
                .andExpect(status().reason(containsString("Coordinates are not from The Netherlands")));
    }

    @Test
    public void getForecast() throws Exception {
        System.out.println("Running getForecast");
        //MvcResult mvcResult =
                mvc.perform(get("/weather/forecast").contentType(MediaType.APPLICATION_JSON))
                .andDo(print())
                .andExpect(status().isOk())
                .andReturn();
        //System.out.println("MVCResult: " + mvcResult.getResponse().getContentAsString());
    }
}
