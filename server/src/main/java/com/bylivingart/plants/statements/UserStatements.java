package com.bylivingart.plants.statements;

import com.bylivingart.plants.Exceptions.BadRequestException;
import com.bylivingart.plants.Exceptions.NotFoundException;
import com.bylivingart.plants.Exceptions.UnauthorizedException;
import com.bylivingart.plants.SecurityConfig;
import com.bylivingart.plants.dataclasses.User;
import org.springframework.security.crypto.bcrypt.BCrypt;
import org.springframework.web.client.HttpClientErrorException;

import javax.servlet.http.HttpServletRequest;
import java.security.Security;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

public class UserStatements {
    public static ArrayList<User> getAllUsers(Connection conn) throws Exception {
        ArrayList<User> list = new ArrayList<>();
        PreparedStatement preparedStatement = conn.prepareStatement("SELECT * FROM users");
        ResultSet result = preparedStatement.executeQuery();
        if (!result.next()) {
            throw new NotFoundException("No data in database");
        } else {
            do {
                list.add(getResult(result.getInt("id"), result));
            } while (result.next());
            return list;
        }
    }

    public static User createUser(User user, Connection conn) throws Exception {
        boolean userExists = false;
        ArrayList<User> users = getAllUsers(conn);
        for (User userFromList : users) {
            if (user.getUser_name().equals(userFromList.getUser_name())) {
                userExists = true;
                break;
            }
        }
        if (!userExists) {
            if (!user.getPassword().isEmpty() && user.getPassword().length() > 6) {
                User newUser = SecurityConfig.HashUserPassword(user);
                PreparedStatement ps = conn.prepareStatement("INSERT INTO users VALUES (DEFAULT, ?, ?, ?, ?)");
                newUser.setAuthority("ROLE_USER");
                fillPreparedStatement(ps, newUser).execute();

                PreparedStatement ps2 = conn.prepareStatement("SELECT * FROM users WHERE user_name=? AND password=? AND authority=? AND enabled=?");
                ResultSet rs = fillPreparedStatement(ps2, newUser).executeQuery();
                if (!rs.next()) {
                    throw new NotFoundException("User not found");
                } else {
                    return getResult(rs.getInt("id"), rs);
                }
            } else {
                throw new BadRequestException("Password is not long enough. It has to be at least a length of 6.");
            }
        } else {
            throw new BadRequestException("User already exists.");
        }
    }

    public static User updateUser(User user, Connection conn, HttpServletRequest request) throws Exception {
        int id = SecurityConfig.getUserIdFromBase64(request);
        User newUser = SecurityConfig.HashUserPassword(user);
        newUser.setAuthority("ROLE_USER");

        if (id == newUser.getId()) {
            PreparedStatement ps = conn.prepareStatement("UPDATE users SET user_name=?, password=?, authority=?, enabled=? WHERE id=?;");
            fillPreparedStatement(ps, newUser);
            ps.setInt(5, id);
            ps.executeUpdate();

            PreparedStatement preparedStatement1 = conn.prepareStatement("SELECT * FROM users WHERE id=?;");
            preparedStatement1.setInt(1, id);
            ResultSet resultSet = preparedStatement1.executeQuery();

            if (!resultSet.next()) {
                throw new NotFoundException("User doesn't exist on this id after updating");
            } else {
                return getResult(id, resultSet);
            }
        } else {
            throw new UnauthorizedException("Unauthorized");
        }
    }

    public static User deleteUser(Connection conn, HttpServletRequest request) throws Exception {
        int id = SecurityConfig.getUserIdFromBase64(request);
        PreparedStatement preparedStatement = conn.prepareStatement("SELECT * FROM users WHERE id=?;");
        preparedStatement.setInt(1, id);
        ResultSet resultSet = preparedStatement.executeQuery();
        if (!resultSet.next()) {
            throw new NotFoundException("User doesn't exist.");
        } else {
            User user = getResult(id, resultSet);
            PreparedStatement preparedStatement1 = conn.prepareStatement("DELETE FROM users where id=?;");
            preparedStatement1.setInt(1, id);
            preparedStatement1.execute();
            return user;
        }

    }

    public static boolean checkUserPassword(String password, String userName, Connection conn) throws Exception {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE user_name=?;");
        ps.setString(1, userName);
        ResultSet rs = ps.executeQuery();
        if (!rs.next()) {
            throw new NotFoundException("User not found");
        } else {
            User user = getResult(rs.getInt("id"), rs);
            return BCrypt.checkpw(password, user.getPassword());
        }
    }

    private static PreparedStatement fillPreparedStatement(PreparedStatement ps, User user) throws Exception{
        ps.setString(1, user.getUser_name());
        ps.setString(2, user.getPassword());
        ps.setString(3, user.getAuthority());
        ps.setBoolean(4, user.getEnabled());
        return ps;
    }

    private static User getResult(int id, ResultSet resultSet) throws Exception {
        String user_nameResult = resultSet.getString("user_name");
        String passwordResult = resultSet.getString("password");
        String authorityResult = resultSet.getString("authority");
        Boolean enabledResult = resultSet.getBoolean("enabled");
        return new User(id, user_nameResult, passwordResult, authorityResult, enabledResult);
    }
}
