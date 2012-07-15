use strict;

package Salvation::Roles::SystemReference;

use Moose::Role;

has 'system' => ( is => 'ro', isa => 'Salvation::System', default => undef, lazy => 1, required => 1 );

no Moose::Role;

-1;

