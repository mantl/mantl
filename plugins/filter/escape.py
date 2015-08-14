# -*- encoding: utf-8 -*-
"""regex filter plugin to escape passwords, etc"""
import re

def escape(string):
    return re.escape(string)


class FilterModule(object):
    def filters(self):
        return {
            'escape': escape
        }
