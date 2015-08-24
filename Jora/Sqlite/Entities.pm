#!/usr/bin/perl

package Jora::Sqlite::Entities;

use strict;
use warnings;

use DBI;
use DBD::SQLite;
use Jora::Config;
use Carp;
use Data::Dumper;

my $dbh;

INIT {
        $dbh = DBI->connect(
                "dbi:SQLite:dbname=$Jora::Config::Config{'sqlite.filename'}",
                "", "", { RaiseError => 1 } )
          or croak $DBI::errstr;
}

sub create_entity {
        my ( $entity, $table, $checks ) = ( shift, shift, shift );
        &$checks if $checks;
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

sub modify_entity {
        my ( $entity, $field, $original_key, $table, $checks ) =
          ( shift, shift, shift, shift, shift );
        my $original_value = $entity->{$original_key};
        delete $entity->{$original_key};

        &$checks if $checks;

        my $query =
          $dbh->prepare( "UPDATE $Jora::Config::Config{$table} SET "
                  . join( ", ", map { "$_ = '$entity->{$_}'" } keys %$entity )
                  . " WHERE $field = '$original_value'" );

        $query->execute() or croak "Can't execute statement: $DBI::errstr";
}

1;

