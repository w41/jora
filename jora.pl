#!/usr/bin/perl

use v5.14;

use Getopt::Long qw(GetOptions);
use Jora::Commands::Command;
use Jora::Commands::CreateTask;
use Jora::Commands::DeleteTask;
use Jora::Commands::ModifyTask;
use Jora::Commands::GetTaskInfo;
use Jora::Commands::ShowHelp;
use Data::Dumper;
use Moose;
use Carp;
use Jora::Config;
use Jora::Sqlite;
use Scalar::Util;

Jora::Config->initialize();
Jora::Sqlite->initialize();

my %commands = (
        "task" => {
                "create" => Jora::Commands::CreateTask->meta(),
                "delete" => Jora::Commands::DeleteTask->meta(),
                "modify" => Jora::Commands::ModifyTask->meta(),
                "info"   => Jora::Commands::GetTaskInfo->meta(),
        },
        "help" => Jora::Commands::ShowHelp->meta(),
);

my $cmd_or_category;
$cmd_or_category = shift or croak("Command unspecified, try 'help'.");
print $cmd_or_category, "\n";

# print Dumper(%commands);

if ( $commands{$cmd_or_category} ) {
        if ( blessed( $commands{$cmd_or_category} ) ) {
                $commands{$cmd_or_category}->name->new( \@ARGV, id => 1 )
                  ->execute;
        } else {
                my $cmd_name = shift;
                my $cmd      = $commands{$cmd_or_category}{$cmd_name};
                $cmd
                  or croak
                  "Command $cmd_or_category $cmd_name not found, try 'help'.";
                $cmd->name->new( \@ARGV, id => 1 )->execute;
        }
} else {
        croak "Command $cmd_or_category not found, try 'help'.";
}
