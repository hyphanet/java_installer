/* 
    Copyright (C) 2015 Stephen Oliver <steve@infincia.com>
    
    This code is distributed under the GNU General Public License, version 2.
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/

#import "FNNodeController.h"

#import "FNFCPWrapper.h"

@interface FNNodeController()
@property FNFCPWrapper *fcpWrapper;
@end

@implementation FNNodeController
 
- (instancetype)init {
    self = [super init];
    if (self) {
        self.currentNodeState = FNNodeStateUnknown;
        self.fcpWrapper = [[FNFCPWrapper alloc] init];
        self.fcpWrapper.delegate = self;
        self.fcpWrapper.dataSource = self;
        [self.fcpWrapper nodeStateLoop];
        // spawn a thread to keep the node status indicator updated in realtime. The method called here cannot be run again while this thread is running
        [NSThread detachNewThreadSelector:@selector(checkNodeStatus) toTarget:self withObject:nil];
    }
    return self;
}

- (void)checkNodeStatus {

	//get users preferred location of node files and put it in a string
	NSString *nodeFilesLocation = (NSString*)[[[NSUserDefaults standardUserDefaults] objectForKey:FNNodeInstallationDirectoryKey] stringByStandardizingPath];
	//make a new string to store the absolute path of the anchor file
	NSString *anchorFile = [NSString stringWithFormat:@"%@%@", nodeFilesLocation, @"/Freenet.anchor"];
	//NSLog(@"%@", anchorFile);
	// start a continuous loop to set the status indicator, this whole method (checkNodeStatus) should be started from a separate thread so it doesn't block main app
	while (1) {
        @autoreleasepool {
		//file manager for reading anchor file
			NSFileManager *fileManager;
			fileManager = [NSFileManager defaultManager];
			//if the anchor file exists, the node should be running.
			if([fileManager isReadableFileAtPath:anchorFile]) {
				/* 
                If we find the anchor file we we send an FNNodeStateRunningNotification 
                event and save the node state here.
                
                This can be a false positive, the node may be stopped even if 
                this file exists, but normally it should be accurate.
            */
            self.currentNodeState = FNNodeStateRunning;
				[[NSNotificationCenter defaultCenter] postNotificationName:FNNodeStateRunningNotification object:nil];
			}
			else {
				/* 
                Otherwise we send a FNNodeStateNotRunningNotification event and
                save the node state here.
                 
                This should be 100% accurate, the node won't run without that 
                anchor file being present
            */
            self.currentNodeState = FNNodeStateNotRunning;
				[[NSNotificationCenter defaultCenter] postNotificationName:FNNodeStateNotRunningNotification object:nil];
			}
        }
		[NSThread sleepForTimeInterval:FNNodeCheckTimeInterval]; 
	}
	
}

- (void)startFreenet {
	//get users preferred location of node files and put it in a string
	NSString *nodeFilesLocation = (NSString*)[[[NSUserDefaults standardUserDefaults] objectForKey:FNNodeInstallationDirectoryKey] stringByStandardizingPath];
	//make a new string to store the absolute path to the run script
	NSString *runScript = [NSString stringWithFormat:@"%@%@", nodeFilesLocation, @"/run.sh start"];
	
	//make a new string to store the absolute path of the anchor file
    NSString *anchorFile = [NSString stringWithFormat:@"%@%@", nodeFilesLocation, @"/Freenet.anchor"];
	//NSLog(@"%@", anchorFile);
    
	//load arguments into an array for use later by run.sh script
	NSArray * startArguments = [NSArray arrayWithObjects:@"-c",runScript,nil];
	
    //file manager for reading anchor file
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	if([fileManager isReadableFileAtPath:anchorFile]) {
		// user wants to start freenet, but anchor file is already there. Either node crashed or node file location is wrong.
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Error"];
		[alert setInformativeText:@"Your node is already running!"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
	}	
	else {
		//nstask to start freenet
        [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:startArguments];
    }
	
}

- (void)stopFreenet {
	//get users preferred location of node files and put it in a string	
	NSString *nodeFilesLocation = (NSString*)[[[NSUserDefaults standardUserDefaults] objectForKey:FNNodeInstallationDirectoryKey] stringByStandardizingPath];
	//make a new string to store the absolute path of the anchor file
	NSString *anchorFile = [NSString stringWithFormat:@"%@%@", nodeFilesLocation, @"/Freenet.anchor"];
	//NSLog(@"%@", anchorFile);
	//make a new string to store the absolute path to the stop script
	NSString *stopScript = [NSString stringWithFormat:@"%@%@", nodeFilesLocation, @"/run.sh stop"];
	//load arguments into an array for use later by run.sh script
	NSArray *stopArguments = [NSArray arrayWithObjects:@"-c", stopScript, nil];
	//file manager for reading anchor file
	NSFileManager *fileManager;
	fileManager = [NSFileManager defaultManager];
	if([fileManager isReadableFileAtPath:anchorFile]) {
		// since we found the anchor file and the user wants to stop freenet, we set an NSTask to delete the file, which should cause the node to stop
        [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:stopArguments];
    
    } else {
		//if user wants to stop freenet but anchor file doesn't exist, either node isn't running or files aren't where they should be. Either way we can't do anything but throw an error box up on the screen
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Error"];
		[alert setInformativeText:@"Your freenet node was not running!"];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert runModal];
    }
}

#pragma mark - FNFCPWrapperDelegate methods

-(void)didReceiveNodeHello:(NSDictionary *)nodeHello {
    //NSLog(@"Node hello: %@", nodeHello);
}

-(void)didReceiveNodeStats:(NSDictionary *)nodeStats {
    [[NSNotificationCenter defaultCenter] postNotificationName:FNNodeStatsReceivedNotification object:nodeStats];
}

#pragma mark - FNFCPWrapperDataSource methods

-(NSURL *)nodeFCPURL {
    NSString *nodeFCPURLString = [[NSUserDefaults standardUserDefaults] valueForKey:FNNodeFCPURLKey];
    return [NSURL URLWithString:nodeFCPURLString];
}

@end
