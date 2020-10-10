//
//  MDPictureClipViewController.m
//  MDPictureEditor
//
//  Created by huangqun on 2020/9/29.
//  Copyright © 2020 com.md. All rights reserved.
//

#import "MDPictureClipViewController.h"
#import "MDImageUtil.h"

// 判断是否是刘海屏
#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

@interface MDPictureClipViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *bgScrollView;                   /**<  缩放容器  */
@property (nonatomic, strong) UIImageView *imageView;                       /**<  图片视图  */
@property (nonatomic, strong) UIView *maskingView;                          /**<  蒙层视图  */
@property (weak, nonatomic) IBOutlet UIView *bottomView;                    /**<  底部的功能操作视图  */

@property (nonatomic, assign) CGFloat imageZoomScale;        /**<  图片原图与显示图之间的缩放比例  */
@property (nonatomic, assign) eImageScale imageSizeScale;    /**<  图片宽度比例  */

@end

@implementation MDPictureClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 默认设置
    [self defaultConfig];
    
    [self.view bringSubviewToFront:self.bottomView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

/// 默认设置
- (void)defaultConfig {
    self.imageSizeScale = eImageScale_9_16;
    self.imageView.image = self.originalImage;
    self.bgScrollView.frame = [self setHollowMaskView];
    [self updateLayout];
}

#pragma mark -
#pragma mark - subView
- (UIScrollView *)bgScrollView {
    if (_bgScrollView == nil) {
        _bgScrollView = [[UIScrollView alloc] init];
        _bgScrollView.delegate = self;
        _bgScrollView.bouncesZoom = YES;
        _bgScrollView.maximumZoomScale = 5; // 最大放大倍数
        _bgScrollView.minimumZoomScale = 1; // 最小缩小倍数
        _bgScrollView.multipleTouchEnabled = YES;
        _bgScrollView.scrollsToTop = NO;
        _bgScrollView.delaysContentTouches = NO;  //默认YES, 设置NO则无论手指移动的多么快，始终都会将触摸事件传递给内部控件；
        _bgScrollView.canCancelContentTouches = NO;
        _bgScrollView.alwaysBounceVertical = YES;
        _bgScrollView.alwaysBounceHorizontal = YES;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _bgScrollView.clipsToBounds = NO;
        if (@available(iOS 11.0, *)) {
            _bgScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.view addSubview:_bgScrollView];
    }
    return _bgScrollView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [UIImageView new];
        _imageView.userInteractionEnabled = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bgScrollView addSubview:_imageView];
    }
    return _imageView;
}

- (UIView *)maskingView {
    if (_maskingView == nil) {
        _maskingView = [UIView new];
        _maskingView.userInteractionEnabled = NO;
        //_maskingView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - (kIsBangsScreen ?  88 + 34 : 64) - self.bottomView.bounds.size.height);
        _maskingView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - (kIsBangsScreen ?  34 : 0) - self.bottomView.bounds.size.height);
        _maskingView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        [self.view addSubview:_maskingView];
        
    }
    return _maskingView;
}

/// 设置镂空的蒙层并返回镂空区域的frame
- (CGRect)setHollowMaskView {
    [self.maskingView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    // 计算镂空区域
    CGFloat ratio = [MDImageUtil getImageSizeScaleValue:self.imageSizeScale];  // 获取宽高比
    CGFloat width = self.view.bounds.size.width - 10 * 2;
    CGFloat height = width / ratio;
    CGRect alphaRect = CGRectMake(10.0, (self.maskingView.bounds.size.height - height) / 2.0, width, height);

    // 设置镂空区域描边
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:alphaRect];
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.frame = self.maskingView.bounds;
    borderLayer.lineWidth = 3.0;
    borderLayer.strokeColor = [UIColor whiteColor].CGColor;   // 设置路径形状的颜色
    borderLayer.path = bezierPath.CGPath;
    [self.maskingView.layer addSublayer:borderLayer];

    // 设置镂空
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    // 设置第一个路径
    UIBezierPath *bezierPath1= [UIBezierPath bezierPathWithRect:self.maskingView.bounds];
    // 设置透明区域路径
    [bezierPath1 appendPath:[[UIBezierPath bezierPathWithRect:alphaRect] bezierPathByReversingPath]];
    maskLayer.path = bezierPath1.CGPath;
    self.maskingView.layer.mask = maskLayer;
    
    return alphaRect;
}

