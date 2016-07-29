//
//  ViewController.m
//  RZAudioCachePlayer
//
//  Created by Zrocky on 16/7/28.
//  Copyright © 2016年 Zrocky. All rights reserved.
//

#import "ViewController.h"
#import "UIColor+RGB.h"
#import "UIView+ZXAdjustFrame.h"
#import "RZPlayer.h"
#import "UIButton+RZColorState.h"

@interface ViewController ()
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIImageView *diskView;
@property (nonatomic, strong) UILabel *currentTimeLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *skipBtn;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIProgressView *cacheView;

@property (nonatomic, strong) RZPlayer *audioPlayer;

@property (nonatomic, strong) NSArray *audios;
@property (nonatomic, assign) NSInteger selectedIndex;
@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self setupLayout];
    
    [RZPlayer clearCache];
    self.audioPlayer = [[RZPlayer alloc] initWithURL:[NSURL URLWithString:[self.audios valueForKeyPath:@"url"][self.selectedIndex]]];
    [self playBtnClick:self.playBtn];
    [self updateAudioInfo];
    
    [self.audioPlayer addObserver:self forKeyPath:@"progress" options:NSKeyValueObservingOptionNew context:nil];
    [self.audioPlayer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:nil];
    [self.audioPlayer addObserver:self forKeyPath:@"cacheProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setupSubviews {
    [self.view addSubview:self.bgView];
    [self.view insertSubview:self.blurView aboveSubview:self.bgView];
    [self.view addSubview:self.diskView];
    [self.view addSubview:self.currentTimeLabel];
    [self.view addSubview:self.durationLabel];
    [self.view addSubview:self.playBtn];
    [self.view addSubview:self.skipBtn];
    [self.view addSubview:self.cacheView];
    [self.view addSubview:self.progressSlider];
}

- (void)setupLayout {
    self.bgView.frame = self.view.bounds;
    self.blurView.frame = self.view.bounds;
    CGSize diskSize = (CGSize){self.view.width * 0.6, self.view.width * 0.6};
    CGFloat diskX = (self.view.width - diskSize.width) * 0.5;
    self.diskView.frame = (CGRect){diskX, 100, diskSize};
    self.diskView.layer.masksToBounds = YES;
    self.diskView.layer.cornerRadius = self.diskView.width * 0.5;

    CGFloat progressW = self.view.width * 0.7;
    CGFloat progressX = (self.view.width - progressW) * 0.5;
    self.progressSlider.frame = CGRectMake(progressX, self.diskView.bottom + 40, progressW, 20);
    
    CGRect trackRect = [self.progressSlider trackRectForBounds:self.progressSlider.frame];
    self.cacheView.frame = CGRectMake(trackRect.origin.x, self.progressSlider.y + trackRect.origin.y, trackRect.size.width, trackRect.size.height);
    
    [self.currentTimeLabel sizeToFit];
    self.currentTimeLabel.width = 40;
    self.currentTimeLabel.centerY = self.progressSlider.centerY;
    self.currentTimeLabel.x = 10;
    
    [self.durationLabel sizeToFit];
    self.durationLabel.width = 40;
    self.durationLabel.centerY = self.progressSlider.centerY;
    self.durationLabel.x = self.view.width - 10 - self.durationLabel.width;
    
    self.playBtn.frame = CGRectMake(60, self.progressSlider.bottom + 60, 100, 40);
    self.playBtn.layer.cornerRadius = self.playBtn.height * 0.5;
    self.playBtn.layer.masksToBounds = YES;
    self.skipBtn.frame = CGRectMake(self.view.width - 60 - 100, self.playBtn.y, 100, 40);
    self.skipBtn.layer.cornerRadius = self.skipBtn.height * 0.5;
    self.skipBtn.layer.masksToBounds = YES;
}


#pragma mark - delegate

#pragma mark - event response
- (void)playBtnClick:(UIButton *)btn {
    if (btn.selected) {
        [self.audioPlayer pause];
    }else {
        [self.audioPlayer play];
    }
    btn.selected = !btn.selected;
}

- (void)skipBtnClick {
    NSLog(@"%@", [self.audioPlayer currentItemCacheFilePath]);
    self.selectedIndex ++;
    if (self.selectedIndex >= self.audios.count) {
        self.selectedIndex = 0;
    }
    [self.audioPlayer stop];
    NSURL *URL = [NSURL URLWithString:[self.audios valueForKeyPath:@"url"][self.selectedIndex]];
    [self.audioPlayer replaceItemWithURL:URL];
    [self.audioPlayer play];
    [self updateAudioInfo];
}

- (void)sliderValueChanged:(UISlider *)slider {
    float seekTime = self.audioPlayer.duration * slider.value;
    [self.audioPlayer seekToTime:seekTime];
}

