use strict;
use warnings;

use Test::More tests => 9;

use_ok( 'CPAN::Changes' );

my $changes = CPAN::Changes->new;
$changes->add_release(
    {   date    => '2010-06-16',
        version => '0.01',
        changes => { '' => [ 'Initial release' ] },
    }
);

{
    my $expected = <<EOCHANGES;
0.01 2010-06-16
 - Initial release

EOCHANGES

    is( $changes->serialize, $expected, 'serialize' );
}

{
    $changes->preamble( 'Revision history for perl module Foo::Bar' );

    my $expected = <<EOCHANGES;
Revision history for perl module Foo::Bar

0.01 2010-06-16
 - Initial release

EOCHANGES

    is( $changes->serialize, $expected, 'serialize with preamble' );
}

{
    my $release = $changes->release( '0.01' );
    $release->clear_changes;
    $release->add_changes( { group => 'Group 1' }, 'Initial release' );

    my $expected = <<EOCHANGES;
Revision history for perl module Foo::Bar

0.01 2010-06-16
 [Group 1]
 - Initial release

EOCHANGES

    is( $changes->serialize, $expected,
        'serialize with ground and preamble' );
}

{
    $changes->add_release(
        {   version => '0.02',
            date    => '2010-06-17',
            changes => { '' => [ 'New version' ] },
        }
    );

    my $expected = <<EOCHANGES;
Revision history for perl module Foo::Bar

0.02 2010-06-17
 - New version

0.01 2010-06-16
 [Group 1]
 - Initial release

EOCHANGES

    is( $changes->serialize, $expected, 'serialize with multiple releases' );
}

{
    $changes->releases(
        {   version => '0.01',
            date    => '2010-06-16',
            changes => {
                '' => [
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. In quis tortor ac urna faucibus feugiat.'
                ]
            },
        }
    );

    my $expected = <<EOCHANGES;
Revision history for perl module Foo::Bar

0.01 2010-06-16
 - Lorem ipsum dolor sit amet, consectetur adipiscing elit. In quis tortor
   ac urna faucibus feugiat.

EOCHANGES

    is( $changes->serialize, $expected, 'serialize with line-wrap' );
}

{
    $changes->releases(
        {   version => '0.01',
            date    => '2010-06-16',
            note    => 'Note',
            changes => {
                '' => [
                    'Test'
                ]
            },
        }
    );

    my $expected = <<EOCHANGES;
Revision history for perl module Foo::Bar

0.01 2010-06-16 Note
 - Test

EOCHANGES

    is( $changes->serialize, $expected, 'serialize with note' );
}

{
    $changes->releases(
        {   version => '0.01',
            date    => 'Unknown',
            note    => '(Oops)',
            changes => {
                '' => [
                    'Test'
                ]
            },
        }
    );

    my $expected = <<EOCHANGES;
Revision history for perl module Foo::Bar

0.01 Unknown (Oops)
 - Test

EOCHANGES

    is( $changes->serialize, $expected, 'serialize with unknown date and note' );
}

{
    my $changes = CPAN::Changes->new;
    $changes->add_release(
        {   date    => '',
            version => '0.01',
            note    => '',
            changes => { '' => [ 'Initial release' ] },
        }
    );
    my $expected = <<EOCHANGES;
0.01
 - Initial release

EOCHANGES

    is( $changes->serialize, $expected, 'serialize w/ defined but empty date and note' );
}
