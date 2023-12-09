#!/usr/bin/env perl 
##---------------------------------------------------------------------------##
##  File:
##      @(#) tetoolsDfamUpdate
##  Author:
##      Robert Hubley <rhubley@systemsbiology.org>
##  Description:
##      A configuration utility for the RepeatMasker distribution.
##
#******************************************************************************
#* Copyright (C) Institute for Systems Biology 2003-2023 Developed by
#* Robert Hubley.
#*
#* This work is licensed under the Open Source License v2.1.  To view a copy
#* of this license, visit http://www.opensource.org/licenses/osl-2.1.php or
#* see the license.txt file contained in this distribution.
#*
###############################################################################

=head1 NAME

tetoolsDfamUpdate - Configure the TETools RepeatMasker distribution with updated database

=head1 SYNOPSIS

  perl ./tetoolsDfamUpdate.pl

=head1 DESCRIPTION

  A one-off tool to support the update of RepeatMasker 4.1.6 (and Dfam 3.8) in
  the TETools container.  This should be used with a map'd library directory
  per instructions TETools project page.

=head1 CONFIGURATION OVERRIDES

=head1 SEE ALSO

=over 4

RepeatMasker

=back

=head1 COPYRIGHT

Copyright 2003-2023 Robert Hubley, Institute for Systems Biology

=head1 AUTHOR

Robert Hubley <rhubley@systemsbiology.org>

=cut

#
# Module Dependence
#
use strict;
use Config;
use Cwd;
use FindBin;
use Getopt::Long;
use Pod::Text;
use Data::Dumper;
use lib $FindBin::Bin;
use RepeatMaskerConfig;
use POSIX qw(:sys_wait_h);

# No output buffering
$|=1;

#
# Release Version
#
my $version = $RepeatMaskerConfig::VERSION;
my $df_version = $RepeatMaskerConfig::DFAM_VERSION;

#
# First...make sure we are running in the same directory
# as the script is located.  This avoids problems where
# this script ends up in someones path and they run it
# unqualified from another installation directory.
#
if ( getcwd() ne $FindBin::RealBin ) {
  print "\n    The RepeatMasker configure script must be run from\n"
      . "    inside the RepeatMasker installation directory:\n\n"
      . "       $FindBin::RealBin\n\n"
      . "    Perhaps this is not the \"configure\" you are looking for?\n\n";
  exit;
}

#
# Option processing
#  e.g.
#   -t: Single letter binary option
#   -t=s: String parameters
#   -t=i: Number parameters
#
my @getopt_args = ( '-version', '-perlbin=s' );

# Add configuration parameters as additional command-line options
push @getopt_args, RepeatMaskerConfig::getCommandLineOptions();

#
# Get the supplied command line options, and set flags
#
my %options = ();
Getopt::Long::config( "noignorecase", "bundling_override" );
unless ( GetOptions( \%options, @getopt_args ) ) {
  usage();
}

sub usage {
  print "$0\n";
  exec "pod2text $0";
  exit( 1 );
}

#
# Resolve configuration settings using the following precedence: 
# command line first, then environment, followed by config
# file.
#
RepeatMaskerConfig::resolveConfiguration(\%options);
my $config = $RepeatMaskerConfig::configuration;

my $rmLocation = "$FindBin::Bin";
if ( -d "$rmLocation/Libraries" &&
     $config->{'LIBDIR'}->{'value'} eq "" ){
  $config->{'LIBDIR'}->{'value'} = $rmLocation . "/Libraries";
}
if ( ! RepeatMaskerConfig::validateParam('LIBDIR') ) {
  RepeatMaskerConfig::promptForParam('LIBDIR');
}

my $LIBDIR = $config->{'LIBDIR'}->{'value'};
my $c_df_version = $df_version;
$c_df_version =~ s/\.//g;

print "\n\nChecking for libraries...\n\n";

# First check that we have a default library directory, if not try to create it
if ( ! -d "$LIBDIR/famdb" ) {
  print "  ** Creating library directory $LIBDIR/famdb **\n";
  mkdir("$LIBDIR/famdb");
}

## Handle error reporting if we suspect that the famdb folder is corrupt
if ( -e "$LIBDIR/famdb/merge.working" ) {
  my $dlTime = `cat $LIBDIR/famdb/merge.working`;
  die "It appears a previous attempt to merge Dfam and Repbase failed on $dlTime" . 
      "The files in $LIBDIR/famdb may be corrupt.\n" .
      "Please remove all files from this folder and rerun configure to retry.\n\n";
}  
 
