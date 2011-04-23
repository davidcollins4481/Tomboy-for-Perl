use Test::More qw(no_plan);
use strict;
use warnings;

BEGIN { 
    use_ok('Tomboy::Note');
};

ok(`which tomboy`, "Tomboy installed");

my $title   = 'Test title for Tomboy module';
my $content = "This is some content";
my $uri;

# Create brand-new note
{
    # content is not sticking
    my $note = Tomboy::Note->new({
        title   => $title,
        content => $content,
    });

    $uri = $note->uri;

    ok($note, "Created note");
    ok($note->exists, "Note exists");
    ok($note->uri, "Note has uri");
    
    ok($note->title, "Note has title");
    ok($note->content, "Note has content");
    ok($note->createdDate, "Note has created date");
    ok($note->changedDate, "Note has created date");
}

# Access scope

# Retrieve created note by uri and test values
{
    my $note = Tomboy::Note->new({ uri => $uri });
    is(ref($note),'Tomboy::Note', "Retrieving note by uri");
    is($note->title, $title, "Title is same as it was initialized with");
    is($note->uri, $uri, "Note uri is same as it was initialized with");
    # clean up
    #ok($note->delete, "Deleting note");
    #ok(!$note->exists, "Note does not exist");
}

