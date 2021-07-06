<%-- 
    Document   : gate
    Created on : 18 May 2021, 10:06:00
    Author     : oscar
--%>

<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.dto.TicketMachineConfig"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="org.solent.com528.project.impl.webclient.WebClientObjectFactory"%>
<%@page import="java.text.DateFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="org.solent.com528.project.impl.webclient.DateTimeAdapter"%>
<%@page import="org.solent.com528.project.model.dto.Station"%>
<%@page import="java.util.Date"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String errorMessage = "";
    boolean isValid = false;
    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();
    TicketMachineConfig ticketMachineConf = serviceFacade.getTicketMachineConfig(WebClientObjectFactory.getTicketMachineUuid());
    StationDAO stationDAO = serviceFacade.getStationDAO();
    List<Station> stationList = new ArrayList();
    try {
        stationList = ticketMachineConf.getStationList();
    }
    catch(Exception ex){
        errorMessage = "Ticket machine UUID is invalid";
    }
    
    String arrivalStationStr = request.getParameter("arrivalStation");
    if(arrivalStationStr == null || arrivalStationStr.isEmpty()){
        arrivalStationStr = "";
    }   

    String ticketStr = request.getParameter("ticketXMLArea");
    if (ticketStr == null || ticketStr.isEmpty()) {
        ticketStr = "";
    }

    if(ticketStr != ""){
        boolean encodeIsValid = TicketEncoderImpl.validateTicket(ticketStr);
            try {
                Station arrivalStation = stationDAO.findByName(arrivalStationStr);
                String departureStationName = ticketMachineConf.getStationName();
                Station departureStation = stationDAO.findByName(departureStationName);
                int departZone = departureStation.getZone();
                int arrivalZone = arrivalStation.getZone();
                int zonesTravelled = -1;
                
                if(departZone > arrivalZone){
                    zonesTravelled = departZone - arrivalZone;
                } else if(departZone < arrivalZone){
                    zonesTravelled = arrivalZone - departZone;
                }
                
                if(zonesTravelled == 0){
                    zonesTravelled = 1; 
                }

                SimpleDateFormat formatter= new SimpleDateFormat("yyyy-MM-dd 'at' HH:mm:ss z");
                Date currentDateTime = new Date(System.currentTimeMillis());
                DateFormat df = new SimpleDateFormat(DateTimeAdapter.DATE_FORMAT);

                if (encodeIsValid) {
                isValid = true;
            }
        } catch (Exception ex) {
            if(arrivalStationStr == ""){
                errorMessage = "Arrival Station is ";
            } else {
                errorMessage = ex.getMessage();
            }
        }    
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Ticket Gate</title>
    </head>
    <body style="width: 100%;">
        <div style="text-align: center;">
            <div style="color:red;"><%=errorMessage%></div>
            <h1>Ticket Gate</h1>
            <% if (isValid) { %>
                <div style="color:green; font-size:64px; text-align: center;">GATE OPEN</div>
            <%  } else {  %>
                <div style="color:red; font-size:64px; text-align: center;">GATE LOCKED</div>
            <% } %>
        </div>
        <form action="./gate.jsp"  method="post" style="width: 95%; margin-left: auto; margin-right: auto;">
            <div>
                <h3 style="display: inline-block; margin-right: 5%;">Arrival Station:</h3>
                <select name="arrivalStation" id="arrivalStation" onchange="submit" style="display: inline-block;">
                    <option value="NOTSET">Select Arrival Station</option>
                    <%
                        for (Station station : stationList) {
                    %>
                    <option value="<%=station.getName()%>"><%=station.getName()%></option>
                    <%
                        }
                    %>
                    <option value="NOTSET">Select Arrival Station</option>
                </select>
            </div>
            <h3>Enter Ticket XML Below:</h3>
            <textarea name="ticketXMLArea" id="ticketXMLArea" rows="15" cols="150" ><%=ticketStr%></textarea>
            <div style="width: 15%; margin-left: auto; margin-right: auto; margin-top: 25px;">
                <button type="submit" >Validate Ticket</button>
            </div>
        </form>
    </body>
</html>
