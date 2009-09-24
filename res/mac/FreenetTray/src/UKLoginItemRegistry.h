//
//  UKLoginItemRegistry.h
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

// -----------------------------------------------------------------------------
//	Headers:
// -----------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "LoginItemsAE.h"

/*
	This class is a wrapper around Apple's LoginItemsAE sample code.
	
	allLoginItems returns an array of dictionaries containing the URL of the
	login item under key UKLoginItemURL and the launch hidden status under
	UKLoginItemHidden.
	
	All methods that return a BOOL generally return YES on success and NO on
	failure.
*/

// -----------------------------------------------------------------------------
//	Constants:
// -----------------------------------------------------------------------------

#define UKLoginItemURL		((NSString*)kLIAEURL)
#define UKLoginItemHidden	((NSString*)kLIAEHidden)


// -----------------------------------------------------------------------------
//	Class Declaration:
// -----------------------------------------------------------------------------

@interface UKLoginItemRegistry : NSObject
{

}

+(NSArray*)	allLoginItems;
+(BOOL)		removeLoginItemAtIndex: (int)idx;

+(BOOL)		addLoginItemWithURL: (NSURL*)url hideIt: (BOOL)hide;
+(int)		indexForLoginItemWithURL: (NSURL*)url;		// Use this to detect whether you've already been set, if needed.
+(BOOL)		removeLoginItemWithURL: (NSURL*)url;

+(BOOL)		addLoginItemWithPath: (NSString*)path hideIt: (BOOL)hide;
+(int)		indexForLoginItemWithPath: (NSString*)path;	// Use this to detect whether you've already been set, if needed.
+(BOOL)		removeLoginItemWithPath: (NSString*)path;

@end
