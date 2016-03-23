//
//  CTViewTools.m
//  SPUIView
//
//  Created by WBapple on 16/1/20.
//  Copyright © 2016年 chinasofti. All rights reserved.
//

#import "CTViewTools.h"

@implementation CTViewTools

static CGContextRef _context;

+ (UIColor *)colorWithImg:(UIImage *)img point:(CGPoint)point
{
    UIColor *color = nil;
    CGImageRef inImage = img.CGImage;
    // Create off screen bitmap context to draw the image into. Format ARGB is 4
    // bytes for each pixel: Alpa, Red, Green, Blue
    [self createARGBBitmapContextFromImage:inImage];
    //    if (cgctx == NULL)
    //    {
    //        return nil;
    //    }

    size_t w = CGImageGetWidth (inImage);
    size_t h = CGImageGetHeight (inImage);
    CGRect rect = { { 0, 0 }, { w, h } };

    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage (_context, rect, inImage);

    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char *data = CGBitmapContextGetData (_context);
    if (data != NULL)
    {
        // offset locates the pixel in the data from x,y.
        // 4 for 4 bytes of data per pixel, w is width of one row of data.
        @try
        {
            int offset = 4 * ((w * round (point.y)) + round (point.x));
            //            SVInfo(@"offset: %d", offset);
            int alpha = data[offset];
            int red = data[offset + 1];
            int green = data[offset + 2];
            int blue = data[offset + 3];
            //            SVInfo(@"offset: %i colors: RGB A %i %i %i  %i", offset, red, green, blue,
            //                  alpha);
            color = [UIColor colorWithRed:(red / 255.0f)
                                    green:(green / 255.0f)
                                     blue:(blue / 255.0f)
                                    alpha:(alpha / 255.0f)];
        }
        @catch (NSException *e)
        {
            SVInfo (@"%@", [e reason]);
        }
        @finally
        {
        }
    }
    // When finished, release the context
    CGContextRelease (_context);
    // Free image data memory for the context
    if (data)
    {
        free (data);
    }
    return color;
}

+ (void)createARGBBitmapContextFromImage:(CGImageRef)inImage
{

    //    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    void *bitmapData;
    unsigned long bitmapByteCount;
    unsigned long bitmapBytesPerRow;

    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth (inImage);
    size_t pixelsHigh = CGImageGetHeight (inImage);

    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow = (pixelsWide * 4);
    bitmapByteCount = (bitmapBytesPerRow * pixelsHigh);

    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB ();

    if (colorSpace == NULL)
    {
        fprintf (stderr, "Error allocating color spacen");
        return;
    }

    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc (bitmapByteCount);
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease (colorSpace);
        return;
    }

    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    _context = CGBitmapContextCreate (bitmapData, pixelsWide, pixelsHigh,
                                      8, // bits per component
                                      bitmapBytesPerRow, colorSpace, kCGImageAlphaPremultipliedFirst);
    if (!_context)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    // Make sure and release colorspace before returning
    CGColorSpaceRelease (colorSpace);

    //    return context;
}

@end
