#!/usr/bin/perl

use strict;

package test;

use Devel::Cycle;

use SomeSystem::Services::FirstService;
# use SomeSystem::Services::FirstService::Defaults::V;

# use Salvation::View;

use Data::Dumper;

use SomeSystem;

my $system = SomeSystem -> new();

print Dumper( my $result = $system -> start() );

{
my $service = SomeSystem::Services::FirstService -> new( system => $system );

$service -> model();
$service -> view();
$service -> output_processor();

print Dumper( $service );

find_cycle( $service );
}


#{
#use Salvation::Service::View::Stack::Convert::To::XML ();

#print Salvation::Service::View::Stack::Convert::To::XML -> parse( $result -> [ 0 ] -> { 'state' } -> view_output() ) . "\n";
#}


find_cycle( $system );
# find_cycle( $service );
find_cycle( $result );
# my $service = SomeSystem::Services::FirstService -> new( args => { skip_false => 1 } );

# print Dumper( $service -> view() -> process() );
# print Dumper( $service -> dataset() -> service() );
# find_cycle( $service );
# find_cycle( $service -> model() );
# find_cycle( $service -> hook() );
# print Dumper(
# $service -> intent( 'SomeSystem::Services::SecondService' ) -> service() ] );
# print Dumper( $Salvation::View::SimpleCache::ZEE_CACHE );
# print Dumper( \%INC );
# find_cycle( $service );
# find_cycle( $service -> model() );
# print Dumper( SomeSystem::Services::FirstService::Defaults::V -> new() -> process() );
# Salvation::View -> new();
print "1\n";

exit 0;

