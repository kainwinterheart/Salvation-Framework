use strict;

package Salvation::Service::View::Stack::Parser;

use Carp::Assert 'assert';

use Scalar::Util 'blessed';

sub parse
{
	my ( $self, $stack, $args ) = @_;

	$args ||= {};

	assert( blessed $stack );
	assert( $stack -> isa( 'Salvation::Service::View::Stack' ) );
	assert( $stack -> is_list() );

	$self -> __trigger( 'before_stack', $args, $stack );

	foreach my $node ( @{ $stack -> frames() } )
	{
		$self -> __parse_node( $node, $args );
	}

	$self -> __trigger( 'after_stack', $args, $stack );

	return 1;
}

sub __parse_node
{
	my ( $self, $node, $args ) = @_;

	$args ||= {};

	$self -> __trigger( 'before_node', $args, $node );

	if( blessed $node )
	{
		assert( $node -> isa( 'Salvation::Service::View::Stack::Frame' ) );

		$self -> __trigger( 'before_frame', $args, $node );

		if( $node -> is_list() )
		{
			$self -> __trigger( 'before_frame_list', $args, $node );

			foreach my $node ( @{ $node -> data() } )
			{
				$self -> __parse_node( $node, $args );
			}

			$self -> __trigger( 'after_frame_list', $args, $node );
		} else
		{
			$self -> __trigger( 'before_frame_single', $args, $node );

			$self -> __parse_node( $node -> data(), $args );

			$self -> __trigger( 'after_frame_single', $args, $node );
		}

		$self -> __trigger( 'after_frame', $args, $node );
	} else
	{
		$self -> __trigger( 'raw', $args, $node );
	}

	$self -> __trigger( 'after_node', $args, $node );

	return 1;
}

sub __trigger
{
	my ( undef, $event, $args, $node ) = @_;

	$args ||= {};

	if( ref( my $code = $args -> { 'events' } -> { $event } ) eq 'CODE' )
	{
		$code -> ( $node );
	}

	return 1;
}

-1;