if ( -e "$LIBDIR/famdb/download.working" ) {
  my $dlTime = `cat $LIBDIR/famdb/download.working`;
  die "It appears a previous attempt to automatically download Dfam $df_version failed on $dlTime" .
      "The files in $LIBDIR/famdb may not be complete.\n" .
      "Please remove all files from this folder and rerun configure to begin a new download.\n\n";
}  

# Check to see if there is an existing rmlib.config file (RepeatMasker's library configuration status file)
my $rmlibConfig = {};
if ( -e "$LIBDIR/famdb/rmlib.config" ) {
  $rmlibConfig = readConfig("$LIBDIR/famdb/rmlib.config");
}      
$rmlibConfig->{'famdb_files'} = {} if ( ! exists $rmlibConfig->{'famdb_files'} );

# Flag merging of repbase
my $hasRepbase = 0;
$hasRepbase = 1 if ( -s "$LIBDIR/RMRBSeqs.embl" );

# Now compare current files with previously processed files
my ( $hasFamDBRoot, $mergeRB, $rebuildRMLib, $gzip, $famdb_prefix ) = compareFiles( $LIBDIR, $rmlibConfig );


my $answer;
if ( ! $hasFamDBRoot ) {
  if ( $gzip ) {
    die "The FamDB database in $LIBDIR/famdb appears be compressed (gzipd).  Please uncompress the FamDB partitions and rerun configure.\n\n";
  }
  do { 
    print "   *** No libraries present ***\n\n";
    print "Choose:\n";
    print "   1. Download minimal Dfam df_version (partition 0) using wget or curl\n";
    print "      (please see https://dfam.org/releases/current/families/FamDB/README.txt for full list of Dfam partitions.)\n";
    print "   2. Exit and download libraries manually (Dfam $df_version or newer).\n";
    print "\n\nEnter Selection: ";
    $answer = <STDIN>;
    $answer =~ s/[\n\r]+//g;
  } while ( $answer ne "1" && $answer ne "2" );

  if ( $answer eq "2" ) {
    print "\n\nPlease download a copy of the Dfam database ( famdb HDF5 format )\n" . 
        "from: https://www.dfam.org/releases/Dfam_$df_version/families/FamDB\n\n" .
        "Minimally you may download just the root partition (file ending\n" .
        "with \"*.0.h5\"), uncompress it ( gunzip ), store in the\n" .
        "$LIBDIR/famdb folder,\n" .
        "and rerun the configure program. See\n" . 
        "  https://www.dfam.org/releases/Dfam_$df_version/families/FamDB/README\n" .
        "for more details on the taxanomic coverage of each partition.\n\n\n";
    exit(0);
  }
  system( "clear" );
  my $hasWget = `sh -c 'command -v wget'`;
  $hasWget =~ s/[\n\r]+//g;
  my $hasCurl = `sh -c 'command -v curl'`;
  $hasCurl =~ s/[\n\r]+//g;

  # Create a sentinel
  open OUT,">$LIBDIR/famdb/download.working" or die "Could not open $LIBDIR/famdb/download.working for writing!\n";
  print OUT "" . localtime() . "\n";
  close OUT;

  if ( $hasCurl ne "" ) {
    print "Downloading Dfam $df_version root partition using $hasCurl\n";
    system("$hasCurl https://www.dfam.org/releases/Dfam_$df_version/families/FamDB/dfam$c_df_version" ."_full.0.h5.gz -o $LIBDIR/famdb/dfam$c_df_version" ."_full.0.h5.gz");
    if ( $? ) {
      unlink("$LIBDIR/famdb/dfam$c_df_version" . "_full.0.h5.gz") if ( -e "$LIBDIR/famdb/dfam$c_df_version" . "_full.0.h5.gz" );
      unlink("$LIBDIR/famdb/download.working");
      die "curl failed to download https://www.dfam.org/releases/Dfam_$df_version/families/FamDB/dfam$c_df_version"."_full.0.h5.gz.\n" .
          "Please check your connnectivity and try again.\n";
    }
  }elsif ( $hasWget ne "" ) {
    print "Downloading Dfam $df_version root partition using $hasWget\n";
    system("$hasWget https://www.dfam.org/releases/Dfam_$df_version/families/FamDB/dfam$c_df_version" . "_full.0.h5.gz -O $LIBDIR/famdb/dfam$c_df_version" . "_full.0.h5.gz");
    if ( $? ) {
      unlink("$LIBDIR/famdb/dfam$c_df_version" . "_full.0.h5.gz") if ( -e "$LIBDIR/famdb/dfam$c_df_version" . "_full.0.h5.gz" );
      unlink("$LIBDIR/famdb/download.working");
      die "wget failed to download https://www.dfam.org/releases/Dfam_$df_version/families/FamDB/dfam$c_df_version"."_full.0.h5.gz.\n" .
          "Please check your connnectivity and try again.\n";
    }
  }else {
    print "Neither wget nor curl are in this users path.  Cannot automatically\n" .
        "download the Dfam database.\n\n" .
        "Please download a copy of the database ( famdb HDF5 format )\n" .
        "from: https://www.dfam.org/releases/Dfam_$df_version/families/FamDB\n" .
        "Minimally you may download just the root partition (file ending with \"*.0.h5\"),\n" .
        "uncompress it ( gunzip ), and store in $LIBDIR/famdb folder,\n" . 
        "and rerun the configure program. See\n" . 
        "      https://www.dfam.org/releases/Dfam_$df_version/families/FamDB/README\n" .
        "for more details on the taxanomic coverage of each partition.\n\n\n";
  }

  if ( -s "$LIBDIR/famdb/dfam$c_df_version"."_full.0.h5.gz" ) {
    print "Uncompressing Dfam $df_version root partition\n";
    defined(my $pid = fork) or die "Couldn't fork: $!";
    if (!$pid) { # Child
      system("gunzip $LIBDIR/famdb/dfam$c_df_version"."_full.0.h5.gz");
      exit;
    } else { # Parent
      while (! waitpid($pid, WNOHANG)) {
        sleep 2;
        print ".";
      }
    }
    print "\n";
  }else {
    die "Failed to download https://www.dfam.org/releases/Dfam_$df_version/families/FamDB/dfam_$c_df_version"."_full.0.h5.gz to the\n" .
        "$LIBDIR/famdb folder.  Please remove any files from this directory and manually download/uncompress\n" .
        "the Dfam FamDB partitions and restart configure.\n";
  }
  unlink("$LIBDIR/famdb/download.working");

  # re-compare current files with previously processed files
  ( $hasFamDBRoot, $mergeRB, $rebuildRMLib, $gzip, $famdb_prefix ) = compareFiles( $LIBDIR, $rmlibConfig );
}

