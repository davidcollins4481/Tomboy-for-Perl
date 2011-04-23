use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Tomboy',
    VERSION_FROM      => 'lib/Tomboy.pm', # finds $VERSION
    PREREQ_PM         => {
	    Net::DBus::GLib => '0.33.0'
	},
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/Tomboy.pm',
       AUTHOR         => 'David Collins<davidcollins4481@gmail.com>') : ()),
);
