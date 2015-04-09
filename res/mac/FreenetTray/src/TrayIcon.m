/* 
    Copyright (C) 2015 Stephen Oliver <steve@infincia.com>
    
    This code is distributed under the GNU General Public License, version 2.
    
    3rd party libraries may be distributed under an alternate Open Source license.
    
    See the LICENSE file included with this code for details.
    
*/

#import "TrayIcon.h"


@implementation TrayIcon

#pragma mark Cache

static NSImage* _imageOfRunningIcon = nil;
static NSImage* _imageOfNotRunningIcon = nil;
static NSImage* _imageOfHighlightedIcon = nil;

#pragma mark Initialization

+ (void)initialize
{
}

#pragma mark Drawing Methods

+ (void)drawRunningIcon
{
    //// Color Declarations
    NSColor* run = [NSColor colorWithCalibratedRed: 0.161 green: 0.322 blue: 0.765 alpha: 1];

    //// Group
    {
        //// BlueBunny Drawing
        NSBezierPath* blueBunnyPath = NSBezierPath.bezierPath;
        [blueBunnyPath moveToPoint: NSMakePoint(9.93, 12.35)];
        [blueBunnyPath curveToPoint: NSMakePoint(12.14, 11.7) controlPoint1: NSMakePoint(14.19, 16.89) controlPoint2: NSMakePoint(17.09, 14.87)];
        [blueBunnyPath curveToPoint: NSMakePoint(12.04, 10.56) controlPoint1: NSMakePoint(10.57, 10.69) controlPoint2: NSMakePoint(10.98, 10.4)];
        [blueBunnyPath curveToPoint: NSMakePoint(14.71, 10.22) controlPoint1: NSMakePoint(13.53, 10.78) controlPoint2: NSMakePoint(14.35, 10.5)];
        [blueBunnyPath curveToPoint: NSMakePoint(16.3, 10.56) controlPoint1: NSMakePoint(15.58, 9.55) controlPoint2: NSMakePoint(16.01, 10.05)];
        [blueBunnyPath curveToPoint: NSMakePoint(17.41, 9.42) controlPoint1: NSMakePoint(16.88, 11.57) controlPoint2: NSMakePoint(18.84, 10.47)];
        [blueBunnyPath curveToPoint: NSMakePoint(17.46, 7.13) controlPoint1: NSMakePoint(16.29, 8.59) controlPoint2: NSMakePoint(16.44, 7.67)];
        [blueBunnyPath curveToPoint: NSMakePoint(22.94, 2.09) controlPoint1: NSMakePoint(19.34, 6.14) controlPoint2: NSMakePoint(23.57, 4.18)];
        [blueBunnyPath curveToPoint: NSMakePoint(21.15, 1.52) controlPoint1: NSMakePoint(22.68, 1.24) controlPoint2: NSMakePoint(22.21, 0.44)];
        [blueBunnyPath curveToPoint: NSMakePoint(13.25, 5.99) controlPoint1: NSMakePoint(19.16, 3.55) controlPoint2: NSMakePoint(17.83, 5.28)];
        [blueBunnyPath curveToPoint: NSMakePoint(4.46, 5.78) controlPoint1: NSMakePoint(10.29, 6.45) controlPoint2: NSMakePoint(7.31, 7.21)];
        [blueBunnyPath curveToPoint: NSMakePoint(1.06, 5.46) controlPoint1: NSMakePoint(3.11, 5.08) controlPoint2: NSMakePoint(1.42, 4.62)];
        [blueBunnyPath curveToPoint: NSMakePoint(5.3, 7.65) controlPoint1: NSMakePoint(0.59, 6.54) controlPoint2: NSMakePoint(2.98, 7.43)];
        [blueBunnyPath curveToPoint: NSMakePoint(6.09, 9.26) controlPoint1: NSMakePoint(6.8, 7.79) controlPoint2: NSMakePoint(8.15, 8.77)];
        [blueBunnyPath curveToPoint: NSMakePoint(8.3, 11.7) controlPoint1: NSMakePoint(3.55, 10.03) controlPoint2: NSMakePoint(6.47, 12.23)];
        [blueBunnyPath curveToPoint: NSMakePoint(9.93, 12.35) controlPoint1: NSMakePoint(9.49, 11.36) controlPoint2: NSMakePoint(9.61, 12.01)];
        [blueBunnyPath closePath];
        [blueBunnyPath setMiterLimit: 4];
        [run setFill];
        [blueBunnyPath fill];
        [run setStroke];
        [blueBunnyPath setLineWidth: 1];
        [blueBunnyPath stroke];
    }
}

