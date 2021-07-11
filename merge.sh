#!/bin/bash
set -eu
set -o pipefail

function usage {
  echo '
usage:
  '$0' <path-to-mp4-files>
will identify all files that looks like they are part of a recording 
(using the timestamp in the filename) and stich them together.
It will create a video "ride_<original-timestamp>_full.mp4" in the original directory
  ' >&2
  exit 1
}

[[ $# -eq 1 ]] || usage
echo "working on $1"
cd "$1"

ls *A.mp4 |perl -MTime::Piece -ne 'chomp; 
  $file = $_; 
  ($date,$time) = $file =~ /([0-9]{8})_([0-9]{6})/; 
  $time = $date.$time; 
  $t = Time::Piece->strptime($time,"%Y%m%d%H%M%S");
  $diff = $t-$t_last;
  #print "$diff\n";
  if(defined $t_last &&
    ($diff<=305)){
    push @files, $file;
  } else {
    print join(" ",@files)."\n" unless @files == 0;
    $target_file = $file;
    $target_file =~ s/A\.mp4$/_full.mp4/;
    $target_file = "ride_".$target_file;
    @files=($target_file,$file);
  };
  $last_time=$time;
  $t_last=$t;
  END{
        print join(" ",@files)."\n";
  }
' |  while read i
do
  #echo got: $i
  ar=($i)
  TARGET=${ar[0]}
  ar=("${ar[@]:1}")
  if [ -f "$PWD/$TARGET" ]
  then
    echo $TARGET found will skip
  else
    echo $TARGET
    #echo  creating $TARGET " from " "${ar[@]}"
    #echo ffmpeg ffmpeg -f concat -safe 0 -i <(for f in ./*.wav; do echo "file '$PWD/$f'"; done) -c copy output.wav
    ffmpeg -f concat -safe 0 -i <(for f in "${ar[@]}"; do echo "file '$PWD/$f'"; done) -c copy "$PWD/$TARGET" > /dev/null
    #echo $(for f in "${ar[@]}"; do echo "file '$PWD/$f'"; done) copy $TARGET
  fi
done