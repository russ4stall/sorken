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
                <table id="people-table" class="table table-striped">
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
                            <tr data-bind="ifnot: $data.editMode">
                                <td data-bind="text: $data.id"></td>
                                <td data-bind="text: $data.name"></td>
                                <td data-bind="text: $data.age"></td>
                                <td data-bind="text: $data.notes"></td>
                                <td><button class="btn btn-outline-primary" data-bind="click: editToggle">Edit</button></td>
                            </tr>
                            <tr data-bind="if: $data.editMode">
                                <td data-bind="text: $data.id"></td>
                                <td>
                                    <input class="form-control" type="text" data-bind="value: $data.name">
                                </td>
                                <td>
                                    <input class="form-control" type="text" data-bind="value: $data.age">
                                </td>
                                <td>
                                    <input class="form-control" type="text" data-bind="value: $data.notes">
                                </td>
                                <td>
                                    <button class="btn btn-outline-danger" data-bind="click: editToggle">Cancel</button>
                                    <button class="btn btn-primary" data-bind="click: save">Save</button>
                                </td>
                            </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>

        var Person = function(id, name, age, notes, isDeleted) {
            var self = this;
            this.id = id;
            this.name = ko.observable(name);
            this.age = ko.observable(age);
            this.notes = ko.observable(notes);
            this.isDeleted = ko.observable(isDeleted);
            this.editMode = ko.observable(false);

            this.editToggle = function () {
                this.editMode(!this.editMode());
            };

            this.save = function () {
                var url = "/api/people?";
                url = url + "id=" + self.id;
                url = url + "&age=" + self.age();
                url = url + "&name=" + self.name();
                url = url + "&notes=" + self.notes();

                $.ajax({
                    url: url,
                    type: 'PUT',
                    success: function() {
                        self.editMode(false);
                    }
                });
            }
        };

        var ViewModel = function () {
            this.people = ko.observableArray();

            this.handleUpdateFromServer = function(person) {
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
            }
        };

        $(document).ready(function () {
            var viewModel = new ViewModel();
            ko.applyBindings(viewModel);

            $.getJSON("/api/people", function(data) {

                $.each( data, function( key, person ) {
                    //var person = JSON.parse(val)
                    viewModel.people.push(new Person(person.id, person.name, person.age, person.notes, person.isDeleted));
                });
            });

            //open websocket
            if ("WebSocket" in window) {
                //var hostnameAndPort = "192.168.1.10:8080";
                var hostnameAndPort = "localhost:8080";

                var ws = new WebSocket("ws://" + hostnameAndPort + "/watch-for-people");
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