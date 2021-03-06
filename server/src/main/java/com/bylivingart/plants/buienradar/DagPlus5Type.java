//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2020.04.07 at 05:46:22 PM CEST 
//


package com.bylivingart.plants.buienradar;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for dag-plus5Type complex type.
 *
 * <p>The following schema fragment specifies the expected content contained within this class.
 *
 * <pre>
 * &lt;complexType name="dag-plus5Type">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="datum" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="dagweek" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="kanszon" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="kansregen" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="minmmregen" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="maxmmregen" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="mintemp" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="mintempmax" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="maxtemp" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="maxtempmax" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="windrichting" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="windkracht" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="icoon" type="{}icoonType"/>
 *         &lt;element name="sneeuwcms" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "dag-plus5Type", propOrder = {
        "datum",
        "dagweek",
        "kanszon",
        "kansregen",
        "minmmregen",
        "maxmmregen",
        "mintemp",
        "mintempmax",
        "maxtemp",
        "maxtempmax",
        "windrichting",
        "windkracht",
        "icoon",
        "sneeuwcms"
})
public class DagPlus5Type {

    @XmlElement(required = true)
    protected String datum;
    @XmlElement(required = true)
    protected String dagweek;
    @XmlElement(required = true)
    protected String kanszon;
    @XmlElement(required = true)
    protected String kansregen;
    @XmlElement(required = true)
    protected String minmmregen;
    @XmlElement(required = true)
    protected String maxmmregen;
    @XmlElement(required = true)
    protected String mintemp;
    @XmlElement(required = true)
    protected String mintempmax;
    @XmlElement(required = true)
    protected String maxtemp;
    @XmlElement(required = true)
    protected String maxtempmax;
    @XmlElement(required = true)
    protected String windrichting;
    @XmlElement(required = true)
    protected String windkracht;
    @XmlElement(required = true)
    protected IcoonType icoon;
    @XmlElement(required = true)
    protected String sneeuwcms;

    /**
     * Gets the value of the datum property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getDatum() {
        return datum;
    }

    /**
     * Sets the value of the datum property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setDatum(String value) {
        this.datum = value;
    }

    /**
     * Gets the value of the dagweek property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getDagweek() {
        return dagweek;
    }

    /**
     * Sets the value of the dagweek property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setDagweek(String value) {
        this.dagweek = value;
    }

    /**
     * Gets the value of the kanszon property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getKanszon() {
        return kanszon;
    }

    /**
     * Sets the value of the kanszon property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setKanszon(String value) {
        this.kanszon = value;
    }

    /**
     * Gets the value of the kansregen property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getKansregen() {
        return kansregen;
    }

    /**
     * Sets the value of the kansregen property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setKansregen(String value) {
        this.kansregen = value;
    }

    /**
     * Gets the value of the minmmregen property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getMinmmregen() {
        return minmmregen;
    }

    /**
     * Sets the value of the minmmregen property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setMinmmregen(String value) {
        this.minmmregen = value;
    }

    /**
     * Gets the value of the maxmmregen property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getMaxmmregen() {
        return maxmmregen;
    }

    /**
     * Sets the value of the maxmmregen property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setMaxmmregen(String value) {
        this.maxmmregen = value;
    }

    /**
     * Gets the value of the mintemp property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getMintemp() {
        return mintemp;
    }

    /**
     * Sets the value of the mintemp property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setMintemp(String value) {
        this.mintemp = value;
    }

    /**
     * Gets the value of the mintempmax property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getMintempmax() {
        return mintempmax;
    }

    /**
     * Sets the value of the mintempmax property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setMintempmax(String value) {
        this.mintempmax = value;
    }

    /**
     * Gets the value of the maxtemp property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getMaxtemp() {
        return maxtemp;
    }

    /**
     * Sets the value of the maxtemp property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setMaxtemp(String value) {
        this.maxtemp = value;
    }

    /**
     * Gets the value of the maxtempmax property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getMaxtempmax() {
        return maxtempmax;
    }

    /**
     * Sets the value of the maxtempmax property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setMaxtempmax(String value) {
        this.maxtempmax = value;
    }

    /**
     * Gets the value of the windrichting property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getWindrichting() {
        return windrichting;
    }

    /**
     * Sets the value of the windrichting property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setWindrichting(String value) {
        this.windrichting = value;
    }

    /**
     * Gets the value of the windkracht property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getWindkracht() {
        return windkracht;
    }

    /**
     * Sets the value of the windkracht property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setWindkracht(String value) {
        this.windkracht = value;
    }

    /**
     * Gets the value of the icoon property.
     *
     * @return possible object is
     * {@link IcoonType }
     */
    public IcoonType getIcoon() {
        return icoon;
    }

    /**
     * Sets the value of the icoon property.
     *
     * @param value allowed object is
     *              {@link IcoonType }
     */
    public void setIcoon(IcoonType value) {
        this.icoon = value;
    }

    /**
     * Gets the value of the sneeuwcms property.
     *
     * @return possible object is
     * {@link String }
     */
    public String getSneeuwcms() {
        return sneeuwcms;
    }

    /**
     * Sets the value of the sneeuwcms property.
     *
     * @param value allowed object is
     *              {@link String }
     */
    public void setSneeuwcms(String value) {
        this.sneeuwcms = value;
    }

}
