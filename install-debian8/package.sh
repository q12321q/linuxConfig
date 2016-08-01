#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install curl \
                     python \
                     python-dev \
                     python-pip \
                     python3 \
                     python3-dev \
                     python3-pip

# Python package
sudo pip3 install jedi \
                  flake8
