#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 17;

BEGIN { 
    use_ok('Tree::Parser') 
}

use Tree::Simple;
use Array::Iterator;

my $tree_string = "1.0\n\t1.1\n\t1.2\n\t1.3\n2.0\n\t2.1\n\t\t2.1.1\n\t2.2\n3.0";

chomp $tree_string;

my $tree = Tree::Simple->new(Tree::Simple->ROOT)
            ->addChildren(
                Tree::Simple->new("1.0")
                            ->addChildren(
                            Tree::Simple->new("1.1"),
                            Tree::Simple->new("1.2"),
                            Tree::Simple->new("1.3")
                            ),
                Tree::Simple->new("2.0")
                            ->addChildren(
                            Tree::Simple->new("2.1")
                                        ->addChildren(
                                        Tree::Simple->new("2.1.1"),
                                        ),
                            Tree::Simple->new("2.2")                                        
                            ),
                Tree::Simple->new("3.0")
            );	

isa_ok($tree, "Tree::Simple");

my $parse_filter = sub {
    my ($line_iterator) = @_;
    my $line = $line_iterator->next();
    my ($tabs, $node) = $line =~ /(\t*)(.*)/;
    my $depth = length $tabs;
    return ($depth, $node);
};
 
# tree as input 
{                       
    my $tp = Tree::Parser->new($tree);
    
    isa_ok($tp, "Tree::Parser");
    
    $tp->setDeparseFilter(sub { 
        my ($tree) = @_;
        return ("\t" x $tree->getDepth()) . $tree->getNodeValue();
    });
    
    my @deparsed_string = $tp->deparse();
    
    is((join "\n" => @deparsed_string), $tree_string, '... deparse worked');
}

# using setInput to set a string
{
    my $tp = Tree::Parser->new();
    isa_ok($tp, "Tree::Parser");
    
    $tp->setInput($tree_string);
    
    $tp->setParseFilter($parse_filter);    
    
    $tp->parse();
    
    my $tree = $tp->getTree();

    isa_ok($tree, "Tree::Simple");
    
    my @accumulation;
    $tree->traverse(sub {
        my ($tree) = @_;
        push @accumulation, $tree->getNodeValue();
    });
    
    ok(eq_array(
            [ @accumulation ], 
            [ qw/1.0 1.1 1.2 1.3 2.0 2.1 2.1.1 2.2 3.0/ ]
        ), '... parse test failed');
}

# using setInput to set an array of lines
{
    my $tp = Tree::Parser->new();
    isa_ok($tp, "Tree::Parser");
    
    $tp->setInput([ split /\n/ => $tree_string ]);
    
    $tp->setParseFilter($parse_filter);    
    
    my $tree = $tp->parse();

    isa_ok($tree, "Tree::Simple");
    
    my @accumulation;
    $tree->traverse(sub {
        my ($tree) = @_;
        push @accumulation, $tree->getNodeValue();
    });
    
    ok(eq_array(
            [ @accumulation ], 
            [ qw/1.0 1.1 1.2 1.3 2.0 2.1 2.1.1 2.2 3.0/ ]
        ), '... parse test failed');
}

# using new to set an Array::Iterator
{
    my $tp = Tree::Parser->new(Array::Iterator->new( split /\n/ => $tree_string ));
    isa_ok($tp, "Tree::Parser");
    
    $tp->setParseFilter($parse_filter);    
    
    my $tree = $tp->parse();

    isa_ok($tree, "Tree::Simple");
    
    my @accumulation;
    $tree->traverse(sub {
        my ($tree) = @_;
        push @accumulation, $tree->getNodeValue();
    });
    
    ok(eq_array(
            [ @accumulation ], 
            [ qw/1.0 1.1 1.2 1.3 2.0 2.1 2.1.1 2.2 3.0/ ]
        ), '... parse test failed');
}

# using new to set an Array::Iterator
{
    my $tp = Tree::Parser->new("t/sample.tree");
    isa_ok($tp, "Tree::Parser");
    
    $tp->setParseFilter(sub {
        my ($line_iterator) = @_;
        my $line = $line_iterator->next();
        my ($tabs, $node) = $line =~ /(\s*)(.*)/;
        my $depth = length $tabs;
        return ($depth, $node);
    });   
    
    my $tree = $tp->parse();

    isa_ok($tree, "Tree::Simple");
    
    my @accumulation;
    $tree->traverse(sub {
        my ($tree) = @_;
        push @accumulation, $tree->getNodeValue();
    });
    
    ok(eq_array(
            [ @accumulation ], 
            [ qw/1.0 1.1 1.1.1 1.1.2 1.2 1.2.1 1.2.2 2.0 2.1 2.2 3.0 3.1 3.1.1 3.2 3.3 3.3.1/ ]
        ), '... parse test failed');

}

{
    eval {
        my $tp = Tree::Parser->new(bless({}, "Fail"));
    };
    if ($@) {
        like($@, qr/Incorrect Object Type/, '.. be sure we have the right exception');
    }
    else {
        fail('... this should have thrown an exception');
    }
}

