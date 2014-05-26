//
//  Tank.m
//  CocoaTanks
//
//  Created by Kent Miller on 5/24/14.
//  Copyright (c) 2014 Kent Miller. All rights reserved.
//

#import "Tank.h"

static int bulletSerialNo = 0;
@implementation Bullet

-(id) init
{
    self = [super init];
    if (self)
    {
        bulletSerialNo += 1;
        self.bulletID = [NSNumber numberWithInt:bulletSerialNo];
    }
    return self;
}

@end

@implementation Tank

-(NSString *) description
{
    return [NSString stringWithFormat:@"theta: %f v: %f", self.direction, self.velocity];
}

-(NSString *) tankStateString
{
    NSString *s = [NSString stringWithFormat:@"( %.02f,  %.02f)\ndir:  %.02f v: %.02f\nammo: %d next: %d\narmor: %.02f\nenemy: (%d, %.02f,  %.02f,  %.02f)",
                self.x, self.y, self.direction, self.velocity, self.ammo, self.nextShot, self.armor,
                self.canSeeEnemy, self.enemyDirection, self.enemyX, self.enemyY ];
    return s;
}

-(Tank *) init
{
    acceleration       = 0.1;
    brake              = -0.3;
    maxVelocity        = 2.0;
    rotaterate         = 1.0;
    firepower          = 25.0;
    firerate           = 3;
    maxAmmo            = 100;
    maxArmor           = 100.0;
    self.visibilityDistance = 50.0;
    self.visibilityArc      = 1.5;
    return self;
}

-(void) ResetTank
{
    self.velocity  = 0.0;
    self.ammo      = maxAmmo;
    self.armor     = maxArmor;
    self.nextShot  = 0;
    self.direction = 1.57079;  // = north
}

-(void) MoveTank
{
    float vx = self.velocity * cosf(self.direction);
    float vy = self.velocity * sinf(self.direction);
    self.x += vx;
    self.y += vy;
    
    //Collide with side?  stop
    if (self.x < 0.0)
    {
        self.x = 0.0;
        self.velocity = 0;
    }
    else if (self.x > 100.0)
    {
        self.x = 100.0;
        self.velocity = 0;
    }
    if (self.y < 0.0)
    {
        self.y = 0.0;
        self.velocity = 0.0;
    }
    else if (self.y > 100.0)
    {
        self.y = 100.0;
        self.velocity = 0.0;
    }
}

-(void) UpdateTank:(NSMutableArray *) bullets
{
    Move move = {0};
    
    move.direction = self.direction;
    move.velocity  = self.velocity;
    move.ammo      = self.ammo;
    move.armor     = self.armor;
    move.nextShot  = self.nextShot;
    move.x         = self.x;
    move.y         = self.y;
    move.contact   = self.canSeeEnemy;
    move.contactDirection = self.enemyDirection;
    move.contactx  = self.enemyX;
    move.contacty  = self.enemyY;
    move.hit       = self.tookDamage;
    move.hitFromDirection = self.fromDirection;
    
    [self Think:&move];
    
    if ((move.wantToShoot) && (self.ammo > 0) && (self.nextShot == 0))
    {
        //create a bullet
        Bullet *b = [[Bullet alloc] init];
        b.destx = move.shotX;
        b.desty = move.shotY;
        b.x     = self.x;
        b.y     = self.y;
        b.direction = self.direction;
        b.damageradius = 12.0;
        b.damage = 20.0;
        b.velocity = 8.0;
        self.ammo--;
        self.nextShot = firerate;
        [bullets addObject:b];
    }
    else if (self.nextShot > 0)
    {
        self.nextShot--;
    }
    
    //update direction
    float directionDelta = move.newDirection - self.direction;
    float absDelta = fabsf(directionDelta);
    if ( absDelta < rotaterate)
    {
        self.direction = move.newDirection;
    }
    else
    {
        //Do I want to turn left or right?
        int left = (directionDelta > 0);
        if (fabsf(directionDelta) > M_PI)
            left = !left;
        if (left)
            self.direction = self.direction + rotaterate;
        else
            self.direction = self.direction - rotaterate;
    }
    
    self.direction = fmodf(self.direction, 2*M_PI);
    if (self.direction < 0.0)
        self.direction = self.direction + (2*M_PI);
    
    //update velocity
    float deltav = move.newSpeed - self.velocity;
    if (deltav < 0)
    {
        if (deltav > brake)
            self.velocity = self.velocity + deltav;
        else
            self.velocity = move.newSpeed;
    }
    else
    {
        if (deltav > acceleration)
            self.velocity = self.velocity + acceleration;
        else
            self.velocity = move.newSpeed;
    }
    if (self.velocity < 0.0)
        self.velocity = 0.0;
    else if (self.velocity > maxVelocity)
        self.velocity = maxVelocity;
    
    //move
    [self MoveTank];
}

