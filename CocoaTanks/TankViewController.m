//
//  TankViewController.m
//  CocoaTanks
//
//  Created by Kent Miller on 5/24/14.
//  Copyright (c) 2014 Kent Miller. All rights reserved.
//

#import "TankViewController.h"
#import "TankView.h"

@interface TankViewController ()

@end

@implementation TankStatusView

- (void)drawRect:(NSRect)dirtyRect
{
    [self.bkg setFill];
    NSRectFill(dirtyRect);
    
    [self.status drawInRect:self.bounds withAttributes:nil];
}

@end

@implementation TankViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) awakeFromNib
{
    self.game = [[TankGame alloc] init];
    [self.game reset];
    self.tankView.game = self.game;
    
    [self.timer invalidate];
    self.lastTimer = CACurrentMediaTime();
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(gametimer:) userInfo:nil repeats:YES];
    
    self.Tank1Status.bkg = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:1.0 alpha:1.0];
    self.Tank2Status.bkg = [NSColor colorWithCalibratedRed:1.0 green:0.8 blue:0.8 alpha:1.0];
    self.Tank1Status.status = [self.game.tank1 tankStateString];
    self.Tank2Status.status = [self.game.tank2 tankStateString];
    
    paused = YES;
}

-(void) frame
{
    if (self.game.gameState != kPlaying)
    {
        [self.tankView setNeedsDisplay:YES];
        [self.Tank1Status setNeedsDisplay:YES];
        [self.Tank2Status setNeedsDisplay:YES];
        return;
    }
    [self.game advance];
    [self.tankView setNeedsDisplay:YES];
    
    self.Tank1Status.status = [self.game.tank1 tankStateString];
    self.Tank2Status.status = [self.game.tank2 tankStateString];
    [self.Tank1Status setNeedsDisplay:YES];
    [self.Tank2Status setNeedsDisplay:YES];
}

-(void) gametimer:(id) userInfo
{
//    CFTimeInterval now = CACurrentMediaTime();
//    CFTimeInterval elapsed = now - self.lastTimer;
    if (paused)
        return;
    
    [self frame];
//    self.lastTimer = now;
}

- (IBAction)Pause:(id)sender
{
    paused = YES;
}

- (IBAction)Play:(id)sender
{
    if (self.game.gameState != kPlaying)
    {
        [self.game reset];
    }
    else
        paused = NO;
}

- (IBAction)Step:(id)sender
{
    if (paused)
    {
        [self frame];
    }
    else
        paused = YES;
}


@end
