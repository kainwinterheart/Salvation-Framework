use strict;

package Salvation::SharedStorage;

use Moose;

has 'data'	=> ( is => 'rw', isa => 'HashRef', lazy => 1, default => sub{ {} } );

sub put
{
	my ( $self, $key, $val ) = @_;

	$self -> data() -> { $key } = $val;

	return $self -> get( $key );
}

sub get
{
	my ( $self, $key ) = @_;

	return $self -> data() -> { $key };
}

sub clear
{
	return shift -> data( {} );
}

no Moose;

-1;

