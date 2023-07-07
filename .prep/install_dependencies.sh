#!/bin/bash

sudo apt-get install git python3-pip libffi-dev build-essential python3-poetry -y --no-install-recommends
poetry install --no-dev
