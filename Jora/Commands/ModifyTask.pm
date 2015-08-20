#!/usr/bin/perl
package Jora::Commands::ModifyTask;

use strict;
use warnings;

use Moose;
use Jora::Sqlite;
use Getopt::Long qw/GetOptionsFromArray/;
use Data::Dumper;

extends 'Jora::Commands::Command';

has 'original_name' => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
);

has [ 'subject', 'description' ] => (
        is  => 'ro',
        isa => 'Maybe[Str]',
);

has ['assigned_user_id'] => (
        is  => 'ro',
        isa => 'Maybe[Int]',
);

has ['author_id'] => (
        is  => 'ro',
        isa => 'Maybe[Int]',
);

has ['name'] => (
        is  => 'ro',
        isa => 'Maybe[Str]',
);

around BUILDARGS => sub {
        my ( $orig, $class, $argv ) = ( shift, shift, shift );
        my ( $original_name, $subject, $description, $assigned_user_id,
                $author_id, $name )
          = ( shift @$argv, undef, undef, undef, undef, undef );
        GetOptionsFromArray(
                $argv,
                "s|subject=s"                        => \$subject,
                "d|desc|description=s"               => \$description,
                "u|user|assigned|assigned_user_id=i" => \$assigned_user_id,
                "a|author|author_id=i"               => \$author_id,
                "n|name|newname=s"                   => \$name
        );
        return $class->$orig(
                @_,
                original_name    => $original_name,
                subject          => $subject,
                description      => $description,
                assigned_user_id => $assigned_user_id,
                author_id        => $author_id,
                name             => $name
        );
};

sub execute {
        my $self = { %{ $_[0] } };
        print Dumper($self);
        delete $self->{id};
        defined $self->{$_} or delete $self->{$_} for keys %$self;
        print Dumper($self);
        Jora::Sqlite::modify_task($self);
        print Dumper($self);
}

1;
