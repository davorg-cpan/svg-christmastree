package SVG::ChristmasTree;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
use SVG;
use Math::Trig qw[deg2rad tan];

# Constants that we haven't made into attributes yet
use constant {
  TREE_WIDTH => 600,
  TOP_ANGLE  => 90,
  POT_TOP_WIDTH => 300,
  POT_BOT_WIDTH => 200,
  TRUNK_WIDTH => 100,
  BAUBLE_RADIUS => 20,
};

has width => (
  isa => 'Int',
  is  => 'ro',
  default => 1_000,
);

has height => (
  isa => 'Int',
  is  => 'ro',
  default => 1_000,
);

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

sub as_xml {
  my $self = shift;

  $self->pot;
  $self->trunk;
  my $width = TREE_WIDTH;
  my $tri_bottom = $self->height - $self->pot_height - $self->trunk_length;
  for (1 .. $self->layers) {
    my $h = $self->triangle(TOP_ANGLE, $width, $tri_bottom);
    $self->bauble($self->mid_y - ($width/2), $tri_bottom);
    $self->bauble($self->mid_y + ($width/2), $tri_bottom);
    $width *= 5/6;
    $tri_bottom -= ($h * .5)
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
  # If I remember my trig correctlt...
  my $height = ($base / 2) / tan($top_angle);

  $x = [ $self->mid_y - ($base / 2), $self->mid_y, $self->mid_y + ($base / 2) ];
  $y = [ $bottom, $bottom - $height, $bottom ];

  $self->coloured_shape(
    $x, $y, $self->leaf_colour,
  );

  return $height;
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
