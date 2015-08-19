#!/usr/bin/perl

package Jora::Sqlite;

use strict;
use warnings;
use DBI;
use DBD::SQLite;
use Carp;
use Jora::Config;

my $dbh;

sub initialize {
        $dbh = DBI->connect(
                "dbi:SQLite:dbname=$Jora::Config::Config{'sqlite.filename'}",
                "", "", { RaiseError => 1 } )
          or croak $DBI::errstr;
}

sub create_task {
        my $task = shift;
        my $query =
          $dbh->prepare( "INSERT INTO $Jora::Config::Config{'sqlite.tasks'}("
                  . ( join ", ", keys %$task )
                  . ") VALUES ("
                  . ( join ", ", map { "'$_'" } values %$task )
                  . ")" );
        $query->execute() or croak "Can't execute statement: $DBI::errstr";
}

sub delete_task {
        my $name  = shift;
        my $query = $dbh->prepare(
"DELETE FROM $Jora::Config::Config{'sqlite.tasks'} WHERE name = '$name'"
        );
        $query->execute() or croak "Can't execute statement: $DBI::errstr";

}

sub modify_task {
        my $task = shift;
        my $name = $task->{name};
        delete local $task->{name};

        grep { $_ eq $name } keys %{ get_tasks() }
          or croak "Task doesn't exist.";

        my $query =
          $dbh->prepare( "UPDATE $Jora::Config::Config{'sqlite.tasks'} SET "
                  . join( ", ", map { "$_ = '$task->{$_}'" } keys %$task )
                  . " WHERE name = '$name'" );

        $query->execute() or croak "Can't execute statement: $DBI::errstr";
}

1;
