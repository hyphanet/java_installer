//
//  UKLoginItemRegistry.m
//  TalkingMoose (XC2)
//
//  Created by Uli Kusterer on 14.03.06.
//  Copyright 2006 M. Uli Kusterer. All rights reserved.
//
/*Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.
* Neither the name of the <organization> nor the
names of its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY PAUL BETTS ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <copyright holder> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*/

#import "UKLoginItemRegistry.h"


@implementation UKLoginItemRegistry

+(NSArray*)	allLoginItems
{
	NSArray*	itemsList = nil;
	OSStatus	err = LIAECopyLoginItems( (CFArrayRef*) &itemsList );	// Take advantage of toll-free bridging.
	if( err != noErr )
	{
		NSLog(@"Couldn't list login items error %ld", err);
		return nil;
	}
	
	return [itemsList autorelease];
}

+(BOOL)		addLoginItemWithURL: (NSURL*)url hideIt: (BOOL)hide			// Main bottleneck for adding a login item.
{
	OSStatus err = LIAEAddURLAtEnd( (CFURLRef) url, hide );	// CFURLRef is toll-free bridged to NSURL.
	
	if( err != noErr )
		NSLog(@"Couldn't add login item error %ld", err);
	
	return( err == noErr );
}


+(BOOL)		removeLoginItemAtIndex: (int)idx			// Main bottleneck for getting rid of a login item.
{
	OSStatus err = LIAERemove( idx );
	
	if( err != noErr )
		NSLog(@"Couldn't remove login intem error %ld", err);
	
	return( err == noErr );
}


+(int)		indexForLoginItemWithURL: (NSURL*)url		// Main bottleneck for finding a login item in the list.
{
	NSArray*		loginItems = [self allLoginItems];
	NSEnumerator*	enny = [loginItems objectEnumerator];
	NSDictionary*	currLoginItem = nil;
	int				x = 0;
	
	while(( currLoginItem = [enny nextObject] ))
	{
		if( [[currLoginItem objectForKey: UKLoginItemURL] isEqualTo: url] )
			return x;
		
		x++;
	}
	
	return -1;
}

+(int)		indexForLoginItemWithPath: (NSString*)path
{
	NSURL*	url = [NSURL fileURLWithPath: path];
	
	return [self indexForLoginItemWithURL: url];
}

+(BOOL)		addLoginItemWithPath: (NSString*)path hideIt: (BOOL)hide
{
	NSURL*	url = [NSURL fileURLWithPath: path];
	
	return [self addLoginItemWithURL: url hideIt: hide];
}


+(BOOL)		removeLoginItemWithPath: (NSString*)path
{
	int		idx = [self indexForLoginItemWithPath: path];
	
	return (idx != -1) && [self removeLoginItemAtIndex: idx];	// Found item? Remove it and return success flag. Else return NO.
}


+(BOOL)		removeLoginItemWithURL: (NSURL*)url
{
	int		idx = [self indexForLoginItemWithURL: url];
	
	return (idx != -1) && [self removeLoginItemAtIndex: idx];	// Found item? Remove it and return success flag. Else return NO.
}

@end
