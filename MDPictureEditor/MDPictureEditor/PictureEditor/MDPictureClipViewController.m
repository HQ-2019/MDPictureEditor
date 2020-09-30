//
//  MDPictureClipViewController.m
//  MDPictureEditor
//
//  Created by huangqun on 2020/9/29.
//  Copyright © 2020 com.md. All rights reserved.
//

#import "MDPictureClipViewController.h"

@interface MDPictureClipViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *bgScrollView;                   /**<  缩放容器  */
@property (nonatomic, strong) UIImageView *imageView;                       /**<  图片视图  */
@property (nonatomic, strong) UIView *maskingView;                          /**<  蒙层视图  */

@end

@implementation MDPictureClipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = [UIImage imageNamed:@"owl"];
    CGRect rect = [self setHollowMaskView];
    self.bgScrollView.frame = rect;
    [self updateLayout];
}

- (UIScrollView *)bgScrollView {
    if (_bgScrollView == nil) {
        _bgScrollView = [[UIScrollView alloc] init];
        _bgScrollView.delegate = self;
        _bgScrollView.bouncesZoom = YES;
        _bgScrollView.maximumZoomScale = 5; // 最大放大倍数
        _bgScrollView.minimumZoomScale = 1; // 最小缩小倍数
        _bgScrollView.multipleTouchEnabled = YES;
        _bgScrollView.scrollsToTop = NO;
        _bgScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _bgScrollView.delaysContentTouches = NO;  //默认YES, 设置NO则无论手指移动的多么快，始终都会将触摸事件传递给内部控件；
        _bgScrollView.canCancelContentTouches = NO;
        _bgScrollView.alwaysBounceVertical = YES;
        _bgScrollView.alwaysBounceHorizontal = YES;
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
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
        _maskingView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 120);
        _maskingView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        [self.view addSubview:_maskingView];
        
    }
    return _maskingView;
}


/// 设置镂空的蒙层并返回镂空区域的frame
- (CGRect)setHollowMaskView {
    //描边
    CGFloat ratio = 3.0 / 4.0;  // 设置宽高比
    if (random() % 2 == 0 ) {
        ratio = 4.0 / 3.0;
    }
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = width * ratio;
    CGRect alphaRect = CGRectMake(10, (self.maskingView.bounds.size.height - height) / 2, width - 10 * 2, height);
    [self.maskingView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    // 设置描边
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:alphaRect];
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.frame = self.maskingView.bounds;
    borderLayer.lineWidth = 3;
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

// 设置数据后要更新布局数据
- (void)updateLayout {
    [self.bgScrollView setZoomScale:1.0 animated:NO];
    
    CGFloat imageW = self.imageView.image.size.width;
    CGFloat imageH = self.imageView.image.size.height;
    CGFloat height =  self.view.bounds.size.width * imageH / imageW;

    self.imageView.frame = CGRectMake(0, 0, self.bgScrollView.bounds.size.width, height);
    self.bgScrollView.contentSize = CGSizeMake(self.bgScrollView.bounds.size.width, height);
    
    // 定位到内容中心位置
    self.bgScrollView.contentOffset = CGPointMake(0, (self.bgScrollView.contentSize.height - self.bgScrollView.bounds.size.height) / 2);
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

@end
