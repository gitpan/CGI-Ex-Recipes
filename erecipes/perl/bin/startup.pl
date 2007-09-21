package ourobscurepackage;
BEGIN {
    $ENV{SITE_ROOT}= "/opt/apache2/htdocs/recipes/";
}
die "I refuse to work without mod_perl!" unless exists $ENV{MOD_PERL};
use utf8;
use strict;
use warnings;
use lib  $ENV{SITE_ROOT} . "/perl/lib";
use CGI::Ex;
use CGI::Ex::Conf;
use Template::Alloy;
use CGI::Ex::Recipes;
our $conf_obj = CGI::Ex::Conf->new({'paths'=>[$ENV{SITE_ROOT}],'directive'=>'MERGE'});
our $conf = $conf_obj->read($ENV{SITE_ROOT} .'/conf/Recipes.conf');
    $conf->{base_dir_abs} = $ENV{SITE_ROOT};
    $conf->{template_args}{INCLUDE_PATH} = $ENV{SITE_ROOT};
our $template_obj = Template::Alloy->new($conf->{template_args});
our $dbh = DBI->connect_cached(
               'dbi:SQLite:dbname=' . $ENV{SITE_ROOT} . '/' . $conf->{'db_file'}, '', '', 
               {'private_'. __PACKAGE__ => __PACKAGE__ , RaiseError => 1}
           );
1;
