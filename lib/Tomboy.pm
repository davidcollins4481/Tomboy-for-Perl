package Tomboy;

use Net::DBus::GLib;
use 5.010000;
use strict;
use warnings;
use Tomboy::Note;
our $VERSION = '0.01';

our $white_list = {
    'Version'               => 1,
    'Introspect'            => 1,
    'DisplayNoteWithSearch' => 1,
    'FindNote'              => 1,
    'FindStartHereNote'     => 1,
    'DisplaySearch'         => 1,
    'DisplaySearchWithText' => 1,
    # process args for these methods
    # to allow returning of Tomboy::Note Objects
    '__processArgs' => {
        'ListAllNotes'       => 1,
        'GetAllNotesWithTag' => 1,
        'SearchNotes'        => 1,
    },
    '__creation' => {
        'CreateNote'            => 1,
        'CreateNamedNote'       => 1,
    }
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
    # TODO: is this going to work or am i going to have
    # to further differentiate between methods that return
    # nothing and methods that have return values?
    return $self->{_obj}->$method if $$white_list{$method};
    
    # Methods that return a list of Tomboy::Note's
    my $processedMethods = $$white_list{'__processArgs'};
    if ($$processedMethods{$method}) {
        # prepare the arguments
        my $notes = [];
        
        if (@args) {
            # passing an array like this looks ugly
            # but it allows the values within it
            # to each be passed as seperate arguments
            $notes = $self->{_obj}->$method(@args);
        } else {
            $notes = $self->{_obj}->$method;
        }
        
        return [ map { Tomboy::Note->new({ uri => $_ }) } @$notes ];
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

Reference:
http://arstechnica.com/open-source/news/2007/09/using-the-tomboy-d-bus-interface.ars

Methods to be supported in this class:

Version
Introspect
DisplayNoteWithSearch (?)
FindNote (?)
FindStartHereNote (?)
CreateNote
CreateNamedNote
DisplaySearch
DisplaySearchWithText

Methods To wrap (return obj version of results as Tomboy::Note):

ListAllNotes (?)
GetAllNotesWithTag
SearchNotes
