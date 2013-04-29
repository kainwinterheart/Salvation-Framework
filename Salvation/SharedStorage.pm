use strict;

package Salvation::SharedStorage;

use Moose;


has 'data'	=> ( is => 'rw', isa => 'HashRef', lazy => 1, default => sub{ {} } );


foreach my $method ( ( 'get', 'put' ) )
{
	foreach my $event ( ( 'before', 'around', 'after' ) )
	{
		my $storage = sprintf( '__%s_%s_handlers', $event, $method );

		has $storage => ( is => 'rw', isa => 'ArrayRef[CodeRef]', lazy => 1, default => sub{ [] }, init_arg => undef );

		{
			my $accessor = sprintf( 'add_%s_%s_handler', $event, $method );

			no strict 'refs';

			*$accessor = sub
			{
				my ( $self, $code ) = @_;

				if( $event eq 'around' )
				{
					if( my $orig = shift @{ $self -> $storage() } )
					{
						unshift @{ $self -> $storage() }, sub
						{
							my ( $lorig, $self, @rest ) = @_;

							return $code -> ( sub{ $orig -> ( $lorig, $self, @rest ) }, $self, @rest );
						};

					} else
					{
						push @{ $self -> $storage() }, $code;
					}

				} elsif( $event eq 'after' )
				{
					push @{ $self -> $storage() }, $code;

				} elsif( $event eq 'before' )
				{
					unshift @{ $self -> $storage() }, $code;

				} else
				{
					die sprintf( 'Unknown event: %s', $event );
				}

				return 1;
			};

			use strict 'refs';
		}
	}

	before $method => sub
	{
		my $self = shift;

		my $storage = sprintf( '__before_%s_handlers', $method );

		foreach my $code ( @{ $self -> $storage() } )
		{
			$code -> ( $self );
		}
	};

	around $method => sub
	{
		my ( $orig, $self, @rest ) = @_;

		my $storage = sprintf( '__around_%s_handlers', $method );

		if( my $method = $self -> $storage() -> [ 0 ] )
		{
			return $method -> ( $orig, $self, @rest );
		}

		return $self -> $orig( @rest );
	};

	after $method => sub
	{
		my $self = shift;

		my $storage = sprintf( '__after_%s_handlers', $method );

		foreach my $code ( @{ $self -> $storage() } )
		{
			$code -> ( $self );
		}
	};
}


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

