use strict;

package Salvation::System;

use Moose;

with 'Salvation::Roles::SharedStorage', 'Salvation::Roles::AppArgs';

use Salvation::Stuff ( '&load_class', '&full_pkg' );

use Carp '&longmess';

has '__services'   => ( is => 'rw', isa => 'ArrayRef[ArrayRef[Defined]]', lazy => 1, default => sub{ [] } ); # Servicelist => Spec

has '__loaded_services'	=> ( is => 'ro', isa => 'ArrayRef[Str]', init_arg => undef, lazy => 1, builder => '__get_services' );

has '__throwable_fatals'	=> ( is => 'ro', isa => 'ArrayRef[Any]', init_arg => undef, lazy => 1, default => sub{ [] } );

sub Service
{
	my ( $self, @spec ) = @_;

	push @{ $self -> __services() }, \@spec;

	return 1;
}

sub Fatal
{
	my ( $self, @rest ) = @_;

	push @{ $self -> __throwable_fatals() }, @rest;

	return 1;
}

sub __get_services
{
	my $self     = shift;
	my @services = ();

	foreach my $spec ( @{ $self -> __services() } )
	{
		my ( $name, $flags ) = @$spec;

		if( ref( my $code = $flags -> { 'transform_name' } ) eq 'CODE' )
		{
			$name = $code -> ( $self, $name );
		}

		my $ok = 1;

		if( ref( my $code = $flags -> { 'constraint' } ) eq 'CODE' )
		{
			$ok = $code -> ( $self, $name );
		}

		if( $name and $ok )
		{
			if( &load_class( $name = $self -> __full_service_pkg( $name ) ) )
			{
				push @services, $name;
			}
		}
	}

	return \@services;
}

sub __full_service_pkg
{
	my ( $self, $name, $orig ) = @_;

	return &full_pkg( ( $orig or ref( $self ) ), 'Services', $name );
}

sub stop
{
	goto THROW_SCHEDULED_FATALS; # EVILNESS
}

sub start
{
	my $self = shift;

	$self -> main();

	my @states = ();

	foreach my $service ( @{ $self -> __loaded_services() } )
	{
		if( defined( my $state = $self -> run_service( $service ) ) )
		{
			push @states, $state;
		}
	}

THROW_SCHEDULED_FATALS:
	if( scalar( my @fatals = @{ $self -> __throwable_fatals() } ) )
	{
		if( scalar( grep{ ref } @fatals ) )
		{
			if( scalar( @fatals ) > 1 )
			{
				die \@fatals;

			} else
			{
				die @fatals;
			}
		} else
		{
			die @fatals, &longmess();
		}
	}

	return $self -> output( \@states );
}

sub run_service
{
	my ( $self, $service ) = @_;

	my $has_hook = undef;
	my $rerun    = undef;
	my $state    = undef;

RUN_SERVICE:
	{
		eval
		{
			my $instance = $service -> new(
				system   => $self,
				args     => $self -> args(),
				__nohook => ( ( $self -> args() -> { 'nohook' } or $rerun ) ? 1 : 0 )
			);

			$has_hook = ( $instance -> hook() ? 1 : 0 );
			$rerun    = $instance -> RERUN_ON_BAD_HOOK();

			if( $instance -> start() == 0 )
			{
				my $op = $instance -> output_processor();

				$state = {
					service => $service,
					state   => $instance -> state(),
					( $op ? ( op => $op ) : () )
				};

			} elsif( my $err = $instance -> storage() -> get( '$@' ) )
			{
				$self -> on_service_thrown_error( {
					'$@'     => $err,
					instance => $instance,
					service  => $service
				} );
			}
		};

		if( my $err = $@ )
		{
			eval
			{
				$self -> on_service_error( {
					'$@'	=> $err,
					service => $service
				} );
			};

			if( $has_hook and $rerun )
			{
				$self -> on_service_rerun( {
					service => $service
				} );

				redo RUN_SERVICE;
			}
		}
	}

	return $state;
}

sub main
{
}

sub output
{
	my ( undef, $states ) = @_;

	my $output = '';

	foreach my $node ( @$states )
	{
		if( my $op = $node -> { 'op' } )
		{
			$output .= eval{ $op -> main() };
		}
	}

	my ( $decl ) = ( $output =~ m/<\?xml(.+?)\?>/i );

	if( $decl )
	{
		$output =~ s/<\?xml(.+?)\?>[\n]?//gi;
		$output = sprintf( '<?xml%s?>%s<output>%s</output>', $decl, "\n", $output );
	}

	return $output;
}

sub on_service_thrown_error
{
}

sub on_service_error
{
}

sub on_service_rerun
{
}

sub on_node_rendering_error
{
}

sub on_hook_load_error
{
}

sub on_service_shared_storage_get
{
}

sub on_service_shared_storage_put
{
}

sub on_shared_storage_get
{
}

sub on_shared_storage_put
{
}

sub on_service_controller_method_error
{
}

sub on_service_shared_storage_receives_error_notification
{
}

sub on_shared_storage_receives_error_notification
{
}

__PACKAGE__ -> meta() -> make_immutable();

no Moose;

-1;

