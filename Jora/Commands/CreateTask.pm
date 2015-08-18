#!/usr/bin/perl
package Jora::Commands::CreateTask;

use strict;
use warnings;

use Moose;
use Jora::Sqlite;
use Getopt::Long qw/GetOptionsFromArray/;
use Data::Dumper;

extends 'Jora::Commands::Command';

has 'name' => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

has ['subject', 'description'] => (
	is => 'ro',
	isa => 'Maybe[Str]',
);

around BUILDARGS => sub {
	my ($orig, $class, $name) = (shift, shift, shift);
	my ($subject, $description);
	GetOptionsFromArray(\@_, "s=s" => \$subject, "d=s" => \$description);
	print Dumper($subject, $description);
	return $class->$orig(@_, name => $name, subject => $subject, description => $description);
};

sub BUILD {
	print Dumper(shift);
}

sub execute {
	my $self = shift;
	print Dumper($self);
	Jora::Sqlite::create_task($self->name, $self->subject, $self->description);
}

1;