# Installation scenarios
#  1: Both Dfam *and* RepBase RepeatMasker Edition
if ( $mergeRB ) {
    defined(my $pid = fork) or die "Couldn't fork: $!";
    if (!$pid) { # Child
      system("$FindBin::RealBin/addRepBase.pl -libdir $LIBDIR");
      exit;
    } else { # Parent
      while (! waitpid($pid, WNOHANG)) {
        sleep 2;
        print ".";
      }
    }
    print "\n";
    if ( -e "$LIBDIR/famdb/merge.working" ) {
      die "Merging RepBase failed!";
    }
    foreach my $partition ( keys( %{$rmlibConfig->{'famdb_files'}} ) ) {
      my @stat = stat("$LIBDIR/famdb/$partition");
      $rmlibConfig->{'famdb_files'}->{$partition}->{'repbase_merged'} = 1; 
      $rmlibConfig->{'famdb_files'}->{$partition}->{'size'} = $stat[7];
    }
#  2: Dfam partioned FamDB only
}else { 
  print " - Found a FamDB root partition\n\n";
}

my $dbInfo = `$rmLocation/famdb.py -i $LIBDIR/famdb info`;
writeConfig($rmlibConfig, "$LIBDIR/famdb/rmlib.config");

if ( $rebuildRMLib ) {
print "Building FASTA version of RepeatMasker.lib ...";

defined(my $pid = fork) or die "Couldn't fork: $!";
if (!$pid) { # Child
  # Anthony made a really fast version
  system("$rmLocation/famdb.py -i $rmLocation/Libraries/famdb fasta_all > $rmLocation/Libraries/RepeatMasker.lib");
  exit;
} else { # Parent
  while (! waitpid($pid, WNOHANG)) {
    sleep 2;
    print ".";
  }
}
print "\n";

}

