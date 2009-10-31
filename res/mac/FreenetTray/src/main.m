//
//  main.m
// This code is distributed under the GNU General
// Public License, version 2 (or at your option any later version). See
// http://www.gnu.org/ for further details of the GPL. */
// Code version 1.1

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	return NSApplicationMain(argc,  (const char **) argv);
	[pool release];
}

