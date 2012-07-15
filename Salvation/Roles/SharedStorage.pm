use strict;

package Salvation::Roles::SharedStorage;

use Moose::Role;

has 'storage' => ( is => 'rw', isa => 'Salvation::SharedStorage', lazy => 1, default => sub{ require Salvation::SharedStorage; return Salvation::SharedStorage -> new(); } );

no Moose::Role;

-1;

