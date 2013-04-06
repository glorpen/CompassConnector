from os.path import dirname, join
import re
import sys

passed = 0
failed = 0

f = join(dirname(__file__),"out","css","app.css")
print 'Testing file "%s"' % f

with open(f,"rt") as f:
	data = f.read()
	
	def assert_match(pattern):
		global failed, passed
		
		_pattern = re.sub(r"([\(\)])",r"\\\1", pattern)
		
		if re.search(_pattern, data) is None:
			print 'Failed test: "%s"' % pattern
			failed+=1
		else:
			passed+=1
			
	for test in re.findall(r"/\*\s@test (.*?)[ \t]*\*/\w*$", data, re.MULTILINE):
		assert_match(test)
	
print "Passed tests:\t%d\nFailed tests:\t%d" % (passed, failed)
