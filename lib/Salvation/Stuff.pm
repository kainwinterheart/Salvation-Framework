use strict;

package Salvation::Stuff;

require Exporter;

our @ISA 	 = ( 'Exporter' );
our @EXPORT 	 = ();

our @EXPORT_OK 	 = ( '&full_pkg',
		     '&load_class',
		     '&is_namespace_present' );

our %EXPORT_TAGS = ( all => \@EXPORT_OK );
our $VERSION 	 = 1.00;

sub full_pkg
{
	return join( '::', @_ );
}

sub load_class
{
	my $class = shift;

	return 1 if &is_namespace_present( $class ) and $class -> can( 'new' );

	require Module::Load;

	eval{ &Module::Load::load( $class ) };

	return 1 if &is_namespace_present( $class );

	require Module::Loaded;

	return ( &Module::Loaded::is_loaded( $class ) ? 1 : 0 );
}

sub is_namespace_present
{
	my $ns = shift;

	my @parts = split( /\:\:/, $ns );
	my $ok    = 0;
	my $node  = undef;

	foreach my $part ( @parts )
	{	
		if( $node = ( $node //= *::{ 'HASH' } ) -> { sprintf( '%s::', $part ) } )
		{
			++$ok;

		} else
		{
			last;
		}
	}

	return ( scalar( @parts ) == $ok );
}

-1;

