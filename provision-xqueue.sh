set -e
set -o pipefail
set -x

if [ "$RUN_MIGRATINS" == 0 ]; then
	if [ "$DB_PROVISION" == 1 ]; then
        # Load database dumps
         echo -e "${GREEN}Load xqueue database dump"
        ./load-db.sh xqueue
    fi
fi
