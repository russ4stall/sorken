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
    <script src="https://code.jquery.com/jquery-3.1.1.slim.min.js" integrity="sha384-A7FZj7v+d/sdmMqp/nOQwliLvUsJfDHW+k9Omg/a/EheAdgtzNs3hpfag6Ed950n"
        crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tether/1.4.0/js/tether.min.js" integrity="sha384-DztdAPBWPRXSA/3eYEEUWrWCy7G5KFbe8fFjk5JAIxUYHKkDx6Qin1DkWx51bBrb"
        crossorigin="anonymous"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0-alpha.6/js/bootstrap.min.js" integrity="sha384-vBWWzlZJ8ea9aCX4pEW3rVHjgjt7zpkNpZk+02D9phzyeVkE+jo0ieGizqPLForn"
        crossorigin="anonymous"></script>

</head>

<body>
    <div class="container">
        <div class="row">
            <div class="col-sm-4">
                <table id="people-table" class="table table-striped">
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Name</th>
                            <th>Age</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${people}" var="person">
                            <tr data-person-id="${person.id}">
                                <td>${person.id}</td>
                                <td>${person.name}</td>
                                <td>${person.age}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function () {
            if ("WebSocket" in window) {
                var ws = new WebSocket("ws://localhost:8080/sorken/watch-for-people");
                ws.onopen = function () { console.log("Now people watching..."); };
                ws.onmessage = function (evt) {
                    var person = JSON.parse(evt.data);
                    console.log("received: ", person);                    
                    $("#people-table tbody").append("<tr data-person-id='" + person.id + "'><td>" + person.id + "</td><td>" + person.name + "</td><td>" + person.age + "</td></tr>")
                };
                ws.onclose = function () { console.log("Connection is closed..."); };
            } else {
                alert("WebSocket NOT supported by your Browser!");
            }
        });
    </script>
</body>

</html>