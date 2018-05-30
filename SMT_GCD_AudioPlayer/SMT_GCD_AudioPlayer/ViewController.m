//
//  ViewController.m
//  SMT_GCD_AudioPlayer
//
//  Created by Yang on 30/05/2018.
//  Copyright © 2018 SeaMoonTime. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property(nonatomic,strong) AVPlayer *player;
@property(nonatomic,assign) BOOL bPlay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _bPlay = NO;
        
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (AVPlayer *)player{
    if (!_player) {
        NSURL *url = [NSURL URLWithString:@"http://download.leicacloud.com/3DDisto.mp3"];
        AVPlayerItem *songItem = [[AVPlayerItem alloc]initWithURL:url];
        _player = [[AVPlayer alloc]initWithPlayerItem:songItem];
    }
    return _player;
}

- (IBAction)onPlayAudio:(UIButton *)sender {
    
    _bPlay = !_bPlay;
    if (_bPlay) {
        [self.player play];
        [self.playButton setTitle:@"暂停播放" forState:UIControlStateNormal];
    }else{
        [self.player pause];
        [self.playButton setTitle:@"播放音频" forState:UIControlStateNormal];
    }
    
    
}


@end
