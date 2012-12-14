//
//  controllerLogic.h
// This code is distributed under the GNU General
// Public License, version 2 (or at your option any later version). See
// http://www.gnu.org/ for further details of the GPL. */
// Code version 1.1

#import <Cocoa/Cocoa.h>
@interface controllerLogic : NSObject {
	NSStatusItem *trayItem;
	NSMenu *trayMenu;
	NSImage *trayImageRunning;
	NSImage *trayImageNotRunning;
	NSImage *trayHighlightImage;
	NSMenuItem *startStopToggle;
	NSMenuItem *webInterfaceOption;
	NSMenuItem *quitItem;
    NSMenuItem *aboutPanel;
	NSMutableURLRequest *nodeRequest;
}

- (void)startFreenet:(id)sender;
- (void)stopFreenet:(id)sender;
- (void)openWebInterface:(id)sender;
- (void)showAboutPanel:(id)sender;
- (void)checkNodeStatus:(id)sender;
- (void)nodeRunning:(id)sender;
- (void)nodeNotRunning:(id)sender;
- (void)initializeSystemTray:(id)sender;
- (void)quitProgram:(id)sender;
uint sleep();
- (void) addLoginItem;
@end
