#!/usr/bin/perl
use strict;
use warnings;
use DBI;

# Database connection information
my $dsn = "DBI:mysql:database=your_database;host=localhost";
my $username = "your_username";
my $password = "your_password";

# Error log file
my $error_log = "/path/to/your/error.log";

# Number of connection attempts
my $max_attempts = 5;
my $attempt = 0;

my $dbh;

# Attempt to connect to the database
while ($attempt < $max_attempts) {
    eval {
        $dbh = DBI->connect($dsn, $username, $password, { RaiseError => 1, PrintError => 0, AutoCommit => 1 });
    };
    last unless $@;  # Exit loop if connection is successful

    # If here, connection attempt failed
    print "Failed to connect to database, attempt $attempt: $@\n";
    $attempt++;

    # Wait before retrying
    sleep(5);
}

# If we failed to connect after all attempts, log the error and exit
unless ($dbh) {
    open my $fh, '>>', $error_log or die "Could not open error log: $!";
    print $fh "Failed to connect to database after $max_attempts attempts\n";
    close $fh;
    die "Failed to connect to database after $max_attempts attempts\n";
}

# If here, we have a database connection
eval {
    # Create a table
    $dbh->do("
        CREATE TABLE IF NOT EXISTS test_table (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(30),
            age INT
        )
    ");

    # Insert some data
    $dbh->do("INSERT INTO test_table (name, age) VALUES ('Alice', 20), ('Bob', 25)");

    # Select and print the data
    my $sth = $dbh->prepare("SELECT * FROM test_table");
    $sth->execute();

    while (my $row = $sth->fetchrow_hashref()) {
        print "ID: $row->{id}, Name: $row->{name}, Age: $row->{age}\n";
    }

    # Disconnect from the database
    $dbh->disconnect();
};

# If an error occurred, log it and exit
if ($@) {
    open my $fh, '>>', $error_log or die "Could not open error log: $!";
    print $fh "An error occurred: $@\n";
    close $fh;
    die "An error occurred: $@\n";
}
