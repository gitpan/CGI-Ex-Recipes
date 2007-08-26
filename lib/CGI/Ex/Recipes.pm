package CGI::Ex::Recipes;
use utf8;
use warnings;
use strict;
use Carp qw(croak);
use base qw(CGI::Ex::App);
use CGI::Ex::Die register => 1;
use CGI::Ex::Dump qw(debug dex_warn);
use CGI::Ex::Recipes::DBIx qw(
    dbh
    sql
    create_tables
    categories
    recipes
);

our $VERSION = '0.04';

sub ext_conf {
    my $self = shift;
    $self->{'ext_conf'} = shift if @_ == 1;
    return $self->{'ext_conf'} || 'conf';
}

sub load_conf { $_[0]->{'load_conf'} || 1 }

sub base_dir_abs {$_[0]->{'base_dir_abs'} || ['./']}

sub allow_morph {
    my ( $self, $step ) = @_;
   return $self->conf->{allow_morph}->{$step};
}

#...but rather override the path_info_map hook for a particular step.
sub path_info_map {
    my ($self) = @_;
    my $step = $self->form->{ $self->step_key } || $self->conf->{default_step};
    return $self->conf->{path_info_map}{$step} || do {
        my $step = $self->form->{ $self->step_key } || $self->conf->{default_step};
        return '' if $step eq $self->conf->{default_step};
        [ 
            [ 
                qr{^/$step/(\d+)}, 'id' 
            ] 
        ];
    }
}

#Will be run natively for all subclasses
sub skip { shift->form->{'id'} ? 0 : 1 }

#ADDING AUTHENTICATION TO THE ENTIRE APPLICATION
sub get_pass_by_user {
   my $self = shift;
   my $user = shift;
   return $self->conf->{users}{$user};
}

#ADDING AUTHENTICATION TO INDIVIDUAL STEPS
sub require_auth { 
    my ($self, $step) = @_;  
    #allow configuration first
    return $self->conf->{require_auth}{$step} || 0;
}

#get authentication arguments from configuration if there is such
sub auth_args { 
    my $self = shift;
    {
        $self->conf->{template_args},
        $self->conf->{auth_args}
    };
}
#Me in 0.01:
#   ADDING ADDITIONAL TEMPLATE VARIABLES
#   the application object for all steps

#Paul on 25.06.2007 21:00:
#   In the hash_base method you store $self in $self->{'hash_base'}.  This
#   presents a problem in that you have created a circular ref.  This
#   is "somewhat" fine in a CGI environment because it will be cleaned up in the
#   global destruction phase, but in a mod_perl environment that ref will stay
#   resident until apache is restarted.

#   The way to do something like that is to do....

#Me now:   
#   and here it is  the application object for all steps available in templates
sub hash_base {
    my $self = shift;
    my $hash = $self->SUPER::hash_base(@_);
    $hash->{'app'} = $self;
    #require Scalar::Util; 
    Scalar::Util::weaken($hash->{'app'});
    return $hash;
}


sub post_navigate {
   my $self = shift;
   # show what happened
   if ($self->{'debug'}) {
       #debug $self->dump_history;
       #debug $self->conf;
       #debug \%ENV;
       #debug $self->cookies;
       debug $self->form;
       #debug \%INC;
   }
   #or do other usefull things.
}

sub pre_navigate { 

    #efectively logout
    require CGI::Ex::Auth;
    $_[0]->CGI::Ex::Auth::delete_cookie({'key'=>'cea_user'}) 
        if $_[0]->form->{'logout'};
    return 0;
}

sub pre_step {
    $_[0]->step_args;
    #run other things here
    return 0;
}

# hook/method - returns parsed arguments from C<$self->form->{step_info}> 
#for the curent step
# initially called in pre_step
sub step_args {
    return $_[0]->form->{step_args} || do {
        if($_[0]->form->{step_info}){
            my @step_args = split /\//,$_[0]->form->{step_info};
            for( my $i = 0 ; $i < @step_args; $i = $i+2 ){
                $_[0]->form->{step_args}{$step_args[$i]} = $step_args[$i+1] || '';
            }
        }
        return $_[0]->form->{step_args} || {};
    }
}



