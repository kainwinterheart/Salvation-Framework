use strict;

package SomeSystem::Services::FirstService::Defaults::C;

use Moose;

extends 'Salvation::Service::Controller';

sub asd
{
#	shift -> service() -> throw( 'controller error' );
}

no Moose;

-1;

