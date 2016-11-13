//
//  UIImage+FixAppearance.m
//  Pods
//
//  Created by baidu on 16/10/28.
//
//

#import "UIImage+FixAppearance.h"

@implementation UIImage (FixAppearance)
- (UIImage *)fixOrientation__fix {
    UIImage *aImage = self;
    UIImage *img = nil;
    @autoreleasepool {
        // No-op if the orientation is already correct
        if (aImage.imageOrientation == UIImageOrientationUp)
            return aImage;
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        switch (aImage.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
                transform = CGAffineTransformRotate(transform, M_PI);
                break;
                
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
                transform = CGAffineTransformRotate(transform, M_PI_2);
                break;
                
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
                transform = CGAffineTransformRotate(transform, -M_PI_2);
                break;
            default:
                break;
        }
        
        switch (aImage.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
                
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
                transform = CGAffineTransformScale(transform, -1, 1);
                break;
            default:
                break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                                 CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                                 CGImageGetColorSpace(aImage.CGImage),
                                                 CGImageGetBitmapInfo(aImage.CGImage));
        CGContextConcatCTM(ctx, transform);
        switch (aImage.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                // Grr...
                CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
                break;
                
            default:
                CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
                break;
        }
        
        // And now we just create a new UIImage from the drawing context
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        img = [UIImage imageWithCGImage:cgimg scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
    }
    return img;
}

- (UIImage*) fixScale
{
    UIImage* willFixImage = self;
    UIImage* image = nil;
    @autoreleasepool {
        if (ABS(image.scale - [UIScreen mainScreen].scale) > 0.001) {
            image = [UIImage imageWithCGImage:willFixImage.CGImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
        }
    }
    return image;
}

- (UIImage*) fixAppearance
{
    UIImage* image = [self fixOrientation__fix];
    return  [image fixScale];
}

@end
