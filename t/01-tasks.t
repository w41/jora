use strict;
use warnings;
use Test::More;
use Test::Fatal qw/dies_ok/;

use Jora::Commands::CreateTask;
use Jora::Commands::DeleteTask;
use Jora::Commands::ModifyTask;
use Jora::Commands::GetTaskInfo;
use Jora::Config;
use Jora::Sqlite;

`./install.sh`;
is( $?, 0, "perform clean install" );

Jora::Config->initialize;
Jora::Sqlite->initialize;

my $result = 1;
for ( 1 .. 100 ) {
        $result &&= Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST' . $_ . ' -a 15' ],
                id => 1 )->execute;
}

ok( $result, "add 100 tasks" );

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST7 -a 15' ], id => 1 )
          ->execute,
          "add duplicate task"
};

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', '-a 15' ], id => 1 )
          ->execute,
          "add nameless task"
};

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST' ], id => 1 )
          ->execute,
          "add authorless task"
};

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST -a test' ],
                id => 1 )->execute,
          "add task with non-numeric author"
};

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST -u test' ],
                id => 1 )->execute,
          "add task with non-numeric assignee"
};

dies_ok {
        Jora::Commands::DeleteTask->new( [ split ' ', 'TEST' ], id => 1 )
          ->execute,
          "delete non-existing task"
};

ok(
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST -a 15 -s TEST' ],
                id => 1 )->execute,
        "add task with subject"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with subject"
);

ok(
        Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST -a 15 --subj TEST' ],
                id => 1 )->execute,
        "add task with subject"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with subject"
);

ok(
        Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST -a 15 --subject TEST' ],
                id => 1 )->execute,
        "add task with subject"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with subject"
);

ok(
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST -a 15 -d TEST' ],
                id => 1 )->execute,
        "add task with description"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with description"
);

ok(
        Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST -a 15 --desc TEST' ],
                id => 1 )->execute,
        "add task with description"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with description"
);

ok(
        Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST -a 15 --description TEST' ],
                id => 1 )->execute,
        "add task with description"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete task with description"
);

dies_ok {
        Jora::Commands::ModifyTask->new( [ split ' ', 'MODIFY_TEST' ], id => 1 )
          ->execute,
          "modify non-existing task"
};

dies_ok {
        Jora::Commands::ModifyTask->new( [ split ' ', '-a 15' ], id => 1 )
          ->execute,
          "modify nameless task"
};

Jora::Commands::CreateTask->new(
        [
                split ' ',
'MODIFY_TEST -a 15 -u 1 --subj MODIFY_TEST --description MODIFY_TEST'
        ],
        id => 1
)->execute;

Jora::Commands::ModifyTask->new( [ split ' ', 'MODIFY_TEST -a 16' ], id => 1 )
  ->execute;

is(
        %{
                [
                        Jora::Commands::GetTaskInfo->new(
                                [ split ' ', 'MODIFY_TEST' ],
                                id => 1 )->execute
                ]->[1]
          }{author_id},
        16,
        "modify task author id"
);

Jora::Commands::ModifyTask->new( [ split ' ', 'MODIFY_TEST -u 16' ], id => 1 )
  ->execute;

is(
        %{
                [
                        Jora::Commands::GetTaskInfo->new(
                                [ split ' ', 'MODIFY_TEST' ],
                                id => 1 )->execute
                ]->[1]
          }{assigned_user_id},
        16,
        "modify task assigned user id"
);

Jora::Commands::ModifyTask->new( [ split ' ', 'MODIFY_TEST --subj MODIFIED' ],
        id => 1 )->execute;

is(
        %{
                [
                        Jora::Commands::GetTaskInfo->new(
                                [ split ' ', 'MODIFY_TEST' ],
                                id => 1 )->execute
                ]->[1]
          }{subject},
        "MODIFIED",
        "modify task subject"
);

Jora::Commands::ModifyTask->new( [ split ' ', 'MODIFY_TEST --desc MODIFIED' ],
        id => 1 )->execute;

is(
        %{
                [
                        Jora::Commands::GetTaskInfo->new(
                                [ split ' ', 'MODIFY_TEST' ],
                                id => 1 )->execute
                ]->[1]
          }{description},
        "MODIFIED",
        "modify task description"
);
Jora::Commands::CreateTask->new(
        [
                split ' ',
'MODIFY_TEST2 -a 15 -u 1 --subj MODIFY_TEST2 --description MODIFY_TEST2'
        ],
        id => 1
)->execute;

dies_ok {
        Jora::Commands::ModifyTask->new(
                [ split ' ', 'MODIFY_TEST -n MODIFY_TEST2' ],
                id => 1 )->execute,
          "rename task to an already existing name"

};

done_testing();
