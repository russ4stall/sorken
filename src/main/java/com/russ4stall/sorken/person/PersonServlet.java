package com.russ4stall.sorken.person;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/people")
public class PersonServlet extends HttpServlet {
    private PersonService personService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ServletContext context = getServletContext();
        personService = (PersonService) context.getAttribute("personService");
        
        req.setAttribute("people", personService.getPeople());

        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/people.jsp");
        dispatcher.forward(req,resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        switch(action) {
            case "ADD": handleAdd(req);
                break;
            case "REMOVE": handleRemove(req);
        }
        resp.sendRedirect("/people");
    }

    private void handleAdd(HttpServletRequest req) {        
        ServletContext context = getServletContext();
        personService = (PersonService) context.getAttribute("personService");

        String nameParam = req.getParameter("name");
        String ageParam = req.getParameter("age");
        String notes = req.getParameter("notes");

        int age = 0;
        String name = "DEFAULT";

        if (ageParam != "") {
            age = Integer.valueOf(ageParam);
        }

        if (nameParam != "") {
            name = nameParam;
        }

        personService.addPerson(new Person(name, age, notes));
    }

    private void handleRemove(HttpServletRequest req) {

    }    
}