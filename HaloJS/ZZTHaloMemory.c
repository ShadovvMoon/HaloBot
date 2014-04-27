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
//  ZZTHaloMemoryStructs.c
//  DarkAetherII
//
//  Created by Paul Whitcomb on 12/26/13.
//  Copyright (c) 2013 Paul Whitcomb. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include "ZZTHaloMemory.h"

#define PLAYERS_ARRAY_POINTER 0x45E5A8
#define OBJECT_TABLE_POINTER 0x47871C
#define HALO_PRINTF 0x1588a8
#define MAP_INDEX 0x40440000

void *(*haloprintf)(ColorARGB *color, const char *message, ...) = (void *)HALO_PRINTF;

typedef struct {
	uint32_t classA;
	uint32_t classB;
	uint32_t classC;
	TagID identity;
	char *name;
	void *data;
	char padding[0x8];
} __attribute__((packed)) Tag;

static Tag *mapTagArray = NULL;

typedef struct {
	Tag *tagArray;
	TagID scenarioTag;
	uint32_t mapId;
	uint32_t tagCount;
	uint32_t vertexObjectCount;
	uint32_t vertexOffset;
	uint32_t indicesObjectCount;
	uint32_t vertexSize;
	uint32_t modelSize;
	char tagsSignature[0x4];
} __attribute__((packed)) MapIndex;

PlayersTable *GetPlayersTable() {
    return (PlayersTable *)(*(uint32_t *)PLAYERS_ARRAY_POINTER);
}

uint32_t swapEndian32(uint32_t integer) {
    char *swappedValue = calloc(4,1);
    swappedValue[3] = integer       & 0xFF;
    swappedValue[2] = integer >> 8  & 0xFF;
    swappedValue[1] = integer >> 16 & 0xFF;
    swappedValue[0] = integer >> 24 & 0xFF;
    return *(uint32_t *)swappedValue;
}

TagID SearchForTag(const char *name,const char *tagClass) {
    MapIndex *index = (MapIndex *)(MAP_INDEX);
    uint32_t classLittle = swapEndian32(*(uint32_t *)tagClass);
    for(uint32_t i=0;i<index->tagCount; i++) {
        if(strcmp(name,index->tagArray[i].name) == 0 && index->tagArray[i].classA == classLittle)
            return index->tagArray[i].identity;
    }
    ColorARGB *color = calloc(sizeof(ColorARGB),0x1);
    color->alpha = 1.0;
    color->red = 1.0;
    haloprintf(color,"ERROR: Failed to find tag %s",name);
    free(color);
    return NullTagID;
}

Player *GetPlayer(int player) {
    return &(*GetPlayersTable()).players[player];
}
ObjectsTable *GetObjectsTable() {
    return (ObjectsTable *)(*(uint32_t *)OBJECT_TABLE_POINTER);
}
BaseObject *ObjectFromObjectTableIndex(uint16_t objectTableIndex)
{
    if(objectTableIndex == 0xFFFF)
        return NULL;
    else
        return (GetObjectsTable())->objects[objectTableIndex].object;
}
BaseObject *ObjectFromObjectID(ObjectID ObjectID)
{
    return ObjectFromObjectTableIndex(ObjectID.objectTableIndex);
}
Player *PlayerFromObjectID(ObjectID ObjectID) {
    for(uint32_t i=0;i<GetPlayersTable()->maximumPlayersPossible;i++) {
        Player *player = GetPlayer(i);
        if(player->ObjectID.objectTableIndex == ObjectID.objectTableIndex) return player;
    }
    return NULL;
}
ObjectID ObjectIDFromPlayer(int playerInt) {
    Player *player = GetPlayer(playerInt);
    return player->ObjectID;
}
ObjectID ObjectIDFromIndex(int object) {
    ObjectID objid = {object,0xE174 + object};
    return objid;
}
TagID GetScenarioTagID() {
    return ((MapIndex *)(MAP_INDEX))->scenarioTag;
}
void *TagDataFromTagID(TagID tagID)
{
    MapIndex *index = (MapIndex *)(MAP_INDEX);
    if(tagID.tagTableIndex >= index->tagCount)
        return NULL;
    return index->tagArray[tagID.tagTableIndex].data;
}
int GetBitOfBitmask(uint32_t bitmask,int bit)
{
    return (bitmask >> bit) & 1;
}
uint32_t WriteBitToBitmask(uint32_t bitmask,int bit,int newValue,int size)
{
    uint32_t k = 0;
    for(int i=0;i<32;i++)
    {
        uint32_t s = GetBitOfBitmask(bitmask,i);
        if(size*8-1-i == bit) s = newValue;
        s = (s << i);
        k+=s;
    }
    return k;
}
bool IsHost() {
    return *(int8_t *)(0x3D79DC) != 1;
}

bool IsMultiplayer() {
    return *(int8_t *)(0x3D79DC) != 0;
}
char *MapName() {
    return *(void **)(0x70F0C) + 0x20;
}
unsigned int GetTagCount() {
    return ((MapIndex *)(MAP_INDEX))->tagCount;
}