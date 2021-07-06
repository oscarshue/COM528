/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package org.solent.com528.project.impl.webclient;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import javax.xml.bind.annotation.adapters.XmlAdapter;

/**
 * see https://javarevisited.blogspot.com/2017/04/jaxb-date-format-example-using-annotation-XMLAdapter.html
 * This class binds a specific date format to the generated xml
 * see https://stackoverflow.com/questions/13568543/how-do-you-specify-the-date-format-used-when-jaxb-marshals-xsddatetime
 * @author cgallen
 */
public class DateTimeAdapter extends XmlAdapter<String, Date> {

    public static final String DATE_FORMAT = "dd-MM-yyyy HH:mm:ss";

    private final DateFormat dateFormat = new SimpleDateFormat(DATE_FORMAT);

    @Override
    public Date unmarshal(String xml) throws Exception {
        synchronized (dateFormat) {
            return dateFormat.parse(xml);
        }
    }

    @Override
    public String marshal(Date object) throws Exception {
        synchronized (dateFormat) {
            return dateFormat.format(object);
        }
    }

}
