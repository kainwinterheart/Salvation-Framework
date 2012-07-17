use strict;

package SomeSystem::Services::FirstService::Defaults::M;

use Moose;

extends 'Salvation::Service::Model';

sub columns_some_custom_column
{
	return ( rand(), '<asd>";\'фывфыв</asd>\\' );
}

sub __columns
{
	my ( undef, $obj, $col ) = @_;

	return $obj -> $col();
}

no Moose;

-1;

