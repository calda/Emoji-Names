/*
 SVGKImage
 
 The main class in SVGKit - this is the one you'll normally interact with
 
 c.f. SVGKit.h for more info on using SVGKit
 
 What is an SVGKImage?
 
 An SVGKImage is as close to "the SVG version of a UIImage" as we could possibly get. We cannot
 subclass UIImage because Apple has defined UIImage as immutable - and SVG images actually change
 (each time you zoom in, we want to re-render the SVG as a higher-resolution set of pixels)
 
 We use the exact same method names as UIImage, and try to be literally as identical as possible.

 Creating an SVGKImage:
 
 - PREFERRED: use the "imageNamed:" method
 - CUSTOM SVGKSource class: use the "initWithSource:" method
 - CUSTOM PARSING: Parse using SVGKParser, then send the parse-result to "initWithParsedSVG:"
 
 
 Data:
 - UIImage: not supported yet: will be a cached UIImage that is re-generated on demand. Will enable us to implement an SVGKImageView
 that works as a drop-in replacement for UIImageView
 
 - DOMTree: the SVG DOM spec, the root element of a tree of SVGElement subclasses
 - CALayerTree: the root element of a tree of CALayer subclasses
 
 - size: as per the UIImage.size, returns a size in Apple Points (i.e. 320 == width of iPhone, irrespective of Retina)
 - scale: ??? unknown how we'll define this, but could be useful when doing auto-re-render-on-zoom
 - svgWidth: the internal SVGLength used to generate the correct .size
 - svgHeight: the internal SVGLength used to generate the correct .size
 - rootElement: the SVGSVGElement instance that is the root of the parse SVG tree. Use this to access the full SVG document
 
 */

#import <UIKit/UIKit.h>

#define ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED 1 // if ENABLED, then ALL instances created with imageNamed: are shared, and are NEVER RELEASED

@class SVGDefsElement;

@class SVGKImage; // needed for typedef below

@interface SVGKImage : NSObject // doesn't extend UIImage because Apple made UIImage immutable
{
#if ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED
    BOOL cameFromGlobalCache;
#endif
}

/** Generates an image on the fly
 
 NB you can get MUCH BETTER performance using the methods such as exportUIImageAntiAliased and exportNSDataAntiAliased
 */
@property (weak, nonatomic, readonly) UIImage* UIImage;

#pragma mark - methods to quick load an SVG as an image
/**
 This is the preferred method for loading SVG files.
 
 Like Apple's [UIImage imageNamed:] method, it has a global cache of loaded SVG files to greatly
 increase performance. Unlike UIImage, SVGKImage's tend to be light in memory usage, but if needed,
 you can disable this at compile-time by setting ENABLE_GLOBAL_IMAGE_CACHE_FOR_SVGKIMAGE_IMAGE_NAMED to 0.
 
 As of SVGKit 1.2.0, this method:
 
 - Finds the SVG file (adding .svg extension if missing) in the App's sandboxed Documents folder
 - If that's missing, it finds the same file in the App's Bundle (i.e. the files stored at compile-time by Xcode, and shipped as the app)
 - Creates an SVGKSource so that you can later inspect exactly where it found the file
 */
+ (SVGKImage *)imageNamed:(NSString *)name;
+ (SVGKImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;

/** NB: if an SVG defines no limits to itself - neither a viewbox, nor an <svg width=""> nor an <svg height=""> - and
 you have not explicitly given the SVGKImage instance a "user defined size" (by setting .size) ... then there is NO
 LEGAL SIZE VALUE for self.size to return, and it WILL ASSERT!
 
 Use this method to double-check, before calling .size, whether it's going to give you a legal value safely
 */
-(BOOL) hasSize;

/**
 NB: always call "hasSize" before calling this method; some SVG's may have NO DEFINED SIZE, and so
 the .size method could return an invalid value (c.f. the hasSize method for details on how to
 workaround that issue)
 
 SVG's are infinitely scalable, by definition - but authors can OPTIONALLY set a "preferred size".
 
 Also, we allow you to set an explicit "this is the size I'm going to render at, deal with it" size,
 which will OVERRIDE the author's own size (if they configured one), and force the SVG to resize itself
 to fit your dictated size.
 
 (NB: this is as per the spec, so it's OK)
 
 NOTE: if you change this property, it will invalidate any cached render-data, and all future
 renders will be done at this pixel-size/pixel-resolution
 
 NOTE: when you read the .UIImage property of this class, it generates a bitmap using the
 current value of this property (or x2 if retina display) -- and if you've never set the
 property, it will use the de-facto value obtained by reading the SVG file and looking for
 author-dictated size, etc
 */
@property(nonatomic) CGSize             size;

@end
