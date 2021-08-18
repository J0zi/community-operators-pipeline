#!/bin/bash
TIMESTAMP='20210818T0000000'
#SOURCE_INDEXES=( 'quay.io/community-operators-pipeline/catalog:v4.8' 'quay.io/community-operators-pipeline/catalog:v4.7' 'quay.io/community-operators-pipeline/catalog:v4.6' )
BASE_INDEX="quay.io/openshift-community-operators/catalog"
VERSIONS="v4.6 v4.7 v4.8"
CONTAINER_TOOL="docker"

rm /tmp/bundles

for INDEX in $VERSIONS
do
IDENTIFIER=$RANDOM
echo "IDENTIFIER=$IDENTIFIER"
$CONTAINER_TOOL pull $BASE_INDEX:$INDEX
$CONTAINER_TOOL rm -f $INDEX
$CONTAINER_TOOL create --name $INDEX $BASE_INDEX:$INDEX
$CONTAINER_TOOL cp $INDEX:/database/index.db /tmp/$INDEX.db
sqlite3 /tmp/"$INDEX".db   'select bundlepath from operatorbundle' >> /tmp/bundles

done

head /tmp/bundles
echo "."
tail /tmp/bundles
date
#cat /tmp/bundles|grep ecl |sort|uniq| xargs -n1 -P10 -I {}  crane copy {} {}--$TIMESTAMP
cat /tmp/bundles|sort|uniq| xargs -n1 -P10 -I {}  crane copy {} {}--$TIMESTAMP
date
#IFS=$'\r\n' GLOBIGNORE='*' command eval  'BUNDLE_LIST=($(cat /tmp/bundles|sort|uniq))'
#IFS=$'\r\n' GLOBIGNORE='*' command eval  'BUNDLE_LIST=($(cat /tmp/bundles|sort|uniq|head -n 2))'
#
#for BUNDLE in "${BUNDLE_LIST[@]}"; do
#  echo; echo "${BUNDLE}--$TIMESTAMP"
#  crane copy $BUNDLE "${BUNDLE}--$TIMESTAMP"
##Crane (https://github.com/google/go-containerregistry/blob/master/cmd/crane/doc/crane.md) offers a lot of the same functionality as skopeo, but has a binary release available as part of the tarballs at https://github.com/google/go-containerregistry/releases
#done