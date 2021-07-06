<%-- 
    Document   : ticketMachine
    Created on : 17 May 2021, 10:43:11
    Author     : oscar
--%>

<%@page import="org.solent.com528.project.model.dto.TicketMachineConfig"%>
<%@page import="java.net.URL"%>
<%@page import="java.util.Set"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page import="org.solent.com528.project.impl.webclient.TicketInfo"%>
<%@page import="org.solent.com528.project.model.dto.Rate"%>
<%@page import="org.solent.com528.project.model.dto.Ticket"%>
<%@page import="org.solent.com528.project.model.dao.PriceCalculatorDAO"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="org.solent.com528.project.impl.webclient.WebClientObjectFactory"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.dto.Station"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.solent.com528.project.impl.webclient.DateTimeAdapter"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.util.Date"%>

<!DOCTYPE html>
<%
    String errorMessage = "";
    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();
    PriceCalculatorDAO priceCalcDAO = serviceFacade.getPriceCalculatorDAO();
    String ticketMachineUuid = WebClientObjectFactory.getTicketMachineUuid();
    if(ticketMachineUuid.isEmpty())
    {
        ticketMachineUuid = null;
    }
    
    double offPeakPricePerZone = priceCalcDAO.getOffpeakPricePerZone();
    double peakPricePerZone = priceCalcDAO.getPeakPricePerZone();

    TicketMachineConfig ticketMachineConf = serviceFacade.getTicketMachineConfig(ticketMachineUuid);
    List<Station> stationList = new ArrayList();
    try
    {
        stationList = ticketMachineConf.getStationList();
    }
    catch(Exception ex)
    {
        errorMessage = "Ticket machine UUID is invalid";
    }
    String ticketStr = "";
    String actionStr = request.getParameter("action");
    if(actionStr == null || actionStr.isEmpty())
    {
        actionStr = "";
    }
    
    DateFormat df = new SimpleDateFormat(DateTimeAdapter.DATE_FORMAT);

    String validFromStr = request.getParameter("validFrom");
    if (validFromStr == null || validFromStr.isEmpty()) {
        validFromStr = df.format(new Date());
    }
    
    String startStationStr = "UNDEFINED";
    if(!stationList.isEmpty())
    {
        ticketMachineConf.getStationName();
        startStationStr = ticketMachineConf.getStationName();
    }
    

    String endStationStr = request.getParameter("endStation");
    if (endStationStr == null || endStationStr.isEmpty()) {
        endStationStr = "UNDEFINED";
    }
    String priceStr = request.getParameter("price");
    if (priceStr == null || priceStr.isEmpty()) {
        priceStr = "00.00";
    }
    String cardNoStr = request.getParameter("cardNo");
    if(cardNoStr == null || cardNoStr.isEmpty()){
        cardNoStr ="";
    }

    if (startStationStr != "UNDEFINED" && endStationStr != "UNDEFINED") {
            Date validFromDate =null;
            boolean dateTimeValid = false;
            try
            {
                validFromDate = df.parse(validFromStr);
                dateTimeValid = true;
            }
            catch(Exception ex)
            {
                errorMessage = "The Date Time value is invalid";
            }
            
            if(dateTimeValid)
            {
            boolean stationExists = false;
            double pricePerZone = priceCalcDAO.getPricePerZone(validFromDate);
            Station endStation = null;

            for(Station station : stationList)
            {
                if(station.getName().equals(endStationStr))
                {
                    endStation = station;
                    stationExists = true;
                }
            }

            if(stationExists)
            {
                int startStationZone =  ticketMachineConf.getStationZone();
                int endStationZone =  endStation.getZone();
                int zoneDif = 1;
                if(startStationZone > endStationZone)
                {
                     zoneDif = startStationZone - endStationZone;
                }
                else if(startStationZone < endStationZone)
                {
                      zoneDif = endStationZone - startStationZone;
                }
                if(zoneDif == 0){ 
                    zoneDif = 1; 
                }
                double price = zoneDif * pricePerZone;
                priceStr = "£"+price;
                
                TicketInfo.StartStation = startStationStr;
                TicketInfo.validFrom = validFromDate;
                TicketInfo.price = price;
                TicketInfo.zonesTravelable = zoneDif;
            }
            else
            {
                errorMessage = "this station doesn't exsist, or has an invalid station UUID.";
            }
        }       

    }

    if(actionStr.equals("buyTicket"))
    {
        long cardNo = 0;
        try{
            cardNo = Long.parseLong(cardNoStr);
        }
        catch(Exception ex)
        {
            errorMessage = "card is invalid parse error";
        }
        boolean cardIsReal = false;
        if(cardNoStr.length() == 16 && cardNo != 0)
        {
            cardIsReal = true;
        }

        if(cardIsReal)
        {
            Rate rate = priceCalcDAO.getRate(TicketInfo.validFrom);
            Ticket ticket = new Ticket();
            ticket.setCost(TicketInfo.price);
            ticket.setIssueDate(TicketInfo.validFrom);
            ticket.setStartStation(TicketInfo.StartStation);
            ticket.setRate(rate);
            String encodedTicket =  TicketEncoderImpl.encodeTicket(ticket);
            String[] encodedTicketSplit = encodedTicket.split("<encryptedHash>");
            encodedTicketSplit = encodedTicketSplit[1].split("</encryptedHash");
            String hash = encodedTicketSplit[0];
            ticket.setEncryptedHash(hash);

            ticketStr = encodedTicket;
        }
        else
        {
            errorMessage = "card is invalid";
        }
    }
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Ticket Machine</title>
    </head>
    <body style="text-align: center;">
        <!-- Below div is a placeholder for error messages if an error occurs. -->
        <div style="color:red;"><%=errorMessage%></div>
        <h1>Create and Purchase a New Ticket</h1>        
        <form action="./ticketMachine.jsp"  method="post">
            <table style="margin-left: auto; margin-right: auto; width: 35%;">
                <tr>
                    <td style="text-align: left;">Starting Station:</td>
                    <td style="text-align: left;">
                        <input style="text-align: left;" readonly value="<%=startStationStr%>"/>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: left;">Destination Station:</td>
                    <td style="text-align: left;">
                         <select name="endStation" id="endStation" onchange="submit">
                             <option value="UNDEFINED">Select a Station</option>
                             <%
                                for (Station station : stationList) {
                            %>
                           <option value="<%=station.getName()%>"><%=station.getName()%></option>
                            <%
                                }
                            %>
                            <option value="UNDEFINED">Select a Station</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: left;">Time Your Ticket is Valid From:</td>
                    <td style="text-align: left;">
                        <input type="text" name="validFrom" value="<%=validFromStr%>">
                    </td>
                </tr>
            </table>
            <button type="submit" style="margin-top: 15px;">Configure Ticket Price</button>
        </form> 
        <h1>Payment Details</h1>
        <form action="./ticketMachine.jsp"  method="get">
            <table style="margin-left: auto; margin-right: auto; width: 35%;">
                <tr>
                    <td style="text-align: left;">Ticket Price:</td>
                    <td style="text-align: left;">
                        <input type="text" name="price" value="<%=priceStr%>" readonly>
                    </td>
                </tr>                
                 <tr>
                    <td style="text-align: left;">Enter Your 16-Digit Card Number:</td>
                    <td style="text-align: left;">
                        <input type="text" name="cardNo" value="<%=cardNoStr%>">
                    </td>
                </tr>
            </table>
            <button type="submit" name="action" value="buyTicket" style="margin-top: 15px;">Buy Ticket</button>
        </form>
        <h2>Your Ticket XML</h2>
        <textarea id="ticketTextArea" rows="15" cols="150" readonly><%=ticketStr%></textarea>
    </body>
</html>