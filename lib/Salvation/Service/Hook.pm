use strict;

package Salvation::Service::Hook;

use Moose;

extends 'Salvation::Service';

has '__associated_service'	=> ( is => 'rw', isa => 'Salvation::Service', lazy => 1, default => undef, weak_ref => 1, predicate => '__has_associated_service', trigger => sub{ shift -> __associated_service_trigger( @_ ) } );

has '__parent_link'	=> ( is => 'rw', isa => sprintf( 'Maybe[%s]', __PACKAGE__ ), lazy => 1, default => undef, predicate => '__has_parent_link' );

has '__Call_cache'	=> ( is => 'rw', isa => 'ArrayRef[Any]', lazy => 1, default => sub{ [] }, predicate => '__has_Call_cache', clearer => '__clear_Call_cache' );


sub Call
{
	my ( $self, @rest ) = @_;

	if( $self -> __has_associated_service() )
	{
		$self -> __associated_service() -> Call( @rest );

	} else
	{
		push @{ $self -> __Call_cache() }, \@rest;
	}

	return 1;
}

sub init
{
	shift -> __associated_service() -> init( @_ );
}

sub main
{
	shift -> __associated_service() -> main( @_ );
}

sub __associated_service_trigger
{
	my $self = shift;

	if( $self -> __has_Call_cache() )
	{
		foreach my $args ( @{ $self -> __Call_cache() } )
		{
			$self -> Call( @$args );
		}

		$self -> __clear_Call_cache();
	}

	return 1;
}

sub __associate_with_hook
{
	my ( $self, $hook ) = @_;

	$hook -> __parent_link( $self );
	$hook -> __associated_service( $self -> __associated_service() );

	return 1;
}

__PACKAGE__ -> meta() -> make_immutable();

no Moose;

-1;

