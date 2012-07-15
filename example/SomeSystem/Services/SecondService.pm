use strict;

package SomeSystem::Services::SecondService;

use Moose;

extends 'Salvation::Service';

sub BUILD
{
	my $self = shift;

#	die 'another test error';
#	$self -> throw( 'test error' );
}

no Moose;

-1;