#
# Freeze RMLIB/RepeatPeps library for RepeatModeler use among others
# 
if ( RepeatMaskerConfig::validateParam('RMBLAST_DIR') ) 
{
   my $binDir = $config->{'RMBLAST_DIR'}->{'value'};
   print "Building RMBlast frozen libraries..\n";
   system(   "$binDir/makeblastdb -dbtype nucl -in "
           . "$LIBDIR/RepeatMasker.lib > /dev/null 2>&1" );
   system(   "$binDir/makeblastdb -dbtype prot -in "
           . "$LIBDIR/RepeatPeps.lib > /dev/null 2>&1" );
}
if ( RepeatMaskerConfig::validateParam('ABBLAST_DIR') ) 
{
   my $binDir = $config->{'ABBLAST_DIR'}->{'value'};
   print "Building WUBlast/ABBlast frozen libraries..\n";
   system(   "$binDir/xdformat -n -I "
           . "$LIBDIR/RepeatMasker.lib > /dev/null 2>&1" );
   system(   "$binDir/xdformat -p -I "
           . "$LIBDIR/RepeatPeps.lib > /dev/null 2>&1" );
}

print "The program is installed with a the following repeat libraries:\n";
print "$dbInfo\n";

print "Further documentation on the program may be found here:\n";
print "  $rmLocation/repeatmasker.help\n\n";



sub readConfig {
  my $fileName     = shift;                                                
  my $fileContents = "";
  my $oldSep       = $/;
  undef $/;
  my $in;
  open $in, "$fileName";
  $fileContents = <$in>;
  $/            = $oldSep;
  close $in;
  return eval( $fileContents );
}

sub writeConfig {
  my $data     = shift;
  my $fileName = shift;

  my $data_dumper = new Data::Dumper( [ $data ] );
  $data_dumper->Purity( 1 )->Terse( 1 )->Deepcopy( 1 );
  open OUT, ">$fileName";
  print OUT $data_dumper->Dump();
  close OUT;
}

sub compareFiles {
  my $LIBDIR = shift;
  my $rmlibConfig = shift;

  my $hasFamDBRoot = 0;
  my $famdb_prefix = "";
  my @famdb_files = ();
  my $mergeRB = 0;
  my $rebuildRMLib = 0;
  my $gzip = 0;
  $rmlibConfig->{'files'} = ();
  my %seen = ();
  opendir DIR, "$LIBDIR/famdb" or die "Could not open $LIBDIR/famdb directory\n";
  while ( my $entry = readdir(DIR) ) {
    next if ( $entry =~ /^\.+$/ || -d "$LIBDIR/famdb/$entry" );
    push @{$rmlibConfig->{'files'}}, $entry;
    if ( -s "$LIBDIR/famdb/$entry" && $entry =~ /(\S+)\.(\d+)\.h5$/ ) {
      $seen{$entry} = 1;
      # FamDB file
      if ( $famdb_prefix ne "" && $famdb_prefix ne $1 ) {
         die "There appears to be more than one FamDB database in the $LIBDIR/famdb directory: $famdb_prefix and $1\n\n";
      }
      $famdb_prefix = $1;
      if ( $2 eq "0" ) {
        $hasFamDBRoot = 1;
      }
  
      my @stat = stat("$LIBDIR/famdb/$entry");
      if ( exists $rmlibConfig->{'famdb_files'}->{$entry} &&
          $rmlibConfig->{'famdb_files'}->{$entry}->{'size'} != $stat[7] ) {
        die "There appears to be a problem with the FamDB database.  The file $entry has changed size from $rmlibConfig->{'famdb_files'}->{$entry}->{'size'} to $stat[7]. Please remove all files from this directory, download (at a minimum) the root partition of a FamDB database, and re-run configure.\n\n";
      } elsif ( exists $rmlibConfig->{'famdb_files'}->{$entry} ) {
        if ( $hasRepbase && ! exists $rmlibConfig->{'famdb_files'}->{$entry}->{'repbase_merged'} )
        {
          $mergeRB = 1;
          $rebuildRMLib = 1;
        }
      }else {
        if ( $hasRepbase ) {
          $mergeRB = 1
        }
        $rebuildRMLib = 1;
        $rmlibConfig->{'famdb_files'}->{$entry} = {};
        $rmlibConfig->{'famdb_files'}->{$entry}->{'size'} = $stat[7];
      }
    }elsif ( -s "$LIBDIR/famdb/$entry" && $entry =~ /(\S+)\.(\d+)\.h5.gz/ ) {
      $gzip = 1;
    }
  }
  # If a partition is deleted make sure we rebuild the RMlib accordingly
  foreach my $partition ( keys( %{$rmlibConfig->{'famdb_files'}} ) ) {
    if ( ! exists $seen{$partition} ) {
      delete $rmlibConfig->{'famdb_files'}->{$partition};
      $rebuildRMLib = 1;
    }
  }
  closedir(DIR);
  return ( $hasFamDBRoot, $mergeRB, $rebuildRMLib, $gzip, $famdb_prefix ); 
}


1;
