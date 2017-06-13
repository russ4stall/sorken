package com.russ4stall.sorken.person;

import java.util.ArrayList;
import java.util.List;

public class PersonService {
    private List<Person> people;
    private List<PersonAddedListener> listeners;

    public PersonService() {
        people = new ArrayList<>();
        listeners = new ArrayList<>();
    }

    public void addPerson(Person person) {
        person.setId(getNextId());
        people.add(person);
        notifyPersonAddedListeners(person);
    }

    public void removePerson(int personId) {
        
        for (int i = people.size() - 1; i >= 0; i--) {
            if (people.get(i).getId() == personId) {
                people.remove(i);

                //notifyPersonRemovedListeners(personId);

            }
        }

    }

    public List<Person> getPeople() {
        return people;
    }

    private int getNextId() {
        int id = 0;

        for (Person p : people) {
            if (p.getId() > id) {
                id = p.getId();
            }
        }

        return ++id;
    }

    public void registerPersonAddedListener (PersonAddedListener listener) {
        // Add the listener to the list of registered listeners
        this.listeners.add(listener);
    }
    public void unregisterPersonAddedListener (PersonAddedListener listener) {
        // Remove the listener from the list of the registered listeners
        this.listeners.remove(listener);
    }

    protected void notifyPersonAddedListeners (Person person) {
        // Notify each of the listeners in the list of registered listeners
        this.listeners.forEach(listener -> listener.onPersonAdded(person));
    }
}