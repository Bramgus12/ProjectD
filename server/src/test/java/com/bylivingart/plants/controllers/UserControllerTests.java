package com.bylivingart.plants.controllers;


import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultHandlers.print;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@RunWith(SpringRunner.class)
@ContextConfiguration(classes = {com.bylivingart.plants.SecurityConfig.class, com.bylivingart.plants.AuthenticationEntryPoint.class, com.bylivingart.plants.PlantsApplication.class})
@WebMvcTest(WeatherController.class)
public class UserControllerTests {

    @Autowired
    private MockMvc mvc;

    @Test
    public void getAllUsers() throws Exception {
        System.out.println("Running getAllUsers");
        mvc.perform(get("/admin/users/").contentType(MediaType.APPLICATION_JSON))
            .andDo(print())
            .andExpect(status().isUnauthorized());

        mvc.perform(get("/admin/users/")
                .header("Authorization", "Basic Li4uOi4uLg==")
            .contentType(MediaType.APPLICATION_JSON))
            .andDo(print())
            .andExpect(status().isUnauthorized());

//        mvc.perform(get("/user/users/")
//                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
//                .header("Authorization", "Basic YWRtaW46b25qdWlzdDEx"))
//            .andDo(print())
//            .andExpect(status().isOk());
    }

}
