//
//  MDImageUtil.h
//  MDPictureEditor
//
//  Created by huangqun on 2020/10/9.
//  Copyright © 2020 com.md. All rights reserved.
//

#import <UIKit/UIKit.h>

/**<  图片宽高比例  */
typedef NS_ENUM(NSUInteger, eImageScale) {
    eImageScale_9_16 = 0,           /**<  9:16  */
    eImageScale_16_9,
    eImageScale_1_1,
    eImageScale_3_4,
    eImageScale_4_3,
};

NS_ASSUME_NONNULL_BEGIN

@interface MDImageUtil : NSObject

/// 获取图片尺寸枚举对应的宽高比例值
/// @param imageSizeScale 尺寸枚举
+ (CGFloat)getImageSizeScaleValue:(eImageScale)imageSizeScale;

/// 获取一张裁剪后的图片
/// @param originalImage 原图
/// @param cropRect 裁剪区域
+ (UIImage *)cropImage:(UIImage *)originalImage rect:(CGRect)cropRect;

/// 将图片旋转（Core Graphics）
/// @param originalImage 原图
/// @param rotation 旋转角度 顺时针旋转为负数如-90°，逆时针旋转为正数如90°
+ (UIImage *)rotationImage:(UIImage *)originalImage rotation:(CGFloat)rotation;

/// 旋转图片（Core Image，根据设置的滤镜输出新的图片，该方法对CPU和耗时比Core Graphics小）
/// @param originalImage 原图
/// @param angle 旋转角度 顺时针旋转为负数如-90°，逆时针旋转为正数如90°
+ (UIImage *)rotationImage:(UIImage *)originalImage angle:(CGFloat)angle;

@end

NS_ASSUME_NONNULL_END
