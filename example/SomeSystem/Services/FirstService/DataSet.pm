use strict;

package SomeSystem::Services::FirstService::DataSet;

use Moose;

extends 'Salvation::Service::DataSet';

use Drwebcom::Stuff::ClassHash ();

sub main
{
	return [ Drwebcom::Stuff::ClassHash -> new( data => { id => 100500, title => 'test', ltype => ( int( rand( 2 ) ) + 1 ), lsubtype => ( int( rand( 2 ) ) + 1 ) } ) ];
}

no Moose;

-1;

