#!/usr/bin/env bash
# shellcheck disable=SC2129

# Author: VSCODIUM-EXPERT
# Date: 2026-03-29
# Description: Force build for Kullisa Stage.

set -e

export SHOULD_BUILD="yes"
export SHOULD_DEPLOY="yes"
export RELEASE_VERSION="1.112.02066"

# For GitHub Actions environment variables
if [[ "${GITHUB_ENV}" ]]; then
  echo "SHOULD_BUILD=${SHOULD_BUILD}" >> "${GITHUB_ENV}"
  echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}" >> "${GITHUB_ENV}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
fi

echo "Kullisa Stage: Version fixed to ${RELEASE_VERSION}. Starting build."

exit 0
