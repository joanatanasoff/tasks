<?php



$servername = "dbserver_replace";
$username = "dbuser_replace";
$dbport = "dbport_replace";
$password = "dbpassword_replace";
$webserver = "webserver_replace";
$dbname = "iaas_db";
$table = "iaas_table";


echo "<h1>Hello from $webserver</h1>";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname, $dbport);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// SQL to fetch first 3 rows
$sql = "SELECT * FROM " . $table . " LIMIT 3";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    echo "<table border='1'><tr>";
    // Output data of each field in the first row
    $fields = $result->fetch_fields();
    foreach ($fields as $field) {
        echo "<th>" . $field->name . "</th>";
    }
    echo "</tr>";
    // Output data of each row
    while($row = $result->fetch_assoc()) {
        echo "<tr>";
        foreach ($fields as $field) {
            echo "<td>" . $row[$field->name] . "</td>";
        }
        echo "</tr>";
    }
    echo "</table>";
} else {
    echo "0 results";
}
$conn->close();
?>

