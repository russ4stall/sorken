package com.russ4stall.sorken;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import com.russ4stall.sorken.person.*;

@WebListener
public class AppListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent event) {
        PersonService personService = new PersonService();
        personService.addPerson(new Person("Russ", 28));        

        event.getServletContext().setAttribute("personService", personService);
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        
    }

}