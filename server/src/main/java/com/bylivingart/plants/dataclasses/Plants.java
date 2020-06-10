package com.bylivingart.plants.dataclasses;


import javax.validation.constraints.*;

public class Plants {
    private int id;

    @NotBlank(message = "Mag niet leeg zijn")
    private String name;

    @NotNull(message = "Mag niet leeg zijn")
    private double waterScale;

    @NotNull(message = "Mag niet leeg zijn")
    private double waterNumber;

    @NotBlank(message = "Mag niet leeg zijn")
    private String waterText;

    @NotNull(message = "Mag niet leeg zijn")
    private double sunScale;

    @NotNull(message = "Mag niet leeg zijn")
    private double sunNumber;

    @NotBlank(message = "Mag niet leeg zijn")
    private String sunText;

    @NotBlank(message = "Mag niet leeg zijn")
    private String description;

    @NotNull(message = "Mag niet leeg zijn")
    @Min(value = 0, message = "Temperatuur mag niet lager zijn dan 0")
    @Max(value = 55, message = "Temperatuur mag niet hoger zijn dan 55")
    private int optimumTemp;

    @NotBlank
    @Pattern(regexp = "[a-zA-Z0-9!-.]+((.jpe?g)|(.JPE?G))", message = "Moet een .jpeg of .jpg zijn")
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