use strict;

package Salvation::Service::View;

use Moose;

with 'Salvation::Roles::ServiceReference';

use Salvation::Service::View::SimpleCache;

use Salvation::Service::View::Stack ();
use Salvation::Service::View::Stack::Frame ();
use Salvation::Service::View::Stack::Frame::List ();

sub MULTINODE { 0 }

sub main
{
	return [];
}

sub process
{
	my $self   = shift;
	my @output = ();

	$self -> service() -> dataset() -> seek( 0 );

	while( my $node = $self -> service() -> dataset() -> fetch() )
	{
		push @output, $self -> process_node( $node );
	}

	$self -> service() -> dataset() -> seek( 0 );

	return $self -> service() -> state() -> view_output( ( $self -> MULTINODE() ? \@output : $output[ 0 ] ) );
}

sub process_node
{
	my ( $self, $obj, $order ) = @_;

	my $args  = $self -> service() -> args();

	my $type  = undef;
	my $stack = Salvation::Service::View::Stack -> new();

	foreach my $node ( @{ $order or $self -> main() } )
	{
		if( ref( $node ) eq 'ARRAY' )
		{
			my $list = Salvation::Service::View::Stack::Frame::List -> new( fname => $type );

			foreach my $subnode ( @$node )
			{
				if( $subnode )
				{
					my $flags = {};

					if( ref( $subnode ) eq 'HASH' )
					{
						( $subnode, $flags ) = %$subnode;
					}

					if( ref( $flags -> { 'constraint' } ) eq 'CODE' )
					{
						unless( $flags -> { 'constraint' } -> ( $self, $obj, $args ) )
						{
							next;
						}
					}

					my ( $val, $cap ) = ( undef, undef );

					{
						my $default_value_getter  = sprintf( '__%s', $type );
						my $specific_value_getter = sprintf( '%s_%s', $type, $subnode );

						# Both following arrays actually can contain one more element
						# that is a HashRef, and it's already used sometimes
						# so don't think you can just add another element here
						my $default_value_getter_args  = [ $obj, $subnode ];
						my $specific_value_getter_args = [ $obj ];

						my $rendered = undef;
						my $cacheid  = undef;
						my $cached   = undef;

						unless( $flags -> { 'nocache' } )
						{
							eval
							{
								if( $self -> service() -> model() -> can( $default_value_getter ) )
								{
									my ( $dry ) = ( $self -> service() -> model() -> $default_value_getter( @$default_value_getter_args, { raw => 1 } ) );

									if( defined $dry )
									{
										$cacheid = $self -> service() -> __cacheid( $subnode, $dry );
									}
								}
							};
						}

						if( $cacheid and &rsc_exists( $type, $cacheid ) )
						{
								( $val, $cap ) = @{ &rsc_retrieve( $type, $cacheid ) };
								$rendered = 1;
								$cached   = 1;
						}

ACTUAL_RENDERING_OF_EACH_NODE:
						foreach my $spec ( (
							{ name => $specific_value_getter, args => $specific_value_getter_args },
							{ name => $default_value_getter,  args => $default_value_getter_args }
						) )
						{
							my $name = $spec -> { 'name' };

							if( not $rendered and $self -> service() -> model() -> can( $name ) )
							{
								( $val, $cap ) = eval{ $self -> service() -> model() -> $name( @{ $spec -> { 'args' } } ) };

								if( my $err = $@ )
								{
									$self -> service() -> system() -> on_node_rendering_error( {
										'$@'     => $err,
										view     => ( ref( $self ) or $self ),
										instance => $self,
										spec     => $spec
									} );
								} else
								{
									$rendered = 1;
									last ACTUAL_RENDERING_OF_EACH_NODE;
								}
							}
						}

						if( $rendered and $cacheid and not $cached )
						{
							&rsc_store( $type, $cacheid, [ $val, $cap ] );
						}
					}

					if( not( $val ) and ( $args -> { 'skip_false' } or $flags -> { 'skip_false' } ) and not exists $flags -> { 'sticky' } )
					{
						next;
					}

					unless( defined $cap )
					{
						$cap = sprintf( '[FIELD_%s]',
								uc( $subnode ) );
					}

					my $frame = Salvation::Service::View::Stack::Frame -> new( ftype => $type,
											  fname => $subnode,
											  cap   => $cap,
											  data  => $val );

					$list -> add( $frame );
				}
			}

			if( scalar @{ $list -> data() or [] } )
			{
				$stack -> add( $list );
			}

		} elsif( ref( $node ) eq 'CODE' )
		{
			my $results = $node -> ( $self, $obj, $args );

			if( ref( $results ) eq 'HASH' )
			{
				my $frame = Salvation::Service::View::Stack::Frame -> new( %$results );

				$stack -> add( $frame );
			}

		} elsif( not ref $node )
		{
			$type = $node;
		}
	}

	return $stack;
}

__PACKAGE__ -> meta() -> make_immutable();

no Moose;

-1;