#========================== UTIL ==============================
#Utility funcions - may be moved to an Util class if needed
sub strftmime {
    my $self = shift;
    require POSIX;
    POSIX::strftime(shift,localtime( shift||time ) );
}
sub now {time};
1; # End of CGI::Ex::Recipes


__END__

=head1 NAME

CGI::Ex::Recipes - A usage example for CGI::Ex::App!

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

You may find in index.cgi the following:

    use CGI::Ex::Recipes;
    CGI::Ex::Recipes->new({
        conf_file => './conf/Recipes.conf',
    })->navigate;
    ...

=head1 DESCRIPTION

This small but relatively complete application was inspired by the examples 
given by Paul in his documentation. I decided to go further and experiment with 
the recomendations and features which the framework provides. 
You are encouraged to play with it and use it as a starting point  for far more 
complex and customized applications.

=head1 REQUIREMENTS
    
    CGI::Ex
    DBI
    DBD::SQLite
    SQL::Abstract
    YAML

=head1 INSTALL

    1. CPAN
        
    2. svn checkout https://bcc.svn.sourceforge.net:443/svnroot/bcc/trunk/recipes
    into some viewable by the server dir with option AllowOverride All

=head1 MOD_PERL

See in the distribution index.pl and perl/bin/startup.pl.
Modify these files to meet your needs.
More to write...


=head1 METHODS

Below are mentioned only methods which are overridden or not provided by CGI::Ex::App.
Some of them or their modified variants, or parts of them will probably find 
their way up to the base module. Some of them did it already.
This way they will become obsolete, but that is the point.

Others will stay here since they provide some specific for the application functionality.
Writing more specific methods will meen you make your own application, 
reflecting your own buziness logic.
This is good, because CGI::Ex::Recipes has done his job, by providing a codebase and 
starting point for you.

You are wellcome to give feedback if you think some functionality is enough 
common to go up straight to CGI::Ex::App.

Bellow are described  overriten methods and methods defined in this package.  


=head2 load_conf

Returns  the value of C<$self-E<gt>{load_conf}> or 1(TRUE) by default.

=head2 pre_step

Returns 0 after executing C<$self-E<gt>step_args()>.

=head2 allow_morph

Blindly returns the current value of allow_morph key in Recipes.conf,
which should be interpreted as TRUE or FALSE.


=head2 path_info_map

This is just our example implementation, following recomendations in L<CGI::Ex::App>.


=head2 skip

Ran at the beginning of the loop before prepare, info_complete, and finalize are called. 
If it returns true, nav_loop moves on to the next step (the current step is skipped).

In our case we bind it to the presence of the C<id> parameter from the HTTP request. 
So if there is an C<id> parameter it returns 0 otherwise 1.

=head2 get_pass_by_user

Returns the password for the given user. See the get_pass_by_user method of CGI::Ex::Auth 
for more information. Installed as a hook to the authentication object during the 
get_valid_auth method.

We get the password from the configuration file, which is enough for 
this demo, but you can do and SQL query for that purpose if you store
your users' info in the database.

=head2 require_auth

Returns 0 or 1 depending on configuration for individual steps.
This way we make only some steps to require authentication.

=head2 auth_args

Get authentication arguments from configuration if there is such
and returns a hashref. The template_args are merged in also.

=head2 hash_base

=head2 post_navigate

=head1 UTILITY METHODS

These may go in another module - created specifically for this purpose.
And ofcource there are plenty of modules providing beter implementation.

=head2 strftmime

=head2 now

=head1 AUTHOR

Красимир Беров, C<< <k.berov at gmail.com> >>

=head1 BUGS

Probably many.

Please report any bugs or feature requests to k.berov@gmail.com by putting "CGI::Ex::Recipes" 
in the Subject line

=head1 ACKNOWLEDGEMENTS

    Larry Wall - for Perl
    
    Paul Seamons - for all his modules and especially for CGI::Ex didtro
    
    Anyone wich published anything on CPAN

=head1 COPYRIGHT & LICENSE

Copyright 2007 Красимир Беров, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

