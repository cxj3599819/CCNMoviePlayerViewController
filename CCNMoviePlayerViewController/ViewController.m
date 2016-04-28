//
//  ViewController.m
//  CCNMoviePlayerViewController
//
//  Created by zcc on 16/4/28.
//  Copyright © 2016年 CCN. All rights reserved.
//

#import "ViewController.h"
#import "MoviePlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 200, 30)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"点击看视频" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

- (void)btnClick:(UIButton *)btn{
    MoviePlayerViewController *mp = [[MoviePlayerViewController alloc]init];
    [self.navigationController pushViewController:mp animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
