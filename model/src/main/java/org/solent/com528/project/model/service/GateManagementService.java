package org.solent.com528.project.model.service;

import java.util.Date;
import org.solent.com528.project.model.dto.Ticket;

public interface GateManagementService {
    
    public Ticket createTicket(String zonesStr, Date validFrom, Date validTo, String startStationStr);

}
