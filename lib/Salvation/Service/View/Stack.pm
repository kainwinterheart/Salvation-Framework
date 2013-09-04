use strict;

package Salvation::Service::View::Stack;

use Moose;

extends 'Salvation::Service::View::Stack::Frame::List';

foreach my $attr ( ( 'id', 'ftype', 'cap', 'fname' ) )
{
	has $attr => ( is => 'ro', isa => 'Undef' );
}

has '_frames'   => ( is         => 'rw',
                     isa        => 'ArrayRef[Salvation::Service::View::Stack::Frame]',
                     init_arg   => 'frames',
                     default    => sub{ [] },
                     predicate  => '_has_frames',
                     clearer    => '_clear_frames',
                     lazy       => 1
                   );

sub frames
{
	return shift -> data();
}

__PACKAGE__ -> meta() -> make_immutable();

no Moose;

-1;