#pragma mark -
#pragma mark - 更新图片布局
// 设置数据后要更新布局数据
- (void)updateLayout {
    [self.bgScrollView setZoomScale:1.0 animated:NO];
    
    // 计算图片按比例缩放后的尺寸
    CGFloat imageW = self.imageView.image.size.width;
    CGFloat imageH = self.imageView.image.size.height;
    CGFloat scale = 1.0; // 缩放比例
    CGFloat width = 0.0;
    CGFloat height = 0.0;

    // 根据图片内容实际的宽高比与期望显示的尺寸比例来确定以宽的缩放比例为准还是以高的缩放比例为准（前提是缩放后图片能铺满显示的尺寸区域）
    if (imageW / self.bgScrollView.bounds.size.width > imageH / self.bgScrollView.bounds.size.height) {
        scale = self.bgScrollView.bounds.size.height / imageH;
        height = self.bgScrollView.bounds.size.height;
        width = imageW * scale;
    } else {
        scale = self.bgScrollView.bounds.size.width / imageW;
        width = self.bgScrollView.bounds.size.width;
        height = imageH * scale;
    }
    
    self.imageView.frame = CGRectMake(0, 0, width, height);
    self.imageZoomScale = scale;
    
    // 设置滚动视图的内容大小
    self.bgScrollView.contentSize = CGSizeMake(width, height);
    // 定位到内容中心位置
    self.bgScrollView.contentOffset = CGPointMake((self.bgScrollView.contentSize.width - self.bgScrollView.bounds.size.width) / 2, (self.bgScrollView.contentSize.height - self.bgScrollView.bounds.size.height) / 2);
}

/// 获取图片裁剪区域
- (CGRect)getImageCropRect {
    CGFloat scrollViewZoomScale = self.bgScrollView.zoomScale;  // 滚动视图当前的缩放值
    CGFloat x = self.bgScrollView.contentOffset.x / self.imageZoomScale / scrollViewZoomScale;
    CGFloat y = self.bgScrollView.contentOffset.y / self.imageZoomScale / scrollViewZoomScale;
    CGFloat width = self.bgScrollView.bounds.size.width / self.imageZoomScale / scrollViewZoomScale;
    CGFloat height = self.bgScrollView.bounds.size.height / self.imageZoomScale / scrollViewZoomScale;
    CGRect cropRect = CGRectMake(x, y, width, height);
    return cropRect;
}

#pragma mark -
#pragma mark - UIScrollViewDelegate
// 返回需要缩放的视图控件 缩放过程中
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 延触摸中心点缩放
    CGSize size = scrollView.frame.size;
    CGSize contentSize = scrollView.contentSize;
    CGFloat offsetX = (size.width > contentSize.width) ? (size.width - contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (size.height > contentSize.height) ? (size.height - contentSize.height) * 0.5 : 0.0;
    self.imageView.center = CGPointMake(contentSize.width * 0.5 + offsetX, contentSize.height * 0.5 + offsetY);
}

#pragma mark -
#pragma mark - 按钮事件

/// 取消图片编辑
- (IBAction)cancelButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/// 确定图片编辑
- (IBAction)confirmButtonAction:(UIButton *)sender {
    self.imageView.image = [MDImageUtil cropImage:self.imageView.image rect:[self getImageCropRect]];
    [self updateLayout];
    
    if (self.changeImageBlcok) {
        self.changeImageBlcok(self.imageView.image);
    }
}

/// 将图片还原
- (IBAction)restoreImageTapAction:(UITapGestureRecognizer *)sender {
    [self defaultConfig];
    if (self.changeImageBlcok) {
        self.changeImageBlcok(self.imageView.image);
    }
}

/// 旋转图片 每次旋转90°
- (IBAction)rotationImageTapAction:(UITapGestureRecognizer *)sender {
//    self.imageView.image = [MDImageUtil rotationImage:self.imageView.image ratation:90];
    self.imageView.image = [MDImageUtil rotationImage:self.imageView.image angle:90];
    [self updateLayout];
}

- (IBAction)imageScaleTapAction_9_16:(UITapGestureRecognizer *)sender {
    [self setScaleImageTapAction:sender];
}
- (IBAction)imageScaleTapAction_3_4:(UITapGestureRecognizer *)sender {
    [self setScaleImageTapAction:sender];
}
- (IBAction)imageScaleTapAction_1_1:(UITapGestureRecognizer *)sender {
    [self setScaleImageTapAction:sender];
}

- (IBAction)imageScaleTapAction_16_9:(UITapGestureRecognizer *)sender {
    [self setScaleImageTapAction:sender];
}

- (IBAction)imageScaleTapAction_4_3:(UITapGestureRecognizer *)sender {
    [self setScaleImageTapAction:sender];
}

/// 设置图片裁剪比例
- (void)setScaleImageTapAction:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case 2: // 9:16
            self.imageSizeScale = eImageScale_9_16;
            break;
        case 3: // 3:4
            self.imageSizeScale = eImageScale_3_4;
            break;
        case 4: // 1:1
            self.imageSizeScale = eImageScale_1_1;
            break;
        case 5: // 4:3
            self.imageSizeScale = eImageScale_4_3;
            break;
        case 6: // 16:9
            self.imageSizeScale = eImageScale_16_9;
            break;
        default:
            break;
    }
    
    self.bgScrollView.frame = [self setHollowMaskView];
    [self updateLayout];
}

@end
