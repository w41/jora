#!/usr/bin/perl
package Jora::Commands::Misc::ShowHelp;

use strict;
use warnings;

use Moose;
use Data::Dumper;

extends 'Jora::Commands::Command';

has 'cmd' => (
        is  => 'ro',
        isa => 'Maybe[Str]',
);

around BUILDARGS => sub {
        my ( $orig, $class, $argv ) = ( shift, shift, shift );
        return $class->$orig( @_, cmd => shift $argv );
};

sub execute {
        my $self = shift;
        if ( !$self->cmd ) {
                print "General usage.\n";
        } else {
                print "Command-specific usage.\n";
        }
}

1;
