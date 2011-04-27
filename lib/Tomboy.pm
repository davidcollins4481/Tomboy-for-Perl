package Tomboy;

use Net::DBus::GLib;
use 5.010000;
use strict;
use warnings;
use Tomboy::Note;
our $VERSION = '0.01';

our $blacklist = {
    'CreateNote'      => 1,
    'CreateNamedNote' => 1,
};

our $white_list = {
    'Version'               => 1,
    'Introspect'            => 1,
    'DisplayNoteWithSearch' => 1,
    'FindStartHereNote'     => 1,
    'DisplaySearch'         => 1,
    'DisplaySearchWithText' => 1,
    # process args for these methods
    # to allow returning of Tomboy::Note Objects
    '__processArgs' => {
        'ListAllNotes'       => 1,
        'GetAllNotesWithTag' => 1,
        'SearchNotes'        => 1,
        'FindNote'           => 1,
    },
    '__creation' => {
        'CreateNote'            => 1,
        'CreateNamedNote'       => 1,
    }
};

# for calls that feel a bit more comfortable
our $aliases = {
    'findNote'              => 'FindNote',
    'searchNotes'           => 'SearchNotes',
    'getAllNotesWithTag'    => 'GetAllNotesWithTag',
    'findStartHereNote'     => 'FindStartHereNote',
    'listAllNotes'          => 'ListAllNotes',
};


sub new {
    my ($class,$args) = @_;
    
    my $bus = Net::DBus::GLib->session;
    my $service = $bus->get_service("org.gnome.Tomboy");
    
    return bless {
        _obj      => $service->get_object("/org/gnome/Tomboy/RemoteControl"),
    }, $class;
}

sub AUTOLOAD {
    my ($self,@args) = @_;
    our ($AUTOLOAD);
    my $method = $AUTOLOAD;
    $method =~ s/.*:://;
    
    # check for an alias
    if (my $unaliased = $$aliases{$method}) {
        $method = $unaliased;
    }
    
    # TODO: is this going to work or am i going to have
    # to further differentiate between methods that return
    # nothing and methods that have return values?
    return $self->{_obj}->$method if $$white_list{$method};
    
    # Methods that return a list of Tomboy::Note's
    my $processedMethods = $$white_list{'__processArgs'};
    if ($$processedMethods{$method}) {
        # prepare the arguments
        my $result = [];
        
        if (@args) {
            # passing an array like this looks ugly
            # but it allows the values within it
            # to each be passed as seperate arguments
            $result = $self->{_obj}->$method(@args);
        } else {
            $result = $self->{_obj}->$method;
        }

        # need to process result a bit
        if (ref($result)) {
            return [ map { Tomboy::Note->new({ uri => $_ }) } @$result ];
        } elsif ($result =~ qr{^note://tomboy/[\d\w-]*}) {
            # a single uri
            return Tomboy::Note->new({ uri => $result });
        }
    }

    # Creation methods
    my $creationMethods = $$white_list{'__creation'};
    if ($$creationMethods{$method}) {
        # creation methods should return a Tomboy::Note object
        my $uri = scalar @args ? 
            $self->{_obj}->$method(shift @args)
            :
            $self->{_obj}->$method
        ;
        
        return Tomboy::Note->new({ uri => $uri });
    }
}

1;
__END__

=head1 NAME

Tomboy - Perl API to access Tomboy functionality through DBus

=head1 SYNOPSIS

my $tomboy = Tomboy->new;

my $total_notes = $tomboy->ListAllNotes;

$uri = $$total_notes[0]->uri;

ref($$total_notes[0]); # Tomboy::Note

my $notes = $tomboy->GetAllNotesWithTag($note_tag);

my $case_sensitive = 0;
my $search_notes = $tomboy->searchNotes("search term", $case_sensitive);

=head1 DESCRIPTION

This class is meant to go with Tomboy::Note. Note manipulation should be done there.
Tomboy MUST be installed to use this. This module uses DBus to access Tomboy's functionality. 
This module has NOT been tested on Windows or Mac. Software is still in development
so please back up notes before using just to be safe. 

=cut
