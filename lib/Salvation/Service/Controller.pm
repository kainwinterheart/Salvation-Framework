use strict;

package Salvation::Service::Controller;

use Moose;

with 'Salvation::Roles::ServiceReference';

sub init
{
}

sub main
{
}

sub before_view_processing
{
}

sub after_view_processing
{
}

__PACKAGE__ -> meta() -> make_immutable();

no Moose;

-1;

