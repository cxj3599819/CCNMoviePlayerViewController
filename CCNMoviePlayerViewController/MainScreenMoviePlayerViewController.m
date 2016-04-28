//
//  MainScreenMoviePlayerViewController.m
//  CCNMoviePlayerViewController
//
//  Created by zcc on 16/4/28.
//  Copyright © 2016年 CCN. All rights reserved.
//

#import "MainScreenMoviePlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MainScreenMoviePlayerViewController ()

#define TopViewHeight 55
#define BottomViewHeight 72
#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height

//上层建筑
@property (nonatomic,strong)UIView *topView;
@property (nonatomic,strong)UIButton *backBtn;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIButton *settingsBtn;

//经济基础
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)UIButton *playBtn;
@property (nonatomic,strong)UILabel *textLabel;
@property (nonatomic,assign)BOOL isPlay;
@property (nonatomic,strong)UISlider *movieProgressSlider;//进度条
@property (nonatomic,assign)CGFloat ProgressBeginToMove;
@property (nonatomic,assign)CGFloat totalMovieDuration;//视频总时间

//核心躯干
@property (nonatomic,strong)AVPlayer *player;
@property (nonatomic,strong)AVPlayerItem *playerItem;

//神之右手
@property (nonatomic,strong)UIView *settingsView;
@property (nonatomic,strong)UIView *rightView;
@property (nonatomic,strong)UIButton *setTestBtn;

//touch evens
@property (nonatomic,assign)BOOL isShowView;
@property (nonatomic,assign)BOOL isSettingsViewShow;
@property (nonatomic,assign)BOOL isSlideOrClick;

@property (nonatomic,strong)UISlider *volumeViewSlider;
@property (nonatomic,assign)float systemVolume;//系统音量值
@property (nonatomic,assign)float systemBrightness;//系统亮度
@property (nonatomic,assign)CGPoint startPoint;//起始位置坐标

@property (nonatomic,assign)BOOL isTouchBeganLeft;//起始位置方向
@property (nonatomic,copy)NSString *isSlideDirection;//滑动方向
@property (nonatomic,assign)float startProgress;//起始进度条
@property (nonatomic,assign)float NowProgress;//进度条当前位置

//监控进度
@property (nonatomic,strong)NSTimer *avTimer;

@end

@implementation MainScreenMoviePlayerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self prefersStatusBarHidden];
    self.view.backgroundColor = [UIColor blackColor];
    //我来组成躯干
    [self createAvPlayer];
    //我来组成头部
    [self createTopView];
    //我来组成底部
    [self createBottomView];
    //我来组成右手
    [self createRightSettingsView];
    //获取系统音量
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    //获取系统亮度
    _systemBrightness = [UIScreen mainScreen].brightness;
    
}

#pragma mark - 播放器躯干
- (void)createAvPlayer{
    //设置静音状态也可播放声音
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    CGRect playerFrame = CGRectMake(0, 0, self.view.layer.bounds.size.height, self.view.layer.bounds.size.width);
    
    AVURLAsset *asset = [AVURLAsset assetWithURL: _url];
    Float64 duration = CMTimeGetSeconds(asset.duration);
    //获取视频总时长
    _totalMovieDuration = duration;
    
    _playerItem = [AVPlayerItem playerItemWithAsset: asset];
    
    _player = [[AVPlayer alloc]initWithPlayerItem:_playerItem];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = playerFrame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
}

#pragma mark - 头部View
- (void)createTopView{
    CGFloat titleLableWidth = 400;
    _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.height, TopViewHeight)];
    _topView.backgroundColor = [UIColor lightGrayColor];
    
    _backBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, TopViewHeight)];
    [_backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [_backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_backBtn];
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.height/2-titleLableWidth/2, 0, titleLableWidth, TopViewHeight)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.text = @"我是标题";
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.userInteractionEnabled = NO;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_topView addSubview:_titleLabel];
    
    _settingsBtn = [[UIButton alloc]initWithFrame:CGRectMake(mainHeight - 50, 0, 50, TopViewHeight)];
    [_settingsBtn setTitle:@"设置" forState:UIControlStateNormal];
    [_settingsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_settingsBtn addTarget:self action:@selector(settingsClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_settingsBtn];
    
    [self.view addSubview:_topView];
}

//返回Click
- (void)backClick{
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        //do someing
        [weakSelf.avTimer invalidate];
        weakSelf.avTimer = nil;
    }];
}

//设置Click
- (void)settingsClick:(UIButton *)btn{
    
    _isShowView = NO;
    _isSettingsViewShow = YES;
    _settingsView.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        _topView.alpha = 0;
        _bottomView.alpha = 0;
    }];
}

