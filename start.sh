#!/bin/bash

BASEDIR="$( cd "$( dirname "$0" )" && pwd)"
RUNDIR="$BASEDIR"/run
DBDIR="$RUNDIR"/db
LOGDIR="$RUNDIR"/log

KEY="$RUNDIR"/key
SYSCONFIG="$RUNDIR"/etc/sys.config

ERL=erl
NAME="openacd@127.0.0.1"
COOKIE=oucxdevcookie

mkdir -p "$RUNDIR"
mkdir -p "$DBDIR"
mkdir -p "$LOGDIR"

export OPENACD_RUN_DIR="$RUNDIR"

if [ ! -f "$KEY" ]; then
	echo "RSA key does not exist, generating..."
	ssh-keygen -t rsa -f "$KEY" -N ""
	RES=$?
	if [ $RES != 0 ]; then
		echo "Key generation failed with error $RES!"
		exit $RES
	fi
fi

if [ ! -f "$SYSCONFIG" ]; then
	mkdir -p `dirname $SYSCONFIG`

	CONFIGNODENAME=`erl -eval "io:format(\"~s\",[node()]),halt(1)" -name $NAME -noshell`
	cat > "$SYSCONFIG" <<EOF
[{'OpenACD', [
	{nodes, ['$CONFIGNODENAME']}
	, {console_loglevel, info}
	, {logfiles, [{"$LOGDIR/openacd.log", debug}]}
	, {plugins, `cat enabled_plugins | sed -e "s:\.$::g"`}
]},
{sasl, [
	{errlog_type, error} % disable SASL progress reports
]}].
EOF

fi

ERL_LIBS="$BASEDIR"/deps:"$BASEDIR"/core:"$BASEDIR"/plugins:$ERL_LIBS
exec erl -s openacd -config "$SYSCONFIG" -name "$NAME"
