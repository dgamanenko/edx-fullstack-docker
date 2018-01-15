set -e
set -o pipefail
set -x

docker run --rm --volumes-from edx.fullstack.elasticsearch -v $(pwd)/.dev/backups:/backup debian:jessie tar zxvf /backup/elasticsearch.tar.gz

