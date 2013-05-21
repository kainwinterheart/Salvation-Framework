use strict;

package Salvation::Service::Intent;

use Moose;

with 'Salvation::Roles::AppArgs', 'Salvation::Roles::DataSet', 'Salvation::Roles::SharedStorage', 'Salvation::Roles::SystemReference', 'Salvation::Roles::ServiceState';

use Salvation::Stuff '&load_class';

has '__service'	=> ( is => 'ro', isa => 'Str', required => 1, lazy => 1, default => undef, init_arg => 'service' );

has 'service' => ( is => 'ro', isa => 'Salvation::Service', builder => '_build_service', lazy => 1, init_arg => undef );

sub _build_service
{
	my $self = shift;

	return ( &load_class( $self -> __service() ) ? $self -> __service() -> new(
		( map{ $_ => $self -> $_() } ( 'args', 'dataset', 'storage', 'system', 'state' ) )
	) : undef );
}

sub main
{
}

sub start
{
	return shift -> service() -> main();
}

no Moose;

-1;

