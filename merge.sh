#!/bin/bash
# if you modify check with https://www.shellcheck.net/
set -eu
set -o pipefail

function usage {
  echo '
usage:
  '"$0"' <path-to-mp4-files> <output-dir>
will identify all files that looks like they are part of a recording 
(using the timestamp in the filename) and stich them together.
It will create a video "ride_<original-timestamp>_full.mp4" in the output directory
set DRY_RUN to no create any files
  ' >&2
  exit 1
}

[[ $# -eq 2 ]] || usage
echo "working on $1"
cd "$1"
echo "output in $2"
OUTDIR="$2"
[[ -z "${DRY_RUN-}" ]] || echo dry-run mode >&2
find . -name  "*A.mp4" -print |sed 's|^\./||'|sort|perl -MTime::Piece -ne 'chomp; 
  $file = $_; 
  ($date,$time) = $file =~ /^([0-9]{8})_([0-9]{6})A\.mp4/;
  if(defined $date && defined $time) { 
    $time = $date.$time; 
    $t = Time::Piece->strptime($time,"%Y%m%d%H%M%S");
    $diff = $t-$t_last;
    #print STDERR "$diff\n";
    if(defined $t_last &&
      ($diff<=325)){
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
  }
  END{
        print join(" ",@files)."\n";
  }
'  |  while read -r i
do
  echo "i=$i"
  IFS=" " read -r -a ar <<< "$i"
  TARGET=$OUTDIR/${ar[0]}  
  ar=("${ar[@]:1}")
  if [ -f "$TARGET" ]
  then
    echo "$TARGET found will skip"
  else
    echo  "creating $TARGET from ${ar[*]}"
    if [[ -z "${DRY_RUN-}" ]]
    then   
      ffmpeg -nostdin -f concat -safe 0 -i <(for f in "${ar[@]}"; do echo "file '$PWD/$f'"; done) -c copy "$TARGET"
    fi
    #for some reason the above creates truncated file names as the output
    # I work around that by creating a script using the below.
    #echo "ffmpeg -f concat -safe 0 -i <(for f in ""${ar[@]}""; do echo \"file '$PWD/\$f'\"; done) -c copy '$PWD/$TARGET'"
    #echo $(for f in "${ar[@]}"; do echo "file '$PWD/$f'"; done) copy $TARGET
  fi
done
