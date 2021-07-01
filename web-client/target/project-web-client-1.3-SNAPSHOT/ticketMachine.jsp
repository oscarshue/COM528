<%-- 
    Document   : ticketMachine
    Created on : 17 May 2021, 10:43:11
    Author     : oscar
--%>

<%@page import="org.w3c.dom.Document"%>
<%@page import="java.util.List"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Date"%>
<%@page import="org.solent.com528.project.impl.webclient.WebClientObjectFactory"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.dto.Station"%>

<!DOCTYPE html>
<%
    // accessing service 
    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();
    StationDAO stationDAO = serviceFacade.getStationDAO();
    Set<Integer> zones = stationDAO.getAllZones();
    List<Station> stationList = new ArrayList<Station>();
    stationList = stationDAO.findAll();    
%>
<%!
    /*String selectedStation = request.getParameter("startingStationDropDown");
    List<Station> stationList = new ArrayList<Station>();
    int selectedStationsZone = 0;
    public int getStation(){
        for(Station station : stationList){
           if(selectedStation.equals(station.getName())){
               selectedStationsZone = station.getZone();
           }
        }
        return selectedStationsZone;
    }*/
%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Ticket Machine</title>
    </head>
    <body style="text-align: center;">
        <h1>Create a new ticket</h1>
        <form action="#">
            <p style="display: inline-block; width: 110px;">Starting Station: </p>
            <select id="startingStationDropDown" name="startingStationDropDown" style="margin-left: 20px; width: 200px;">
                <option selected>Select a Starting Station</option>
                <%
                    for (Station station : stationList) {
                %>
                    <option id="selectedStartingStation"><%=station.getName()%></option>
                <%
                    }
                %>
            </select><br/>
            
            <p style="display: inline-block; width: 110px;">Starting Zone: </p>
            <input id="startingZoneInput" type="number" value="" style="margin-left: 20px; width: 192px;"/><br/>
            
            <p style="display: inline-block; width: 110px;">Ending Station: </p>
            <select id="endingStationInput" name="endingStationInput" style="margin-left: 20px; width: 200px;">
                <option selected>Select a Destination Station</option>
                <%
                    for (Station station : stationList) {
                %>
                    <option id="selectedEndingStation"><%=station.getName()%></option>
                <%
                    }
                %>
            </select><br/>
                
            <p style="display: inline-block; width: 110px;">Ending Zone: </p>
            <input id="endingZoneInput" type="number" style="margin-left: 20px; width: 192px;"/><br/>
            
            <button style="margin: 25px 0px 0px 10px;" type="submit">Create Ticket</button>            
        </form>
        <h1 style="margin-top: 50px;">Ticket XML</h1>
        <div>
            <textarea id="ticketXML" name="ticketXML" style="width: 600px;height: 175px; resize: none;">
                
            </textarea>
        </div>
    </body>
</html>
