//
//  MDPictureClipViewController.h
//  MDPictureEditor
//
//  Created by huangqun on 2020/9/29.
//  Copyright © 2020 com.md. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDPictureClipViewController : UIViewController

@property (nonatomic, strong) UIImage *originalImage;                   /**<  必传参数 需要裁剪的原图片  */

@property (nonatomic, copy) void(^changeImageBlcok)(UIImage *image);    /**<  将裁剪后的图片回传  */

@end

NS_ASSUME_NONNULL_END
