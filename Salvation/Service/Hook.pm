use strict;

package Salvation::Service::Hook;

use Moose;

extends 'Salvation::Service';

has '__parent_link'	=> ( is => 'rw', isa => sprintf( 'Maybe[%s]', __PACKAGE__ ), lazy => 1, default => undef );

sub main
{
}

no Moose;

-1;

