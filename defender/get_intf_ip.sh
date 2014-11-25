#!/bin/bash
ifconfig $1 | grep "inet addr:" | sed -e 's/inet addr://g' | awk '{ print $1 }'
