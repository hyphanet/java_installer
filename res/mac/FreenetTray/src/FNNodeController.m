/* 
    This code is distributed under the GNU General Public License, version 2 
    (or at your option any later version).
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/

#import "FNNodeController.h"
#import "NSBundle+LoginItem.h"

@implementation FNNodeController
 
- (instancetype)init {
    self = [super init];
    if (self) {
        // spawn a thread to keep the node status indicator updated in realtime. The method called here cannot be run again while this thread is running
        [NSThread detachNewThreadSelector:@selector(checkNodeStatus:) toTarget:self withObject:nil];
        //start the tray item
        [self initializeSystemTray:nil];
    }
    return self;
}

- (void) addLoginItem {
    [[NSBundle mainBundle] addToLoginItems];
}

- (void)initializeSystemTray:(id)sender {
	// load some images into memory
	trayImageRunning = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FreenetTray-Running-24" ofType:@"png"]];
	trayImageNotRunning = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FreenetTray-NotRunning-24" ofType:@"png"]];
	trayHighlightImage = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FreenetTray-Selected-24" ofType:@"png"]];
	// create an NSMenu to hold our menu options, and populate it with our initial items
	// this is not the best way to create a GUI, but there are only a few items so it isn't necessary to use interface builder
	// there are some strange bugs/behavior when you try to modify NSMenuItems that were created in interface builder, so these are created in code instead
	trayMenu = [[[NSMenu alloc] initWithTitle:@""] retain];
	// this item is changed later on in reaction to the node status
	startStopToggle = [trayMenu addItemWithTitle: @"Start Freenet"  
						action: @selector (startFreenet:)  
				 keyEquivalent: @"s"];
	// opens the node url in the users default browser
	webInterfaceOption = [trayMenu addItemWithTitle: @"Open Web Interface"  
											 action: @selector (openWebInterface:)  
									  keyEquivalent: @"w"];
	[trayMenu addItem:[NSMenuItem separatorItem]];
	//not currently implemented so commented out
	//preferencesOption = [trayMenu addItemWithTitle: @"Preferences"  
	//										action: @selector (openPreferences:)  
	//								 keyEquivalent: @"p"];
	// opens the standard about panel with info sourced from the info.plist file
	aboutPanel = [trayMenu addItemWithTitle: @"About"  
                                     action: @selector (showAboutPanel:)  
									  keyEquivalent: @"a"];
	// ends the program
	quitItem = [trayMenu addItemWithTitle: @"Quit"  
								   action: @selector (quitProgram:)  
							keyEquivalent: @"q"];
	// create an NSStatusItem and load some images, strings and variables into it. Icon size area is square, but can be made to fit longer images
    trayItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	// sets the image that will be displayed when the menu bar item is clicked
	[trayItem setAlternateImage:trayHighlightImage];
	//no title
	[trayItem setTitle:@""];
	[trayItem setToolTip:@"Freenet Menu"];
	// this can be turned off if highlighting isn't needed
	[trayItem setHighlightMode:YES];
	// set our previously created NSMenu to be the main menu of this NSStatusItem
	[trayItem setMenu:trayMenu];
	// enable our NSStatusItem
	[trayItem setEnabled:YES];
}

-(void)nodeRunning:(id)sender {
	//node was running so change the image to reflect that
	[trayItem setImage:trayImageRunning];
	//change the title of the main menu option
	[startStopToggle setTitle:@"Stop Freenet"];
	// change the action of the main menu option
	[startStopToggle setAction:@selector(stopFreenet:)];
}

-(void)nodeNotRunning:(id)sender {
	//node was not running so set image accordingly 
	[trayItem setImage:trayImageNotRunning];
	//change the title of the main menu option
	[startStopToggle setTitle:@"Start Freenet"];
	// change the action of the main menu option
	[startStopToggle setAction:@selector(startFreenet:)];
}

- (void)checkNodeStatus:(id)sender {

	//get users preferred location of node files and put it in a string
	NSString *nodeFilesLocation = (NSString*)[[[NSUserDefaults standardUserDefaults] objectForKey:FNNodeInstallationDirectoryKey] stringByStandardizingPath];
	//make a new string to store the absolute path of the anchor file
	NSString *anchorFile = [NSString stringWithFormat:@"%@%@", nodeFilesLocation, @"/Freenet.anchor"];
	//NSLog(@"%@", anchorFile);
	// start a continuous loop to set the status indicator, this whole method (checkNodeStatus) should be started from a separate thread so it doesn't block main app
	while (1) {
        NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
		//file manager for reading anchor file
		NSFileManager *fileManager;
		fileManager = [NSFileManager defaultManager];
		//if the anchor file exists, the node should be running.
		if([fileManager isReadableFileAtPath:anchorFile]) {
			// if we find the anchor file we run the NodeRunning method, this can be a false positive, node may be stopped even if this file exists
			[self performSelectorOnMainThread:@selector(nodeRunning:) withObject:nil waitUntilDone:NO];
		}
		else {
			// otherwise we run NodeNotRunning which will display the Not Running image to the user, this should be 100% reliable, the node won't run without that anchor file
			[self performSelectorOnMainThread:@selector(nodeNotRunning:) withObject:nil waitUntilDone:NO];
		}
        [autoreleasepool release];
		[NSThread sleepForTimeInterval:5]; 
	}
	
}

- (void)startFreenet:(id)sender {
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
		[alert release];
	}	
	else {
		//nstask to start freenet
        [NSTask launchedTaskWithLaunchPath:@"/bin/sh" arguments:startArguments];
    }
	
}

- (void)stopFreenet:(id)sender {
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
		[alert release];
    }
}

- (void)openWebInterface:(id)sender {
	//load the URL of our node from the preferences
	NSString *nodeURL = [[NSUserDefaults standardUserDefaults] valueForKey:FNNodeURLKey];
	// This is a method to open the fproxy page in users default browser.
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:nodeURL]];
}

-(void)showAboutPanel:(id)sender {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:sender];
}

- (void) dealloc {
	[trayMenu release];
	[trayItem release];
	[super dealloc];
}

- (void)quitProgram:(id)sender {
	[NSApp terminate:self];
}

@end
