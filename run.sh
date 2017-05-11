make all

if type google-chrome >/dev/null 2>&1; then
	google-chrome index.html;
elif type firefox >/dev/null 2>&1; then
	firefox index.html;
else
	xdg-open index.html;
fi
