/* 
    This code is distributed under the GNU General Public License, version 2 
    (or at your option any later version).
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/

@import Cocoa;

@interface FNNodeController : NSObject {
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
- (void) addLoginItem;
@end
