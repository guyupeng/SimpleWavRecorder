//
//  AudioRec.m
//  SimpleRecorder
//
//  Created by Yupeng Gu on 7/20/17.
//  Copyright © 2017 Yupeng Gu. All rights reserved.
//

#import "AudioRec.h"

@interface AudioRec () <AVCaptureAudioDataOutputSampleBufferDelegate>

@end
@implementation AudioRec
typedef struct {
    char     chunk_id[4];
    uint32_t chunk_size;
    char     format[4];
    char     fmtchunk_id[4];
    uint32_t fmtchunk_size;
    uint16_t audio_format;
    uint16_t num_channels;
    uint32_t sample_rate;
    uint32_t byte_rate;
    uint16_t block_align;
    uint16_t bitspersample;
    char     datachunk_id[4];
    uint32_t datachunk_size;
}WavHeader;
WavHeader header1;

- (instancetype)init
{
    [self setCaptureSession];
    currentSampleTime = 0;
    audioData = malloc(sizeof(short)*48000*30+4096);
    self.isPlaying = NO;
    self.isRecording = NO;
    return self;
}

-(AVCaptureSession *)setCaptureSession
{
    
    if(_captureSession != nil){
        return _captureSession;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession beginConfiguration];
    
    _captureSession.sessionPreset = AVCaptureSessionPresetLow;
    [_captureSession commitConfiguration];
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput= [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!audioInput) return nil;
    [_captureSession addInput:audioInput];
    
    dispatch_queue_t audioQueue = dispatch_queue_create("com.audios.queue", NULL);
    _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    [_audioOutput setSampleBufferDelegate:self queue:audioQueue];
    [_captureSession addOutput:_audioOutput];
    
    return _captureSession;
}

- (void)startRecording
{
    currentSampleTime = 0;
    [_captureSession startRunning];
    self.isRecording = YES;
}

- (void)stopRecording
{
    [_captureSession stopRunning];
    self.isRecording = NO;
    
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *fileName = [docsDir stringByAppendingPathComponent:@"Rec.wav"];
    
    FILE *fp = fopen([fileName UTF8String],"w");
    UInt32 samps = (UInt32)currentSampleTime;
    
    
    header1.chunk_id[0] = 'R';
    header1.chunk_id[1] = 'I';
    header1.chunk_id[2] = 'F';
    header1.chunk_id[3] = 'F';
    header1.chunk_size = 4 + (8 + 16) + (8 + (samps * 2));
    
    header1.format[0] = 'W';
    header1.format[1] = 'A';
    header1.format[2] = 'V';
    header1.format[3] = 'E';
    
    header1.fmtchunk_id[0] = 'f';
    header1.fmtchunk_id[1] = 'm';
    header1.fmtchunk_id[2] = 't';
    header1.fmtchunk_id[3] = ' ';
    
    header1.fmtchunk_size = 16;
    header1.audio_format = 1;
    header1.num_channels = 1;
    header1.sample_rate = 44100;
    header1.byte_rate = (header1.sample_rate * header1.num_channels * 1);
    header1.block_align = 2;
    header1.bitspersample = 16;
    
    header1.datachunk_id[0] = 'd';
    header1.datachunk_id[1] = 'a';
    header1.datachunk_id[2] = 't';
    header1.datachunk_id[3] = 'a';
    header1.datachunk_size = (samps * 2); /* frame count * number of channels * bits per sample / 8 */
    
    fwrite(&header1, 1, sizeof(WavHeader), fp);
    fwrite(audioData,1,header1.datachunk_size,fp);
    fclose(fp);
}

- (void)playAudio
{
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSURL *tmpFileUrl = [NSURL URLWithString:[docsDir stringByAppendingPathComponent:@"Rec.wav"]];

    NSError *error = nil;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tmpFileUrl error:&error];
    [audioPlayer play];
    self.isPlaying = YES;
}

- (void)stopAudio
{
    [audioPlayer stop];
    self.isPlaying = NO;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if(!CMSampleBufferDataIsReady(sampleBuffer)){
        NSLog( @"sample buffer is not ready. Skipping sample" );
        return;
    }
    CMItemCount numberOfFrames = CMSampleBufferGetNumSamples(sampleBuffer);
    NSLog(@"receive %d samples at time %2.2f",(int)numberOfFrames,(float)currentSampleTime/44100.0);
    CMBlockBufferRef buffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    size_t dataLength = CMBlockBufferGetDataLength(buffer);
    short audioBuffer[1024];
    CMBlockBufferCopyDataBytes(buffer, 0, dataLength, audioBuffer);
    if (currentSampleTime>30*44100){
        [self stopRecording];
        return;
    }
    for(int i = 0; i< 1024; i++){
        *(audioData+currentSampleTime+i) = *(audioBuffer+i);
    }
    currentSampleTime += (double)numberOfFrames;
}
@end
