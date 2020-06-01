package com.bylivingart.plants;

import com.bylivingart.plants.controllers.WeatherControllerTests;
import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;
import org.springframework.boot.test.context.SpringBootTest;

@RunWith(Suite.class)
@Suite.SuiteClasses({WeatherControllerTests.class})
@SpringBootTest
public class PlantsApplicationTestsRunner {
    @Test
    void contextLoads() {
    }
}
