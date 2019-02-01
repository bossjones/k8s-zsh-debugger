# MOTD - message of the day

# Get the column size of the terminal.
# Responsive terminal design? Yes.
COLUMNS=$(tput cols)

# Select a random file from .motd/ and display it.
MOTD_FILE="$(print -l ~/.motd/**/*(.) | sort -R | tail -n 1)"

if [ "$COLUMNS" -le 40 ]; then
	clear
elif [ "$COLUMNS" -le 80 ]; then
	clear
else
	echo "$(cat $MOTD_FILE)"
fi
