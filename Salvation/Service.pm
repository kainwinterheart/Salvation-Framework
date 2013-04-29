use strict;

package Salvation::Service;

use Moose;

with 'Salvation::Roles::AppArgs', 'Salvation::Roles::DataSet', 'Salvation::Roles::SharedStorage', 'Salvation::Roles::SystemReference', 'Salvation::Roles::ServiceState';

use Salvation::Stuff ( '&load_class', '&full_pkg' );

use Digest::MD5 '&md5_hex';

foreach my $name ( ( 'model', 'view', 'controller' ) )
{
	my $ucfirst = ucfirst( $name );

	has $name => ( is => 'ro', isa => 'Maybe[Salvation::Service::' . $ucfirst . ']', lazy => 1, init_arg => undef, default => sub{ return shift -> __build_infrastructure_reference( substr( $ucfirst, 0, 1 ) ); } );
}

has 'output_processor' => ( is => 'ro', isa => 'Maybe[Salvation::Service::OutputProcessor]', lazy => 1, init_arg => undef, default => sub
{
	my $self = shift;

	return $self -> __build_infrastructure_reference( 'OutputProcessor' => ( system => $self -> system(), state => $self -> state() ) );
} );

has '__nohook'	=> ( is => 'ro', isa => 'Bool', default => 0, lazy => 1 );

has 'hook'	=> ( is => 'ro', isa => 'Maybe[Salvation::Service::Hook]', lazy => 1, builder => '_build_hook', predicate => 'has_hook' );

has '__hooks'	=> ( is => 'rw', isa => 'ArrayRef[ArrayRef[ArrayRef[Defined]]]', lazy => 1, default => sub{ [] } ); # Hooklist => Speclist => Spec

has '__controller_methods'	=> ( is => 'rw', isa => 'ArrayRef[ArrayRef[Defined]]', lazy => 1, default => sub{ [] } ); # Speclist => Spec

sub RERUN_ON_BAD_HOOK { 1 }

sub intent
{
	my ( $self, $service ) = @_;

	require Salvation::Service::Intent;

	return Salvation::Service::Intent -> new(
		service => $service,
		( map{ $_ => $self -> $_() } ( 'args', 'dataset', 'storage', 'system', 'state' ) )
	);
}

sub Hook
{
	my ( $self, @list ) = @_;

	push @{ $self -> __hooks() }, \@list;

	return 1;
}

sub Call
{
	my ( $self, @list ) = @_;

	push @{ $self -> __controller_methods() }, \@list;

	return 1;
}

sub __get_hook
{
	my $self   = shift;
	my $result = '';

SCAN_HOOK_LIST:
	foreach my $list ( @{ $self -> __hooks() } )
	{
		my @path = ();

		foreach my $spec ( @$list )
		{
			my ( $value, $type, $flags ) = @$spec;

			$flags ||= {};

			if( ref( my $code = $flags -> { 'transform_value' } ) eq 'CODE' )
			{
				$value = $code -> ( $self, $value, $type );
			}

			if( ref( my $code = $flags -> { 'transform_type' } ) eq 'CODE' )
			{
				$type = $code -> ( $self, $value, $type );
			}

			if( ref( my $code = $flags -> { 'transform_value_and_type' } ) eq 'CODE' )
			{
				( $value, $type ) = $code -> ( $self, $value, $type );
			}

			my $ok = 1;

			if( ref( my $code = $flags -> { 'constraint' } ) eq 'CODE' )
			{
				$ok = $code -> ( $self, $value, $type );
			}

			if( $value and $type and $ok )
			{
				push @path, $type, $value;
			} else
			{
				next SCAN_HOOK_LIST;
			}
		}

		if( scalar @path )
		{
			if( $self -> __load_hook( $result = &full_pkg( @path ) ) )
			{
				last SCAN_HOOK_LIST;

			} else
			{
				if( my $err = $@ )
				{
					$self -> system() -> on_hook_load_error( {
						'$@'     => $err,
						hook     => $result,
						service  => ( ref( $self ) or $self ),
						instance => $self
					} );
				}

				$result = '';
			}
		}
	}

	return $result;
}

sub __run_controller_methods
{
	my $self = shift;

	foreach my $spec ( @{ $self -> __controller_methods() } )
	{
		last if $self -> state() -> stopped();

		my ( $method, $flags ) = @$spec;

		$flags ||= {};

		if( ref( my $code = $flags -> { 'transform_method' } ) eq 'CODE' )
		{
			$method = $code -> ( $self, $method );
		}

		my $ok = 1;

		if( ref( my $code = $flags -> { 'constraint' } ) eq 'CODE' )
		{
			$ok = $code -> ( $self, $method );
		}

		if( $method and $ok )
		{
			my @args = ();

			if( ref( my $args = $flags -> { 'args' } ) eq 'ARRAY' )
			{
				@args = @$args;
			}

			$self -> __safecall( 'controller', sub{ shift -> $method( @args ) } );

			if( ( my $err = $self -> storage() -> get( '$@' ) ) and $flags -> { 'fatal' } )
			{
				$self -> state() -> stop();
			}
		}
	}

	return 1;
}

