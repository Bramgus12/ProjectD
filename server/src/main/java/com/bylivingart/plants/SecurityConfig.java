package com.bylivingart.plants;

import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.Exceptions.UnauthorizedException;
import com.bylivingart.plants.dataclasses.User;
import com.bylivingart.plants.statements.UserStatements;
import org.apache.commons.codec.binary.Base64;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.AuthenticationEntryPoint;

import javax.servlet.http.HttpServletRequest;
import javax.sql.DataSource;
import javax.swing.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@Configuration
@EnableWebSecurity
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    private DataSource dataSource;

    public static int getUserIdFromBase64(HttpServletRequest request) throws Exception {
        String basic = request.getHeader("Authorization");
        Connection conn = new DatabaseConnection().getConnection();
        String base64 = basic.substring(6);
        byte[] array = Base64.decodeBase64(base64.getBytes());
        String decodedBase64 = new String(array);
        String[] base64Array = decodedBase64.split(":");
        String username = base64Array[0];
        String password = base64Array[1];

        if (UserStatements.checkUserPassword(password, username, conn)) {
            PreparedStatement ps = conn.prepareStatement("SELECT id FROM users where user_name=?");
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (!rs.next()) {
                throw new NotFoundException("User not found");
            } else {
                return rs.getInt("id");
            }
        } else {
            throw new UnauthorizedException("Unauthorized");
        }
    }

    public static User HashUserPassword(User user) {
        User newUser = new User();
        newUser.setId(user.getId());
        newUser.setAuthority(user.getAuthority());
        newUser.setUser_name(user.getUser_name());
        newUser.setEnabled(user.getEnabled());
        String newPassword = encoder().encode(user.getPassword());
        System.out.println(newPassword);
        newUser.setPassword(newPassword);
        return newUser;
    }

    @Bean
    public static javax.sql.DataSource createDataSource() throws Exception {
        String propFileName = "Database_config.properties";
        String[] values = GetPropertyValues.getDatabasePropValues(propFileName);
        org.postgresql.ds.PGSimpleDataSource ds = new org.postgresql.ds.PGSimpleDataSource();
        ds.setUrl(values[0]);
        ds.setUser(values[1]);
        ds.setPassword(values[2]);
        return ds;
    }

    @Bean
    public static PasswordEncoder encoder() {
        return new BCryptPasswordEncoder();
    }

    @Autowired
    protected void configureGlobal(AuthenticationManagerBuilder auth) throws Exception {
        auth.jdbcAuthentication().dataSource(dataSource)
                .usersByUsernameQuery("SELECT user_name, password, enabled"
                        + " FROM users WHERE user_name=?;")
                .authoritiesByUsernameQuery("SELECT user_name, authority "
                        + "FROM users WHERE user_name=?")
                .passwordEncoder(new BCryptPasswordEncoder());
    }


    @Configuration
    @Order(1)
    public static class UserStatementsSecurity3 extends WebSecurityConfigurerAdapter {
        @Autowired
        private AuthenticationEntryPoint authEntryPoint;

        protected void configure(HttpSecurity http) throws Exception {
            http
                    .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()
                    .csrf().disable().antMatcher("/admin/**")
                    .authorizeRequests().anyRequest()
                    .hasRole("ADMIN")
                    .and().httpBasic()
                    .authenticationEntryPoint(authEntryPoint);
        }
    }

    @Configuration
    @Order(2)
    public static class ApiWebSecurityConfigurationAdapter extends WebSecurityConfigurerAdapter {
        @Autowired
        private AuthenticationEntryPoint authEntryPoint;

        protected void configure(HttpSecurity http) throws Exception {
            http
                    .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS).and()
                    .csrf().disable()
                    .antMatcher("/user/**")
                    .authorizeRequests().anyRequest()
                    .hasAnyRole("USER", "ADMIN")
                    .and()
                    .httpBasic().authenticationEntryPoint(authEntryPoint);
        }
    }

    @Order(3)
    @Configuration
    public static class FormLoginWebSecurityConfigurerAdapter extends WebSecurityConfigurerAdapter {

        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http.csrf().disable().authorizeRequests().anyRequest().permitAll();
        }
    }

}
