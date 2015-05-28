# -*- coding: utf-8 -*-
import pytest
import sys
import os


@pytest.yield_fixture(autouse=True)
def pathify():
    path = os.path.abspath(os.path.join(
        os.path.dirname(__file__),  # here
        '..', '..', '..',  # root
        'plugins', 'inventory',  # location of terraform.py
    ))

    sys.path.append(path)
    yield
    sys.path = [p for p in sys.path if p != path]
