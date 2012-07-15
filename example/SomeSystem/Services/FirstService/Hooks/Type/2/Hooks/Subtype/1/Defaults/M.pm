use strict;

package SomeSystem::Services::FirstService::Hooks::Type::2::Hooks::Subtype::1::Defaults::M;

use Moose;

extends 'SomeSystem::Services::FirstService::Hooks::Type::2::Defaults::M';

sub columns_id
{
	my ( undef, $node ) = @_;

	return $node -> id() . ' from another hook';
}

no Moose;

-1;

