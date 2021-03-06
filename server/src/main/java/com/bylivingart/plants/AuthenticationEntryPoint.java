package com.bylivingart.plants;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.www.BasicAuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@Component
public class AuthenticationEntryPoint extends BasicAuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authEx)
            throws IOException {
        response.addHeader("WWW-Authenticate", "Basic realm=" + getRealmName());
        response.addHeader("content-type", "application/json");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        System.out.println("HTTP STATUS 401 - " + authEx.getMessage() + " - URI: " + request.getRequestURI() + " - Host: " + request.getRemoteHost());
        HandleException.handleUnauthorizedException(authEx, response);
    }

    @Override
    public void afterPropertiesSet() {
        setRealmName("DeveloperStack");
        super.afterPropertiesSet();
    }

}