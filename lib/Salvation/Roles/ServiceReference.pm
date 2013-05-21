use strict;

package Salvation::Roles::ServiceReference;

use Moose::Role;

has 'service' => ( is => 'ro', isa => 'Salvation::Service', default => undef, lazy => 1, weak_ref => 1, required => 1 );

no Moose::Role;

-1;

