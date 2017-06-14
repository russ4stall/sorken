package com.russ4stall.sorken.person;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class PersonService {
    private List<Person> people;
    private List<PersonUpdatedListener> listeners;

    public PersonService() {
        people = new CopyOnWriteArrayList<>();
        listeners = new CopyOnWriteArrayList<>();
    }

    public Person getPersonById(int id) {
        Person person = people.stream()
                .filter(x -> x.getId() == id)
                .findFirst()
                .get();

        return person;
    }

    public Person addPerson(Person person) {
        person.setId(getNextId());
        people.add(person);
        notifyPersonUpdatedListeners(person);
        return person;
    }

    public void updatePerson(Person person) {
        Person toUpdate = people.stream()
                .filter(x -> x.getId() == person.getId())
                .findFirst()
                .get();

        toUpdate.setName(person.getName());
        toUpdate.setNotes(person.getNotes());
        toUpdate.setAge(person.getAge());

        notifyPersonUpdatedListeners(toUpdate);
    }

    public void removePerson(int personId) {
        Person person = people.stream()
                .filter(x -> x.getId() == personId)
                .findFirst()
                .get();

        people.remove(person);
        person.setDeleted(true);

        notifyPersonUpdatedListeners(person);
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

    public void registerPersonUpdatedListener(PersonUpdatedListener listener) {
        this.listeners.add(listener);
    }
    public void unregisterPersonUpdatedListener(PersonUpdatedListener listener) {
        this.listeners.remove(listener);
    }

    protected void notifyPersonUpdatedListeners (Person person) {
        this.listeners.forEach(listener -> listener.onUpdate(person));
    }
}