#!/usr/bin/perl
package Jora::Commands::ModifyTask;

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
	my ($orig, $class, $argv) = (shift, shift, shift);
	my ($name, $subject, $description) = (shift @$argv);
	GetOptionsFromArray($argv, "s=s" => \$subject, "d=s" => \$description);
	return $class->$orig(@_, name => $name, subject => $subject, description => $description);
};

sub execute {
	my $self = shift;
	Jora::Sqlite::modify_task($self->name, $self->subject, $self->description);
}

1;
