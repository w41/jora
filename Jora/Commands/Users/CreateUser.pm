#!/usr/bin/perl
package Jora::Commands::Users::CreateUser;

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
        my ($login) = ( shift @$argv );
        return $class->$orig( @_, login => $login, );
};

sub execute {
        my $self = { %{ $_[0] } };
        delete $self->{id};
        defined $self->{$_} or delete $self->{$_} for keys %$self;
        Jora::Sqlite::create_user($self);
}

1;
