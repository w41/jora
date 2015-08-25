#!/usr/bin/perl
package Jora::Commands::Users::DeleteUser;

use strict;
use warnings;

use Moose;
use Jora::Sqlite;
use Getopt::Long qw/GetOptionsFromArray/;
use Data::Dumper;

extends 'Jora::Commands::Command';

has 'login' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
);

around BUILDARGS => sub {
        my ( $orig, $class, $argv ) = ( shift, shift, shift );
        return $class->$orig( @_, login => shift @$argv );
};

sub execute {
        my $self = shift;
        Jora::Sqlite::delete_user( $self->login );
}

1;
