#!/usr/bin/env bash

# Run this script from within the test folder

PYTHONPATH=$PYTHONPATH:inventory/:../plugins/inventory python -m unittest discover inventory