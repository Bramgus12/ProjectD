package com.bylivingart.plants.dataclasses;

import javax.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class UserPlants {
    @Null
    private int id;

    @NotNull
    private int userId;

    @NotBlank
    private String nickname;

    @NotNull
    @Max(5)
    @Min(0)
    private BigDecimal potVolume;

    @NotNull
    private BigDecimal lat;

    @NotNull
    private BigDecimal lon;

    @NotBlank
    private String imageName;

    @PastOrPresent(message = "Must be a date in the past or the present.")
    private LocalDateTime lastWaterDate;

    @NotNull
    @Max(value = 5, message = "Has to be lower than 5.0")
    @Min(value = 0, message = "Hast to be higher than 0.0")
    private BigDecimal distanceToWindow;

    @NotNull
    @Max(value = 55, message = "Temperature has to be lower than 55")
    @Min(value = -20, message = "Temperature has to be higher than -20")
    private int maxTemp;

    @Max(value = -20, message = "Temperature has to be higher than -20")
    @Min(value = 55, message = "Temperature has to be lower than 55")
    private int minTemp;

    @NotBlank(message = "Has to be a valid plantId")
    private int plantId;

    public UserPlants() {
    }

    public UserPlants(
            int id,
            int userId,
            String nickname,
            BigDecimal potVolume,
            BigDecimal lat,
            BigDecimal lon,
            String imageName,
            LocalDateTime lastWaterDate,
            BigDecimal distanceToWindow,
            int maxTemp,
            int minTemp,
            int plantId
    ) {
        this.id = id;
        this.userId = userId;
        this.nickname = nickname;
        this.potVolume = potVolume;
        this.lat = lat;
        this.lon = lon;
        this.imageName = imageName;
        this.lastWaterDate = lastWaterDate;
        this.distanceToWindow = distanceToWindow;
        this.maxTemp = maxTemp;
        this.minTemp = minTemp;
        this.plantId = plantId;
    }

    /**
     * @return the deviceId
     */
    public int getUserId() {
        return userId;
    }

    /**
     * @param userId the deviceId to set
     */
    public void setUserId(int userId) {
        this.userId = userId;
    }

    /**
     * @return the distanceToWindow
     */
    public BigDecimal getDistanceToWindow() {
        return distanceToWindow;
    }

    /**
     * @param distanceToWindow the distanceToWindow to set
     */
    public void setDistanceToWindow(BigDecimal distanceToWindow) {
        this.distanceToWindow = distanceToWindow;
    }

    /**
     * @return the id
     */
    public int getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * @return the imageName
     */
    public String getImageName() {
        return imageName;
    }

    /**
     * @param imageName the imageName to set
     */
    public void setImageName(String imageName) {
        this.imageName = imageName;
    }

    /**
     * @return the lastWaterDate
     */
    public LocalDateTime getLastWaterDate() {
        return lastWaterDate;
    }

    /**
     * @param lastWaterDate the lastWaterDate to set
     */
    public void setLastWaterDate(LocalDateTime lastWaterDate) {
        this.lastWaterDate = lastWaterDate;
    }

    /**
     * @return the lat
     */
    public BigDecimal getLat() {
        return lat;
    }

    /**
     * @param lat the lat to set
     */
    public void setLat(BigDecimal lat) {
        this.lat = lat;
    }

    /**
     * @return the lon
     */
    public BigDecimal getLon() {
        return lon;
    }

    /**
     * @param lon the lon to set
     */
    public void setLon(BigDecimal lon) {
        this.lon = lon;
    }

    /**
     * @return the maxTemp
     */
    public int getMaxTemp() {
        return maxTemp;
    }

    /**
     * @param maxTemp the maxTemp to set
     */
    public void setMaxTemp(int maxTemp) {
        this.maxTemp = maxTemp;
    }

    /**
     * @return the minTemp
     */
    public int getMinTemp() {
        return minTemp;
    }

    /**
     * @param minTemp the minTemp to set
     */
    public void setMinTemp(int minTemp) {
        this.minTemp = minTemp;
    }

    /**
     * @return the nickname
     */
    public String getNickname() {
        return nickname;
    }

    /**
     * @param nickname the nickname to set
     */
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    /**
     * @return the plantId
     */
    public int getPlantId() {
        return plantId;
    }

    /**
     * @param plantId the plantId to set
     */
    public void setPlantId(int plantId) {
        this.plantId = plantId;
    }

    /**
     * @return the potVolume
     */
    public BigDecimal getPotVolume() {
        return potVolume;
    }

    /**
     * @param potVolume the potVolume to set
     */
    public void setPotVolume(BigDecimal potVolume) {
        this.potVolume = potVolume;
    }
}