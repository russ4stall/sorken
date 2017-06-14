package com.russ4stall.sorken.person;

import com.google.gson.Gson;
import com.russ4stall.sorken.BaseResourceServlet;
import org.apache.commons.lang3.StringUtils;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * @author Russ
 */
@WebServlet("/api/people")
public class PeopleResourceServlet extends BaseResourceServlet {
    PersonService personService;


    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ServletContext context = getServletContext();
        personService = (PersonService) context.getAttribute("personService");

        json(req, resp, personService.getPeople());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        ServletContext context = getServletContext();
        personService = (PersonService) context.getAttribute("personService");

        String name = req.getParameter("name");
        String notes = req.getParameter("notes");
        int age = 0;
        if (!StringUtils.isEmpty(req.getParameter("age"))) {
            age = Integer.valueOf(req.getParameter("age"));
        }

        Person newPerson = personService.addPerson(new Person(name, age, notes));

        json(req, resp, newPerson);
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (StringUtils.isEmpty(req.getParameter("id"))) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        ServletContext context = getServletContext();
        personService = (PersonService) context.getAttribute("personService");

        int id = Integer.valueOf(req.getParameter("id"));

        Person person = personService.getPersonById(id);

        if (person == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        if (!StringUtils.isEmpty(req.getParameter("name"))) {
            person.setName(req.getParameter("name"));
        }

        if (!StringUtils.isEmpty(req.getParameter("notes"))) {
            person.setNotes(req.getParameter("notes"));
        }

        if (!StringUtils.isEmpty(req.getParameter("age"))) {
            person.setAge(Integer.valueOf(req.getParameter("age")));
        }

        personService.updatePerson(person);

        json(req, resp, person);
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (StringUtils.isEmpty(req.getParameter("id"))) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        ServletContext context = getServletContext();
        personService = (PersonService) context.getAttribute("personService");

        int id = Integer.valueOf(req.getParameter("id"));

        personService.removePerson(id);

        resp.setStatus(HttpServletResponse.SC_NO_CONTENT);
    }
}
