# about
My bikecam continously records in 3 or 5 minute intervals.

I sync to my computer and stitch the videos together:

```
~/bin/bikesync.sh
```

the script relies on the fact that my cameras have a different directory `UDISK` vs `ESCAPE 4W`.

# installation

git clone in a directory of your choocing.
Cd in that directory.
I assume `~/bin/` exists and is in your path

```
ln -s $(pwd)/bikesync.sh ~/bin/
```

Edit the bikesync.sh and set the names of the cameras and their aliases.
You can also modify the stagging locations.

# requirements
  - ffmepg
  - perl
  - bash
# merge the files

```
./merge.sh ~/Videos/Videos_raw/bikecam/video/ ~/Videos/Videos_raw/ "postfix"
```

# upload to youtube
TODO: https://github.com/tokland/youtube-upload