package com.bylivingart.plants.dataclasses;


public class Plants {
    private int id;
    private String name;
    private double waterScale;
    private double waterNumber;
    private String waterText;
    private double sunScale;
    private double sunNumber;
    private String sunText;
    private String description;
    private int optimumTemp;
    private String imageName;

    public Plants(){}

    public Plants(int id, String name, double waterScale, double waterNumber, String waterText, double sunScale, double sunNumber, String sunText, String description, int optimumTemp, String imageName){
        this.id = id;
        this.name = name;
        this.waterScale = waterScale;
        this.waterNumber = waterNumber;
        this.waterText = waterText;
        this.sunScale = sunScale;
        this.sunNumber = sunNumber;
        this.sunText = sunText;
        this.description = description;
        this.optimumTemp = optimumTemp;
        this.imageName = imageName;
    }

    /**
     * @return the description
     */
    public String getDescription() {
        return description;
    }

    /**
     * @return the id
     */
    public int getId() {
        return id;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @return the optimumTemp
     */
    public int getOptimumTemp() {
        return optimumTemp;
    }

    /**
     * @return the sunNumber
     */
    public double getSunNumber() {
        return sunNumber;
    }

    /**
     * @return the sunScale
     */
    public double getSunScale() {
        return sunScale;
    }

    /**
     * @return the sunText
     */
    public String getSunText() {
        return sunText;
    }

    /**
     * @return the waterNumber
     */
    public double getWaterNumber() {
        return waterNumber;
    }

    /**
     * @return the waterScale
     */
    public double getWaterScale() {
        return waterScale;
    }

    /**
     * @return the waterText
     */
    public String getWaterText() {
        return waterText;
    }

    public String getImageName() {
        return imageName;
    }

    /**
     * @param description the description to set
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * @param id the id to set
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @param optimumTemp the optimumTemp to set
     */
    public void setOptimumTemp(int optimumTemp) {
        this.optimumTemp = optimumTemp;
    }

    /**
     * @param sunNumber the sunNumber to set
     */
    public void setSunNumber(double sunNumber) {
        this.sunNumber = sunNumber;
    }

    /**
     * @param sunScale the sunScale to set
     */
    public void setSunScale(double sunScale) {
        this.sunScale = sunScale;
    }

    /**
     * @param sunText the sunText to set
     */
    public void setSunText(String sunText) {
        this.sunText = sunText;
    }

    /**
     * @param waterNumber the waterNumber to set
     */
    public void setWaterNumber(double waterNumber) {
        this.waterNumber = waterNumber;
    }

    /**
     * @param waterScale the waterScale to set
     */
    public void setWaterScale(double waterScale) {
        this.waterScale = waterScale;
    }

    /**
     * @param waterText the waterText to set
     */
    public void setWaterText(String waterText) {
        this.waterText = waterText;
    }

    public void setImageName(String imageName) {
        this.imageName = imageName;
    }
}