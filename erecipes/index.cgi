#!/opt/kperl/bin/perl
use utf8;
use strict;
use warnings;
use lib ( './perl/lib' );
use CGI::Ex::Recipes;
CGI::Ex::Recipes->new({ 'conf_file' =>'./conf/Recipes.conf' })->navigate();
