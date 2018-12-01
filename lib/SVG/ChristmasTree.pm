=head1 NAME

SVG::ChristmasTree

=head1 DESCRIPTION

Perl extension to draw Christmas trees with SVG

=head1 SYNOPSIS

    # Default tree
    my $tree = SVG::ChristmasTree->new;
    print $tree->as_xml;

=cut

package SVG::ChristmasTree;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
use SVG;
use Math::Trig qw[deg2rad tan];
use POSIX 'round';

# Constants that we haven't made into attributes yet
use constant {
  TREE_WIDTH => 600,          # Width of the bottom tree layer
  TOP_ANGLE  => 90,           # Angle at the top of the tree triangles
  LAYER_SIZE_RATIO => (5/6),  # How much smaller each layer gets
  LAYER_STACKING => 0.5,      # How far up a layer triangle does the next one start
  POT_TOP_WIDTH => 300,       # Width of the top of the pot
  POT_BOT_WIDTH => 200,       # Width of the bottom of the pot
  TRUNK_WIDTH => 100,         # Width of the trunk
  BAUBLE_RADIUS => 20,        # Radius of a bauble
  STAR_RADIUS => 40,          # Raduis of the star
};

has width => (
  isa => 'Int',
  is  => 'ro',
  default => 1_000,
);

has height => (
  isa => 'Int',
  is  => 'ro',
  lazy_build => 1,
);

# Height is calculated from all the other stuff
sub _build_height {
  my $self = shift;

  # Pot height ...
  my $height = $self->pot_height;
  # ... plus the trunk length ...
  $height += $self->trunk_length;
  # ... for most of the layers ...
  for (0 .. $self->layers - 2) {
    # ... add LAYER_STACKING of the height ...
    $height += $self->triangle_heights->[$_] * LAYER_STACKING;
  }
  # ... add all of the last layer ...
  $height += $self->triangle_heights->[-1];
  # ... and (finally) half of the star
  $height += STAR_RADIUS / 2;

  return round $height;
}

has triangle_heights => (
  isa => 'ArrayRef',
  is => 'ro',
  lazy_build => 1,
);

sub _build_triangle_heights {
  my $self = shift;

  my @heights;
  my $width = TREE_WIDTH;
  for (1 .. $self->layers) {
    push @heights, $self->triangle_height($width, TOP_ANGLE);
    $width *= LAYER_SIZE_RATIO;
  }

  return \@heights;
}

sub triangle_height {
  my $self = shift;
  my ($base, $top_angle) = @_;

  # Assume $top_angle is in degrees
  $top_angle = deg2rad($top_angle) / 2;
  # If I remember my trig correctly...
  return ($base / 2) / tan($top_angle);
}

has svg => (
  isa  => 'SVG',
  is   => 'ro',
  lazy_build => 1,
);

sub _build_svg {
  my $self = shift;

  return SVG->new(
    width => $self->width,
    height => $self->height,
  );
}

has layers => (
  isa => 'Int',
  is  => 'ro',
  default => 4,
);

has trunk_length => (
  isa => 'Int',
  is  => 'ro',
  default => 100,
);

has leaf_colour => (
  isa => 'Str',
  is  => 'ro',
  default => 'rgb(0,127,0)',
);

has bauble_colour => (
  isa => 'Str',
  is  => 'ro',
  default => 'rgb(212,175,55)',
);

has trunk_colour => (
  isa => 'Str',
  is  => 'ro',
  default => 'rgb(139,69,19)',
);

has pot_colour => (
  isa => 'Str',
  is  => 'ro',
  default => 'rgb(191,0,0)',
);

has pot_height => (
  isa => 'Int',
  is  => 'ro',
  default => 200,
);

has triangles => (
  isa => 'ArrayRef',
  is => 'ro',
  lazy_build => 1,
);

sub _build_triangles {
  my $self = shift;

  my $width = TREE_WIDTH;
  my $tri_bottom = $self->height - $self->pot_height - $self->trunk_length;

  my @triangles;
  for (1 .. $self->layers) {
    push @triangles, $self->triangle(TOP_ANGLE, $width, $tri_bottom);
    $width *= LAYER_SIZE_RATIO;
    $tri_bottom -= $triangles[-1]->{h} * LAYER_STACKING;
  }

  return \@triangles;
}

sub as_xml {
  my $self = shift;

  $self->pot;
  $self->trunk;

  for (@{$self->triangles}) {
    my $h = $self->triangle(TOP_ANGLE, $_->{w}, $_->{b});
    $self->bauble($self->mid_y - ($_->{w}/2), $_->{b});
    $self->bauble($self->mid_y + ($_->{w}/2), $_->{b});
    $self->coloured_shape(
      $_->{x}, $_->{y}, $self->leaf_colour,
    );
  }

  return $self->svg->xmlify;
}

sub pot {
  my $self = shift;

  my $pot_top = $self->height - $self->pot_height;

  $self->coloured_shape(
    [  $self->mid_y - (POT_BOT_WIDTH / 2),
       $self->mid_y - (POT_TOP_WIDTH / 2),
       $self->mid_y + (POT_TOP_WIDTH / 2),
       $self->mid_y + (POT_BOT_WIDTH / 2) ],
    [ $self->height, $pot_top, $pot_top, $self->height ],
    $self->pot_colour,
  );
}

sub trunk {
  my $self = shift;

  my $trunk_bottom = $self->height - $self->pot_height;
  my $trunk_top    = $trunk_bottom - $self->trunk_length;

  $self->coloured_shape(
    [ $self->mid_y - (TRUNK_WIDTH / 2), $self->mid_y - (TRUNK_WIDTH / 2),
      $self->mid_y + (TRUNK_WIDTH / 2), $self->mid_y + (TRUNK_WIDTH / 2) ],
    [ $trunk_bottom, $trunk_top, $trunk_top, $trunk_bottom ],
    $self->trunk_colour,
  );
}

sub triangle {
  my $self = shift;
  my ($top_angle, $base, $bottom) = @_;

  my ($x, $y);

  # Assume $top_angle is in degrees
  $top_angle = deg2rad($top_angle) / 2;
  # If I remember my trig correctly...
  my $height = ($base / 2) / tan($top_angle);

  $x = [ $self->mid_y - ($base / 2), $self->mid_y, $self->mid_y + ($base / 2) ];
  $y = [ $bottom, $bottom - $height, $bottom ];

  return {
    x => $x,      # array ref of x points
    y => $y,      # array ref of y points
    h => $height, # height of the triangle
    w => $base,   # length of the base of the triangle
    b => $bottom, # y-coord of the bottom of the triangle
  };
}

sub bauble {
  my $self = shift;
  my ($x, $y) = @_;

  $self->svg->circle(
    cx => $x,
    cy => $y + BAUBLE_RADIUS,
    r => BAUBLE_RADIUS,
    style => {
      fill => $self->bauble_colour,
      stroke => $self->bauble_colour,
    },
  );
}

sub mid_y {
  my $self = shift;

  return $self->width / 2;
}

sub coloured_shape {
  my $self = shift;
  my ($x, $y, $colour) = @_;

  my $path = $self->svg->get_path(
    x => $x,
    y => $y,
    -type => 'polyline',
    -closed => 1,
  );

  $self->svg->polyline(
    %$path,
    style => {
      fill => $colour,
      stroke => $colour,
    },
  );
}

1;
