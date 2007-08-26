package CGI::Ex::Recipes::Install;
use utf8;
use warnings;
use strict;
use Carp qw(croak);
use Data::Dumper;
use CGI();
use File::Find;
use File::Copy;
use File::Path;
use Config;
our $VERSION = '0.1';

#starts the install procedure
sub new {
    my $class = shift || croak "Usage: ".__PACKAGE__."->new";
    my $self  = ref($_[0]) ? shift() : (@_ % 2) ? {} : {@_};
    bless $self, $class;
    $self->_init;
    return $self;
}

#???
sub _init {
    my $self = shift;
    $self->{q} = CGI->new();
    #1. Guess the mode - offline is default
    
    #2. Collect info about the environment and exit gracefully if 
    #permissions or anything needed is missing
    return $self;
}

#install the application
sub run {
    my $self = shift;
    $self->{q}->print( Dumper( \%{$self->{q}->Vars()} ) );
    $self->install;
}

sub install {
        my $self = shift;
    #Yeah, there is File::Copy::Recursive but I needed a little fun.
    
    print '*' x 40, $/;
    print
        "CGI::Ex::Recipes - Example application using$/"
        ."CGI::Ex::App - Anti-framework application framework.$/";
    print '*' x 40, $/;
    
    print "Using $Config{perlpath} " . $Config{version} . ' on ' . $Config{'osname'} . $/;
    print 'Using UTF8LOCALE - GOOOD!' . $/ if ${^UTF8LOCALE};
    my $src  = $self->{q}->param('src') || croak('Please provide source directory.'.$/.usage() );
    my $dest = $self->{q}->param('dest')|| croak('Please provide destination directory.'.$/.usage());
    $src  =~ s|/\z||;
    $dest =~ s|/\z||;
    
    #check if $src and $dest are the same.
    if ( $src eq $dest ) {
        print
            "Source path:'$src'$/should not be the same as $/"
            . "destination path: '$dest'$/... exiting."
            . $/;
        exit;
    }
    
    #check if $dest is under $src

=pod
    
    if ( $dest =~ /$src/ ) {
        print
            "Destination path: '$dest'$/ can not be under$/"
            . "source path: '$src'$/... exiting.$/";
        exit;
    }
    
=cut

    #check if $src and $dest exist
    if(!-e $src || !-d $src){
        print "Source path: '$src'$/does not exists or is not a directory$/"
            ."... exiting.$/";
        exit;
    }
    if(!-e $dest){
        eval { mkpath($dest) };
        if ($@) {
            print "Couldn't create $dest:$/$@$/" . "... exiting.$/";
            exit;
        }
    }elsif(!-d $dest) {
        print "Destination path: $/'$dest'$/exists but is not a directory$/"
            ."... exiting.$/";
        exit;
    }
    ##############################
    #blah ... we can start work...
    ##############################
    $self->_install;
}# end sub install

sub _install {
    my $self = shift;
    my $src  = $self->{q}->param('src');
    my $dest = $self->{q}->param('dest');
    print "Installing $src/* to $dest/*...$/";
    #sleep 1;
    finddepth(
        {   wanted => sub {
                
                my $file = $File::Find::name;
                if (-l $file){
                    warn "$/Found link '$file'... skipping $/";
                    return;
                }
                if ( $file !~ /\.svn/ )
                {
                    #wow
                    my $file_dest = $file;
                    $file_dest =~s/^$src/$dest/;
                    my $dest_dir = $File::Find::dir;
                    $dest_dir =~s/^$src/$dest/;
                    print "Copying $file $/"
                         ."to:     $file_dest" . $/;
                    if ( !-e $dest_dir ){ mkpath($dest_dir)  }
                    if (  -d $file     ){ mkpath($file_dest) }
                    if ( !-d $file     ){
                        copy( $file, $file_dest) or die "Copy failed: $!";
                        
                        
                        #chmod pl and cgi appropriately
                        if($file_dest =~/\.(pl|cgi)$/) {
                            chmod 0755,$file_dest and change_shebang($file_dest);
                        }
                            
                    }
                        #make (tmp|conf|logs|data|files) and below world writable
                        chmod 0777,$file_dest
                            if($file_dest =~/(tmp|conf|logs|data|files)/);
                        #TODO:REMEMBER to write a script which will change permissions as needed
                    #sleep 1;

                }
    
            },
            no_chdir => 1,
        },
        $src
    );


}#end sub _install

sub usage {
    'Usage:'.$/.$0 .' src=/from/path dest=/to/path'.$/;
}
sub change_shebang {
    my ( $file ) = @_;
    my @THE_FILE;
    open THE_FILE, "<$file";
    binmode THE_FILE;
    @THE_FILE = <THE_FILE>;
    close THE_FILE;
    open THE_FILE, ">$file";
    binmode THE_FILE;
    my $new_shebang = "$Config{perlpath}".$Config{_exe};
    print "changing shebang to ". $new_shebang.$/;      
    $new_shebang && $THE_FILE[0]=~ s/^#!\s*\S+/#!$new_shebang/s ;

    
    foreach my $line (@THE_FILE){
        print THE_FILE $line;
    }
    close THE_FILE;
}

1;
