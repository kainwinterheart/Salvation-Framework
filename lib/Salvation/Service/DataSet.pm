use strict;

package Salvation::Service::DataSet;

use Moose;

with 'Salvation::Roles::ServiceReference';

has '__data'	=> ( is => 'rw', isa => 'ArrayRef[Defined]', lazy => 1, builder => 'main' );

has '__iterator'	=> ( is => 'rw', isa => 'Int', default => 0 );

sub main
{
	return [];
}

sub first
{
	return shift -> __data() -> [ 0 ];
}

sub last
{
	my $data = shift -> __data();

	return $data -> [ $#$data ];
}

sub get
{
	my ( $self, $index ) = @_;

	return $self -> __data() -> [ ( defined( $index ) ? $index : $self -> __iterator() ) ];
}

sub seek
{
	return shift -> __iterator( shift );
}

sub fetch
{
	my $self = shift;

	my $index = $self -> __iterator();
	my $data  = $self -> __data();

	return undef if $index > $#$data;

	my $result = $data -> [ $index ];

	$self -> __iterator( $index + 1 );

	return $result;
}

no Moose;

-1;

