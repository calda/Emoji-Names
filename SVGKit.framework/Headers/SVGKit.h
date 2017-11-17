/*!
 
 SVGKit - https://github.com/SVGKit/SVGKit
 
 THE MOST IMPORTANT ELEMENTS YOU'LL INTERACT WITH:
 
 1. SVGKImage = contains most of the convenience methods for loading / reading / displaying SVG files
 2. SVGKImageView = the easiest / fastest way to display an SVGKImage on screen
 3. SVGKLayer = the low-level way of getting an SVG as a bunch of layers
 
 SVGKImage makes heavy use of the following classes - you'll often use these classes (most of them given to you by an SVGKImage):
 
 4. SVGKSource = the "file" or "URL" for loading the SVG data
 5. SVGKParseResult = contains the parsed SVG file AND/OR the list of errors during parsing
 
 */

#include "TargetConditionals.h"

#define V_1_COMPATIBILITY_COMPILE_CALAYEREXPORTER_CLASS 0

#import "SVGKImage.h"

#ifndef SVGKIT_LOG_CONTEXT
    #define SVGKIT_LOG_CONTEXT 556
#endif

@interface SVGKit : NSObject

+ (void) enableLogging;

@end





// MARK: - Framework Header File Content

#import <UIKit/UIKit.h>

//! Project version number for SVGKitFramework-iOS.
FOUNDATION_EXPORT double SVGKitFramework_VersionNumber;

//! Project version string for SVGKitFramework-iOS.
FOUNDATION_EXPORT const unsigned char SVGKitFramework_VersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SVGKitFramework_iOS/PublicHeader.h>


#import "SVGKImage.h"
