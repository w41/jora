use strict;
use warnings;
use Test::More;
use Test::Fatal qw/dies_ok/;

BEGIN {
        `./install.sh`;
        is( $?, 0, "perform clean install" );
}

use Jora::Commands::Tasks::CreateTask;
use Jora::Commands::Tasks::DeleteTask;
use Jora::Commands::Tasks::ModifyTask;
use Jora::Commands::Tasks::GetTaskInfo;
use Jora::Commands::Users::CreateUser;
use Jora::Config;
use Jora::Sqlite;
use Jora::Sqlite::Entities;

Jora::Commands::Users::CreateUser->new( [ split ' ', 'TEST' ], id => 1 )
  ->execute;

my $result = 1;
for ( 1 .. 100 ) {
        $result &&= Jora::Commands::Tasks::CreateTask->new(
                [ split ' ', 'TEST' . $_ . ' -a 1' ],
                id => 1 )->execute;
}

ok( $result, "add 100 tasks" );

dies_ok {
        Jora::Commands::Tasks::CreateTask->new( [ split ' ', 'TEST7 -a 1' ],
                id => 1 )->execute,
          "add duplicate task"
};

dies_ok {
        Jora::Commands::Tasks::CreateTask->new( [ split ' ', '-a 1' ], id => 1 )
          ->execute,
          "add nameless task"
};

dies_ok {
        Jora::Commands::Tasks::CreateTask->new( [ split ' ', 'TEST' ], id => 1 )
          ->execute,
          "add authorless task"
};

dies_ok {
        Jora::Commands::Tasks::CreateTask->new( [ split ' ', 'TEST -a test' ],
                id => 1 )->execute,
          "add task with non-numeric author"
};

dies_ok {
        Jora::Commands::Tasks::CreateTask->new( [ split ' ', 'TEST -u test' ],
                id => 1 )->execute,
          "add task with non-numeric assignee"
};

dies_ok {
        Jora::Commands::Tasks::DeleteTask->new( [ split ' ', 'TEST' ], id => 1 )
          ->execute,
          "delete non-existing task"
};

ok(
        Jora::Commands::Tasks::CreateTask->new(
                [ split ' ', 'TEST -a 1 -s TEST' ],
                id => 1 )->execute,
        "add task with subject"
);

ok(
        Jora::Commands::Tasks::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with subject"
);

ok(
        Jora::Commands::Tasks::CreateTask->new(
                [ split ' ', 'TEST -a 1 --subj TEST' ],
                id => 1 )->execute,
        "add task with subject"
);

ok(
        Jora::Commands::Tasks::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with subject"
);

ok(
        Jora::Commands::Tasks::CreateTask->new(
                [ split ' ', 'TEST -a 1 --subject TEST' ],
                id => 1 )->execute,
        "add task with subject"
);

ok(
        Jora::Commands::Tasks::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with subject"
);

ok(
        Jora::Commands::Tasks::CreateTask->new(
                [ split ' ', 'TEST -a 1 -d TEST' ],
                id => 1 )->execute,
        "add task with description"
);

ok(
        Jora::Commands::Tasks::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with description"
);

ok(
        Jora::Commands::Tasks::CreateTask->new(
                [ split ' ', 'TEST -a 1 --desc TEST' ],
                id => 1 )->execute,
        "add task with description"
);

ok(
        Jora::Commands::Tasks::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with description"
);

ok(
        Jora::Commands::Tasks::CreateTask->new(
                [ split ' ', 'TEST -a 1 --description TEST' ],
                id => 1 )->execute,
        "add task with description"
);

ok(
        Jora::Commands::Tasks::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with description"
);

dies_ok {
        Jora::Commands::Tasks::ModifyTask->new( [ split ' ', 'MODIFY_TEST' ],
                id => 1 )->execute,
          "modify non-existing task"
};

dies_ok {
        Jora::Commands::Tasks::ModifyTask->new( [ split ' ', '-a 1' ], id => 1 )
          ->execute,
          "modify nameless task"
};

Jora::Commands::Tasks::CreateTask->new(
        [
                split ' ',
'MODIFY_TEST -a 1 -u 1 --subj MODIFY_TEST --description MODIFY_TEST'
        ],
        id => 1
)->execute;

Jora::Commands::Tasks::ModifyTask->new( [ split ' ', 'MODIFY_TEST -a 1' ],
        id => 1 )->execute;

is(
        %{
                [
                        Jora::Commands::Tasks::GetTaskInfo->new(
                                [ split ' ', 'MODIFY_TEST' ],
                                id => 1 )->execute
                ]->[1]
          }{author_id},
        1,
        "modify task author id"
);

Jora::Commands::Tasks::ModifyTask->new( [ split ' ', 'MODIFY_TEST -u 1' ],
        id => 1 )->execute;

is(
        %{
                [
                        Jora::Commands::Tasks::GetTaskInfo->new(
                                [ split ' ', 'MODIFY_TEST' ],
                                id => 1 )->execute
                ]->[1]
          }{assigned_user_id},
        1,
        "modify task assigned user id"
);

Jora::Commands::Tasks::ModifyTask->new(
        [ split ' ', 'MODIFY_TEST --subj MODIFIED' ],
        id => 1 )->execute;

is(
        %{
                [
                        Jora::Commands::Tasks::GetTaskInfo->new(
                                [ split ' ', 'MODIFY_TEST' ],
                                id => 1 )->execute
                ]->[1]
          }{subject},
        "MODIFIED",
        "modify task subject"
);

Jora::Commands::Tasks::ModifyTask->new(
        [ split ' ', 'MODIFY_TEST --desc MODIFIED' ],
        id => 1 )->execute;

is(
        %{
                [
                        Jora::Commands::Tasks::GetTaskInfo->new(
                                [ split ' ', 'MODIFY_TEST' ],
                                id => 1 )->execute
                ]->[1]
          }{description},
        "MODIFIED",
        "modify task description"
);
Jora::Commands::Tasks::CreateTask->new(
        [
                split ' ',
'MODIFY_TEST2 -a 1 -u 1 --subj MODIFY_TEST2 --description MODIFY_TEST2'
        ],
        id => 1
)->execute;

dies_ok {
        Jora::Commands::Tasks::ModifyTask->new(
                [ split ' ', 'MODIFY_TEST -n MODIFY_TEST2' ],
                id => 1 )->execute,
          "rename task to an already existing name"

};

done_testing();
