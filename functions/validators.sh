#!/usr/bin/env bash

_is_spositive_int () { [[ $1 =~ ^[1-9]+$ ]] }  # 's' means 'strictly'

_is_positive_int () { [[ $1 =~ ^[0-9]+$ ]] }

_is_int () { [[ $1 =~ ^-?[0-9]+$ ]] }