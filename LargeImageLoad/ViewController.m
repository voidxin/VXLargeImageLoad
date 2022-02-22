//
//  ViewController.m
//  LargeImageLoad
//
//  Created by zhangxin on 2022/2/22.
//

#import "ViewController.h"
#import "UIImageView+LoadLargeImage.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *tImageV = [[UIImageView alloc] init];
        [tImageV vx_setLargeImage:[UIImage imageNamed:@"big_image"]];
        tImageV.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
        [self.view addSubview:tImageV];
    });
   
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *tImageV2 = [[UIImageView alloc] init];
        [tImageV2 vx_setLargeImage:[UIImage imageNamed:@"big_image"]];
        tImageV2.frame = CGRectMake(0, 100, self.view.frame.size.width, 100);
        [self.view addSubview:tImageV2];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *tImageV3 = [[UIImageView alloc] init];
        [tImageV3 vx_setLargeImage:[UIImage imageNamed:@"big_image"]];
        tImageV3.frame = CGRectMake(0, 200, self.view.frame.size.width, 100);
        [self.view addSubview:tImageV3];
    });
    
   
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *tImageV4 = [[UIImageView alloc] init];
        [tImageV4 vx_setLargeImage:[UIImage imageNamed:@"big_image"]];
        tImageV4.frame = CGRectMake(0, 300, self.view.frame.size.width, 100);
        [self.view addSubview:tImageV4];
    });
   
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *tImageV5 = [[UIImageView alloc] init];
        [tImageV5 vx_setLargeImage:[UIImage imageNamed:@"big_image"]];
        tImageV5.frame = CGRectMake(0, 400, self.view.frame.size.width, 100);
        [self.view addSubview:tImageV5];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImageView *tImageV6 = [[UIImageView alloc] init];
        [tImageV6 vx_setLargeImage:[UIImage imageNamed:@"big_image"]];
        tImageV6.frame = CGRectMake(0, 500, self.view.frame.size.width, 100);
        [self.view addSubview:tImageV6];
    });
    
    UIImageView *tImageV7 = [[UIImageView alloc] init];
    [tImageV7 vx_setLargeImage:[UIImage imageNamed:@"big_image"]];
    tImageV7.frame = CGRectMake(0, 600, self.view.frame.size.width, 100);
    [self.view addSubview:tImageV7];
    
    
}


@end
