use strict;

package Salvation::Service::Model;

use Moose;

with 'Salvation::Roles::ServiceReference';

sub main
{
}

__PACKAGE__ -> meta() -> make_immutable();

no Moose;

-1;

