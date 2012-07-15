use strict;

package Salvation::Roles::ServiceState;

use Moose::Role;

has 'state'	=> ( is => 'ro', isa => 'Salvation::Service::State', lazy => 1, default => sub{ require Salvation::Service::State; return Salvation::Service::State -> new(); } );

no Moose::Role;

-1;

