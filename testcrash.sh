#!/bin/sh
export KAKOUNE_CONFIG_DIR=$PWD
kak -e "execute-keys <pagedown><pagedown><pagedown><pagedown>" UsefulMod.patch
