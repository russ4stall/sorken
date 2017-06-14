<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <title>Creepin'</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/css/bootstrap.min.css" integrity="sha384-rwoIResjU2yc3z8GV/NPeZWAv56rSmLldC3R/AZzGRnGxQQKnKkoFVhFQhNUwEyJ"
            crossorigin="anonymous">
        <script src="https://code.jquery.com/jquery-3.1.1.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js" integrity="sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb"
            crossorigin="anonymous"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/js/bootstrap.min.js" integrity="sha384-vBWWzlZJ8ea9aCX4pEW3rVHjgjt7zpkNpZk+02D9phzyeVkE+jo0ieGizqPLForn"
            crossorigin="anonymous"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.2/knockout-min.js"></script>

    </head>

    <body>
        <div class="container">
            <div class="row">
                <div class="col">
                    <table id="people-table" class="table table-sm">
                        <thead>
                            <tr>
                                <th>Id</th>
                                <th>Name</th>
                                <th>Age</th>
                                <th>Notes</th>
                                <th></th>

                            </tr>
                        </thead>
                        <tbody data-bind="foreach: people">
                            <tr data-bind="ifnot: $data.inEditMode">
                                <td data-bind="text: $data.id"></td>
                                <td data-bind="text: $data.name"></td>
                                <td data-bind="text: $data.age"></td>
                                <td data-bind="text: $data.notes"></td>
                                <td>
                                    <button class="btn btn-outline-primary btn-sm" data-bind="click: editToggle">Edit</button>
                                    <button class="btn btn-outline-danger btn-sm" data-bind="click: deletePerson">Delete</button>
                                </td>
                            </tr>
                            <tr data-bind="if: $data.inEditMode">
                                <td data-bind="text: $data.id"></td>
                                <td>
                                    <input class="form-control form-control-sm" type="text" required data-bind="value: $data.editName">
                                </td>
                                <td>
                                    <input class="form-control form-control-sm" type="number" required data-bind="value: $data.editAge">
                                </td>
                                <td>
                                    <input class="form-control form-control-sm" type="text" required data-bind="value: $data.editNotes">
                                </td>
                                <td>
                                    <button class="btn btn-outline-secondary btn-sm" data-bind="click: cancel">Cancel</button>
                                    <button class="btn btn-outline-primary btn-sm" data-bind="click: save">Save</button>
                                </td>
                            </tr>
                        </tbody>
                        <tfoot>
                            <tr>
                                <td></td>
                                <td>
                                    <input class="form-control" type="text" placeholder="Name" required data-bind="value: newPerson.editName">
                                </td>
                                <td>
                                    <input class="form-control" type="number" placeholder="Age" required data-bind="value: newPerson.editAge">
                                </td>
                                <td>
                                    <input class="form-control" type="text" placeholder="Notes" required data-bind="value: newPerson.editNotes">
                                </td>
                                <td>                                    
                                    <button class="btn btn-primary" data-bind="click: addPerson">Add</button>
                                </td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>

        <script>
            var Person = function (id, name, age, notes, isDeleted) {
                var self = this;
                this.id = id;
                this.name = ko.observable(name);
                this.age = ko.observable(age);
                this.notes = ko.observable(notes);
                this.isDeleted = ko.observable(isDeleted);

                this.editName = ko.observable(name);
                this.editAge = ko.observable(age);
                this.editNotes = ko.observable(notes);

                this.inEditMode = ko.observable(false);

                this.editToggle = function () {
                    this.inEditMode(!this.inEditMode())
                };

                this.deletePerson = function () {
                    var url = "/api/people?";
                    url = url + "id=" + self.id;
                    $.ajax({
                        url: url,
                        type: 'DELETE',
                        success: function () {
                            console.log("successfully deleted: ", self.id);
                        }
                    });
                };

                this.cancel = function () {
                    this.editName(this.name());
                    this.editAge(this.age());
                    this.editNotes(this.notes());
                    this.inEditMode(false);
                };

                this.save = function () {
                    var url = "/api/people?";
                    url = url + "id=" + self.id;
                    url = url + "&age=" + self.editAge();
                    url = url + "&name=" + self.editName();
                    url = url + "&notes=" + self.editNotes();

                    $.ajax({
                        url: url,
                        type: 'PUT',
                        success: function () {
                            self.name(self.editName());
                            self.age(self.editAge());
                            self.notes(self.editNotes());
                            self.inEditMode(false);
                        }
                    });
                };
            };

            var ViewModel = function () {
                var self = this;
                this.people = ko.observableArray();
                this.newPerson = new Person();

                this.addPerson = function () {                
                    $.post( "/api/people", { name: this.newPerson.editName(), age: this.newPerson.editAge(), notes: this.newPerson.editNotes() }, function () {
                        self.newPerson.editName("").editAge("").editNotes("");
                    });
                };

                this.handleUpdateFromServer = function (person) {
                    for (var i = this.people().length - 1; i >= 0; i--) {
                        if (this.people()[i].id == person.id) {
                            if (person.isDeleted) {
                                this.people.remove(this.people()[i]);
                                return;
                            } else {
                                this.people()[i]
                                    .name(person.name)
                                    .age(person.age)
                                    .notes(person.notes);
                                //this.people()[i].age(person.age);
                                //this.people()[i].notes(person.notes);
                                return;
                            }
                        }
                    }

                    this.people.push(new Person(person.id, person.name, person.age, person.notes, person.isDeleted));
                };
            };

            $(document).ready(function () {
                var viewModel = new ViewModel();
                ko.applyBindings(viewModel);

                $.getJSON("/api/people", function (data) {

                    $.each(data, function (key, person) {
                        //var person = JSON.parse(val)
                        viewModel.people.push(new Person(person.id, person.name, person.age, person.notes, person.isDeleted));
                    });
                });

                //open websocket
                if ("WebSocket" in window) {
                    //var hostnameAndPort = "192.168.1.10:8080";
                    //var hostnameAndPort = "localhost:8080";
                    var host = window.location.host;

                    var ws = new WebSocket("ws://" + host + "/watch-for-people");
                    //var ws = new WebSocket("ws://localhost:8080/watch-for-people");
                    ws.onopen = function () { console.log("Now people watching..."); };
                    ws.onmessage = function (evt) {
                        var person = JSON.parse(evt.data);
                        console.log("received: ", person);

                        viewModel.handleUpdateFromServer(person);
                    };
                    ws.onclose = function () { console.log("Connection is closed..."); };
                } else {
                    alert("WebSocket NOT supported by your Browser!");
                }
            });
        </script>
    </body>

    </html>