use strict;

package Salvation::Service::OutputProcessor;

use Moose;

with 'Salvation::Roles::ServiceState', 'Salvation::Roles::SystemReference';

sub main
{
	my $self = shift;

	require Scalar::Util;
	require XML::Writer;
	require Salvation::Service::View::Stack::Convert::To::XML;

	my $data = $self -> state() -> view_output();

	if( Scalar::Util::blessed( $data ) and $data -> isa( 'Salvation::Service::View::Stack' ) )
	{
		$data = [ $data ];
	}

	my $writer = XML::Writer -> new(
		OUTPUT =>
			my $io = IO::String -> new(
				my $xml
			)
	);

	$writer -> xmlDecl( 'UTF-8' );

	$writer -> startTag( 'data' );

	if( ref( $data ) eq 'ARRAY' )
	{
		my $first = 1;

		foreach my $stack ( @$data )
		{
			Salvation::Service::View::Stack::Convert::To::XML -> parse( $stack, { writer => $writer, nocharset => 1 } );
		}
	}

	$writer -> endTag( 'data' );

	$io -> close();

	return $xml;
}

__PACKAGE__ -> meta() -> make_immutable();

no Moose;

-1;

