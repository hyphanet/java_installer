/* 
    This code is distributed under the GNU General Public License, version 2 
    (or at your option any later version).
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/

@import Cocoa;
@class FNNodeController;

@interface FNDropdownMenuController : NSObject <FNNodeStateProtocol>

@property (retain) FNNodeController *nodeController;

@property (retain) NSStatusItem *statusItem;

@property (retain) IBOutlet NSMenu *dropdownMenu;
@property (retain) IBOutlet NSMenuItem *toggleNodeStateMenuItem;


-(IBAction)toggleNodeState:(id)sender;
-(IBAction)openWebInterface:(id)sender;
-(IBAction)showAboutPanel:(id)sender;

@end