#pragma mark - 底部View
- (void)createBottomView{
    CGFloat titleLableWidth = 400;
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, mainWidth - TopViewHeight, mainHeight, TopViewHeight)];
    _bottomView.backgroundColor = [UIColor lightGrayColor];
    
    _playBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, TopViewHeight)];
    [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_playBtn];
    
    //进度条
    _movieProgressSlider = [[UISlider alloc]initWithFrame:CGRectMake(0, 0, _bottomView.frame.size.width, 10)];
    [_movieProgressSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [_movieProgressSlider setMaximumTrackTintColor:[UIColor colorWithRed:0.49f green:0.48f blue:0.49f alpha:1.00f]];
    [_movieProgressSlider setThumbImage:[UIImage imageNamed:@"progressThumb.png"] forState:UIControlStateNormal];
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidBegin) forControlEvents:UIControlEventTouchDown];
    [_movieProgressSlider addTarget:self action:@selector(scrubbingDidEnd) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel)];
    [_bottomView addSubview:_movieProgressSlider];
    
    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.bounds.size.height/2-titleLableWidth/2, 0, titleLableWidth, TopViewHeight)];
    _textLabel.backgroundColor = [UIColor clearColor];
    //_textLabel.text = @"我是各种操作";
    _textLabel.textColor = [UIColor whiteColor];
    _textLabel.textAlignment = NSTextAlignmentCenter;
    [_bottomView addSubview:_textLabel];
    
    //在totalTimeLabel上显示总时间
    _textLabel.text = [self convertMovieTimeToText:_totalMovieDuration];
    
    [self.view addSubview:_bottomView];
}

//时间文字转换
-(NSString*)convertMovieTimeToText:(CGFloat)time{
    if (time<60.f) {
        return [NSString stringWithFormat:@"%.0f秒",time];
    }else{
        return [NSString stringWithFormat:@"%.2f",time/60];
    }
}

//播放/暂停 Click
- (void)playClick:(UIButton *)btn{
    if (!_isPlay) {
        [self PlayOrStop:YES];
    }else{
        [self PlayOrStop:NO];
    }
}

#pragma mark - play
- (void)PlayOrStop:(BOOL)isPlay{
    if (isPlay) {
        //1.通过实际百分比获取秒数。
        float dragedSeconds = floorf(_totalMovieDuration * _NowProgress);
        CMTime newCMTime = CMTimeMake(dragedSeconds,1);
        //2.更新电影到实际秒数。
        [_player seekToTime:newCMTime];
        //3.play 并且重启timer
        [_player play];
        _isPlay = YES;
        [_playBtn setTitle:@"暂停" forState:UIControlStateNormal];
        self.avTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
        
    }else{
        [_player pause];
        _isPlay = NO;
        [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [self.avTimer invalidate];
    }
}

-(void)updateUI{
    //1.根据播放进度与总进度计算出当前百分比。
    float new = CMTimeGetSeconds(_player.currentItem.currentTime) / CMTimeGetSeconds(_player.currentItem.duration);
    //2.计算当前百分比与实际百分比的差值，
    float DValue = new - _NowProgress;
    //3.实际百分比更新到当前百分比
    _NowProgress = new;
    //4.当前百分比加上差值更新到实际进度条
    self.movieProgressSlider.value = self.movieProgressSlider.value + DValue;
}

//按住滑块
-(void)scrubbingDidBegin{
    _ProgressBeginToMove = _movieProgressSlider.value;
}

//释放滑块
-(void)scrubbingDidEnd{
    [self UpdatePlayer];
}

//拖动停止后更新avplayer
-(void)UpdatePlayer{
    //1.暂停播放
    [self PlayOrStop:NO];
    //2.存储实际百分比值
    _NowProgress = _movieProgressSlider.value;
    //3.重新开始播放
    [self PlayOrStop:YES];
}

#pragma mark - 右侧设置View
- (void)createRightSettingsView{
    
    CGFloat x = mainHeight/5 *3;
    CGFloat width = mainHeight/5 *2;
    _settingsView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainHeight, mainWidth)];
    _settingsView.alpha = 0;
    
    _rightView = [[UIView alloc]initWithFrame:CGRectMake(x, 0, width, mainWidth)];
    _rightView.backgroundColor = [UIColor lightGrayColor];
    [_settingsView addSubview:_rightView];
    
    _setTestBtn = [[UIButton alloc]initWithFrame:CGRectMake(x + 20, 20, width - 40, mainWidth - 140)];
    [_setTestBtn setTitle:@"我是测试按钮" forState:UIControlStateNormal];
    _setTestBtn.backgroundColor = [UIColor redColor];
    [_setTestBtn addTarget:self action:@selector(setTestBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_settingsView addSubview:_setTestBtn];
    
    [self.view addSubview:_settingsView];
}

