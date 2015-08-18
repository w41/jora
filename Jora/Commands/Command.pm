#!/usr/bin/perl

package Jora::Commands::Command;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
use Jora::Commands::CommandIDStore;

has 'id' => ( 
	is => 'ro',	
	isa => 'Int',
	required => 1,
);

sub show_id {
	my $self = shift;

	print "my id is $self->id()\n";
}

__PACKAGE__->meta->make_immutable;

1;
