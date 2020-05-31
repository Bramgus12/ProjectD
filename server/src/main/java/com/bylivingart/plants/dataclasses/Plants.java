package com.bylivingart.plants.dataclasses;


import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Null;

public class Plants {
    @Null
    private int id;

    @NotBlank
    private String name;

    @NotNull
    private double waterScale;

    @NotNull
    private double waterNumber;

    @NotBlank
    private String waterText;

    @NotNull
    private double sunScale;

    @NotNull
    private double sunNumber;

    @NotBlank
    private String sunText;

    @NotBlank
    private String description;

    @NotNull
    private int optimumTemp;

    @NotBlank
    private String imageName;

    public Plants() {
    }

    public Plants(int id, String name, double waterScale, double waterNumber, String waterText, double sunScale, double sunNumber, String sunText, String description, int optimumTemp, String imageName) {
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
     * @param description the description to set
     */
    public void setDescription(String description) {
        this.description = description;
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
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return the optimumTemp
     */
    public int getOptimumTemp() {
        return optimumTemp;
    }

    /**
     * @param optimumTemp the optimumTemp to set
     */
    public void setOptimumTemp(int optimumTemp) {
        this.optimumTemp = optimumTemp;
    }

    /**
     * @return the sunNumber
     */
    public double getSunNumber() {
        return sunNumber;
    }

    /**
     * @param sunNumber the sunNumber to set
     */
    public void setSunNumber(double sunNumber) {
        this.sunNumber = sunNumber;
    }

    /**
     * @return the sunScale
     */
    public double getSunScale() {
        return sunScale;
    }

    /**
     * @param sunScale the sunScale to set
     */
    public void setSunScale(double sunScale) {
        this.sunScale = sunScale;
    }

    /**
     * @return the sunText
     */
    public String getSunText() {
        return sunText;
    }

    /**
     * @param sunText the sunText to set
     */
    public void setSunText(String sunText) {
        this.sunText = sunText;
    }

    /**
     * @return the waterNumber
     */
    public double getWaterNumber() {
        return waterNumber;
    }

    /**
     * @param waterNumber the waterNumber to set
     */
    public void setWaterNumber(double waterNumber) {
        this.waterNumber = waterNumber;
    }

    /**
     * @return the waterScale
     */
    public double getWaterScale() {
        return waterScale;
    }

    /**
     * @param waterScale the waterScale to set
     */
    public void setWaterScale(double waterScale) {
        this.waterScale = waterScale;
    }

    /**
     * @return the waterText
     */
    public String getWaterText() {
        return waterText;
    }

    /**
     * @param waterText the waterText to set
     */
    public void setWaterText(String waterText) {
        this.waterText = waterText;
    }

    public String getImageName() {
        return imageName;
    }

    public void setImageName(String imageName) {
        this.imageName = imageName;
    }
}