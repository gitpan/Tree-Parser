#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 14;
use Test::Exception;

BEGIN { 
    use_ok('Tree::Parser') 
}

my $tp = Tree::Parser->new();

# input errors

throws_ok {
    $tp->setInput();
} qr/Insufficient Arguments \: input undefined/, '... this should die';

throws_ok {
    $tp->setInput("file_that_does_not_exist.tree");
} qr/cannot open file\:/, '... this should die';

throws_ok {
    $tp->setInput("A Tree with no Newlines");
} qr/Incorrect Object Type \: input looked like a single string/, '... this should die';

# parse filter errors

throws_ok {
    $tp->setParseFilter();
} qr/Insufficient Arguments/, '... this should die';

throws_ok {
    $tp->setParseFilter("Fail");
} qr/Insufficient Arguments/, '... this should die';

throws_ok {
    $tp->setParseFilter([]);
} qr/Insufficient Arguments/, '... this should die';

# parse error

throws_ok {
    $tp->parse();
} qr/Parse Error \: No parse filter is specified to parse with/, '... this should die';

$tp->setParseFilter(sub { 1 });

throws_ok {
    $tp->parse();
} qr/Parse Error \: no input has yet been defined, there is nothing to parse/, '... this should die';


# deparse filter errors

throws_ok {
    $tp->setDeparseFilter();
} qr/Insufficient Arguments/, '... this should die';

throws_ok {
    $tp->setDeparseFilter("Fail");
} qr/Insufficient Arguments/, '... this should die';

throws_ok {
    $tp->setDeparseFilter([]);
} qr/Insufficient Arguments/, '... this should die';

# deparse error

throws_ok {
    $tp->deparse();
} qr/Parse Error \: no deparse filter is specified/, '... this should die';

$tp->setDeparseFilter(sub { 1 });

throws_ok {
    $tp->deparse();
} qr/Parse Error \: Tree is a leaf node, cannot de-parse a tree that has not be created yet/, '... this should die';





