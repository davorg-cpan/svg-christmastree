use ExtUtils::MakeMaker;

WriteMakefile(
  NAME => 'SVG::ChristmasTree',
  VERSION_FROM => 'lib/SVG/ChristmasTree.pm',
  LICENSE      => 'perl_5',
  MIN_PERL_VERSION => '5.10.0',

  BUILD_REQUIRES => {
    'Test::More' => 0,
    'ExtUtils::MakeMaker' => 0,
    SVG => 0,
    Moose => 0,
    'MooseX::Getopt' => 0,
    POSIX => 0,
    'Math::Trig' => 0,
    'namespace::autoclean' => 0,
  },
  PREREQ_PM => {
    SVG => 0,
    Moose => 0,
    'MooseX::Getopt' => 0,
    POSIX => 0,
    'Math::Trig' => 0,
    'namespace::autoclean' => 0,
  },
  META_MERGE => {
    'meta-spec' => { version => 2 },
    resources => {
      repository => {
        type => 'git',
        url => 'git://github.com/davorg/svg-christmastree.git',
        web => 'https://github.com/davorg/svg-christmastree',
      },
    },
  },
  EXE_FILES => [ 'bin/tree' ],
);
