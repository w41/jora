#!/usr/bin/perl

use v5.14;

use Getopt::Long qw(GetOptions);
use Jora::Commands::Command;
use Jora::Commands::Tasks::CreateTask;
use Jora::Commands::Tasks::DeleteTask;
use Jora::Commands::Tasks::ModifyTask;
use Jora::Commands::Tasks::GetTaskInfo;
use Jora::Commands::Misc::ShowHelp;
use Jora::Commands::Users::CreateUser;
use Data::Dumper;
use Moose;
use Carp;
use Jora::Config;
use Jora::Sqlite;
use Jora::Sqlite::Entities;
use Scalar::Util;

my %commands = (
        "task" => {
                "create" => Jora::Commands::Tasks::CreateTask->meta(),
                "delete" => Jora::Commands::Tasks::DeleteTask->meta(),
                "modify" => Jora::Commands::Tasks::ModifyTask->meta(),
                "info"   => Jora::Commands::Tasks::GetTaskInfo->meta(),
        },
        "user" => {
                "create" => Jora::Commands::Users::CreateUser->meta(),
        },
        "help" => Jora::Commands::Misc::ShowHelp->meta(),
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
