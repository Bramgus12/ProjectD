//
// This file was generated by the JavaTM Architecture for XML Binding(JAXB) Reference Implementation, v2.2.8-b130911.1802 
// See <a href="http://java.sun.com/xml/jaxb">http://java.sun.com/xml/jaxb</a> 
// Any modifications to this file will be lost upon recompilation of the source schema. 
// Generated on: 2020.04.07 at 05:46:22 PM CEST 
//


package com.bylivingart.plants.buienradar;

import javax.xml.bind.annotation.*;


/**
 * <p>Java class for buienradarnlType complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="buienradarnlType">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="weergegevens" type="{}weergegevensType"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "buienradarnlType", propOrder = {
    "weergegevens"
})
@XmlRootElement(name="buienradarnl")
public class BuienradarnlType {

    @XmlElement(required = true)
    protected WeergegevensType weergegevens;

    /**
     * Gets the value of the weergegevens property.
     * 
     * @return
     *     possible object is
     *     {@link WeergegevensType }
     *     
     */
    public WeergegevensType getWeergegevens() {
        return weergegevens;
    }

    /**
     * Sets the value of the weergegevens property.
     * 
     * @param value
     *     allowed object is
     *     {@link WeergegevensType }
     *     
     */
    public void setWeergegevens(WeergegevensType value) {
        this.weergegevens = value;
    }

}
