//
//  AudioRec.h
//  SimpleRecorder
//
//  Created by Yupeng Gu on 7/20/17.
//  Copyright © 2017 Yupeng Gu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>


@interface AudioRec : NSObject <AVCaptureMetadataOutputObjectsDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *audioPlayer;
    UInt32 currentSampleTime;
    short *audioData;
}

@property (nonatomic) BOOL isRecording;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic,strong)AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic,strong)AVCaptureSession *captureSession;


- (void)startRecording;
- (void)stopRecording;
- (void)playAudio;
- (void)stopAudio;

@end
