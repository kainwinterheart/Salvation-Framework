use strict;

package Salvation::Service::State;

use Moose;

use Salvation::Service::View::Stack ();

has 'stopped'	=> ( is => 'rw', isa => 'Bool', default => 0 );

has 'need_to_skip_view'	=> ( is => 'rw', isa => 'Bool', default => 0 );

has 'view_output'	=> ( is => 'rw', isa => 'Salvation::Service::View::Stack|ArrayRef[Salvation::Service::View::Stack]', lazy => 1, default => sub{ [] } );

has 'output'	=> ( is => 'rw', isa => 'Defined', lazy => 1, default => '' );

sub stop
{
	shift -> stopped( 1 );
}

sub resume
{
	shift -> stopped( 0 );
}

sub skip_view
{
	shift -> need_to_skip_view( 1 );
}

sub use_view
{
	shift -> need_to_skip_view( 0 );
}

no Moose;

-1;

