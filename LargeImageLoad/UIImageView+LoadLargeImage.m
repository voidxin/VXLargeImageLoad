//
//  UIImageView+LoadLargeImage.m
//  LargeImageLoad
//
//  Created by zhangxin on 2022/2/22.
//

#import "UIImageView+LoadLargeImage.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define IPAD1_IPHONE3GS
#ifdef IPAD1_IPHONE3GS
// IPAD1_IPHONE3GS 目标图片的位图大小为60M 原图每一次(每小块)加载到内存20M
#   define kDestImageSizeMB 60.0f // The resulting image will be (x)MB of uncompressed image data.
#   define kSourceImageTileSizeMB 20.0f // The tile size will be (x)MB of uncompressed image data.
#endif

/* These constants are suggested initial values for iPad2, and iPhone 4 */
//#define IPAD2_IPHONE4
#ifdef IPAD2_IPHONE4
// ipad2_IPHONE4 目标图片的位图大小为120M 原图每一次(每小块)加载到内存40M
#   define kDestImageSizeMB 120.0f // The resulting image will be (x)MB of uncompressed image data.
#   define kSourceImageTileSizeMB 40.0f // The tile size will be (x)MB of uncompressed image data.
#endif

/* These constants are suggested initial values for iPhone3G, iPod2 and earlier devices */
//#define IPHONE3G_IPOD2_AND_EARLIER
#ifdef IPHONE3G_IPOD2_AND_EARLIER
#   define kDestImageSizeMB 30.0f // The resulting image will be (x)MB of uncompressed image data.
#   define kSourceImageTileSizeMB 10.0f // The tile size will be (x)MB of uncompressed image data.
#endif

/* Constants for all other iOS devices are left to be defined by the developer.
 The purpose of this sample is to illustrate that device specific constants can
 and should be created by you the developer, versus iterating a complete list. */

#define bytesPerMB 1048576.0f
#define bytesPerPixel 4.0f
#define pixelsPerMB ( bytesPerMB / bytesPerPixel ) // 262144 pixels, for 4 bytes per pixel.
// 目标图片的总像素个数
#define destTotalPixels kDestImageSizeMB * pixelsPerMB
// 原始图每小块的总像素个数
#define tileTotalPixels kSourceImageTileSizeMB * pixelsPerMB
#define destSeemOverlap 2.0f // the numbers of pixels to overlap the seems where tiles meet.

@interface UIImageView()
@property (nonatomic,assign)CGContextRef destContext;
@end

