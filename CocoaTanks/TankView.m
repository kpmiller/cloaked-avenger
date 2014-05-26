//
//  TankView.m
//  CocoaTanks
//
//  Created by Kent Miller on 5/24/14.
//  Copyright (c) 2014 Kent Miller. All rights reserved.
//

#import "TankView.h"

@implementation TankView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void) awakeFromNib
{
}

-(CGPoint) translateGamePointToView:(CGPoint) gamePoint
{
    CGPoint p = {0,0};

    CGSize gameboard = self.game.gameboard;
    
    p.x = (self.bounds.size.width / gameboard.width) * gamePoint.x;
    p.y = (self.bounds.size.height / gameboard.height) * gamePoint.y;
    return p;
    
}

-(void) DrawTank:(Tank *)t tint:(int) tint
{
    NSColor *tankColor = nil;
    NSColor *searchColor = nil;
    if (tint == 1)
    {
        tankColor = [NSColor blueColor];
        if (t.canSeeEnemy)
            searchColor = [NSColor colorWithCalibratedRed:0.6 green:0.6 blue:0.8 alpha:0.8];
        else
            searchColor = [NSColor colorWithCalibratedRed:0.8 green:0.8 blue:1.0 alpha:0.8];
    }
    else
    {
        tankColor = [NSColor redColor];
        if (t.canSeeEnemy)
            searchColor = [NSColor colorWithCalibratedRed:0.8 green:0.6 blue:0.6 alpha:0.8];
        else
            searchColor = [NSColor colorWithCalibratedRed:1.0 green:0.8 blue:0.8 alpha:0.8];
    }


    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    CGPoint t1p = [self translateGamePointToView:CGPointMake(t.x, t.y)];


    [searchColor setFill];
    CGPoint arcd = [self translateGamePointToView:CGPointMake(0.0, t.visibilityDistance)];
    CGContextBeginPath (ctx);
    float f = t.visibilityArc / 2.0;
    CGContextMoveToPoint(ctx, t1p.x, t1p.y);
    CGContextAddArc(ctx, t1p.x, t1p.y, arcd.y, t.direction -f,  t.direction + f, 0);
    CGContextMoveToPoint(ctx, t1p.x, t1p.y);
    CGContextFillPath(ctx);


    CGRect r1 = CGRectMake( t1p.x-5.0, t1p.y-5.0, 10.0, 10.0);
    [tankColor setFill];
    NSRectFill(r1);
    [[NSColor blackColor] setFill];
    //draw a little line in the direction vector
    CGPoint barrel;
    barrel.x = t1p.x + (10.0 * cosf(t.direction));
    barrel.y = t1p.y + (10.0 * sinf(t.direction));
    CGContextBeginPath (ctx);
    CGContextMoveToPoint(ctx, t1p.x, t1p.y);
    CGContextAddLineToPoint(ctx, barrel.x, barrel.y);
    CGContextStrokePath(ctx);

    NSString *armor = [NSString stringWithFormat:@"%.02f", t.armor ];
    CGPoint ar = CGPointMake(t1p.x-30.0, t1p.y);
    [armor drawAtPoint:ar withAttributes:nil];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    if (self.game == nil)
        return;
    
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    [self DrawTank: self.game.tank1 tint:1];
    [self DrawTank: self.game.tank2 tint:2];
    
    if (self.game.gameState != kPlaying)
    {
        NSFont *font = [NSFont fontWithName:@"Helvetica" size:24.0];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        CGPoint ar = CGPointMake(100.0, 100.0);
        switch (self.game.gameState)
        {
            case kP1Wins: [@"Blue tank wins" drawAtPoint:ar withAttributes:attrsDictionary]; break;
            case kP2Wins: [@"Red tank wins" drawAtPoint:ar withAttributes:attrsDictionary]; break;
            case kEndDraw: [@"Both tanks dead" drawAtPoint:ar withAttributes:attrsDictionary]; break;
            default: break;
        }
        return;
    }
    
    for (Bullet *b in self.game.bullets)
    {
        CGPoint p = [self translateGamePointToView:CGPointMake(b.x, b.y)];
        CGRect r = CGRectMake( p.x-2.0, p.y-2.0, 4.0, 4.0);
        [[NSColor blackColor] setFill];
        NSRectFill(r);
    }
    
    for (Bullet *b in self.game.impacts)
    {
        CGPoint p = [self translateGamePointToView:CGPointMake(b.x, b.y)];
        [[NSColor colorWithCalibratedRed:0.7 green:0.2 blue:0.2 alpha:0.8] setFill];
        
        CGContextBeginPath (ctx);
        CGContextMoveToPoint(ctx, p.x, p.y);
        float f = b.damageradius;
        
        //what is the scaled damage radius
        CGPoint p2 = [self translateGamePointToView:CGPointMake(0.0, f)];
        f =  p2.y;
        
        CGRect r = CGRectMake(p.x - f, p.y - f, f*2, f*2);
        CGContextAddEllipseInRect(ctx, r);
        CGContextMoveToPoint(ctx, p.x, p.y);
        CGContextAddLineToPoint(ctx, p.x+f, p.y);
        CGContextFillPath(ctx);
        
        
    }
    
}

@end
