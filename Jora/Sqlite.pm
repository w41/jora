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

sub create_entity {
        my ( $entity, $table ) = ( shift, shift );
        my $query =
          $dbh->prepare( "INSERT INTO $Jora::Config::Config{$table}("
                  . ( join ", ", keys %$entity )
                  . ") VALUES ("
                  . ( join ", ", map { "'$_'" } values %$entity )
                  . ")" );
        $query->execute() or croak "Can't execute statement: $DBI::errstr";
}

sub get_entity_info {
        my ( $entity_name, $field, $table ) = ( shift, shift, shift );
        my $query = $dbh->prepare(
"SELECT * FROM $Jora::Config::Config{$table} WHERE $field = '$entity_name'"
        );
        $query->execute() or croak "Can't execute statement: $DBI::errstr";

        return ( $entity_name, $query->fetchrow_hashref );
}

sub entity_exists {
        return [ get_entity_info( shift, shift, shift ) ]->[1];
}

sub delete_entity {
        my ( $entity_name, $field, $table ) = ( shift, shift, shift );

        entity_exists( $entity_name, $field, $table )
          or croak "Entity doesn't exist.";

        my $query = $dbh->prepare(
"DELETE FROM $Jora::Config::Config{$table} WHERE $field = '$entity_name'"
        );
        $query->execute() or croak "Can't execute statement: $DBI::errstr";

}

sub get_all_entities {
        my $table = shift;
        my $query =
          $dbh->prepare("SELECT * FROM $Jora::Config::Config{$table}");
        $query->execute() or croak "Can't execute statement: $DBI::errstr";

        my $retval;

        while ( local $_ = $query->fetchrow_hashref ) {
                $retval->{ $_->{name} } = $_;
        }

        return $retval;
}

sub get_all_tasks {
        return get_all_entities("sqlite.tasks");
}

sub get_task_info {
        return get_entity_info( shift, "name", "sqlite.tasks" );
}

sub task_exists {
        return entity_exists( shift, "name", "sqlite.tasks" );
}

sub create_task {
        return create_entity( shift, "sqlite.tasks" );
}

sub delete_task {
        return delete_entity( shift, "name", "sqlite.tasks" );
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
