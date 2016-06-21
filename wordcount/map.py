#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2016 Carles Amigó <fr3nd@fr3nd.net>
#
# Distributed under terms of the MIT license.

import sys
import string

for line in sys.stdin:
    for word in line.strip().translate(string.maketrans("", ""),
                                       string.punctuation).lower().split():
        if word != '':
            print word, 1