sub __full_hook_pkg
{
	my ( $self, $pkg, $orig ) = @_;

	return return &full_pkg( ( $orig or ref( $self ) ), 'Hooks', $pkg );
}

sub __full_default_pkg
{
	my ( $self, $pkg, $orig ) = @_;

	return &full_pkg( ( $orig or ref( $self ) ), 'Defaults', $pkg );
}

sub __load_hook
{
	my ( $self, $pkg, $orig ) = @_;

	return &load_class( $self -> __full_hook_pkg( $pkg, $orig ) );
}

sub _build_hook
{
	my $self     = shift;
	my $instance = undef;

	if( not( $self -> __nohook() ) and ( my $hook = $self -> __get_hook() ) )
	{
		$instance = eval{ $self -> intent( $self -> __full_hook_pkg( $hook ) ) -> service() };

		while( $instance and $instance -> hook() )
		{
			my $parent_link = $instance;

			$instance = $instance -> hook();

			$instance -> __parent_link( $parent_link );
		}
	}

	return $instance;
}

sub __build_infrastructure_reference
{
	my ( $self, $suffix, @rest ) = @_;

	my $pkg = '';

	if( my $hook = $self -> hook() )
	{
		my $sref = ref( $self );

		while( $hook )
		{
			last if
				$pkg = $self -> __try_to_load_infrastructure_package( $suffix, $sref, ref( $hook ) );

			$hook = $hook -> __parent_link();
		}
	}

	$pkg ||= $self -> __full_default_pkg( $suffix );

	return ( &load_class( $pkg ) ? $pkg -> new( ( scalar( @rest ) ? @rest : ( service => $self ) ) ) : undef );
}

sub __try_to_load_infrastructure_package
{
	my ( $self, $suffix, $sref, $href ) = @_;

	my $pkg = '';

	$href =~ s/^$sref\:\://;

	unless( &load_class( $pkg = &full_pkg( $sref, $self -> __full_default_pkg( $suffix, $href ) ) ) )
	{
		$pkg = '';
	}

	return $pkg;
}

sub cacheid
{
	# this function can be redefined
	return '';
}

sub __cacheid
{
	my $self = shift;

	return &md5_hex( join( '_',
		ref( $self ),
		( $self -> has_hook() ? ( ref( $self -> hook() ) ) : () ),
		$self -> cacheid(),
		@_
	) );
}

sub __safecall
{
	my $wa = wantarray;
	my ( $self, $method, $code ) = @_;

	my $out = undef;
	my @out = ();

	eval
	{
		if( my $obj = $self -> $method() )
		{
			if( $wa )
			{
				@out = $code -> ( $obj );
			} else
			{
				$out = $code -> ( $obj );
			}
		}
	};

	if( my $err = $@ )
	{
		$self -> storage() -> put( '$@', $err );
	}

	return ( $wa ? @out : $out );
}

sub throw
{
	my ( $self, @rest ) = @_;

	if( my $err = $self -> storage() -> get( '$@' ) )
	{
		push @rest, ( 'Previous error:' => $err );
	}

	$self -> storage() -> put( '$@', \@rest );
	$self -> state() -> stop();

	return 1;
}

sub start
{
	my $self = shift;

	return 1 if $self -> state() -> stopped();

	my $aux = sub{ return $self -> __safecall( 'controller', shift ); };

	$self -> init();	# service -> init

	return 2 if $self -> state() -> stopped();

	$aux -> ( sub{ shift -> init() } );	# controller -> init

	return 3 if $self -> state() -> stopped();

	$self -> __run_controller_methods(); # scheduled controller methods

	return 4 if $self -> state() -> stopped();

	$self -> main();	# service -> main

	return 5 if $self -> state() -> stopped();

	$aux -> ( sub{ shift -> main() } );	# controller -> main

	return 6 if $self -> state() -> stopped();

	unless( $self -> state() -> need_to_skip_view() )
	{
		$aux -> ( sub{ shift -> before_view_processing() } );	# controller -> before_view_processing

		return 7 if $self -> state() -> stopped();

		$self -> __safecall( 'view', sub{ shift -> process() } );	# view -> process

		return 8 if $self -> state() -> stopped();

		$aux -> ( sub{ shift -> after_view_processing() } );	# controller -> after_view_processing
	}

	return 9 if $self -> state() -> stopped();

	return 0;
}

sub main
{
}

sub init
{
}

no Moose;

-1;

