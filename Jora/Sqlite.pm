#!/usr/bin/perl

package Jora::Sqlite;

use strict;
use warnings;
use Carp;
use Data::Dumper;
use Jora::Sqlite::Entities;
use Jora::Config;

sub get_all_tasks {
        return Jora::Sqlite::Entities::get_all_entities("sqlite.tasks");
}

sub get_task_info {
        return Jora::Sqlite::Entities::get_entity_info( shift, "name",
                "sqlite.tasks" );
}

sub task_exists {
        return Jora::Sqlite::Entities::entity_exists( shift, "name",
                "sqlite.tasks" );
}

sub create_task {
        my $task = shift;
        return Jora::Sqlite::Entities::create_entity(
                $task,
                "sqlite.tasks",
                sub {
                        task_exists($task)
                          and croak("Task $task->{name} already exists.");
                        $task->{assigned_user_id}
                          && !user_id_exists( $task->{assigned_user_id} )
                          and croak(
"User id $task->{assigned_user_id} doesn't exist."
                          );
                        !user_id_exists( $task->{author_id} )
                          and
                          croak("User id $task->{author_id} doesn't exist.");
                }
        );
}

sub delete_task {
        return Jora::Sqlite::Entities::delete_entity( shift, "name",
                "sqlite.tasks" );
}

sub delete_user {
        return Jora::Sqlite::Entities::delete_entity( shift, "login",
                "sqlite.users" );
}

sub modify_task {
        my $task          = shift;
        my $original_name = $task->{original_name};
        return Jora::Sqlite::Entities::modify_entity(
                $task, "name",
                "original_name",
                "sqlite.tasks",
                sub {
                        task_exists($original_name)
                          or croak "Task doesn't exist.";
                        $task->{name} && task_exists( $task->{name} )
                          and croak "Task '$task->{name}' already exists.";
                        $task->{author_id}
                          && !user_id_exists( $task->{author_id} )
                          and croak "User id $task->{author_id} doesn't exist.";
                        $task->{assigned_user_id}
                          && !user_id_exists( $task->{assigned_user_id} )
                          and croak
                          "User id $task->{assigned_user_id} doesn't exist.";
                }
        );
}

sub create_user {
        my $user = shift;
        return Jora::Sqlite::Entities::create_entity(
                $user,
                "sqlite.users",
                sub {
                        user_login_exists( $user->{login} )
                          and croak("User $user->{login} already exists.");
                }
        );
}

sub user_id_exists {
        return Jora::Sqlite::Entities::entity_exists( shift, "id",
                "sqlite.users" );
}

sub user_login_exists {
        return Jora::Sqlite::Entities::entity_exists( shift, "login",
                "sqlite.users" );
}

1;
