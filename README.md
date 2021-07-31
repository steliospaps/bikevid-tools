# about
My bikecam continously records in 3 or 5 minute intervals.

I sync to my computer using a command like:

```
rsync -va /media/$USER/UDISK/ ~/Videos/Videos_raw/bikecam/
```
# requirements
  - ffmepg
  - perl
  - bash
# merge the files

```
./merge.sh ~/Videos/Videos_raw/bikecam/video/ ~/Videos/Videos_raw/
```

# upload to youtube
TODO: https://github.com/tokland/youtube-upload