//
//  TankViewController.h
//  CocoaTanks
//
//  Created by Kent Miller on 5/24/14.
//  Copyright (c) 2014 Kent Miller. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TankView.h"
#import "Tank.h"

@interface TankStatusView : NSView
@property (strong) NSString *status;
@property (strong) NSColor *bkg;
@end

@interface TankViewController : NSViewController
{
    BOOL paused;
}
@property TankGame *game;
@property NSTimer *timer;

@property CFTimeInterval lastTimer;

@property (strong) IBOutlet TankView *tankView;

@property (strong) IBOutlet TankStatusView *Tank1Status;
@property (strong) IBOutlet TankStatusView *Tank2Status;

@end

