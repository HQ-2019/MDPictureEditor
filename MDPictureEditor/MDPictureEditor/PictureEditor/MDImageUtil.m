//
//  MDImageUtil.m
//  MDPictureEditor
//
//  Created by huangqun on 2020/10/9.
//  Copyright © 2020 com.md. All rights reserved.
//

#import "MDImageUtil.h"

@implementation MDImageUtil

/// 获取图片尺寸枚举对应的宽高比例值
/// @param imageSizeScale 尺寸枚举
+ (CGFloat)getImageSizeScaleValue:(eImageScale)imageSizeScale {
    CGFloat value = 1.0;
    switch (imageSizeScale) {
        case eImageScale_9_16:
            value = 9.0 / 16.0;
            break;
        case eImageScale_16_9:
            value = 16.0 / 9.0;
            break;
        case eImageScale_3_4:
            value = 3.0 / 4.0;
            break;
        case eImageScale_4_3:
            value = 4.0 / 3.0;
            break;
        default:
            break;
    }
    return value;
}

/// 获取一张裁剪后的图片
/// @param originalImage 原图
/// @param cropRect 裁剪区域
+ (UIImage *)cropImage:(UIImage *)originalImage rect:(CGRect)cropRect {
    // 裁剪区域溢出时返回原图
    if ((cropRect.origin.x + cropRect.size.width) > originalImage.size.width ||
        (cropRect.origin.y + cropRect.size.height) > originalImage.size.height) {
        NSAssert(NO, @"图片裁剪区域溢出，返回原图");
        return originalImage;;
    }
    
//    // 裁剪图片
//    CGImageRef imageRef = CGImageCreateWithImageInRect(originalImage.CGImage, cropRect);
//    CGRect smallRect = CGRectMake(0, 0, CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
//    // 开启图形上下文
//    UIGraphicsBeginImageContext(smallRect.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, smallRect, imageRef);
//    UIImage * image = [UIImage imageWithCGImage:imageRef];
//    // 关闭图形上下文
//    UIGraphicsEndImageContext();
//    CGImageRelease(imageRef);
//    return image;

    // 裁剪图片
    CGImageRef newImageRef = CGImageCreateWithImageInRect(originalImage.CGImage, cropRect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return  newImage;
}

/// 将图片旋转（Core Graphics）
/// @param originalImage 原图
/// @param rotation 旋转角度 顺时针旋转为负数如-90°，逆时针旋转为正数如90°
+ (UIImage *)rotationImage:(UIImage *)originalImage rotation:(CGFloat)rotation {
    
    CGFloat radians = rotation * M_PI / 180.0f;
    size_t width = (size_t)CGImageGetWidth(originalImage.CGImage);
    size_t height = (size_t)CGImageGetHeight(originalImage.CGImage);
    CGRect newRect = CGRectApplyAffineTransform(CGRectMake(0., 0., width, height), CGAffineTransformMakeRotation(radians));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 (size_t)newRect.size.width,
                                                 (size_t)newRect.size.height,
                                                 8,
                                                 (size_t)newRect.size.width * 4,
                                                 colorSpace,
                                                 kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if (!context) {
        return nil;
    }
    
    CGContextSetShouldAntialias(context, true);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextTranslateCTM(context, +(newRect.size.width * 0.5), +(newRect.size.height * 0.5));
    CGContextRotateCTM(context, radians);
    
    CGContextDrawImage(context, CGRectMake(-(width * 0.5), -(height * 0.5), width, height), originalImage.CGImage);
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:imgRef scale:originalImage.scale orientation:originalImage.imageOrientation];
    CGImageRelease(imgRef);
    CGContextRelease(context);
    
    return newImage;
}

/// 旋转图片（Core Image，根据设置的滤镜输出新的图片，该方法对CPU和耗时比Core Graphics小）
/// @param originalImage 原图
/// @param angle 旋转角度 顺时针旋转为负数如-90°，逆时针旋转为正数如90°
+ (UIImage *)rotationImage:(UIImage *)originalImage angle:(CGFloat)angle {
    
    // 将角度转换成弧度
    CGFloat radian = angle * M_PI / 180.0f;
    // 创建3D变换矩阵
    CGAffineTransform transform = CATransform3DGetAffineTransform(CATransform3DRotate(CATransform3DIdentity, radian, 0, 0, 1));
    
    // 设置滤镜
    CIImage *ciImage = [[CIImage alloc] initWithImage:originalImage];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform" keysAndValues:kCIInputImageKey, ciImage, nil];
    [filter setDefaults];
    [filter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];

    // 通过GPU处理图片 kCIContextUseSoftwareRenderer为NO采用GPU处理，为YES采用CPU处理
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(NO)}];
    // 根据滤镜输出图片
    CIImage *outputImage = [filter outputImage];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:[outputImage extent]];
    UIImage *newImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return newImage;
}

@end
