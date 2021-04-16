import sys

import RtlabApi as r


print "script begin"
print "Python: %s" % sys.version
print "RT-LAB: %s" % r.GetRtlabVersion()[0]
print "script end"