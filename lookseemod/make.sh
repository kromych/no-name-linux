#!/bin/bash

export KBUILD_OUTPUT=../build/linux
export KCONFIG_CONFIG=../build/linux/.config

make
