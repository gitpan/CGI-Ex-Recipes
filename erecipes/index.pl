package ourobscurepnamebakalalaheheyoidontknome;
CGI::Ex::Recipes->new({ 
    'base_dir_abs' => $ENV{SITE_ROOT},
    'conf' => $conf,
    'conf_obj' => $conf_obj,
    'template_obj' =>$template_obj,
    'dbh' => $dbh,
    '_package' => __PACKAGE__,
})->navigate();
