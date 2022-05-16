#!/bin/sh -eux

## determine the major EL version we're runninng
major_version="`sed 's/^.\+ release \([.0-9]\+\).*/\1/' /etc/redhat-release | awk -F. '{print $1}'`";

# make sure we use dnf on EL 8+
if [ "$major_version" -ge 8 ]; then
  pkg_cmd="dnf"
else
  pkg_cmd="yum"
fi

echo "Kernel updating"
$pkg_cmd -y update kernel

reboot;
sleep 60;
