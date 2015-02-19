//
//  ViewController.m
//  AVAudioUnitTimeEffectSample
//
//  Created by hiraya.shingo on 2015/02/19.
//  Copyright (c) 2015年 hiraya.shingo. All rights reserved.
//

#import "ViewController.h"

@import AVFoundation;

@interface ViewController ()

@property (nonatomic, strong) AVAudioEngine *engine;
@property (nonatomic, strong) AVAudioPlayerNode *audioPlayerNode;
@property (nonatomic, strong) AVAudioFile *audioFile;
@property (nonatomic, strong) AVAudioUnitTimePitch *audioUnitTimePitch;
@property (nonatomic, strong) AVAudioUnitVarispeed *audioUnitVarispeed;

@property (weak, nonatomic) IBOutlet UILabel *pitchValueLabel;
@property (weak, nonatomic) IBOutlet UIStepper *pitchStepper;
@property (weak, nonatomic) IBOutlet UILabel *speedValueLabel;
@property (weak, nonatomic) IBOutlet UIStepper *speedStepper;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.engine = [AVAudioEngine new];
    
    // Prepare AVAudioFile
    NSString *path = [[NSBundle mainBundle] pathForResource:@"loop.m4a" ofType:nil];
    self.audioFile = [[AVAudioFile alloc] initForReading:[NSURL fileURLWithPath:path]
                                                   error:nil];
    
    // Prepare AVAudioPlayerNode
    self.audioPlayerNode = [AVAudioPlayerNode new];
    [self.engine attachNode:self.audioPlayerNode];
    
    // AVAudioUnitTimePitch
    self.audioUnitTimePitch = [AVAudioUnitTimePitch new];
    self.audioUnitTimePitch.pitch = self.pitchStepper.value;
    [self.engine attachNode:self.audioUnitTimePitch];
    
    // AVAudioUnitVarispeed
    self.audioUnitVarispeed = [AVAudioUnitVarispeed new];
    self.audioUnitVarispeed.rate = self.speedStepper.value;
    [self.engine attachNode:self.audioUnitVarispeed];
    
    // Connect Nodes
    AVAudioMixerNode *mixerNode = [self.engine mainMixerNode];
    [self.engine connect:self.audioPlayerNode
                      to:self.audioUnitTimePitch
                  format:self.audioFile.processingFormat];
    
    [self.engine connect:self.audioUnitTimePitch
                      to:self.audioUnitVarispeed
                  format:self.audioFile.processingFormat];
    
    [self.engine connect:self.audioUnitVarispeed
                      to:mixerNode
                  format:self.audioFile.processingFormat];
    
    // Start engine
    NSError *error;
    [self.engine startAndReturnError:&error];
    if (error) {
        NSLog(@"error:%@", error);
    }
    
    //
    [self updatePitchValueLabel];
    [self updateSpeedValueLabel];
}

- (void)play
{
    // Schedule playing audio file
    [self.audioPlayerNode scheduleFile:self.audioFile
                                atTime:nil
                     completionHandler:^() {
                         [self play];
                     }];
    
    // Start playback
    [self.audioPlayerNode play];
}

- (void)updatePitchValueLabel
{
    if (self.pitchStepper.value > 0) {
        self.pitchValueLabel.text = [NSString stringWithFormat:@"+%.f cents", self.pitchStepper.value];
    } else {
        self.pitchValueLabel.text = [NSString stringWithFormat:@"%.f cents", self.pitchStepper.value];
    }
    
}

- (void)updateSpeedValueLabel
{
    if (self.speedStepper.value > 0) {
        self.speedValueLabel.text = [NSString stringWithFormat:@"+%.1f x", self.speedStepper.value];
    } else {
        self.speedValueLabel.text = [NSString stringWithFormat:@"%.1f x", self.speedStepper.value];
    }
    
}

- (IBAction)didTapPlayButton:(id)sender
{
    if (self.audioPlayerNode.isPlaying) {
        [self.audioPlayerNode stop];
    } else {
        [self play];
    }
}

- (IBAction)didChangePitchStepperValue:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    self.audioUnitTimePitch.pitch = stepper.value;
    [self updatePitchValueLabel];
}

- (IBAction)didChangeSpeedStepperValue:(id)sender
{
    UIStepper *stepper = (UIStepper *)sender;
    self.audioUnitVarispeed.rate = stepper.value;
    [self updateSpeedValueLabel];
}

@end
