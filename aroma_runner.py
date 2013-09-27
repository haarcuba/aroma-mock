#!/usr/bin/env python
import subprocess
import argparse
import re
import os

class Main( object ):
	def __init__( self, suiteDirectory, root, tests ):
		self._suiteDirectory = suiteDirectory
		self._root = root
		if len( tests ) > 0:
			self._files = tests
		else:
			self._files = self._scan()
		self._go()
		print "OK!"

	def _scan( self ):
		PATTERN = re.compile( '_test.coffee$' )
		result = []
		for currentDir, unused, filenames in os.walk( self._root ):
			for filename in filenames:
				match = PATTERN.search( filename )
				if match is not None:
					path = os.path.join( currentDir, filename )
					result.append( path )
		return result

	def _go( self ):
		for file in self._files:
			print 'running %s' % file
			environment = dict( os.environ )
			environment[ 'NODE_PATH' ] = '.:%s' % self._suiteDirectory
			result = subprocess.call( [ 'coffee', file ], env = environment, close_fds = True )
			if result != 0:
				raise Exception( "%s failed!" % file )
		
if __name__ == '__main__':
	parser = argparse.ArgumentParser( description = "I'm the Aroma runner, I run all the Aroma unit tests I can find.\n"\
													"You can specify specific tests or let me search for them" )
	parser.add_argument( 'suiteDirectory', help = '(e.g. suite/) directory where the Aroma test suite *.coffee files are located' )
	parser.add_argument( '--root', default = '.', help = "root of tree to walk looking for tests, default = .", metavar = 'DIRECTORY' )
	parser.add_argument( 'tests', nargs = '*', help = "test suites to run" )
	arguments = parser.parse_args()
	Main( arguments.suiteDirectory, arguments.root, arguments.tests )
