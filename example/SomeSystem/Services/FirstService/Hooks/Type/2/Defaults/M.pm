use strict;

package SomeSystem::Services::FirstService::Hooks::Type::2::Defaults::M;

use Moose;

extends 'SomeSystem::Services::FirstService::Defaults::M';

sub main
{
	die;
}

sub columns_id
{
	my ( undef, $node ) = @_;

	return $node -> id() . ' from hook';
}

no Moose;

-1;

