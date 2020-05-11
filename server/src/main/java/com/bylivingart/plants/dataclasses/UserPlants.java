package com.bylivingart.plants.dataclasses;

import java.time.LocalDateTime;

public class UserPlants {
    private int id;
    private String deviceId;
    private String nickname;
    private double potVolume;
    private double lat;
    private double lon;
    private String imageName;
    private LocalDateTime lastWaterDate;
    private double distanceToWindow;
    private int maxTemp;
    private int minTemp;
    private int plantId;

    public UserPlants(
        int id, 
        String deviceId, 
        String nickname, 
        double potVolume, 
        double lat, 
        double lon, 
        String imageName, 
        LocalDateTime lastWaterDate,
        double distanceToWindow, 
        int maxTemp, 
        int minTemp, 
        int plantId
    ){
        this.id = id;
        this.deviceId = deviceId;
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
    public String getDeviceId() {
        return deviceId;
    }

    /**
     * @return the distanceToWindow
     */
    public double getDistanceToWindow() {
        return distanceToWindow;
    }

    /**
     * @return the id
     */
    public int getId() {
        return id;
    }

    /**
     * @return the imageName
     */
    public String getImageName() {
        return imageName;
    }

    /**
     * @return the lastWaterDate
     */
    public LocalDateTime getLastWaterDate() {
        return lastWaterDate;
    }

    /**
     * @return the lat
     */
    public double getLat() {
        return lat;
    }

    /**
     * @return the lon
     */
    public double getLon() {
        return lon;
    }

    /**
     * @return the maxTemp
     */
    public int getMaxTemp() {
        return maxTemp;
    }

    /**
     * @return the minTemp
     */
    public int getMinTemp() {
        return minTemp;
    }

    /**
     * @return the nickname
     */
    public String getNickname() {
        return nickname;
    }

    /**
     * @return the plantId
     */
    public int getPlantId() {
        return plantId;
    }

    /**
     * @return the potVolume
     */
    public double getPotVolume() {
        return potVolume;
    }

    /**
     * @param deviceId the deviceId to set
     */
    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    /**
     * @param distanceToWindow the distanceToWindow to set
     */
    public void setDistanceToWindow(double distanceToWindow) {
        this.distanceToWindow = distanceToWindow;
    }

    /**
     * @param id the id to set
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * @param imageName the imageName to set
     */
    public void setImageName(String imageName) {
        this.imageName = imageName;
    }

    /**
     * @param lastWaterDate the lastWaterDate to set
     */
    public void setLastWaterDate(LocalDateTime lastWaterDate) {
        this.lastWaterDate = lastWaterDate;
    }

    /**
     * @param lat the lat to set
     */
    public void setLat(double lat) {
        this.lat = lat;
    }

    /**
     * @param lon the lon to set
     */
    public void setLon(double lon) {
        this.lon = lon;
    }

    /**
     * @param maxTemp the maxTemp to set
     */
    public void setMaxTemp(int maxTemp) {
        this.maxTemp = maxTemp;
    }

    /**
     * @param minTemp the minTemp to set
     */
    public void setMinTemp(int minTemp) {
        this.minTemp = minTemp;
    }

    /**
     * @param nickname the nickname to set
     */
    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    /**
     * @param plantId the plantId to set
     */
    public void setPlantId(int plantId) {
        this.plantId = plantId;
    }

    /**
     * @param potVolume the potVolume to set
     */
    public void setPotVolume(double potVolume) {
        this.potVolume = potVolume;
    }
}