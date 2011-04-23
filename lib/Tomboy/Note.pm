package Tomboy::Note;

use Net::DBus::GLib;
use base qw(Class::Accessor);

Tomboy::Note->mk_ro_accessors(qw(uri));

use 5.010000;
use strict;
use warnings;
our $VERSION = '0.01';

our $white_list = {
    # process args for these methods
    # all of these methods require that the notes uri
    # be passed first which is being handled internally
    '__processArgs' => {
        'HideNote'              => 1,
        'DisplayNote'           => 1,
        'NoteExists'            => 1,
        'GetNoteChangeDate'     => 1,
        'GetNoteCreateDate'     => 1,
        'GetNoteTitle'          => 1,
        'DeleteNote'            => 1,
        'GetNoteContents'       => 1,
        'GetNoteContentsXml'    => 1,
        'GetNoteCompleteXml'    => 1,
        'SetNoteContents'       => 1,
        'SetNoteContentsXml'    => 1,
        'SetNoteCompleteXml'    => 1,
        'GetTagsForNote'        => 1,
        'AddTagToNote'          => 1,
        'RemoveTagFromNote'     => 1,
        'NoteDeleted'           => 1,
        'NoteAdded'             => 1,
        'NoteSaved'             => 1,
    }
};

# for calls that feel a bit more comfortable
our $aliases = {
    'exists' => 'NoteExists',
    'delete' => 'DeleteNote',
    'title'  => 'GetNoteTitle',
    'content' => 'GetNoteContents',
    'createdDate' => 'GetNoteCreateDate',
    'changedDate' => 'GetNoteChangeDate',
};

sub new {
    my ($class, $args) = @_;
    my $bus     = Net::DBus::GLib->session;
    my $service = $bus->get_service("org.gnome.Tomboy");
    my $obj     = $service->get_object("/org/gnome/Tomboy/RemoteControl");
    
    my $self = bless {}, $class;
    
    if ($$args{uri}) {
        return 0 if !$obj->NoteExists($$args{uri});
        $$self{uri}  = $$args{uri};
    } else {
        $self->_createNote($obj, $args);
    }
    
    $$self{_obj} = $obj;
    
    return $self;
}

sub _createNote {
    my ($self, $obj, $args) = @_;
    my $note_title = $$args{title};
    
    # TODO: create this through the Tomboy OBJ
    $$self{uri} = $obj->CreateNamedNote($note_title);

    die "Could not create note with title: $note_title\n" if !$$self{uri};
    $obj->DisplayNote($$self{uri});
    $obj->SetNoteContents($$self{uri}, $note_title . "\n\n" . $$args{content});
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
    
    $self->{_obj}->$method if $$white_list{$method};
    
    my $processedMethods = $$white_list{'__processArgs'};
    if ($$processedMethods{$method}) {
        # prepare the arguments
        my $notes = [];
        
        if (@args) {
            # passing an array like this looks ugly
            # but it allows the values within it
            # to each be passed as seperate arguments
            unshift @args, $self->{uri}; 
            return $self->{_obj}->$method(@args);
        } else {
            return $self->{_obj}->$method($self->{uri});
        }
    }
}

1;
__END__

API methods that go in here:
maybe just use these internally?
CreateNote
CreateNamedNote

methods to wrap:

(to take advantage of class properties such as the uri and avoid passing
per individial api call) is uri first param for all of these

HideNote
DisplayNote
NoteExists
GetNoteChangeDate
GetNoteCreateDate
GetNoteTitle
DeleteNote
GetNoteContents
GetNoteContentsXml
GetNoteCompleteXml
SetNoteContents
SetNoteContentsXml
SetNoteCompleteXml
GetTagsForNote
AddTagToNote
RemoveTagFromNote
NoteDeleted (?)
NoteAdded (?)
NoteSaved (?)
