#!/usr/bin/env bash
awww --help > /tmp/awww_help.txt 2>&1
awww-client --help >> /tmp/awww_help.txt 2>&1
which awww >> /tmp/awww_help.txt 2>&1
