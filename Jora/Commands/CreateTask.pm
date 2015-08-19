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
        is       => 'ro',
        isa      => 'Str',
        required => 1,
);

has [ 'subject', 'description' ] => (
        is  => 'ro',
        isa => 'Maybe[Str]',
);

has ['assigned_user_id'] => (
        is  => 'rw',
        isa => 'Maybe[Int]',
);

has ['author_id'] => (
        is       => 'ro',
        isa      => 'Int',
        required => 1,
);

around BUILDARGS => sub {
        my ( $orig, $class, $argv ) = ( shift, shift, shift );
        my ( $name, $subject, $description, $assigned_user_id, $author_id ) =
          ( shift @$argv, undef, undef, undef, undef );
        GetOptionsFromArray(
                $argv,
                "s|subject=s"                        => \$subject,
                "d|desc|description=s"               => \$description,
                "u|user|assigned|assigned_user_id=i" => \$assigned_user_id,
                "a|author|author_id=i"               => \$author_id
        );
        return $class->$orig(
                @_,
                name             => $name,
                subject          => $subject,
                description      => $description,
                assigned_user_id => $assigned_user_id,
                author_id        => $author_id
        );
};

sub execute {
        my $self = { %{ $_[0] } };
        delete $self->{id};
        defined $self->{$_} or delete $self->{$_} for keys %$self;
        Jora::Sqlite::create_task($self);
}

1;
