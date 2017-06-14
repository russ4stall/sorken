package com.russ4stall.sorken;

import com.google.gson.Gson;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * @author Russ
 */
public class BaseResourceServlet extends HttpServlet {

    protected void json(HttpServletRequest req, HttpServletResponse resp, Object o) throws IOException {
        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        Gson gson = new Gson();
        String result = gson.toJson(o);

        out.print(result);
        out.flush();
    }
}
