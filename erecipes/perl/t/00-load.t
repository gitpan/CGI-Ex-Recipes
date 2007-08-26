#!perl -T

use Test::More tests => 9;

BEGIN {
	use_ok( 'CGI::Ex::Recipes' );
	use_ok( 'CGI::Ex::Recipes::View' );
	use_ok( 'CGI::Ex::Recipes::Edit' );
	use_ok( 'CGI::Ex::Recipes::Add' );
	use_ok( 'CGI::Ex::Recipes::Delete' );
	use_ok( 'CGI::Ex::Recipes::Template::Menu' );
	use_ok( 'CGI::Ex::Recipes::DBIx' );
	use_ok( 'CGI::Ex::Recipes::Default' );
	use_ok( 'CGI::Ex::Recipes::Imager' );
}

diag( "Testing CGI::Ex::Recipes $CGI::Ex::Recipes::VERSION, Perl $], $^X" );
