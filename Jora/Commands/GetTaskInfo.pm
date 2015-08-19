#!/usr/bin/perl

package Jora::Commands::GetTaskInfo;

use Moose;
use Data::Dumper;
use Jora::Sqlite;

extends 'Jora::Commands::Command';

has 'name' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
);

around BUILDARGS => sub {
        my ( $orig, $class, $argv ) = ( shift, shift, shift );
        return $class->$orig( @_, name => shift @$argv );
};

sub execute {
        my $self   = shift;
        my @retval = Jora::Sqlite::get_task_info( $self->{name} );
        print Dumper(@retval);
        return @retval;
}

1;
