use strict;

package Salvation::Service::View::Stack::Frame;

use Moose;

has 'id'	=> ( is => 'rw', isa => 'Int', init_arg => undef );

has 'ftype'	=> ( is => 'rw', isa => 'Str', required => 1 );

has 'fname'	=> ( is => 'rw', isa => 'Str', required => 1 );

has 'cap'	=> ( is => 'rw', isa => 'Maybe[Str]' );

has 'data'	=> ( is => 'rw', isa => 'Str|' . __PACKAGE__ . '|Undef' );

has 'is_list'   => ( is => 'ro', isa => 'Bool', default => 0, init_arg => undef );

no Moose;

-1;

