use strict;

package Drwebcom::Stuff::ClassHash;

use Moose;

has '___data' => ( is       => 'rw',
		   isa      => 'HashRef',
		   default  => sub{ {} },
		   init_arg => 'data' );

has '___pref' => ( is       => 'ro',
		   isa      => 'Str',
		   init_arg => 'prefix',
		   default  => '' );

sub ___PRELOAD_DATA{ undef }

sub BUILD
{
	my $self = shift;

	if( my $data = $self -> ___PRELOAD_DATA() )
	{
		$self -> ___data( $data );
	}

	my $prefix = $self -> ___pref();
	my $regexp = ( $prefix ? qr/$prefix/ : undef );

	foreach my $key ( keys %{ $self -> ___data() } )
	{
		if( $regexp )
		{
			$key =~ s/^$regexp//;
		}

		my $name = join( '_', split( /\W/, $key ) );

		next unless $name;

		unless( $self -> meta() -> find_attribute_by_name( $name ) )
		{
			$self -> meta() -> add_attribute( $name,
				       is  	=> 'rw',
				       isa 	=> 'Any',
				       lazy	=> 1,
				       init_arg => undef,
				       default  => sub{ shift -> ___attr( $key ) },
				       trigger  => sub{ shift -> ___attr( $key, shift ) } );
		}
	}

	return undef;
}

sub ___attr
{
        my ( $self, $col, $val ) = @_;

	my $path = $self -> ___pref() . $col;

        if( scalar( @_ ) > 2 )
        {
		my $aname = join( '_', split( /\W/, $col ) );

		unless( $self -> meta() -> find_attribute_by_name( $aname ) )
		{
			$self -> meta() -> add_attribute( $aname,
					is       => 'rw',
					isa      => 'Any',
					lazy     => 1,
					init_arg => undef,
					default  => sub{ shift -> ___attr( $col ) },
					trigger  => sub{ shift -> ___attr( $col, shift ) } );
		}

                $self -> ___data() -> { $path } = $val;
	}

        return $self -> ___data() -> { $path };
}

no Moose;

-1;

