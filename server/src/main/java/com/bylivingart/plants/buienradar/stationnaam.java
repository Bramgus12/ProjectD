package com.bylivingart.plants.buienradar;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name="stationnaam")
public class stationnaam {
    @XmlAttribute
    private String Regio;
}
