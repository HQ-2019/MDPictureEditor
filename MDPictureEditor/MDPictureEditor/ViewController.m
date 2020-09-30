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

- (IBAction)buttonAction:(id)sender {
    
    MDPictureClipViewController *controller = [MDPictureClipViewController new];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
