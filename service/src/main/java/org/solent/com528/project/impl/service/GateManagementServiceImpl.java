/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.solent.com528.project.impl.service;

import solent.ac.uk.com504.examples.ticketgate.crypto.AsymmetricCryptography;
import java.security.PrivateKey;
import java.util.Date;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.solent.com528.project.model.dto.Ticket;
import solent.ac.uk.com504.examples.ticketgate.model.service.GateManagementService;

/**
 *
 * @author cgallen
 */
public class GateManagementServiceImpl implements GateManagementService {

    final static Logger LOG = LogManager.getLogger(GateManagementServiceImpl.class);

    String privateKeyFileOnClasspath = null;

    public GateManagementServiceImpl(String privateKeyFileOnClasspath) {
        this.privateKeyFileOnClasspath = privateKeyFileOnClasspath;
    }

    @Override
    public Ticket createTicket(String zones, Date validFrom, Date validTo, String startStation) {
        LOG.debug("createTicket called (zones="+zones
                + " validFrom="+validFrom
                + " validTo="+validTo
                + " startStation"+startStation
                + ")");
                
        if (zones == null) {
            throw new RuntimeException("zones must not be null");
        }
        if (validFrom == null) {
            throw new RuntimeException("validFrom must not be null");
        }
        if (validTo == null) {
            throw new RuntimeException("validTo must not be null");
        }
        if (startStation == null) {
            throw new RuntimeException("startStation must not be null");
        }

        Ticket ticket = new Ticket();
        ticket.setZones(zones);
        ticket.setValidFrom(validFrom);
        ticket.setValidTo(validTo);
        ticket.setStartStation(startStation);

        String content = ticket.getContent();

        try {
            AsymmetricCryptography ac = new AsymmetricCryptography();
            PrivateKey privateKey = ac.getPrivateFromClassPath(privateKeyFileOnClasspath);

            String encodeKey = ac.encryptText(content, privateKey);
            ticket.setEncodedKey(encodeKey);
        } catch (Exception ex) {
            throw new RuntimeException("problem encoding ticket:", ex);
        }

        return ticket;

    }


}
