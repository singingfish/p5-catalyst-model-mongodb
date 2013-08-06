#!perl -T

# Verify to create object with no dbnames, to list which dbnames exist.
# Verify to create object with dbname and define collection

use strict;
use warnings;
use Test::More tests => 8;

my $COLLECTION_NAME = 'test_Catalyst_Model_MongoDB';

BEGIN {
    use_ok('Catalyst::Model::MongoDB');
}

my $mongo = new_ok 'Catalyst::Model::MongoDB';

# See if a test database is available. Preferably one called 'test'.
my $testdb;
eval '
  my @dbs = $mongo->dbnames();
  if ( grep /^test$/, @dbs ) {
    ($testdb) = grep /^test$/, @dbs;
  } elsif ( grep /test/i, @dbs ) {
    ($testdb) = grep /test/i, @dbs;
  } else {
    $testdb = shift @dbs;
  }
';

# If there is a database available, make reference to a collection
#
SKIP: {
  skip 'No local database available for testing', 5 unless $testdb;
  my $db = new_ok( 'Catalyst::Model::MongoDB' =>[
    dbname => $testdb,
  ] );

  isa_ok ( $db, 'Catalyst::Model::MongoDB' );
  my $coll = $db->collection( $COLLECTION_NAME );

  isa_ok ( $coll, 'MongoDB::Collection' );

  my $test_string = 'Catalyst::Model::MongoDB test';

  isa_ok ( my $id = $coll->insert({ a => $test_string }, {safe=>1}), 'MongoDB::OID' );

  my $record = $coll->find_one({ _id => $id });

  ok(ref($record) eq 'HASH', 'Data read is a hashref');
  ok ( $record->{a} eq $test_string, 'Data read matches inserted data' );

};
