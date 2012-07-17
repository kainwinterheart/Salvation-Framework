use strict;

package Salvation::Service::View::Stack::Convert::To::XML;

use Salvation::Service::View::Stack::Parser ();

use IO::String ();

use XML::Writer ();

sub parse
{
	my ( undef, $stack, $args ) = @_;

	$args ||= {};

	my $writer = ( $args -> { 'writer' } or XML::Writer -> new(
		OUTPUT =>
			my $io = IO::String -> new(
				my $xml
			)
	) );

	my $charset        = ( $args -> { 'charset' } or 'UTF-8' );
	my $stack_tag_name = ( $args -> { 'tags' } -> { 'stack' } or 'stack' );
	my $list_tag_name  = ( $args -> { 'tags' } -> { 'list' }  or 'list' );
	my $frame_tag_name = ( $args -> { 'tags' } -> { 'frame' } or 'frame' );

	$writer -> xmlDecl( $charset ) unless $args -> { 'nocharset' };

	my %default_events = (
		before_stack => sub{ $writer -> startTag( $stack_tag_name ) },
		after_stack  => sub{ $writer -> endTag( $stack_tag_name ) },

		before_frame_list => sub{ $writer -> startTag( $list_tag_name, name => shift -> fname() ) },
		after_frame_list  => sub{ $writer -> endTag( $list_tag_name ) },

		before_frame_single => sub{
			my $frame = shift;

			$writer -> startTag( $frame_tag_name,
					     title => $frame -> cap(),
					     name  => $frame -> fname(),
					     type  => $frame -> ftype() );
		},
		after_frame_single  => sub{ $writer -> endTag( $frame_tag_name ) },

		raw => sub{ $writer -> cdata( shift or '' ) }
	);

	foreach my $event ( keys %default_events )
	{
		unless( exists $args -> { 'events' } -> { $event } )
		{
			$args -> { 'events' } -> { $event } = $default_events{ $event };
		}
	}

	{
		my %filter = (
			tags      => 1,
			charset   => 1,
			writer    => 1,
			nocharset => 1
		);

		Salvation::Service::View::Stack::Parser -> parse( $stack, { map{ $_ => $args -> { $_ } } grep{ not $filter{ $_ } } keys %$args } );
	}

	$io -> close() if $io;

	return $xml;
}

-1;