-(void) Think:(Move*) move
{
}


@end

@implementation Tank1

-(void) Think:(Move*) move
{
    if (evadeCounter > 0)
        evadeCounter--;
    
    if (move->hit)
    {
        //try to go the perpendicular of the direction of the hit
        move->newDirection = move->hitFromDirection - M_PI_2;
        evadeCounter = 10;
    }
    if (move->contact)
    {
        if ((move->hit == 0) && (evadeCounter == 0))
            move->newDirection = move->contactDirection;
        move->wantToShoot = 1;
        move->shotX = move->contactx;
        move->shotY = move->contacty;
        return;
    }
    
    int r = arc4random_uniform(1000);
    r = r - 500;
    
    move->newSpeed  = 100.0;
    
    float turnamt = 0.0;
    
    if (self.x < 10.0)
        move->newDirection = 0.0;
    else if (self.x > 90.0)
        move->newDirection = -M_PI;
    else if (self.y < 10.0)
        move->newDirection = M_PI_2;
    else if (self.y > 90.0)
        move->newDirection = -M_PI_2;
    else if (evadeCounter > 0)
    {
        //keep going in same direction
    }
    else
    {
        turnamt = (float)r / 500.0;
        move->newDirection = move->direction + turnamt;
    }
    
}

@end

@implementation Tank2

-(void) Think:(Move*) move
{
    if (move->contact)
    {
        move->newSpeed = 0.5;
        move->newDirection = move->contactDirection;
        move->wantToShoot = 1;
        move->shotX = move->contactx;
        move->shotY = move->contacty;
    }
    
    float turnamt = 0.0;
    if ((self.x == 0.0) || (self.x == 100.0) ||
        ((self.y == 0.0) || (self.y == 100.0)))
    {
        turnamt = 0.5;  //I'd like to just go the other way
    }
    else
    {
        turnamt = 0.04;
    }

    move->newDirection = move->direction + turnamt;
    move->newSpeed  = 100.0;
}


@end


@implementation TankGame

-(id) init
{

/*
    self.tank1.x = 50.0;
    self.tank1.y = 50.0;
    
    struct test{
        float x, y;
    };
    
    struct test Tests[] = {
    { 30.0, 70.0 },
    { 70.0, 70.0 },
    { 30.0, 30.0 },
    { 70.0, 30.0 },
    { 70.0, 50.0 },
    { 50.0, 70.0 },
    { 30.0, 50.0 },
    { 50.0, 30.0 },
    { -1, -1 },
    };
    
    struct test *t = Tests;
    
    while (t->x != -1)
    {
        float f;
        for (f= 0.0; f < 2*M_PI; f += 0.9)
        {
            self.tank1.direction = f;
            self.tank2.x = t->x;
            self.tank2.y = t->y;
            [self updateVisibility:self.tank1 canSeeTank:self.tank2];
            printf("(%0.2f, %0.2f) facing %0.2f  tank2 (%0.2f, %0.2f, %0.2f) visible: %d\n",
            self.tank1.x, self.tank1.y, self.tank1.direction,
            self.tank2.x, self.tank2.y, self.tank1.enemyDirection, self.tank1.canSeeEnemy);
        }
        t++;
    }
*/
    [self reset];
    return self;
}

