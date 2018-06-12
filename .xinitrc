
# vim: set syntax=sh:
# set frame rate
xset r rate 200 40 &

# launch mpd if not already running
pgrep mpd &>/dev/null || mpd

# set cursor name
xsetroot -cursor_name left_ptr

# set font paths
xset +fp /usr/share/fonts/local
xset +fp /usr/share/fonts/bitmap
xset +fp /usr/share/fonts/artwiz-fonts
xset +fp $HOME/.fonts
xset fp rehash

# set background image
#hsetroot -fill /home/werle/backgrounds/beautiful-green-nature-surreal.jpg
#hsetroot -full /home/werle/backgrounds/split.jpg
hsetroot -full /home/werle/backgrounds/sea.jpg

# compose i3 config
/home/werle/repos/config/config/i3/compile
/home/werle/repos/config/config/i3/polybar/run

ID=$(xinput list | grep TouchPad | awk '{print $6}' | tr -d 'id=' | xargs echo -n)
xinput set-prop $ID "libinput Natural Scrolling Enabled" 1
xinput set-prop $ID "libinput Tapping Enabled" 1
xinput set-prop $ID 'libinput Accel Speed' 1

# launch libinput
exec libinput-gestures &

# launch i3
exec i3
