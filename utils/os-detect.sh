#!/usr/bin/env bash

detect_os() {
  if [ -f /etc/arch-release ]; then
    echo "arch"
  elif [ -f /etc/os-release ] && grep -q "Ubuntu 24.04" /etc/os-release; then
    echo "ubuntu"
  else
    echo "unsupported"
    exit 1
  fi
}
