#!/bin/bash
#
# - Download a tarball of the typesense repo
# - Apply our patches
# - Build the dev docker image
# - Build the deployment docker image.
#

set -ex

TYPESENSE_REPO=main
APPLY_SCRIPT=apply.sh

echo "Checking that we are in the correct directory."
if [ -f "$APPLY_SCRIPT" ]; then
    echo "$APPLY_SCRIPT exists."
else
    echo "$APPLY_SCRIPT not in CWD, exiting."
    exit -1
fi

rm -Rf build
mkdir build
cd build
curl -L  "https://github.com/typesense/typesense/tarball/${TYPESENSE_REPO}" -o typesense.tgz
tar -zxvf typesense.tgz
mv typesense-typesense-* typesense
cd typesense
patch docker/development.Dockerfile ../../patches/development.Dockerfile.diff
patch docker-build.sh ../../patches/docker-build.sh.patch
cp ../../patches/CMakeLists.txt.* docker/patches
sudo rm -Rf build-Linux/
sudo rm -Rf external-Linux/
docker build --file docker/development.Dockerfile --tag typesense/typesense-development:nightly docker/
TYPESENSE_VERSION=nightly ./docker-build.sh --build-deploy-image --create-binary --clean --depclean
