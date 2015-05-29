#!/bin/sh

if [ "$(ps ax | grep asterisk | grep -v grep | wc -l)" -gt 1 ] ; then

	SZ_FILE="/etc/voneto/remparo-sz.cfg.built"

	SZ="SAFE_ZONE=\"\n"

	MODLIST=$(asterisk -rx "module show like chan_" | grep ^chan_ | awk '{print $1}')

	for MOD in $MODLIST ; do
		if [[ "$MOD" == *chan_sip* ]] ; then

			for IP in $(asterisk -rx "sip show peers" | awk '{print $2}' | grep ^[0-9] | sort -u) ; do
				SZ+="\t$IP\n"
			done

		elif [[ "$MOD" == *chan_pjsip* ]] ; then

			for IP in $(asterisk -rx "pjsip show endpoints" | egrep 'Match:|Contact:|Identify:' | awk '{print $2}' | grep ^[0-9] | sed 's/.*\/sip:.*@//g;s/\/32//;s/:.*//' | sort -u) ; do
				SZ+="\t$IP\n"
			done

		fi
	done

	SZ+="\""

	echo -e "$SZ" > "${SZ_FILE}"

	echo -e \\v"==========================="
	echo -e "Generated Safe Zone saved at:"\\v
	echo -e "${SZ_FILE}"\\v
	echo -e "rename it to \"$(echo ${SZ_FILE} | sed 's/\.built//g')\" to make active."
	echo -e "==========================="\\v
	exit 0

else

	echo -e \\v"==========================="
	echo -e "Asterisk doesn't appear to be running."
	echo -e "Unable to build a peers Safe Zone.  Bailing...\\v"
	echo -e "==========================="\\v
	exit 1
fi
