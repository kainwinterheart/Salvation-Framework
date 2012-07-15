use strict;

package SomeSystem::Services::FirstService;

use Moose;

extends 'Salvation::Service';

sub BUILD
{
	my $self = shift;

	$self -> Call( 'asd', { constraint => sub{ int(rand(2))==1 } } );

	$self -> Hook( [ $self -> dataset() -> first() -> ltype(), 'Type' ],
		       [ $self -> dataset() -> first() -> lsubtype(), 'Subtype' ] );

	$self -> Hook( [ $self -> dataset() -> first() -> ltype(), 'Type' ] );
}

no Moose;

-1;

