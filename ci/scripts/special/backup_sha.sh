#!/bin/bash
TIMESTAMP='20210817T0000003'
SOURCE_INDEXES=( 'quay.io/community-operators-pipeline/catalog:v4.8' 'quay.io/community-operators-pipeline/catalog:v4.7' 'quay.io/community-operators-pipeline/catalog:v4.6' )
CONTAINER_TOOL="docker"

rm /tmp/bundles

for INDEX in "${SOURCE_INDEXES[@]}"
do
IDENTIFIER=$RANDOM
echo "IDENTIFIER=$IDENTIFIER"
$CONTAINER_TOOL pull $INDEX
$CONTAINER_TOOL create --name $IDENTIFIER $INDEX
$CONTAINER_TOOL cp $IDENTIFIER:/database/index.db /tmp/$IDENTIFIER.db
sqlite3 /tmp/"$IDENTIFIER".db   'select bundlepath from operatorbundle' >> /tmp/bundles

done

head /tmp/bundles
echo "."
tail /tmp/bundles

IFS=$'\r\n' GLOBIGNORE='*' command eval  'BUNDLE_LIST=($(cat /tmp/bundles|sort|uniq))'
#IFS=$'\r\n' GLOBIGNORE='*' command eval  'BUNDLE_LIST=($(cat /tmp/bundles|sort|uniq|head -n 2))'

for BUNDLE in "${BUNDLE_LIST[@]}"; do
  echo; echo "${BUNDLE}--$TIMESTAMP"
  crane copy $BUNDLE "${BUNDLE}--$TIMESTAMP"
#Crane (https://github.com/google/go-containerregistry/blob/master/cmd/crane/doc/crane.md) offers a lot of the same functionality as skopeo, but has a binary release available as part of the tarballs at https://github.com/google/go-containerregistry/releases
done