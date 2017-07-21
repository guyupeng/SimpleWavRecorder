//
//  ViewController.m
//  SimpleRecorder
//
//  Created by Yupeng Gu on 7/20/17.
//  Copyright © 2017 Yupeng Gu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    UIButton *recBtn;
    UIButton *playBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    audioRec = [[AudioRec alloc] init];
    
    playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [playBtn setTitle:@"play" forState:UIControlStateNormal];
    playBtn.titleLabel.font = [UIFont systemFontOfSize:35];
    [playBtn addTarget:self action:@selector(onPlayBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    
    recBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [recBtn setTitle:@"record" forState:UIControlStateNormal];
    recBtn.titleLabel.font = [UIFont systemFontOfSize:35];
    [recBtn addTarget:self action:@selector(onRecBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recBtn];

    [recBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:recBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:recBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

    [playBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:playBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:playBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:80.0]];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)onPlayBtnTapped:(id)sender
{
    if(audioRec.isPlaying){
        [audioRec stopAudio];
        [playBtn setTitle:@"play" forState:UIControlStateNormal];

    }else{
        [audioRec playAudio];
        [playBtn setTitle:@"stop" forState:UIControlStateNormal];
    }
}

- (void)onRecBtnTapped:(id)sender
{
    if(audioRec.isRecording){
        [audioRec stopRecording];
        [recBtn setTitle:@"record" forState:UIControlStateNormal];
    }else{
        [audioRec startRecording];
        [recBtn setTitle:@"stop" forState:UIControlStateNormal];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
