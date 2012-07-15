use strict;

package SomeSystem::Services::FirstService::Hooks::Type::2;

use Moose;

extends 'Salvation::Service::Hook';

sub BUILD
{
	my $self = shift;

	$self -> Hook( [ $self -> dataset() -> first() -> lsubtype(), 'Subtype' ] );
}

sub main
{
}

no Moose;

-1;

