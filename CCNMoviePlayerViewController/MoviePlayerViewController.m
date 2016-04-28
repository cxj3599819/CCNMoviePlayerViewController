//
//  MoviePlayerViewController.m
//  CCNMoviePlayerViewController
//
//  Created by zcc on 16/4/28.
//  Copyright © 2016年 CCN. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import "MainScreenMoviePlayerViewController.h"


@interface MoviePlayerViewController ()


@end

@implementation MoviePlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //点击全屏按钮
    UIButton *mainScreenBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 200, 30)];
    [mainScreenBtn setTitle:@"全屏" forState:UIControlStateNormal];
    mainScreenBtn.backgroundColor = [UIColor redColor];
    [mainScreenBtn addTarget:self action:@selector(mainScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mainScreenBtn];
    
}

- (void)mainScreenBtnClick:(UIButton *)btn{
    
    MainScreenMoviePlayerViewController *mainScreenMP = [[MainScreenMoviePlayerViewController alloc]init];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"chenyifaer" withExtension:@"mp4"];
    mainScreenMP.url = url;
    
    [self presentViewController:mainScreenMP animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
