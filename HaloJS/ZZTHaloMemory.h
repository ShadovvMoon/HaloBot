/*
 
 Copyright (c) 2014, Paul Whitcomb
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 * Neither the name of Paul Whitcomb nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */
//
//  ZZTHaloMemoryStructs.h
//  DarkAetherII
//
//  Created by Paul Whitcomb on 12/26/13.
//  Copyright (c) 2013 Paul Whitcomb. All rights reserved.
//

#include <stdlib.h>
#include <stdbool.h>
#include "ZZTHaloDataTypes.h"

#ifndef _ZZTHaloMemoryStructs_h
#define _ZZTHaloMemoryStructs_h

#define HALO_NULL -1

typedef struct {
    uint16_t headerId;                          //0x0
    uint16_t isHost;                            //0x2
    unichar name1[0xC];                         //0x4
    uint32_t unknown0;                          //0x1C
    uint32_t team;                              //0x20
    ObjectID interactionObjectID;               //0x24
    uint16_t interactionObjectIDType;           //0x28
    uint16_t unknown11;                         //0x2A
    uint32_t respawnTime;                       //0x2C
    uint32_t respawnTimeGrowth;                 //0x30
    ObjectID ObjectID;                          //0x34
    uint16_t objectType;                        //0x38
    uint16_t unknown12;                         //0x3A
    char unknown1[0xC];                         //0x3C
    unichar name2[0xC];                         //0x48
    uint32_t color;                             //0x60
    uint16_t machineIndex;                      //0x64
    uint16_t machineTeam;                       //0x66
    uint32_t invisibleTime;                     //0x68
    float speedMultiplier;                      //0x6C
    char unknown2[0x14];                        //0x70
    uint32_t lastDeathTime;                     //0x84
    uint32_t slayerTarget;                      //0x88
    char oddManOut;                             //0x8C
    char filler3a[0x3];                         //0x8E
    char unknown3[0x6];                         //0x90
    uint16_t killstreak;                        //0x96
    uint16_t multikill;                         //0x98
    uint16_t lastKillTime;                      //0x9A
    uint16_t kills;                             //0x9C
    uint16_t unknown4[3];                       //0x9E
    uint16_t assists;                           //0xA4
    uint16_t unknown5[3];                       //0xA6
    uint16_t betraysAndSuicides;                //0xAC
    uint16_t deaths;                            //0xAE
    uint16_t suicides;                          //0xB0
    char unknown6[0xE];                         //0xB4
    uint32_t teamkills;                         //0xC0
    uint16_t flagStealsHillRaceTime;            //0xC4
    uint16_t flagReturnsOddballKillsRaceLaps;   //0xC6
    uint16_t ctfScoreOddballKillsRaceBestTime;  //0xC8
    uint16_t filler7;                           //0xCA
    uint32_t telefragTimer;                     //0xCC
    char unknown7[0x4];                         //0xD0
    char telefragEnabled;                       //0xD4
    char unknown10[0x7];                        //0xD5
    uint16_t ping;                              //0xDC
    uint16_t filler10;                          //0xDE
    uint32_t teamkillCount;                     //0xE0
    uint32_t teamkillTimer;                     //0xE4
    char unknown8[0x10];                        //0xE8
    Vector vector;                              //0x98
    char unknown9[0xFC];                        //0x104
} __attribute__((packed)) Player;

typedef struct {
    TagID tagIdentity;                          //0x0
    char unknown0[0x58];                        //0x4
    Vector location;                            //0x5C
    Vector acceleration;                        //0x68
    Vector rotation1;                           //0x74
    Vector rotation2;                           //0x80
    char unknown1[0xC];                         //0x8C
    char unknown2[0x20];                        //0x98
    uint16_t team;                              //0xB8
    uint16_t unknown7;                          //0xBA
    char unknown3[0x8];                         //0xBC
    uint32_t player;                            //0xC4
    ObjectID owner;                             //0xC8
    char unknown4[0xC];                         //0xCC
    float maxHealth;                            //0xD8
    float maxShield;                            //0xDC
    float health;                               //0xE0
    float shield;                               //0xE4
    char unknown5[0x1C];                        //0xE8
    uint32_t shieldsRechargeDelay;              //0x104
    char unknown6[0x10];                        //0x108
    ObjectID heldWeaponIndex;                   //0x118
    ObjectID vehicleIndex;                      //0x11C
    uint32_t vehicleSeat;                       //0x120
} __attribute__((packed)) BaseObject;           //0x124

