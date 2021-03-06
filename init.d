#! /bin/sh
#
# ejabberd        Start/stop ejabberd server
#

### BEGIN INIT INFO
# Provides:          ejabberd
# Required-Start:    $remote_fs $network
# Required-Stop:     $remote_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts ejabberd jabber server
# Description:       Starts ejabberd jabber server, an XMPP
#                    compliant server written in Erlang.
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin
EJABBERD=/usr/sbin/ejabberd
EJABBERDCTL=/usr/sbin/ejabberdctl
EJABBERDUSER=ejabberd
NAME=ejabberd

test -f $EJABBERD || exit 0
test -f $EJABBERDCTL || exit 0

# Include ejabberd defaults if available
if [ -f /etc/default/ejabberd-snapshot ] ; then
    . /etc/default/ejabberd-snapshot
fi

ctl()
{
    action="$1"
    su $EJABBERDUSER -c "$EJABBERDCTL $action" >/dev/null
}

start()
{
    cd /var/lib/ejabberd
    su $EJABBERDUSER -c "$EJABBERD -noshell -detached"

    cnt=0
    while ! (ctl status || test $? = 1) ; do
	echo -n .
	cnt=`expr $cnt + 1`
	if [ $cnt -ge 60 ] ; then
	    echo -n " failed"
	    break
	fi
	sleep 1
    done
}

stop()
{
    if ctl stop ; then
	cnt=0
	sleep 1
	while ctl status || test $? = 1 ; do
	    echo -n .
	    cnt=`expr $cnt + 1`
	    if [ $cnt -ge 60 ] ; then
		echo -n " failed"
		break
	    fi
	    sleep 1
	done
    else
	echo -n " failed"
    fi
}

case "$1" in
    start)
	echo -n "Starting jabber server: $NAME"
	if ctl status ; then
	    echo -n " already running"
	else
	    start
	fi
    ;;
    stop)
	echo -n "Stopping jabber server: $NAME"
	if ctl status ; then
	    stop
	else
	    echo -n " already stopped"
	fi
    ;;
    restart|force-reload)
	echo -n "Restarting jabber server: $NAME"
	if ctl status ; then
	    stop
	    start
	else
	    echo -n " is not running. Starting $NAME"
	    start
	fi
    ;;
    *)
	echo "Usage: $0 {start|stop|restart|force-reload}" >&2
	exit 1
    ;;
esac

if [ $? -eq 0 ]; then
    echo .
else
    echo " failed."
fi

exit 0

