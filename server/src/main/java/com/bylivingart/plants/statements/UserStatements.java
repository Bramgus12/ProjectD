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
import java.sql.Date;
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
        user.setAuthority("ROLE_USER");
        return createUserAdmin(user, conn);
    }

    public static User createUserAdmin(User user, Connection conn) throws Exception {
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
                PreparedStatement ps = conn.prepareStatement("INSERT INTO users VALUES (DEFAULT, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
                fillPreparedStatement(ps, newUser).execute();

                PreparedStatement ps2 = conn.prepareStatement(
                        "SELECT * FROM users WHERE user_name=? AND password=? AND authority=? AND enabled=? AND name=? AND email=? " +
                                "AND date_of_birth=? AND street_name=? AND house_number=? AND addition=? AND city=? AND postal_code=?;"
                );
                ResultSet rs = fillPreparedStatement(ps2, newUser).executeQuery();
                if (!rs.next()) {
                    throw new NotFoundException("User not found");
                } else {
                    User response = getResult(rs.getInt("id"), rs);
                    response.setPassword(null);
                    return response;
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
        user.setAuthority("ROLE_USER");
        return updateUserAdmin(user, id, conn);
    }

    public static User updateUserAdmin(User user, int id, Connection conn) throws Exception {
        User newUser = SecurityConfig.HashUserPassword(user);

        if (id == newUser.getId()) {
            PreparedStatement ps = conn.prepareStatement("UPDATE users SET user_name=?, password=?, authority=?, enabled=?, name=?, email=? " +
                                                    ", date_of_birth=?, street_name=?, house_number=?, addition=?, city=?, postal_code=? " +
                                                    " WHERE id=?;");
            fillPreparedStatement(ps, newUser);
            ps.setInt(13, id);
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

    public static void deleteUser(Connection conn, HttpServletRequest request) throws Exception {
        int id = SecurityConfig.getUserIdFromBase64(request);
        deleteUserAdmin(id, conn);
    }


    public static void deleteUserAdmin(int id, Connection conn) throws Exception {
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id=?;");
        ps.setInt(1, id);
        ResultSet resultSet = ps.executeQuery();
        if (!resultSet.next()) {
            throw new NotFoundException("User doesn't exist.");
        } else {
            PreparedStatement ps1 = conn.prepareStatement("DELETE FROM user_plants WHERE user_id=?;");
            ps1.setInt(1, id);
            ps1.execute();
            PreparedStatement ps2 = conn.prepareStatement("DELETE FROM users where id=?;");
            ps2.setInt(1, id);
            ps2.execute();
        }
    }

    public static User getUserInfo(HttpServletRequest request, Connection conn) throws Exception {
        int id = SecurityConfig.getUserIdFromBase64(request);
        PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id=?");
        ps.setInt(1, id);
        ResultSet rs = ps.executeQuery();
        rs.next();
        return getResult(id, rs);
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
        ps.setString(5, user.getName());
        ps.setString(6, user.getEmail());
        ps.setDate(7, user.getDateOfBirth());
        ps.setString(8, user.getStreetName());
        ps.setInt(9, user.getHouseNumber());
        ps.setString(10, user.getAddition());
        ps.setString(11, user.getCity());
        ps.setString(12, user.getPostalCode());
        return ps;
    }

    private static User getResult(int id, ResultSet rs) throws Exception {
        String userName = rs.getString("user_name");
        String password = rs.getString("password");
        String authority = rs.getString("authority");
        Boolean enabled = rs.getBoolean("enabled");
        String name = rs.getString("name");
        String email = rs.getString("email");
        Date dateOfBirth = rs.getDate("date_of_birth");
        String streetName = rs.getString("street_name");
        int houseNumber = rs.getInt("house_number");
        String addition = rs.getString("addition");
        String city = rs.getString("city");
        String postal_code = rs.getString("postal_code");
        return new User(id, userName, password, authority, enabled, name, email, dateOfBirth, streetName, houseNumber, addition, city, postal_code);
    }
}