typedef struct {
    BaseObject objectData;                      //0x0
    char unknown0[0xE0];                        //0x124
    uint8_t camouflageData;                     //0x204
    char unknown6[0x3];                         //0x205
    uint32_t controlsBitmask;                   //0x208
    char unknown5[0xE6];                        //0x20C
    uint16_t weaponSlot;                        //0x2F2
    uint16_t nextWeaponSlot;                    //0x2F4
    uint16_t unknown1;                          //0x2F6
    ObjectID weapons[4];                        //0x2F8
    char unknown2[0x14];                        //0x308
    uint8_t nadeType;                           //0x31C
    char unknown3;                              //0x31D
    int8_t nadeCount[2];                        //0x31E
    uint16_t zoom;                              //0x320
    char unknown4[0x22];                        //0x322
    float flashlightBattery;                    //0x344
} __attribute__((packed)) BipedObject;          //0x348 - incomplete

typedef struct {
    BaseObject objectData;                      //0x0
    float fuel;                                 //0x124
    char unknown0[0x18];                        //0x128
    float charging;                             //0x140
    char unknown1[0xF8];                        //0x144
    float heat;                                 //0x23C
    float age;                                  //0x240
    uint32_t unknown2;                          //0x244
    float luminosity;                           //0x248
    char unknown3[0x6A];                        //0x24C
    uint16_t primaryAmmo;                       //0x2B6
    uint16_t primaryClip;                       //0x2B8
    char unknown4[0x8];                         //0x2BA
    uint16_t secondaryAmmo;                     //0x2C2
    uint16_t secondaryClip;                     //0x2C4
} __attribute__((packed)) WeaponObject;         //0x2C6 - incomplete

typedef struct {
    TagID tagIdentity;                          //0x0
    uint32_t mumboJumbo;                        //0x4
    BaseObject *object;                         //0x8
} __attribute__((packed)) ObjectIndex;

typedef struct {
    char objectString[0x20];
    uint16_t maximumObjectsPossible;
    uint16_t objectIndexStructSize;
    uint32_t one;
    char dataString[0x4];
    uint16_t numberOfObjects;
    uint16_t numberOfObjects1;
    uint32_t unknown1;
    ObjectIndex *objects;
} __attribute__((packed)) ObjectsTable;

typedef struct {
    char playersString[0x20];
    uint16_t maximumPlayersPossible;
    uint16_t playerStructSize;
    uint32_t numberOfPlayersIngameProbably;
    char dataString[0x4];
    uint32_t unknown0[0x3];
    Player players[0x10];
} __attribute__((packed)) PlayersTable;


PlayersTable *GetPlayersTable();
ObjectsTable *GetObjectsTable();
Player *GetPlayer(int player);
BaseObject *ObjectFromObjectTableIndex(uint16_t objectTableIndex);
BaseObject *ObjectFromObjectID(ObjectID ObjectID);
ObjectID ObjectIDFromPlayer(int playerInt);
ObjectID ObjectIDFromIndex(int object);
Player *PlayerFromObjectID(ObjectID ObjectID);
TagID SearchForTag(const char *name,const char *tagClass);
int GetBitOfBitmask(uint32_t bitmask, int bit);
uint32_t WriteBitToBitmask(uint32_t bitmask,int bit,int newValue,int size);
void *TagDataFromTagID(TagID tagID);
void *(*haloprintf)(ColorARGB *color, const char *message, ...);
char *MapName();
unsigned int GetTagCount();
TagID GetScenarioTagID();
bool IsHost();
bool IsMultiplayer();

#endif