+ (void)drawNotRunningIcon
{
    //// Color Declarations
    NSColor* stop = [NSColor colorWithCalibratedRed: 1 green: 0 blue: 0 alpha: 1];

    //// Group
    {
        //// RedBunny Drawing
        NSBezierPath* redBunnyPath = NSBezierPath.bezierPath;
        [redBunnyPath moveToPoint: NSMakePoint(9.93, 12.35)];
        [redBunnyPath curveToPoint: NSMakePoint(12.14, 11.7) controlPoint1: NSMakePoint(14.19, 16.89) controlPoint2: NSMakePoint(17.09, 14.87)];
        [redBunnyPath curveToPoint: NSMakePoint(12.04, 10.56) controlPoint1: NSMakePoint(10.57, 10.69) controlPoint2: NSMakePoint(10.98, 10.4)];
        [redBunnyPath curveToPoint: NSMakePoint(14.71, 10.22) controlPoint1: NSMakePoint(13.53, 10.78) controlPoint2: NSMakePoint(14.35, 10.5)];
        [redBunnyPath curveToPoint: NSMakePoint(16.3, 10.56) controlPoint1: NSMakePoint(15.58, 9.55) controlPoint2: NSMakePoint(16.01, 10.05)];
        [redBunnyPath curveToPoint: NSMakePoint(17.41, 9.42) controlPoint1: NSMakePoint(16.88, 11.57) controlPoint2: NSMakePoint(18.84, 10.47)];
        [redBunnyPath curveToPoint: NSMakePoint(17.46, 7.13) controlPoint1: NSMakePoint(16.29, 8.59) controlPoint2: NSMakePoint(16.44, 7.67)];
        [redBunnyPath curveToPoint: NSMakePoint(22.94, 2.09) controlPoint1: NSMakePoint(19.34, 6.14) controlPoint2: NSMakePoint(23.57, 4.18)];
        [redBunnyPath curveToPoint: NSMakePoint(21.15, 1.52) controlPoint1: NSMakePoint(22.68, 1.24) controlPoint2: NSMakePoint(22.21, 0.44)];
        [redBunnyPath curveToPoint: NSMakePoint(13.25, 5.99) controlPoint1: NSMakePoint(19.16, 3.55) controlPoint2: NSMakePoint(17.83, 5.28)];
        [redBunnyPath curveToPoint: NSMakePoint(4.46, 5.78) controlPoint1: NSMakePoint(10.29, 6.45) controlPoint2: NSMakePoint(7.31, 7.21)];
        [redBunnyPath curveToPoint: NSMakePoint(1.06, 5.46) controlPoint1: NSMakePoint(3.11, 5.08) controlPoint2: NSMakePoint(1.42, 4.62)];
        [redBunnyPath curveToPoint: NSMakePoint(5.3, 7.65) controlPoint1: NSMakePoint(0.59, 6.54) controlPoint2: NSMakePoint(2.98, 7.43)];
        [redBunnyPath curveToPoint: NSMakePoint(6.09, 9.26) controlPoint1: NSMakePoint(6.8, 7.79) controlPoint2: NSMakePoint(8.15, 8.77)];
        [redBunnyPath curveToPoint: NSMakePoint(8.3, 11.7) controlPoint1: NSMakePoint(3.55, 10.03) controlPoint2: NSMakePoint(6.47, 12.23)];
        [redBunnyPath curveToPoint: NSMakePoint(9.93, 12.35) controlPoint1: NSMakePoint(9.49, 11.36) controlPoint2: NSMakePoint(9.61, 12.01)];
        [redBunnyPath closePath];
        [redBunnyPath setMiterLimit: 4];
        [stop setFill];
        [redBunnyPath fill];
        [stop setStroke];
        [redBunnyPath setLineWidth: 1];
        [redBunnyPath stroke];
    }
}

