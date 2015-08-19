use strict;
use warnings;
use Test::More;
use Test::Fatal qw/dies_ok/;

use Jora::Commands::CreateTask;
use Jora::Commands::DeleteTask;
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

ok( $result, "add 100 commands" );

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST7 -a 15' ], id => 1 )
          ->execute,
          "add duplicate command"
};

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', '-a 15' ], id => 1 )
          ->execute,
          "add nameless command"
};

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST' ], id => 1 )
          ->execute,
          "add authorless command"
};

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST -a test' ],
                id => 1 )->execute,
          "add command with non-numeric author"
};

dies_ok {
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST -u test' ],
                id => 1 )->execute,
          "add command with non-numeric assignee"
};

ok(
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST -a 15 -s TEST' ],
                id => 1 )->execute,
        "add command with subject"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete command with subject"
);

ok(
        Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST -a 15 --subj TEST' ],
                id => 1 )->execute,
        "add command with subject"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete command with subject"
);

ok(
        Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST -a 15 --subject TEST' ],
                id => 1 )->execute,
        "add command with subject"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete command with subject"
);

ok(
        Jora::Commands::CreateTask->new( [ split ' ', 'TEST -a 15 -d TEST' ],
                id => 1 )->execute,
        "add command with description"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete command with description"
);

ok(
        Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST -a 15 --desc TEST' ],
                id => 1 )->execute,
        "add command with description"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete command with description"
);

ok(
        Jora::Commands::CreateTask->new(
                [ split ' ', 'TEST -a 15 --description TEST' ],
                id => 1 )->execute,
        "add command with description"
);

ok(
        Jora::Commands::DeleteTask->new(
                [ split ' ', 'TEST' ], id => 1
          )->execute,
        "delete command with description"
);

done_testing();
