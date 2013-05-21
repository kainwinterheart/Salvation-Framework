use strict;

package Salvation::Stuff;

require Exporter;

our @ISA 	 = ( 'Exporter' );
our @EXPORT 	 = ();

our @EXPORT_OK 	 = ( '&full_pkg',
		     '&load_class' );

our %EXPORT_TAGS = ( all => \@EXPORT_OK );
our $VERSION 	 = 1.00;

sub full_pkg
{
	return join( '::', @_ );
}

sub load_class
{
	my $class = shift;

	my $path = join( '/', split( /\:\:/, $class ) ) . '.pm';

	return ( exists( $INC{ $path } ) or eval
	{
		require $path;
		1;
	} );
}


-1;

