//
//  UIImage+FQBlur.m
//  FriendsPictureQuiz
//
//  Created by Tom Baranes on 30/05/14.
//  Copyright (c) 2014 Tom Baranes. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+FQBlur.h"

@implementation UIImage (FQBlur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 50);
    boxSize = boxSize - (boxSize % 2) + 1;
	
    CGImageRef img = self.CGImage;
	
    vImage_Buffer inBuffer, outBuffer;
	
    vImage_Error error;
	
    void *pixelBuffer;
	
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
	
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
	
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
	
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
	
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
	
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
	
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
	
    if (error) {
        NSLog(@"JFDepthView: error from convolution %ld", error);
    }
	
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
											 outBuffer.width,
											 outBuffer.height,
											 8,
											 outBuffer.rowBytes,
											 colorSpace,
											 (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
	
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
	
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
	
    free(pixelBuffer);
    CFRelease(inBitmapData);
	
    CGImageRelease(imageRef);
	
    return returnImage;
}

@end