- (void)setTestBtnClick:(UIButton *)btn{
    NSLog(@"点击了设置区测试按钮");
}

#pragma mark - touch
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    _isSlideOrClick = YES;
    //右半区调整音量
    CGPoint location = [[touches anyObject] locationInView:self.view];
    CGFloat changeY = location.y - _startPoint.y;
    CGFloat changeX = location.x - _startPoint.x;
    
    if (_isShowView) {
        //上下View为显示状态，此时点击上下View直接return
        CGPoint point = [[touches anyObject] locationInView:self.view];
        if ((point.y>CGRectGetMinY(self.topView.frame)&&point.y< CGRectGetMaxY(self.topView.frame))||(point.y<CGRectGetMaxY(self.bottomView.frame)&&point.y>CGRectGetMinY(self.bottomView.frame))) {
            _isSlideOrClick = NO;
            return;
        }
    }
    
    //初次滑动没有滑动方向，进行判断。已有滑动方向，直接进行操作
    if ([_isSlideDirection isEqualToString:@"横向"]) {
        int index = location.x - _startPoint.x;
        if(index>0){
            _movieProgressSlider.value = _startProgress + abs(index)/10 * 0.008;
        }else{
            _movieProgressSlider.value = _startProgress - abs(index)/10 * 0.008;
        }
    }else if ([_isSlideDirection isEqualToString:@"纵向"]){
        if (_isTouchBeganLeft) {
            int index = location.y - _startPoint.y;
            if(index>0){
                [UIScreen mainScreen].brightness = _systemBrightness - abs(index)/10 * 0.01;
            }else{
                [UIScreen mainScreen].brightness = _systemBrightness + abs(index)/10 * 0.01;
            }
            
        }else{
            int index = location.y - _startPoint.y;
            if(index>0){
                [_volumeViewSlider setValue:_systemVolume - (abs(index)/10 * 0.05) animated:YES];
                [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            }else{
                [_volumeViewSlider setValue:_systemVolume + (abs(index)/10 * 0.05) animated:YES];
                [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        
    }else{
        //"第一次"滑动
        if(fabs(changeX) > fabs(changeY)){
            _isSlideDirection = @"横向";//设置为横向
        }else if(fabs(changeY)>fabs(changeX)){
            _isSlideDirection = @"纵向";//设置为纵向
        }else{
            _isSlideOrClick = NO;
            NSLog(@"不在五行中。");
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if(event.allTouches.count == 1){
        //保存当前触摸的位置
        CGPoint point = [[touches anyObject] locationInView:self.view];
        _startPoint = point;
        _startProgress = _movieProgressSlider.value;
        _systemVolume = _volumeViewSlider.value;
        NSLog(@"volume:%f",_volumeViewSlider.value);
        if(point.x < self.view.frame.size.width/2){
            _isTouchBeganLeft = YES;
        }else{
            _isTouchBeganLeft = NO;
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    CGPoint point = [[touches anyObject] locationInView:self.view];
    if (!_isSettingsViewShow) {
        
        if (_isSlideOrClick) {
            _isSlideDirection = @"";
            _isSlideOrClick = NO;
            
            CGFloat changeY = point.y - _startPoint.y;
            CGFloat changeX = point.x - _startPoint.x;
            //如果位置改变 刷新进度条
            if(fabs(changeX) > fabs(changeY)){
                [self UpdatePlayer];
            }
            return;
        }
        
        if (_isShowView) {
            //上下View为显示状态，此时点击上下View直接return
            if ((point.y>CGRectGetMinY(self.topView.frame)&&point.y< CGRectGetMaxY(self.topView.frame))||(point.y<CGRectGetMaxY(self.bottomView.frame)&&point.y>CGRectGetMinY(self.bottomView.frame))) {
                return;
            }
            _isShowView = NO;
            [UIView animateWithDuration:0.5 animations:^{
                _topView.alpha = 0;
                _bottomView.alpha = 0;
            }];
        }else{
            _isShowView = YES;
            [UIView animateWithDuration:0.5 animations:^{
                _topView.alpha = 1;
                _bottomView.alpha = 1;
            }];
        }
        
    }else{
        if (point.x>CGRectGetMinX(_rightView.frame)&&point.x< CGRectGetMaxX(_rightView.frame)) {
            return;
        }
        _settingsView.alpha = 0;
        _isSettingsViewShow = NO;
    }
    
}

#pragma mark - 状态栏与横屏设置
//隐藏状态栏
- (BOOL)prefersStatusBarHidden{
    return YES;
}

//允许横屏旋转
- (BOOL)shouldAutorotate{
    return YES;
}

//支持左右旋转
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscapeRight|UIInterfaceOrientationMaskLandscapeLeft;
}

//默认为右旋转
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

