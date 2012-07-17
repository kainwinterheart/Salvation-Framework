use strict;

package SomeSystem;

use Moose;

extends 'Salvation::System';

sub BUILD
{
	my $self = shift;

	$self -> Service( 'FirstService' );
	$self -> Service( 'FirstService' );
	$self -> Service( 'SecondService' );
	$self -> Service( 'ThirdService' ); #, { transform_name => sub{ 'FirstService' } } );
}

sub on_service_thrown_error
{
	my $self = shift;

	require Data::Dumper;

#	$self -> Fatal( &Data::Dumper::Dumper( \@_ ) );
	print &Data::Dumper::Dumper( \@_ );
}

sub on_service_error
{
	my $self = shift;

	require Data::Dumper;

#	$self -> Fatal( &Data::Dumper::Dumper( \@_ ) );
	print &Data::Dumper::Dumper( \@_ );
}

sub on_service_rerun
{
	my $self = shift;

	require Data::Dumper;

#	$self -> Fatal( &Data::Dumper::Dumper( \@_ ) );
	print &Data::Dumper::Dumper( \@_ );
}

no Moose;

-1;

