package com.russ4stall.sorken;

import java.io.IOException;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

import javax.servlet.http.HttpSession;
import javax.websocket.EncodeException;
import javax.websocket.EndpointConfig;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.OnError;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import com.russ4stall.sorken.person.Person;
import com.russ4stall.sorken.person.PersonUpdatedListener;
import com.russ4stall.sorken.person.PersonService;
import com.google.gson.Gson;

@ServerEndpoint(value="/watch-for-people", configurator=ServletAwareConfig.class)
public class CreeperSocket implements PersonUpdatedListener {
    private Session session;    
    private static Set<Session> sessions = new CopyOnWriteArraySet<>();
    private PersonService personService;

    @OnOpen
    public void onOpen(Session session, EndpointConfig config) throws Exception {  
        HttpSession httpSession = (HttpSession) config.getUserProperties().get("httpSession");
        personService = (PersonService) httpSession.getServletContext().getAttribute("personService");
        personService.registerPersonUpdatedListener(this);

        this.session = session;
        sessions.add(session);
    }

     @OnMessage
     public void onMessage(String message, Session session) throws Exception {
        System.out.println("Greeting received:" + message);

        try {
            session.getBasicRemote().sendText("You're a creeper aren't ya?");
        } catch (IOException e) {
            e.printStackTrace();
        }
     }

     @OnClose
     public void onClose(Session session) {
         //sessions.remove(session);
         personService.unregisterPersonUpdatedListener(this);
     }

    @OnError
    public void onError(Session session, Throwable throwable) {
        // Do error handling here
    }

    @Override
    public void onUpdate(Person person) {
        Gson gson = new Gson();
        String json = gson.toJson(person);
        
        try {
            session.getBasicRemote().sendText(json);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void broadcast(String message) throws IOException, EncodeException {
        System.out.println("broadcasting to " + sessions.size() + " sessions...");
        
        sessions.forEach(session -> {
            synchronized (session) {
                try {
                    session.getBasicRemote().sendText(message);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        });
    }
}