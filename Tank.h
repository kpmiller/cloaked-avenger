//
//  Tank.h
//  CocoaTanks
//
//  Created by Kent Miller on 5/24/14.
//  Copyright (c) 2014 Kent Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct Move
{
    //input
    int      hit;
    float    hitFromDirection;
    int      contact;
    float    contactDirection;
    float    contactx;
    float    contacty;
    
    //output
    float    newSpeed;
    float    newDirection;
    int      wantToShoot;
    float    shotX;
    float    shotY;
    
    //state
    float    direction;                 //which way am I pointing
    float    velocity;                  //how fast am I currently going
    float    ammo;                      // bullets left
    float    armor;                     // armor left
    float    x;
    float    y;
    int      nextShot;                  // time until I can take next shot
} Move;

@interface Tank : NSObject
{
    //This Tank's adjustable parameters, all normalized to 0-1.0
    float    acceleration;              //How fast I can change speed, units per turn
    float    brake;                     //How fast I can slow down, units per turn
    float    maxVelocity;               //Top speed, units per turn
    float    rotaterate;                //How fast I can turn, radians per turn
    float    firepower;                 //How "strong" my shots are
    int      firerate;                  //After I shoot, how long until I can shoot again
    int      maxAmmo;                   //How many bullets can I hold
    float    maxArmor;                  //How much armor do I start out with
}
@property    int      tookDamage;
@property    float    fromDirection;

@property    int      canSeeEnemy;
@property    float    enemyDirection;
@property    float    enemyX;
@property    float    enemyY;

@property    float    visibilityDistance;        //How far can I see
@property    float    visibilityArc;             //How many radians can I see out the front of my tank

    //This tank's state
@property float    direction;                 //which way am I pointing
@property float    velocity;                  //how fast am I currently going
@property int      ammo;                      // bullets left
@property float    armor;                     // armor left
@property int      nextShot;                  //  How long til my next shot
@property float    x;
@property float    y;


-(void) UpdateTank:(NSMutableArray *) bullets;

-(void) Think:(Move*) move;

-(NSString *) tankStateString;

@end

@interface Tank1 : Tank
{
    int evadeCounter;
}

@end

@interface Tank2 : Tank

@end

@interface Bullet : NSObject
@property     float    destx;
@property     float    desty;
@property     float    x;
@property     float    y;
@property     float    direction;                //the direction of the shot.  The opposite direction should point back to the shooter
@property     float    velocity;
@property     float    damage;
@property     float    damageradius;
@property     NSNumber *bulletID;
@end


@interface TankGame: NSObject

typedef enum {
    kPlaying = 1,
    kP1Wins,
    kP2Wins,
    kEndDraw
} GameState;

@property (strong, nonatomic) Tank* tank1;
@property (strong, nonatomic) Tank* tank2;
@property (strong, nonatomic) NSMutableArray *bullets;
@property (strong, nonatomic) NSMutableArray *impacts;
@property CGSize gameboard;
@property GameState gameState;

-(void) reset;
-(void) advance;

@end