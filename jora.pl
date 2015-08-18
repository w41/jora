#!/usr/bin/perl

use v5.14;

use Getopt::Long qw(GetOptions);
use Jora::Commands::Command;
use Jora::Commands::CreateTask;
use Jora::Commands::DeleteTask;
use Jora::Commands::ShowHelp;
use Data::Dumper;
use Moose;
use Carp;
use Jora::Config;
use Jora::Sqlite;


Jora::Config->initialize();
Jora::Sqlite->initialize();

my %commands = ("create" => Jora::Commands::CreateTask->meta(),
		"delete" => Jora::Commands::DeleteTask->meta(),
		"help" => Jora::Commands::ShowHelp->meta());

my $cmd;
$cmd = shift or croak ("Command unspecified, try 'help'.");
print $cmd, "\n";

# print Dumper(%commands);

if($commands{$cmd}) {
	for my $attr ($commands{$cmd}->get_all_attributes) {
		print $attr->name, "\n";
	}
	my $derp = $commands{$cmd}->name->new(\@ARGV, id => 1);
	$derp->execute;
} else {
	croak "Command $cmd not found, try 'help'."; 
}
