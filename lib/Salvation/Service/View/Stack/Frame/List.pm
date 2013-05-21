use strict;

package Salvation::Service::View::Stack::Frame::List;

use Moose;

extends 'Salvation::Service::View::Stack::Frame';

has 'cap'       => ( is => 'rw', isa => 'Maybe[Str]' );

has 'ftype'	=> ( is => 'rw', isa => 'Maybe[Str]' );

has 'is_list'	=> ( is => 'ro', isa => 'Bool', default => 1, init_arg => undef );

has 'data'	=> ( is => 'ro', isa => 'Undef', init_arg => undef );

has '_frames'   => ( is  	=> 'rw',
		     isa 	=> 'ArrayRef[Salvation::Service::View::Stack::Frame]',
		     init_arg 	=> 'data',
		     default 	=> sub{ [] },
		     predicate 	=> '_has_frames',
		     clearer 	=> '_clear_frames',
		     lazy 	=> 1
		   );

has '_index'    => ( is 	=> 'rw',
		     isa 	=> 'Int',
		     default 	=> 0,
		     init_arg 	=> undef,
		     clearer 	=> '_clear_index',
		     lazy 	=> 1
		   );

has '_byname'	=> ( is 	=> 'rw',
		     isa 	=> 'HashRef',
		     init_arg 	=> undef,
		     default 	=> sub{ {} },
		     clearer 	=> '_clear_byname',
		     lazy 	=> 1
		   );

has '_bytype'	=> ( is 	=> 'rw',
		     isa 	=> 'HashRef',
		     init_arg 	=> undef,
		     default 	=> sub{ {} },
		     clearer 	=> '_clear_bytype',
		     lazy 	=> 1
		   );

sub BUILD
{
        my $self = shift;

	if( $self -> _has_frames() )
	{
		my @frames = @{ $self -> _frames() };

		$self -> wipe_data();

		$self -> add( @frames );
	}
}

sub wipe_data
{
	my $self = shift;

	$self -> _clear_frames();
	$self -> _clear_index();
	$self -> _clear_byname();
	$self -> _clear_bytype();

	return undef;
}

sub add
{
        my $self = shift;

        my $idx = $self -> _index();

	my $byname = $self -> _byname();
	my $bytype = $self -> _bytype();

        foreach my $frame ( @_ )
        {
                ++$idx;

                $frame -> id( $idx );

		if( $frame -> fname() )
		{
			push @{ $byname -> { $frame -> fname() } }, $frame -> id();
		}

		if( $frame -> ftype() )
		{
			push @{ $bytype -> { $frame -> ftype() } }, $frame -> id();
		}

                push @{ $self -> _frames() }, $frame;
        }

        $self -> _index( $idx );

	$self -> _byname( $byname );
	$self -> _bytype( $bytype );

        return $idx;
}

around 'data' => sub
{
	shift;
	return shift -> _frames();
};

sub data_by_type
{
	my $self = shift;
	my $type = shift;

	return $self -> data_by_id( $self -> _bytype() -> { $type } );
}

sub data_by_name
{
	my $self = shift;
	my $name = shift;

	return $self -> data_by_id( $self -> _byname() -> { $name } );
}

sub data_by_id
{
	my $self = shift;
	my $id   = shift;

	my @ids  = ( ( ref( $id ) eq 'ARRAY' ) ? @$id : ( $id ) );

	my @output = map{ $self -> data() -> [ $_ - 1 ] } grep{ sprintf( '%d', $_ ) eq $_ } @ids;

	return ( wantarray ? @output
			   : \@output );
}

no Moose;

-1;

