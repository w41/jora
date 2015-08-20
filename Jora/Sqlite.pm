#!/usr/bin/perl

package Jora::Sqlite;

use strict;
use warnings;
use DBI;
use DBD::SQLite;
use Carp;
use Jora::Config;
use Data::Dumper;

my $dbh;

sub initialize {
        $dbh = DBI->connect(
                "dbi:SQLite:dbname=$Jora::Config::Config{'sqlite.filename'}",
                "", "", { RaiseError => 1 } )
          or croak $DBI::errstr;
}

sub get_tasks {
        my $query =
          $dbh->prepare("SELECT * FROM $Jora::Config::Config{'sqlite.tasks'}");
        $query->execute() or croak "Can't execute statement: $DBI::errstr";

        my $retval;

        while ( local $_ = $query->fetchrow_hashref ) {
                $retval->{ $_->{name} } = $_;
        }

        return $retval;
}

sub get_task_info {
        my $name  = shift;
        my $query = $dbh->prepare(
"SELECT * FROM $Jora::Config::Config{'sqlite.tasks'} WHERE name = '$name'"
        );
        $query->execute() or croak "Can't execute statement: $DBI::errstr";

        return ( $name, \$query->fetchrow_hashref );
}

sub task_exists {
        return ${ [ get_task_info(shift) ]->[1] };
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
        my $name = shift;

        task_exists($name) or croak "Task doesn't exist.";

        my $query = $dbh->prepare(
"DELETE FROM $Jora::Config::Config{'sqlite.tasks'} WHERE name = '$name'"
        );
        $query->execute() or croak "Can't execute statement: $DBI::errstr";

}

sub modify_task {
        my $task          = shift;
        my $original_name = $task->{original_name};
        delete local $task->{original_name};

        task_exists($original_name) or croak "Task doesn't exist.";
        task_exists( $task->{name} )
          and croak "Task '$task->{name}' already exists.";

        my $query =
          $dbh->prepare( "UPDATE $Jora::Config::Config{'sqlite.tasks'} SET "
                  . join( ", ", map { "$_ = '$task->{$_}'" } keys %$task )
                  . " WHERE name = '$original_name'" );

        $query->execute() or croak "Can't execute statement: $DBI::errstr";
}

1;
