package ourobscurepackage;
BEGIN {
    $ENV{SITE_ROOT} = "/opt/apache2/htdocs/recipes/";
    require $ENV{SITE_ROOT} . '/perl/bin/startup.pl';
    warn '$ENV{SITE_ROOT}:'.$ENV{SITE_ROOT};
}
CGI::Ex::Recipes->new({ 
    'conf' => $conf,
    'conf_obj' => $conf_obj,
    'template_obj' =>$template_obj,
    'dbh' => $dbh,
    '_package' => __PACKAGE__,
})->navigate();



=pod

An alternative way to set the SITE_ROOT:

    BEGIN {
    use utf8;
    use strict;
    use warnings;
    # Set libpath (needed for mod_perl)
    our $SITE_ROOT = $ENV{"SCRIPT_FILENAME"} ;
    $SITE_ROOT =~s/^(.*?)\/[^\/]+$/$1/;
    }
    use lib $SITE_ROOT.'/perl/lib';

=cut