+ (void)drawHighlightedIcon
{
    //// Color Declarations
    NSColor* highlight = [NSColor colorWithCalibratedRed: 1 green: 1 blue: 1 alpha: 1];

    //// Group
    {
        //// WhiteBunny Drawing
        NSBezierPath* whiteBunnyPath = NSBezierPath.bezierPath;
        [whiteBunnyPath moveToPoint: NSMakePoint(9.93, 12.35)];
        [whiteBunnyPath curveToPoint: NSMakePoint(12.14, 11.7) controlPoint1: NSMakePoint(14.19, 16.89) controlPoint2: NSMakePoint(17.09, 14.87)];
        [whiteBunnyPath curveToPoint: NSMakePoint(12.04, 10.56) controlPoint1: NSMakePoint(10.57, 10.69) controlPoint2: NSMakePoint(10.98, 10.4)];
        [whiteBunnyPath curveToPoint: NSMakePoint(14.71, 10.22) controlPoint1: NSMakePoint(13.53, 10.78) controlPoint2: NSMakePoint(14.35, 10.5)];
        [whiteBunnyPath curveToPoint: NSMakePoint(16.3, 10.56) controlPoint1: NSMakePoint(15.58, 9.55) controlPoint2: NSMakePoint(16.01, 10.05)];
        [whiteBunnyPath curveToPoint: NSMakePoint(17.41, 9.42) controlPoint1: NSMakePoint(16.88, 11.57) controlPoint2: NSMakePoint(18.84, 10.47)];
        [whiteBunnyPath curveToPoint: NSMakePoint(17.46, 7.13) controlPoint1: NSMakePoint(16.29, 8.59) controlPoint2: NSMakePoint(16.44, 7.67)];
        [whiteBunnyPath curveToPoint: NSMakePoint(22.94, 2.09) controlPoint1: NSMakePoint(19.34, 6.14) controlPoint2: NSMakePoint(23.57, 4.18)];
        [whiteBunnyPath curveToPoint: NSMakePoint(21.15, 1.52) controlPoint1: NSMakePoint(22.68, 1.24) controlPoint2: NSMakePoint(22.21, 0.44)];
        [whiteBunnyPath curveToPoint: NSMakePoint(13.25, 5.99) controlPoint1: NSMakePoint(19.16, 3.55) controlPoint2: NSMakePoint(17.83, 5.28)];
        [whiteBunnyPath curveToPoint: NSMakePoint(4.46, 5.78) controlPoint1: NSMakePoint(10.29, 6.45) controlPoint2: NSMakePoint(7.31, 7.21)];
        [whiteBunnyPath curveToPoint: NSMakePoint(1.06, 5.46) controlPoint1: NSMakePoint(3.11, 5.08) controlPoint2: NSMakePoint(1.42, 4.62)];
        [whiteBunnyPath curveToPoint: NSMakePoint(5.3, 7.65) controlPoint1: NSMakePoint(0.59, 6.54) controlPoint2: NSMakePoint(2.98, 7.43)];
        [whiteBunnyPath curveToPoint: NSMakePoint(6.09, 9.26) controlPoint1: NSMakePoint(6.8, 7.79) controlPoint2: NSMakePoint(8.15, 8.77)];
        [whiteBunnyPath curveToPoint: NSMakePoint(8.3, 11.7) controlPoint1: NSMakePoint(3.55, 10.03) controlPoint2: NSMakePoint(6.47, 12.23)];
        [whiteBunnyPath curveToPoint: NSMakePoint(9.93, 12.35) controlPoint1: NSMakePoint(9.49, 11.36) controlPoint2: NSMakePoint(9.61, 12.01)];
        [whiteBunnyPath closePath];
        [whiteBunnyPath setMiterLimit: 4];
        [highlight setFill];
        [whiteBunnyPath fill];
        [highlight setStroke];
        [whiteBunnyPath setLineWidth: 1];
        [whiteBunnyPath stroke];
    }
}

#pragma mark Generated Images

+ (NSImage*)imageOfRunningIcon
{
    if (_imageOfRunningIcon)
        return _imageOfRunningIcon;

    _imageOfRunningIcon = [NSImage.alloc initWithSize: NSMakeSize(24, 16)];
    [_imageOfRunningIcon lockFocus];
    [TrayIcon drawRunningIcon];

    [_imageOfRunningIcon unlockFocus];

    return _imageOfRunningIcon;
}

+ (NSImage*)imageOfNotRunningIcon
{
    if (_imageOfNotRunningIcon)
        return _imageOfNotRunningIcon;

    _imageOfNotRunningIcon = [NSImage.alloc initWithSize: NSMakeSize(24, 16)];
    [_imageOfNotRunningIcon lockFocus];
    [TrayIcon drawNotRunningIcon];

    [_imageOfNotRunningIcon unlockFocus];

    return _imageOfNotRunningIcon;
}

+ (NSImage*)imageOfHighlightedIcon
{
    if (_imageOfHighlightedIcon)
        return _imageOfHighlightedIcon;

    _imageOfHighlightedIcon = [NSImage.alloc initWithSize: NSMakeSize(24, 16)];
    [_imageOfHighlightedIcon lockFocus];
    [TrayIcon drawHighlightedIcon];

    [_imageOfHighlightedIcon unlockFocus];

    return _imageOfHighlightedIcon;
}

@end
