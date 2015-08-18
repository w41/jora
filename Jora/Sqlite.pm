#!/usr/bin/perl

package Jora::Sqlite;

use strict;
use warnings;
use DBI;
use DBD::SQLite;
use Carp;
use Jora::Config;

my $dbh;

sub initialize {
	$dbh = DBI->connect("dbi:SQLite:dbname=$Jora::Config::Config{'sqlite.filename'}", "", "", { RaiseError => 1 })
		or croak $DBI::errstr;
}

sub create_task {
	my ($name, $subject, $description) = (shift, shift, shift);
	print "name = $name\n";

	my $query = $dbh->prepare("INSERT INTO $Jora::Config::Config{'sqlite.tasks'}(name, subject, description) VALUES ('$name', '$subject', '$description')");
	$query->execute() or croak "Can't execute statement: $DBI::errstr";
}

sub delete_task {
	my $name = shift;
}

1;
