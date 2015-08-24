#!/usr/bin/perl

use strict;
use warnings;

use Config::Simple;

package Jora::Config;

our %Config;

#sub initialize {
#	my $cfg = new Config::Simple(syntax => "ini");
#
#	$cfg->param("sqlite.filename", "jora.sqlite");
#	$cfg->write("jora.cfg");
#}

INIT {
        Config::Simple->import_from( "jora.cfg", \%Config );
}

1;
