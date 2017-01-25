# set frame rate
xset r rate 200 40 &

# turn brightness down a 5%
#xrandr --output VGA1 --brightness 0.95 &

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
hsetroot -fill /home/werle/backgrounds/nyc-dark-blue.jpg

# compose i3 config
/home/werle/repos/config/config/i3/compile

# launch i3
exec i3
