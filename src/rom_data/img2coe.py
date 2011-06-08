#!/usr/bin/env python

import sys
import Image

i = Image.open(sys.argv[1]).convert('L')
assert i.size == (128, 128)
print 'memory_initialization_radix=2;'
print 'memory_initialization_vector='
for y in xrange(128):
    for x in xrange(128):
        if x + y > 0:
            print ','
        pixel = i.getpixel((x,y))
        assert pixel in [0,255]
        if pixel == 255:
            print 0,
        else:
            print 1,
print ';'