-(void) reset
{
    self.gameboard = CGSizeMake(100.0, 100.0);
    self.impacts = [[NSMutableArray alloc]init];
    self.bullets = [[NSMutableArray alloc]init];
    self.tank1 = [[Tank1 alloc] init];
    self.tank2 = [[Tank2 alloc] init];
    [self.tank1 ResetTank];
    self.tank1.x = 5.0;
    self.tank1.y = 50.0;
    self.tank2.direction = M_PI_2;
    [self.tank2 ResetTank];
    self.tank2.x = 95.0;
    self.tank2.y = 50.0;
    self.tank2.direction = M_PI_2;
    self.gameState = kPlaying;
}

-(void) TankDamage:(Tank*) t  bullet:(Bullet *)b
{
    //is tank in bullet radius
    float dx = b.x - t.x;
    float dy = b.y - t.y;
    float distance = sqrtf(dx*dx + dy*dy);
    
    if (distance < b.damageradius)
    {
        t.armor -= b.damage;
        t.tookDamage = 1;
        t.fromDirection = b.direction + M_PI;
    }
}

-(void) updateVisibility:(Tank*) t1 canSeeTank:(Tank*) t2
{
    t1.canSeeEnemy = 0;
    t1.enemyDirection = 0.0;
    t1.enemyX = 0.0;
    t1.enemyY = 0.0;

    //distance betwen tanks
    float dx = t2.x - t1.x;
    float dy = t2.y - t1.y;
    
    float distance = sqrtf(dx*dx + dy*dy);
    if (distance > t1.visibilityDistance)
        return;

    //t2 is within visible range of t1.  Is it within
    // my visibility arc?
    float theta = asinf(dy/distance);
    if (dx < 0.0)
    {
        theta = M_PI - theta;
    }
    if (theta < 0)
        theta = theta + (2*M_PI);
    
    float t1min = t1.direction - (t1.visibilityArc/2);
    float t1max = t1.direction + (t1.visibilityArc/2);
    
    if ((t1min < theta) && (t1max > theta))
    {
        t1.canSeeEnemy = 1;
        t1.enemyDirection = theta;
        t1.enemyX = t2.x;
        t1.enemyY = t2.y;
    }

}

-(void) advance
{
    //remove all the bullets that hit last time
    for (Bullet *impact in self.impacts)
    {
        NSInteger i = 0;
        NSInteger found = -1;
        for (i = 0; i < self.bullets.count; i++)
        {
            Bullet *b = self.bullets[i];
            if ([impact.bulletID isEqualToNumber:b.bulletID])
            {
                found = i;
                break;
            }
        }
        if (found != -1)
            [self.bullets removeObjectAtIndex:found];
    }
    [self.impacts removeAllObjects];
    
    //Remove all the damage from last time
    self.tank1.tookDamage = 0;
    self.tank2.tookDamage = 0;
    
    //update bullets
    for (Bullet *b in self.bullets)
    {
        //how far away am I from the destination?
        float dx = b.destx - b.x;
        float dy = b.desty - b.y;
        float distance = sqrtf(dx*dx + dy*dy);
        if (distance < b.velocity)
        {
            b.x = b.destx;
            b.y = b.desty;
            //bullet arrives, add to hits
            [self.impacts addObject:b];
            
            //update tanks in the radius
            [self TankDamage:self.tank1 bullet:b];
            [self TankDamage:self.tank2 bullet:b];
        }
        else
        {
            //move bullet
            float theta = asinf(dy/distance);
            if (dx < 0.0)
            {
                theta = M_PI - theta;
            }
            if (theta < 0)
                theta = theta + (2*M_PI);
            b.x += (b.velocity * cosf(theta));
            b.y += (b.velocity * sinf(theta));
        }
    }

    //Calculate visibility
    [self updateVisibility:self.tank1 canSeeTank:self.tank2];
    [self updateVisibility:self.tank2 canSeeTank:self.tank1];

    [self.tank1 UpdateTank:self.bullets];
    [self.tank2 UpdateTank:self.bullets];
    
    if ((self.tank1.armor <= 0) && (self.tank2.armor <= 0))
        self.gameState = kEndDraw;
    else if (self.tank1.armor <= 0)
        self.gameState = kP2Wins;
    else if (self.tank2.armor <= 0)
        self.gameState = kP1Wins;
    else
        self.gameState = kPlaying;    
    
}

@end
