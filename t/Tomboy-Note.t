use Test::More tests => 6;
use strict;
use warnings;
BEGIN { use_ok('Tomboy::Note') };

ok(`which tomboy`, "Tomboy installed");

my $title   = 'Test title for Tomboy module';
my $content = "This is\n\nsome content";
my $uri;

# Create brand-new note
{
    # content is not sticking
    $DB::single = 1;
    my $note = Tomboy::Note->new({
        title   => $title,
        content => $content,
    });

    ok($note, "Created note");
    ok($note->exists, "Note exists");
    ok($note->uri, "Note has uri");
    
    ok($note->title, "Note has title");
    #ok($note->content, "Note has content");
    #ok($note->createdDate, "Note has created date");
    #ok($note->changedDate, "Note has created date");
    
    $note->delete;
}

# Retrieve created note by uri and test values
#{
    #my $note = Tomboy::Note->new({ uri => $uri });
    #is(ref($note),'Tomboy::Note', "Retrieving note by uri");
    #is($note->title, $title, "Title is same as it was initialized with");
    #is($note->uri, $uri, "Note uri is same as it was initialized with");
    # clean up
    #ok($note->delete, "Deleting note");
    #ok(!$note->exists, "Note does not exist");
#}

# make sure creating a note with out title/content fails
#{
    #my $note = Tomboy::Note->new({});
    #ok(!$note, "Untitled note does not exist");
#}
