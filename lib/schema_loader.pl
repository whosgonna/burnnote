#!/usr/bin/env perl

use Modern::Perl;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;
make_schema_at(
    'Burnnote::Schema',
    { debug => 1,
      dump_directory => './',
    },
    [ 'dbi:SQLite:dbname=/usr/local/www/burnnote/data/burnnote.db', undef, undef,
       #{ loader_class => 'Burnnote' } # optionally
    ],
);
