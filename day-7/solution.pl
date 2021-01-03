#!/usr/bin/env perl

use strict;
use warnings;
use diagnostics;

package Node;

sub new {
	my $class = shift;
	my $self = {};

	$self->{color} = "";
	$self->{inner} = {};
	$self->{outer} = [];
	
	return bless $self, $class;
}

sub color {
	my $self = shift;
	
	if (@_) {
		$self->{color} = shift;
	}

	return $self->{color};
}

sub inner {
	my $self = shift;

	if (@_) {
		my ($node, $count) = (shift, shift);
		my $color = $node->color();

		$self->{inner}{$color} = [$node, $count];
	}

	return \%{ $self->{inner} };
}

sub outer {
	my $self = shift;

	if (@_) {
		push @{ $self->{outer} }, shift;
	}

	return \@{ $self->{outer} };
}

package solution;

our %visited_nodes;

sub recurse_outer_bags {
	my $node = shift;
	my $count = 0;

	foreach my $outer (@{ $node->outer() }) {
		my $color = $outer->color();

		unless (exists $visited_nodes{$color}) {
			$count = $count + 1 + recurse_outer_bags($outer);
			$visited_nodes{$color} = $outer;
		}
	}

	return $count;
}

sub recurse_inner_bags {
	my $node = shift;
	my $count = 1;

	my %inner_nodes = %{$node->inner()};
	foreach my $key (keys %{ $node->inner() }) {
		my @tmp = @{ $inner_nodes{$key} };
		my ($inode, $bcount) = ($tmp[0], $tmp[1]);

		$count = $count + $bcount * recurse_inner_bags($inode);
	}

	return $count;
}

sub construct_bag_tree {
	my %bag_cache;

	while (<>) {
		my $line = $_;
		chomp $line;

		my ($bag_color, $inner_bags) = $line =~ /(.*) bags contain (.*)./;
		my @inner_bags = split /,/, $inner_bags;

		my $node;
		if (exists $bag_cache{$bag_color}) {
			$node = $bag_cache{$bag_color};
		} else {
			$node = Node->new();
			$node->color($bag_color);
			$bag_cache{$bag_color} = $node;
		}

		foreach my $inner_bag ( @inner_bags ) {
			if ($inner_bag =~ /no other bags/) {
				next;
			}

			my ($count, $color) = $inner_bag =~ /(\d+) (.*?) bags?/;

			my $inner_node;
			if (exists $bag_cache{$color}) {
				$inner_node = $bag_cache{$color};
			} else {
				$inner_node = Node->new();
				$inner_node->color($color);
				$bag_cache{$color} = $inner_node;
			}

			$inner_node->outer($node);
			$node->inner($inner_node, int($count));
		}

		$bag_cache{$bag_color} = $node;
	}

	return $bag_cache{"shiny gold"};
}

my $shiny_gold_bag = construct_bag_tree();
my $total = recurse_outer_bags($shiny_gold_bag);
print "[part 1] bags eventually containing shiny gold bag: $total\n";

$total = recurse_inner_bags($shiny_gold_bag) - 1;
print "[part 2] bags required inside shiny gold bag: $total\n";
