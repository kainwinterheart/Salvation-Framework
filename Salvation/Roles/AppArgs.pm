use strict;

package Salvation::Roles::AppArgs;

use Moose::Role;

has 'args' => ( is => 'rw', isa => 'HashRef', default => sub{ {} }, lazy => 1 );

no Moose::Role;

-1;

