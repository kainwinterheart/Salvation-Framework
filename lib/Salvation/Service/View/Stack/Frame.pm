use strict;

package Salvation::Service::View::Stack::Frame;

use Moose;

has 'id'	=> ( is => 'rw', isa => 'Int', init_arg => undef );

has 'ftype'	=> ( is => 'rw', isa => 'Str', required => 1 );

has 'fname'	=> ( is => 'rw', isa => 'Str', required => 1 );

has 'cap'	=> ( is => 'rw', isa => 'Maybe[Str]' );

has 'data'	=> ( is => 'rw', isa => 'Str|' . __PACKAGE__ . '|Undef' );

has 'is_list'   => ( is => 'ro', isa => 'Bool', default => 0, init_arg => undef );

__PACKAGE__ -> meta() -> make_immutable();

no Moose;

-1;

# ABSTRACT: A result of column processing generated by view

=pod

=head1 NAME

Salvation::Service::View::Stack::Frame - A result of column processing generated by view

=head1 REQUIRES

L<Moose> 

=head1 METHODS

=head2 id

 $frame -> id()

Frame ID. Unique per each frame list. Integer.

=head2 ftype

 $frame -> ftype()

A type of a frame. String.

In example, if a view's template had this:

 some_type => [
 	'some_column'
 ]

then the C<ftype> value for such frame is C<some_type>.

=head2 fname

 $frame -> fname()

A name of a frame. String.

In example, if a view's template had this:

 some_type => [
 	'some_column'
 ]

then the C<fname> value for such frame is C<some_column>.

=head2 cap

 $frame -> cap()

A caption of a frame. String.

As returned by a model, or autogenerated like this:

 sprintf(
 	'FIELD_%s',
	$frame -> fname()
 )

=head2 data

 $frame -> data()

Frame content. A string, a C<Salvation::Service::View::Stack::Frame>-derived object instance or an C<undef>.

As returned by a model.

=head2 is_list

Boolean. Returns false.

=cut