@implementation UIImageView (LoadLargeImage)
- (void)vx_setLargeImage:(UIImage *)tImage {
    [NSThread detachNewThreadSelector:@selector(downsize:) toTarget:self withObject:tImage];
}
- (void)downsize:(UIImage *)sourceImage {
    @autoreleasepool {
        CGRect sourceTile;
        CGRect destTile;
        float imageScale;
        CGSize sourceResolution;
        float sourceTotalPixels;
        float sourceTotalMB;
        CGSize destResolution;
        float sourceSeemOverlap;
        if( sourceImage == nil ) NSLog(@"input image not found!");
        // 获取原图尺寸
        sourceResolution.width = CGImageGetWidth(sourceImage.CGImage);
        sourceResolution.height = CGImageGetHeight(sourceImage.CGImage);
        // 原图总像素个数
        sourceTotalPixels = sourceResolution.width * sourceResolution.height;
        // 原图转成位图的大小
        sourceTotalMB = sourceTotalPixels / pixelsPerMB;
        // 获取当前图片缩放比例
        imageScale = destTotalPixels / sourceTotalPixels;
        // 目标图片的尺寸
        destResolution.width = (int)( sourceResolution.width * imageScale );
        destResolution.height = (int)( sourceResolution.height * imageScale );
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        int bytesPerRow = bytesPerPixel * destResolution.width;
        // allocate enough pixel data to hold the output image.
        void* destBitmapData = malloc( bytesPerRow * destResolution.height );
        if( destBitmapData == NULL ) NSLog(@"failed to allocate space for the output image!");
        // 根据参数，创建目标图片上下文，方便后续直接使用获取图片
        self.destContext = CGBitmapContextCreate( destBitmapData, destResolution.width, destResolution.height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast );
        if(  self.destContext == NULL ) {
            free( destBitmapData );
            NSLog(@"failed to create the output bitmap context!");
        }
        // release the color space object as its job is done
        CGColorSpaceRelease( colorSpace );
        CGContextTranslateCTM(  self.destContext, 0.0f, destResolution.height );
        CGContextScaleCTM(  self.destContext, 1.0f, -1.0f );
        // 原始图每小块的宽度
        sourceTile.size.width = sourceResolution.width;
        // 原始图每小块图片的高度 = 每小块的总像素 / 每小块的宽度
        sourceTile.size.height = (int)( tileTotalPixels / sourceTile.size.width );
        NSLog(@"source tile size: %f x %f",sourceTile.size.width, sourceTile.size.height);
        sourceTile.origin.x = 0.0f;
        // 目标每小块的宽度
        destTile.size.width = destResolution.width;
        // 目标每小块的高度
        destTile.size.height = sourceTile.size.height * imageScale;
        destTile.origin.x = 0.0f;
        NSLog(@"dest tile size: %f x %f",destTile.size.width, destTile.size.height);
        sourceSeemOverlap = (int)( ( destSeemOverlap / destResolution.height ) * sourceResolution.height );
        NSLog(@"dest seem overlap: %f, source seem overlap: %f",destSeemOverlap, sourceSeemOverlap);
        CGImageRef sourceTileImageRef;
        // 迭代的次数(总共需要循环的次数)
        int iterations = (int)( sourceResolution.height / sourceTile.size.height );
        int remainder = (int)sourceResolution.height % (int)sourceTile.size.height;
        if( remainder ) iterations++;
        float sourceTileHeightMinusOverlap = sourceTile.size.height;
        sourceTile.size.height += sourceSeemOverlap;
        destTile.size.height += destSeemOverlap;
        NSLog(@"beginning downsize. iterations: %d, tile height: %f, remainder height: %d", iterations, sourceTile.size.height,remainder );
        for( int y = 0; y < iterations; ++y ) {
            @autoreleasepool {
                // create an autorelease pool to catch calls to -autorelease made within the downsize loop.
                NSLog(@"iteration %d of %d",y+1,iterations);
                // 计算每小块的纵坐标
                sourceTile.origin.y = y * sourceTileHeightMinusOverlap + sourceSeemOverlap;
                destTile.origin.y = ( destResolution.height ) - ( ( y + 1 ) * sourceTileHeightMinusOverlap * imageScale + destSeemOverlap );
                // 获取原始图片的每一小块图
                sourceTileImageRef = CGImageCreateWithImageInRect( sourceImage.CGImage, sourceTile );
                if( y == iterations - 1 && remainder ) {
                    float dify = destTile.size.height;
                    destTile.size.height = CGImageGetHeight( sourceTileImageRef ) * imageScale;
                    dify -= destTile.size.height;
                    destTile.origin.y += dify;
                }
                // 添加到之前创建destContext，
                CGContextDrawImage( self.destContext, destTile, sourceTileImageRef );
                CGImageRelease( sourceTileImageRef );
                if( y < iterations - 1 ) {
                    [self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:YES];
                }
            }
            
        }
        NSLog(@"downsize complete.");
        CGContextRelease(  self.destContext );
        free(destBitmapData);
    }
    
}

-(void)updateView {
    [self createImageFromContext];
}

-(void)createImageFromContext {
    CGImageRef destImageRef = CGBitmapContextCreateImage( self.destContext );
    if( destImageRef == NULL ) NSLog(@"destImageRef is null.");
    UIImage *destImage = [UIImage imageWithCGImage:destImageRef scale:1.0f orientation:UIImageOrientationDownMirrored];
    CGImageRelease( destImageRef );
    if( destImage == nil ) NSLog(@"destImage is nil.");
    if (destImage != nil) {
        self.image = destImage;
    }
}


//利用runtime在分类中添加成员属性
- (void)setDestContext:(CGContextRef)destContext {
    objc_setAssociatedObject(self, @selector(destContext), (__bridge id _Nullable)(destContext), OBJC_ASSOCIATION_ASSIGN);
}

- (CGContextRef)destContext {
    return (__bridge CGContextRef)(objc_getAssociatedObject(self, _cmd));
}
@end
