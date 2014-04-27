//
//  SMHaloHUD.h
//  HaloHUD
//
//  Created by Samuco on 11/23/13.
//  Copyright (c) 2013. All rights reserved.
//

// This class is set as the principle class in Info.plist
// It is important this class' name is unique, so use your favorite prefix

#import <Foundation/Foundation.h>
#import "MDPlugin.h"

BOOL shownMessage;
BOOL botIsActive;
struct point {
    float x;
    float y;
    float z;
};

struct point target;
float distance_to_target;

BOOL hasTarget = FALSE;
BOOL inVehicle = FALSE;
int targetIdentifier;

float shield;

float lastX;
float lastY;
float lastZ;
int stuck_timer;
BOOL isGunner;
BOOL humanDriver;
int BTimer;
int NTimer;
enum target {
    player,
    vehicle,
    friendly_player,
    friendly_vehicle
};
int targetType = player;
NSMutableDictionary *vehicle_tags;

BOOL isDead;
BOOL tabondeath;
int direction;
int next_time;
int dodge_tick;
int is_crouching;
int crouch_tick;

BOOL longRange;
enum currentAction {
    seek,
    attack,
    dodge,
};
int action = attack;

@interface SMHaloBot : NSObject <MDPlugin>
{
    BOOL pluginIsActive;
}
@end