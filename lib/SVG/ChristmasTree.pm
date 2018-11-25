package SVG::ChristmasTree;

use strict;
use warnings;

use Moose;
use namespace::autoclean;
use SVG;
use Math::Trig qw[deg2rad tan];

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

sub as_xml {
  my $self = shift;

  $self->pot;
  $self->trunk;
  my $width = 600;
  my $tri_bottom = 700;
  for (1 .. $self->layers) {
    my $h = $self->triangle(90, $width, $tri_bottom);
    $self->bauble(500 - ($width/2), $tri_bottom);
    $self->bauble(500 + ($width/2), $tri_bottom);
    $width *= 5/6;
    $tri_bottom -= ($h * .5)
  }

  return $self->svg->xmlify;
}

sub pot {
  my $self = shift;
  $self->coloured_shape(
    [  400, 350, 650,  600 ],
    [ 1000, 800, 800, 1000 ],
    $self->pot_colour,
  );
}

sub trunk {
  my $self = shift;

  $self->coloured_shape(
    [ 450, 450, 550, 550 ],
    [ 800, 700, 700, 800 ],
    $self->trunk_colour,
  );
}

sub triangle {
  my $self = shift;
  my ($top_angle, $base, $bottom) = @_;

  my ($x, $y);

  my $height = $base;

  if ($top_angle) {
    $top_angle = deg2rad($top_angle) / 2;
    $height = ($base / 2) / tan($top_angle);
  }

  $x = [ 500 - ($base / 2), 500, 500 + ($base / 2) ];
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
    cy => $y + 20,
    r => 20,
    style => {
      fill => $self->bauble_colour,
      stroke => $self->bauble_colour,
    },
  );
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
  )
}

1;
