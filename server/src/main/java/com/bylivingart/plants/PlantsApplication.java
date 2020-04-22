package com.bylivingart.plants;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class PlantsApplication {

	public static void main(String[] args) {
		SpringApplication.run(PlantsApplication.class, args);
	}

	public static void printErrorInConsole(String errorCode) {
		String ANSI_RESET = "\u001B[0m";
		String ANSI_RED = "\u001B[31m";
		System.out.println(ANSI_RED + errorCode + ANSI_RESET);
	}
}
