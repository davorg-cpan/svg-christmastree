use strict;
use warnings;

use Test::More;
use SVG::ChristmasTree;

ok(my $tree = SVG::ChristmasTree->new(star_colour => 'rgb(255,0,0)', star_size => 120), 'Got an object');
isa_ok($tree, 'SVG::ChristmasTree');
is($tree->width, 1_000, 'Width is correct');
is($tree->height, 913, 'Height is calculated correctly');
is($tree->star_colour, 'rgb(255,0,0)', 'Star colour is correct');
is($tree->star_size, 120, 'Star size is correct');
isa_ok($tree->svg, 'SVG', 'SVG attribute');
can_ok($tree, 'as_xml');
ok(my $xml = $tree->as_xml, 'Got some XML');

done_testing;
