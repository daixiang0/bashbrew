#!/usr/bin/env bash

HUB_URL="159.138.0.63:30003"
NAMESPACE=${HUB_URL}
LIBRARY="/root/library"
USERNAME="admin"
PASSWORD="Harbor12345"
BASHBREW="bashbrew --library ${LIBRARY} --hub-address ${HUB_URL}"

OFFICIAL_SUPPORT_ARCHES="
amd64
arm32v6
arm32v7
arm64v8
windows-amd64
"

OTHER_SUPPORT_ARCHES="
arm32v5
ppc64le
s390x
mips64le
i386
"

function build {
  # build with prefix namespace for each arch
  for arch in ${OFFICIAL_SUPPORT_ARCHES}; do
    ${BASHBREW} --namespace ${NAMESPACE}/library/${arch} --arch ${arch} build --all
  done
}

function put_shared {
  local map_flag
  for arch in ${OFFICIAL_SUPPORT_ARCHES}; do
    map_flag+="--arch-namespace ${arch}=${NAMESPACE}/library/${arch} "
  done

  ${BASHBREW} --namespace ${NAMESPACE}/library ${map_flag} put-shared --username ${USERNAME} --password ${PASSWORD} --all
}

function login {
  docker login ${HUB_URL} --username ${USERNAME} --password ${PASSWORD}
}

function push {

  ${BASHBREW} --namespace ${NAMESPACE} push --all

  for arch in ${OFFICIAL_SUPPORT_ARCHES}; do
    ${BASHBREW} --namespace ${NAMESPACE}/library/${arch} --arch ${arch} push --all
  done
}

set -x

build

login

push

put_shared
