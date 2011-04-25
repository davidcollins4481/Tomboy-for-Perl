use strict;
use warnings;

use Test::More qw(no_plan);

BEGIN { use_ok('Tomboy') };

# Move these to a config file?
my $note_name = "Tomboy.pm testing";
my $note_tag = "testing";
my $search_keyword = "tomboymodule";
my $note_content = "here is some ${search_keyword}";
####

ok(`which tomboy`, "Tomboy installed");
my ($title, $uri);

my $tomboy = Tomboy->new;

ok($tomboy, "Instatiate");
ok($tomboy->Version, "Getting version string");

my $total_notes = $tomboy->ListAllNotes;

ok(scalar(@$total_notes), "User has notes (total=" . scalar(@$total_notes) .")");

$uri = $$total_notes[0]->uri;
like($uri, qr{^note://tomboy/[\d\w-]*}, "Note uri format");

like($tomboy->FindStartHereNote, qr{^note://tomboy/[\d\w-]*}, "Found Start Note Uri");

print "Can I create a note titled '$note_name' for testing purposes (will be deleted when completed - you should do this) [y/n]?\n";

my $answer = <STDIN>;
chomp $answer;

# just don't do it if you get anything else 
# other than "y"
if ($answer eq "y") {
    # going to test a bit of Tomboy::Note's functionality.
    # just don't want to have to prompt the user again
    # for permission to create another note :-(
    my ($note, $tags);
    
    $note = $tomboy->CreateNamedNote($note_name);
    
    isa_ok($note, "Tomboy::Note", "Initial note creation successful");
    
    $note->AddTagToNote($note_tag);
    $tags = $note->GetTagsForNote;

    my $notes = $tomboy->GetAllNotesWithTag($note_tag);
    is($$notes[0]->GetNoteTitle, $note_name, "Retrieve created note by tag");
        
    is($$tags[0], $note_tag, "Retrieve tag for created note");
    is($note->GetNoteTitle, $note_name, "Retrieve title for created note");

    # clean up
    $note->DeleteNote;
} else {
    print "Ok...use at your own peril\n";
}


__END__

TODO: 
Test search functionality and set note content functionality


It's kind of difficult to test a lot of these methods b/c
they rely on the content of the users notes

Which methods are testable without creating a new note?
    - Version
    - Introspect (why would I test this though?)
    - FindStartHereNote (who cares...guess it's one more thing to tell ya something is wrong if it fails)
    - ListAllNotes

creating a new note?

    - DisplayNoteWithSearch
    - FindNote
    - CreateNote
    - CreateNamedNote
    - DisplaySearch
    - DisplaySearchWithText
    - GetAllNotesWithTag
    - SearchNotes
