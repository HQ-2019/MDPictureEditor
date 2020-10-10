//
//  ViewController.m
//  MDPictureEditor
//
//  Created by huangqun on 2020/9/29.
//

#import "ViewController.h"

#import "MDPictureClipViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)imageTap_1:(UITapGestureRecognizer *)sender {
    [self imageTap:sender];
}
- (IBAction)imageTap_2:(UITapGestureRecognizer *)sender {
    [self imageTap:sender];
}
- (IBAction)imageTap_3:(UITapGestureRecognizer *)sender {
    [self imageTap:sender];
}

- (void)imageTap:(UITapGestureRecognizer *)sender {
    UIImageView *imageView = (UIImageView *)sender.view;
    MDPictureClipViewController *controller = [MDPictureClipViewController new];
    controller.originalImage = imageView.image;
    controller.changeImageBlcok = ^(UIImage * _Nonnull image) {
        imageView.image = image;
    };
    [self.navigationController pushViewController:controller animated:YES];
}

@end
