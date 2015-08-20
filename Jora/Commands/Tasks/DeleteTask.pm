#!/usr/bin/perl
package Jora::Commands::Tasks::DeleteTask;

use strict;
use warnings;

use Moose;
use Jora::Sqlite;
use Getopt::Long qw/GetOptionsFromArray/;
use Data::Dumper;

extends 'Jora::Commands::Command';

has 'name' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
);

around BUILDARGS => sub {
        my ( $orig, $class, $argv ) = ( shift, shift, shift );
        return $class->$orig( @_, name => shift $argv );
};

sub execute {
        my $self = shift;
        Jora::Sqlite::delete_task( $self->name );
}

1;
