#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2016 Carles Amigó <fr3nd@fr3nd.net>
#
# Distributed under terms of the MIT license.

import sys

last_word = None

count = 0
for line in sys.stdin:
    word, n = line.split()
    if word != last_word and last_word is not None:
        print last_word, count
        count = int(n)
    else:
        count = int(n) + count
    last_word = word
