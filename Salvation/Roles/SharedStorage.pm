use strict;

package Salvation::Roles::SharedStorage;

use Moose::Role;

has 'storage' => ( is => 'rw', isa => 'Salvation::SharedStorage', lazy => 1, default => sub{ require Salvation::SharedStorage; return Salvation::SharedStorage -> new(); } );

sub __build_storage
{
	my $self = shift;
	my $o    = Salvation::SharedStorage -> new();

	require Salvation::SharedStorage;

	if( $self -> isa( 'Salvation::Service' ) )
	{
		$o -> add_around_get_handler( sub
		{
			my ( $orig, $lself, $key, @rest ) = @_;

			$self -> system() -> on_service_shared_storage_get( {
				service => $self,
				key     => $key
			} );

			return $lself -> $orig( $key, @rest );
		} );

		$o -> add_around_put_handler( sub
		{
			my ( $orig, $lself, $key, $value, @rest ) = @_;

			$self -> system() -> on_service_shared_storage_put( {
				service => $self,
				key     => $key,
				value   => $value
			} );

			return $lself -> $orig( $key, $value, @rest );
		} );

	} elsif( $self -> isa( 'Salvation::System' ) )
	{
		$o -> add_around_get_handler( sub
		{
			my ( $orig, $lself, $key, @rest ) = @_;

			$self -> on_shared_storage_get( {
				key => $key
			} );

			return $lself -> $orig( $key, @rest );
		} );

		$o -> add_around_put_handler( sub
		{
			my ( $orig, $lself, $key, $value, @rest ) = @_;

			$self -> on_shared_storage_put( {
				key   => $key,
				value => $value
			} );

			return $lself -> $orig( $key, $value, @rest );
		} );
	}

	return $o;
}

no Moose::Role;

-1;

