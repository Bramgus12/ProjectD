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
 * <p>Java class for weergegevensType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="weergegevensType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="titel" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="link" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="omschrijving" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="language" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="copyright" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="gebruik" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="image" type="{}imageType"/>
 *         &lt;element name="actueel_weer" type="{}actueel_weerType"/>
 *         &lt;element name="verwachting_meerdaags" type="{}verwachting_meerdaagsType"/>
 *         &lt;element name="verwachting_vandaag" type="{}verwachting_vandaagType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "weergegevensType", propOrder = {
    "titel",
    "link",
    "omschrijving",
    "language",
    "copyright",
    "gebruik",
    "image",
    "actueelWeer",
    "verwachtingMeerdaags",
    "verwachtingVandaag"
})
public class WeergegevensType {

    @XmlElement(required = true)
    protected String titel;
    @XmlElement(required = true)
    protected String link;
    @XmlElement(required = true)
    protected String omschrijving;
    @XmlElement(required = true)
    protected String language;
    @XmlElement(required = true)
    protected String copyright;
    @XmlElement(required = true)
    protected String gebruik;
    @XmlElement(required = true)
    protected ImageType image;
    @XmlElement(name = "actueel_weer", required = true)
    protected ActueelWeerType actueelWeer;
    @XmlElement(name = "verwachting_meerdaags", required = true)
    protected VerwachtingMeerdaagsType verwachtingMeerdaags;
    @XmlElement(name = "verwachting_vandaag", required = true)
    protected VerwachtingVandaagType verwachtingVandaag;

    /**
     * Gets the value of the titel property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getTitel() {
        return titel;
    }

    /**
     * Sets the value of the titel property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setTitel(String value) {
        this.titel = value;
    }

    /**
     * Gets the value of the link property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLink() {
        return link;
    }

    /**
     * Sets the value of the link property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLink(String value) {
        this.link = value;
    }

    /**
     * Gets the value of the omschrijving property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getOmschrijving() {
        return omschrijving;
    }

    /**
     * Sets the value of the omschrijving property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setOmschrijving(String value) {
        this.omschrijving = value;
    }

    /**
     * Gets the value of the language property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getLanguage() {
        return language;
    }

    /**
     * Sets the value of the language property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setLanguage(String value) {
        this.language = value;
    }

    /**
     * Gets the value of the copyright property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getCopyright() {
        return copyright;
    }

    /**
     * Sets the value of the copyright property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setCopyright(String value) {
        this.copyright = value;
    }

    /**
     * Gets the value of the gebruik property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getGebruik() {
        return gebruik;
    }

    /**
     * Sets the value of the gebruik property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setGebruik(String value) {
        this.gebruik = value;
    }

    /**
     * Gets the value of the image property.
     * 
     * @return
     *     possible object is
     *     {@link ImageType }
     *     
     */
    public ImageType getImage() {
        return image;
    }

    /**
     * Sets the value of the image property.
     * 
     * @param value
     *     allowed object is
     *     {@link ImageType }
     *     
     */
    public void setImage(ImageType value) {
        this.image = value;
    }

    /**
     * Gets the value of the actueelWeer property.
     * 
     * @return
     *     possible object is
     *     {@link ActueelWeerType }
     *     
     */
    public ActueelWeerType getActueelWeer() {
        return actueelWeer;
    }

    /**
     * Sets the value of the actueelWeer property.
     * 
     * @param value
     *     allowed object is
     *     {@link ActueelWeerType }
     *     
     */
    public void setActueelWeer(ActueelWeerType value) {
        this.actueelWeer = value;
    }

    /**
     * Gets the value of the verwachtingMeerdaags property.
     * 
     * @return
     *     possible object is
     *     {@link VerwachtingMeerdaagsType }
     *     
     */
    public VerwachtingMeerdaagsType getVerwachtingMeerdaags() {
        return verwachtingMeerdaags;
    }

    /**
     * Sets the value of the verwachtingMeerdaags property.
     * 
     * @param value
     *     allowed object is
     *     {@link VerwachtingMeerdaagsType }
     *     
     */
    public void setVerwachtingMeerdaags(VerwachtingMeerdaagsType value) {
        this.verwachtingMeerdaags = value;
    }

    /**
     * Gets the value of the verwachtingVandaag property.
     * 
     * @return
     *     possible object is
     *     {@link VerwachtingVandaagType }
     *     
     */
    public VerwachtingVandaagType getVerwachtingVandaag() {
        return verwachtingVandaag;
    }

    /**
     * Sets the value of the verwachtingVandaag property.
     * 
     * @param value
     *     allowed object is
     *     {@link VerwachtingVandaagType }
     *     
     */
    public void setVerwachtingVandaag(VerwachtingVandaagType value) {
        this.verwachtingVandaag = value;
    }

}