- (void)sliderValueSelected:(UISlider *)slider {
    self.currentTimeLabel.text = [self convertStringWithTime:self.audioPlayer.duration * slider.value];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"progress"]) {
        if (self.progressSlider.state != UIControlStateHighlighted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressSlider.value = self.audioPlayer.progress;
                self.currentTimeLabel.text = [self convertStringWithTime:self.audioPlayer.duration * self.audioPlayer.progress];
                if (self.audioPlayer.progress == 1.0) {
                    [self skipBtnClick];
                }
            });
        }
    }else if ([keyPath isEqualToString:@"duration"]) {
        self.durationLabel.text = [self convertStringWithTime:self.audioPlayer.duration];
    }else if ([keyPath isEqualToString:@"cacheProgress"]) {
        self.cacheView.progress = self.audioPlayer.cacheProgress;
    }
}

#pragma mark - public methods

#pragma mark - private methods
- (NSString *)convertStringWithTime:(float)time {
    if (isnan(time)) time = 0.f;
    int min = time / 60.0;
    int sec = time - min * 60;
    NSString * minStr = min > 9 ? [NSString stringWithFormat:@"%d",min] : [NSString stringWithFormat:@"0%d",min];
    NSString * secStr = sec > 9 ? [NSString stringWithFormat:@"%d",sec] : [NSString stringWithFormat:@"0%d",sec];
    NSString * timeStr = [NSString stringWithFormat:@"%@:%@",minStr, secStr];
    return timeStr;
}

- (void)updateAudioInfo {
    UIImage *diskImage = [UIImage imageNamed:[self.audios valueForKeyPath:@"cover"][self.selectedIndex]];
    [UIView transitionWithView:self.bgView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.bgView.image = diskImage;
    } completion:nil];
    
    [UIView transitionWithView:self.diskView duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.diskView.image = diskImage;
    } completion:nil];
}

#pragma mark - setter and getter
- (UIImageView *)bgView {
    if (!_bgView) {
        _bgView = [[UIImageView alloc] init];
        _bgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bgView;
}

- (UIVisualEffectView *)blurView {
    if (!_blurView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _blurView.alpha = 0.97;
    }
    return _blurView;
}

- (UIImageView *)diskView {
    if (!_diskView) {
        _diskView = [[UIImageView alloc] init];
        _diskView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _diskView;
}

- (UILabel *)currentTimeLabel {
    if (!_currentTimeLabel) {
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.font = [UIFont systemFontOfSize:14];
        _currentTimeLabel.text = @"00:00";
    }
    return _currentTimeLabel;
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = [UIFont systemFontOfSize:14];
        _durationLabel.text = @"00:00";
    }
    return _durationLabel;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setBackgroundColor:RGB(0x4d9780) forState:UIControlStateNormal];
        [_playBtn setBackgroundColor:RGBA(0x4d9780, 0.8) forState:UIControlStateHighlighted];
        [_playBtn setTitle:NSLocalizedString(@"Play", nil) forState:UIControlStateNormal];
        [_playBtn setTitle:NSLocalizedString(@"Pause", nil) forState:UIControlStateSelected];
    }
    return _playBtn;
}

- (UIButton *)skipBtn {
    if (!_skipBtn) {
        _skipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_skipBtn addTarget:self action:@selector(skipBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_skipBtn setBackgroundColor:RGB(0x4d9780) forState:UIControlStateNormal];
        [_skipBtn setBackgroundColor:RGBA(0x4d9780, 0.8) forState:UIControlStateHighlighted];
        [_skipBtn setTitle:NSLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
    }
    return _skipBtn;
}

- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        [_progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchUpInside];
        [_progressSlider addTarget:self action:@selector(sliderValueSelected:) forControlEvents:UIControlEventTouchDragInside];
        _progressSlider.thumbTintColor = RGB(0x4d9780);
        _progressSlider.minimumTrackTintColor = RGB(0x4d9780);
        _progressSlider.maximumTrackTintColor = [UIColor clearColor];
    }
    return _progressSlider;
}

- (UIProgressView *)cacheView {
    if (!_cacheView) {
        _cacheView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _cacheView.progressTintColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        _cacheView.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    }
    return _cacheView;
}

- (NSArray *)audios {
    if (!_audios) {
        _audios = @[@{@"url": @"http://mr7.doubanio.com/3fd082ae3370d22e48e300ab1d5d6590/1/fm/song/p190415_128k.mp4",
                      @"cover": @"p190415_128k.jpg"},
                    @{@"url": @"http://mr7.doubanio.com/cc19d54291a8cc7d11a54384490f7550/0/fm/song/p1458183_128k.mp4",
                      @"cover": @"p1458183_128k.jpg"},
                    @{@"url": @"http://mr7.doubanio.com/39ec9c9b5bbac0af7b373d1c62c294a3/1/fm/song/p1393354_128k.mp4",
                      @"cover": @"p1393354_128k.jpg"},
                    @{@"url": @"http://mr7.doubanio.com/16c59061a6a82bbb92bdd21e626db152/0/fm/song/p966452_128k.mp4",
                      @"cover": @"p966452_128k.jpg"}
                    ];
    }
    return _audios;
}

@end
