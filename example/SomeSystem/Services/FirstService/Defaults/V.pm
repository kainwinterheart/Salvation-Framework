use strict;

package SomeSystem::Services::FirstService::Defaults::V;

use Moose;

extends 'Salvation::Service::View';

sub main
{
	return [
		columns => [
			'id',
			'title',
			'some_custom_column'
		]
	];
}

no Moose;


-1;

