package com.bylivingart.plants;

import org.junit.internal.runners.statements.Fail;
import org.junit.jupiter.api.Test;
import org.junit.runner.JUnitCore;
import org.junit.runner.Result;
import org.junit.runner.notification.Failure;
import org.springframework.boot.test.context.SpringBootTest;

//@SpringBootTest
public class PlantsApplicationTests {

	public static void main(String args[]) {
		Result res = JUnitCore.runClasses(PlantsApplicationTestsRunner.class);
		for(Failure fail : res.getFailures()){
			System.out.printf(fail.toString());
		}

		System.out.printf("Test completed, result: %s, failed: %s\n", res.wasSuccessful() ? "success" : "failed", res.getFailureCount());
	}
}
