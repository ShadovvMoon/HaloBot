//
//  SMHaloHUD.m
//  HaloHUD
//
//  Created by Samuco on 11/23/13.
//  Copyright (c) 2013. All rights reserved.
//

#import "SMHaloBot.h"
#import "mach_override.h"
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>



//#define
//18/03/2014 1:45:41.790 pm Halo[8666]: Moving 0x402aaf90 to 0x16bf6000

//Players [0x5b52d0]
//mov eax, [0x37a2ac]	0x1BD600	A1 AC A2 37 00
//mov [0x37a2ac], edx	0x1BD61A	90 90 90 90 90 90
//	0x477588	server name
//	0x477725	32 <-- number of players (sent to the lobby)
//0x1B7459	add word [ebx+0x1a0], 0x1	66 83 83 A0 01 00 00 01
//	0x1BB4FC	0x477588
/*	0x37A2AC	10
 0xa10
 0x001b7459 668383A001000001                add        word [ds:ebx+0x1a0], 0x1
 
 
 
 0x4665A5	11
 0x477725	127
 0x173868F2	13*/

typedef struct { //Char values are 0x0 if they're off, and anything else if they're on.
    char jumping; //Jump
    char switchingGrenade; //Changing grenades
    char interacting; //Entering vehicles, activating machines, etc.
    char switchingWeapon;
    char meleeing;
    char flashlight;
    char nading; //Throwing grenades or secondary trigger
    char firing; //Primary trigger
    char unknown2[0x2]; //don't know what these do
    char crouching;
    char zooming;
    char scores; //Viewing scores.
    char reloading;
    char unknown3;
    char talk; //Brings primary chat up
    float unknown4; //Guessing it's a float, but it could also be chars. Hell if I know.
    float moveX; //-1.0 to 1.0 - It's really off/on, like 0.4 does the same as 1.0.
    float moveY; //-1.0 to 1.0
    float lookX; //-1.0 to 1.0 - This is like moving your mouse
    float lookY; //-1.0 to 1.0
} Controls;
Controls *GetPlayerControls() {
    return (Controls *)(0x368730);
}

@implementation SMHaloBot

typedef enum
{
    NONE = 0x0,
    WHITE = 0x343aa0,
    GREY = 0x343ab0,
    BLACK = 0x343ac0,
    RED = 0x343ad0,
    GREEN = 0x343ae0,
    BLUE = 0x343af0,
    CYAN = 0x343b00,
    YELLOW = 0x343b10,
    MAGENTA = 0x343b20,
    PINK = 0x343b30,
    COBALT = 0x343b40,
    ORANGE = 0x343b50,
    PURPLE = 0x343b60,
    TURQUOISE = 0x343b70,
    DARK_GREEN = 0x343b80,
    SALMON = 0x343b90,
    DARK_PINK = 0x343ba0
} ConsoleColor;

void (*consolePrintf)(int color, const char *format, ...) = (void *)0x1588a8;

short object_id_for_player(short player_number)
{
    if (player_number == -1)
        return -1;
    return (short)(*((int32_t *)(0x402AAFFC+0x200*player_number)));
}
int pointerToObject(short number)
{
    if (number == -1)
        return -1;
    
    long address = 0x400506E8 + number * 12 + 0x8;
    return (int)(*((int32_t *)(address)));
}
float readFloat(mach_vm_address_t pointer)
{
    float returnAddress;
    memcpy(&returnAddress, (const void*)pointer, 4);
    
    return returnAddress;
}
int readInt(mach_vm_address_t pointer)
{
    return (int)(*((int32_t *)(pointer)));
}
short readShort(mach_vm_address_t pointer)
{
    return (short)(*((int32_t *)(pointer)));
}
void writeChar(mach_vm_address_t pointer, char value)
{
    (*((int32_t *)(pointer))) = value;
}
char readChar(mach_vm_address_t pointer)
{
    char returnAddress;
    memcpy(&returnAddress, (const void*)pointer,1);
    
    return returnAddress;
    
    return (char)(*((int32_t *)(pointer)));
}
float x_coordinate(mach_vm_address_t pointerToObject)
{
    return readFloat(pointerToObject+0x5c);
}
float y_coordinate(mach_vm_address_t pointerToObject)
{
    return readFloat(pointerToObject+0x5c+4);
}
float z_coordinate(mach_vm_address_t pointerToObject)
{
    return readFloat(pointerToObject+0x5c+8);
}
void nopInstruction(mach_vm_address_t pointerToObject)
{
    memset((void *)pointerToObject, 0x90, 5);
}

void *(*oldRunCommand)(char *command,char *error_result, char *command_name) = NULL;
void runCommand(char *command,char *error_result, char *command_name)
{
    @autoreleasepool
    {
        NSArray *args = [[NSString stringWithFormat:@"%s",command] componentsSeparatedByString:@" "];
        if(strcmp(command_name,"ai_on") == 0 || strcmp(command_name,"ai_on2") == 0)
        {
            if (botIsActive)
            {
                consolePrintf(YELLOW, "AI is already active.");
                return;
            }
            
            if (strcmp(command_name,"ai_on2") == 0)
            {
                tabondeath = TRUE;
            }
            
            mprotect((void *)0xE0000,0x1FFFFE, PROT_READ|PROT_WRITE);
            int a1 = 0x13FEE2;
            int a2 = 0x13FEEF;
            memset((void*)a1, 0x90, 5);
            memset((void*)a2, 0x90, 5);
            
            int a3 = 0x2CA574;
            memset((void*)a3, 0x90, 5);
            
            
            /*Running Time	Self		Symbol Name
             1469.0ms   17.6%	0.0	 	         0x22fbc9
             Running Time	Self		Symbol Name
             15508.0ms   67.5%	0.0	 	        0x230201
             */
            
            
            mprotect((void *)0xE0000,0x1FFFFE, PROT_READ|PROT_EXEC);
            
            
            consolePrintf(GREEN, "AI activated. Type 'ai_off' to deactivate.");
            botIsActive = YES;
        }
        else if(strcmp(command_name,"attack") == 0)
        {
            action = attack;
        }
        else if(strcmp(command_name,"dodge") == 0)
        {
            action = dodge;
        }
        else if(strcmp(command_name,"seek") == 0)
        {
            action = seek;
        }
        else if(strcmp(command_name,"ai_off") == 0)
        {
            if (!botIsActive)
            {
                consolePrintf(YELLOW, "AI is already disabled.");
                return;
            }
            
            mprotect((void *)0xE0000,0x1FFFFE, PROT_READ|PROT_WRITE);
            int a1 = 0x13FEE2;
            int a2 = 0x13FEEF;
            memset((void*)a1, 0xA3, 1);
            memset((void*)a2, 0xA3, 1);
            a1+=1;
            a2+=1;
            memset((void*)a1, 0x30, 1);
            memset((void*)a2, 0x34, 1);
            a1+=1;
            a2+=1;
            memset((void*)a1, 0x15, 1);
            memset((void*)a2, 0x15, 1);
            a1+=1;
            a2+=1;
            memset((void*)a1, 0x3D, 1);
            memset((void*)a2, 0x3D, 1);
            a1+=1;
            a2+=1;
            memset((void*)a1, 0x00, 1);
            memset((void*)a2, 0x00, 1);
         
            //0x2CA574	call 0x5b5c56	E8 DD B6 2E 00
            int a3 = 0x2CA574;
            memset((void*)a3, 0xE8, 1);
            a3++;
            memset((void*)a3, 0xDD, 1);
            a3++;
            memset((void*)a3, 0xB6, 1);
            a3++;
            memset((void*)a3, 0x2E, 1);
            a3++;
            memset((void*)a3, 0x00, 1);
            a3++;
            
            mprotect((void *)0xE0000,0x1FFFFE, PROT_READ|PROT_EXEC);
            
            int a4 = 0x3D1320;
            int value = 0;
            memcpy((void*)a4, &value, 4);
            
            consolePrintf(RED, "AI disabled. Type 'ai_on' to activate.");
            botIsActive = NO;
        }
        else
            oldRunCommand(command,error_result,command_name);
    }
}

#define healthOffset 0xE0
#define shieldOffset 0xE4
#define xOffset 0x5C
#define yOffset 0x5C+4
#define zOffset 0x5C+8




CGFloat angleBetweenLinesInRad(CGPoint line1Start, CGPoint line1End, CGPoint line2Start, CGPoint line2End) {
    CGFloat a = line1End.x - line1Start.x;
    CGFloat b = line1End.y - line1Start.y;
    CGFloat c = line2End.x - line2Start.x;
    CGFloat d = line2End.y - line2Start.y;
    
    CGFloat atanA = atan2(a, b);
    CGFloat atanB = atan2(c, d);
    
    return atanA - atanB;
}

void *haloTick()
{

    int address = 0x37901C;
    if (readInt(address) != selectedAddress)
        memcpy((void*)address, &selectedAddress, 4);
    
    int address2 = 0x379020;
    selectedAddress+=1;
    if (readInt(address2) != selectedAddress)
        memcpy((void*)address2, &selectedAddress, 4);
    selectedAddress-=1;
    

    //Look at the target.
    char my_player_number = (char)(*((int32_t *)0x402AD404));
    short objectID = object_id_for_player(my_player_number);
    int pointer = pointerToObject(objectID);
    
    if (objectID == -1)
    {
        isDead = YES;
    }
    else if (isDead)
    {
        longRange = NO;
        isDead = NO;
    }
    
    
    if (!botIsActive)
        return oldhaloTick();
    
    int a4 = 0x3D1320;
    int value = 1;
    memcpy((void*)a4, &value, 4);
    
    if (pointer != -1)
    {
        char myteam = readChar(0x402AAFE8 + 0x200*my_player_number);
        
        //inVehicle
        
        float x = x_coordinate(pointer);
        float y = y_coordinate(pointer);
        float z = z_coordinate(pointer);
        
        shield = readFloat(pointer + 0x208);
        
        inVehicle = FALSE;
        isGunner = NO;
        
        float weapon_velocity = 1000;
        short weaponId = readShort(pointer+0x118);
        if (weaponId != -1)
        {
            BaseObject *weapon = ObjectFromObjectTableIndex(weaponId);
            if (weapon)
            {
                TagID tag = weapon->tagIdentity;
                HaloWeaponData *data = TagDataFromTagID(tag);
                data->aimAssistAutoaimRange*=2;
                //data->aimAssistMagnetismRange*=2;
                aimDistance = data->aimAssistMagnetismRange;
                
                Reflexive triggers = data->triggers;
                if (triggers.count > 0)
                {
                    HaloWeaponTrigger *triggers_pointer = triggers.pointer;
                    TagDependency proj = triggers_pointer->projectile;
                    TagID projectile_tag = proj.identity;
                    
                    
                    HaloProjectileTag *tag = TagDataFromTagID(projectile_tag);
                    if (tag)
                    {
                        weapon_velocity = tag->physicsFinalVelocity;
                    }
                }
            }
        }
        
        
        seatId = readShort(pointer+0x011C+2);
        short vehicleId = readShort(pointer+0x011C);
        if (vehicleId != -1)
        {
            BaseObject *v = ObjectFromObjectTableIndex(vehicleId);
            if (v)
            {
                TagID tag = v->tagIdentity;
                void *data = TagDataFromTagID(tag);
            }
        }
        

        //consolePrintf(RED, "%f", weapon_velocity);
        if (vehicleId != -1)
        {
            int Vpointer = pointerToObject(vehicleId);
            
           
            if (Vpointer != -1 && Vpointer != 0 && Vpointer != -2)
            {
                x = x_coordinate(Vpointer);
                y = y_coordinate(Vpointer);
                z = z_coordinate(Vpointer);
                
                short human_pid = readShort(Vpointer + 0x328);
                if (human_pid != -1)
                {
                    humanDriver = YES;
                }
                
                short gunner_pid = readShort(Vpointer + 0x32c);
                if (gunner_pid == objectID)
                {
                    isGunner = YES;
                }
                
                inVehicle = YES;
            }
        }
        x = readFloat(pointer+0xA8-8);
        y = readFloat(pointer+0xA8-4);
        z = readFloat(pointer+0xA8);
        
        float distance = sqrt(pow(lastX-x, 2)+pow(lastY-y, 2)+pow(lastZ-z, 2));
        if (distance > 2.0)
        {
            stuck_timer = 0;
            lastX = x;
            lastY = y;
            lastZ = z;
        }
        stuck_timer++;
        consolePrintf(ORANGE, "STUCK %d %d %d %d", stuck_timer, vehicle_stuck_seeker, lastStuckTarget, last2StuckTarget);
        
        
        float cx;
        float cy;
        float cz;
        
        BOOL forced = FALSE;
        int target_id = -1;
        float closest_distance = 1000;
        
        //Find a target
        int i;
        for (i=0; i < 16; i++)
        {
            if (my_player_number == i)
                continue;
            
            short objectIDP = object_id_for_player(i);
            int pointerP = pointerToObject(objectIDP);

            if (objectIDP > 2 && pointerP > 2)
            {
                char team = readChar(0x402AAFE8 + 0x200*i);
                float px = x_coordinate(pointerP);
                float py = y_coordinate(pointerP);
                float pz = z_coordinate(pointerP);

                short vehicleId = readShort(pointerP+0x011C);
                if (vehicleId != -1)
                {
                    int pointerV = pointerToObject(vehicleId);
                    if (pointerV != -1 && pointerV != 0 && pointerV != -2)
                    {
                        px = x_coordinate(pointerV);
                        py = y_coordinate(pointerV);
                        pz = z_coordinate(pointerV);
                    }
                }
                
                px = readFloat(pointerP+0xA8-8);
                py = readFloat(pointerP+0xA8-4);
                pz = readFloat(pointerP+0xA8);
                
                float vx = readFloat(pointerP+0x68);
                float vy = readFloat(pointerP+0x68+4);
                float vz = readFloat(pointerP+0x68+8);
                
                float distanceInfront = distance_to_target/weapon_velocity;
                distanceInfront+=1.0;
                
                
                if (seatId == 0 && inVehicle)
                    distanceInfront=distance_to_target;
                
                px+=vx*distanceInfront;
                py+=vy*distanceInfront;
                pz+=vz*distanceInfront;
                
                float distance = sqrt(pow(px-x, 2)+pow(py-y, 2)+pow(pz-z, 2));
                
                //if (inVehicle)
                //    distance = sqrtf(powf(pz-z, 2));
                
                if ((force_target == objectIDP) || (distance < closest_distance && myteam != team))
                {
                    closest_distance = distance;
                    target_id = i;
                    
                    if (vehicleId != -1)
                    {
                        targetIdentifier = vehicleId;
                        targetType = vehicle;
                    }
                    else
                    {
                        targetIdentifier = objectIDP;
                        targetType = player;
                    }
                    
                    cx = px;
                    cy = py;
                    cz = pz;
                    
                    if (force_target == objectIDP)
                    {
                        forced = YES;
                        break;
                    }
                }
            }
        }

        if (false)//!forced && closest_distance > 50.0 && !inVehicle && stuck_timer < 100)
        {
            
            //Are there any closer vehicles?
            int m;
            for (m=0; m < 1024; m++)
            {
                int pointerO = pointerToObject(m);
                if (pointerO > 0)
                {
                    // if it is biped, it is 0x0
                    // if it is vehicle, it is 0x1

                    int32_t originalTagId = readInt(pointerO);
                    NSNumber *tag = [NSNumber numberWithLong:originalTagId];
                    
                    if ([[vehicle_tags allKeys] containsObject:tag])
                    {
                        //Vehicle tag! Sync if its moving.
                        float px = readFloat(pointerO+0x5C);
                        float py = readFloat(pointerO+0x5C+4);
                        float pz = readFloat(pointerO+0x5C+8);
                        
                        //Is this closer than the closest dist
                        float distance = sqrt(pow(px-x, 2)+pow(py-y, 2)+pow(pz-z, 2));
                        if (distance < closest_distance)
                        {
                            if (m == lastStuckTarget || m == last2StuckTarget)
                                continue;
                            
                            closest_distance = distance;
                            target_id = m;
                            
                            cx = px;
                            cy = py;
                            cz = pz;
                            
                            //consolePrintf(YELLOW, "Found vehicle");
                            targetType = friendly_vehicle;
                            targetIdentifier = m;
                            break;
                        }
                    }
                    
                }
            }
        }
        else
        {
            //consolePrintf(RED, "Seeking %d (%f %f %f)", target_id, cx, cy, cz);
            
             xdelta = 0;
             ydelta = 0;
            int a1 = 0x3D1530;
            int a2 = 0x3D1534;
            
            memcpy((void*)a1, &xdelta, 4);
            memcpy((void*)a2, &ydelta, 4);
        }
        

        //Any players that are < 3 m?
        if (!forced && !inVehicle && stuck_timer < 100)
        {
        for (i=0; i < 16; i++)
        {
            if (my_player_number == i)
                continue;
            
            short objectIDP = object_id_for_player(i);
            int pointerP = pointerToObject(objectIDP);
            
            if (objectIDP > 2 && pointerP > 2)
            {
                char team = readChar(0x402AAFE8 + 0x200*i);
                float px = x_coordinate(pointerP);
                float py = y_coordinate(pointerP);
                float pz = z_coordinate(pointerP);
                
                short vehicleId = readShort(pointerP+0x011C);
                if (vehicleId != -1)
                {
                    int pointerV = pointerToObject(vehicleId);
                    if (pointerV != -1 && pointerV != 0 && pointerV != -2)
                    {
                        px = x_coordinate(pointerV);
                        py = y_coordinate(pointerV);
                        pz = z_coordinate(pointerV);
                    }
                }
                
                px = readFloat(pointerP+0xA8-8);
                py = readFloat(pointerP+0xA8-4);
                pz = readFloat(pointerP+0xA8);
                
                float distance = sqrt(pow(px-x, 2)+pow(py-y, 2)+pow(pz-z, 2));
                if (distance < 3 && myteam == team)
                {
                   
                    
                    if (vehicleId != -1)
                    {
                        if (vehicleId == lastStuckTarget || vehicleId == last2StuckTarget)
                            continue;
                        
                        targetIdentifier = vehicleId;
                        targetType = friendly_vehicle;
                        
                        closest_distance = distance;
                        target_id = i;
                        
                        //consolePrintf(GREEN, "Found friendly");
                        stuck_timer = 0;
                        
                        cx = px;
                        cy = py;
                        cz = pz;
                        
                        break;
                    }
                    else
                    {
                        //targetIdentifier = objectIDP;
                        //targetType = friendly_player;
                    }
                    
                }
            }
        }
        }
        
        if (stuck_timer > 150)
        {
            
            last2StuckTarget = lastStuckTarget;
            
            if (inVehicle)
                lastStuckTarget = vehicleId;
            else
                lastStuckTarget = targetIdentifier;
        }
        
        if (stuck_timer > 250)
        {

            
            //consolePrintf(WHITE, "Stuck");
            vehicle_stuck_seeker = arc4random() % 1000;
            
            //stuck_timer = 100;
            
            //Look at a random location
            //target.x = arc4random() % 500-250;
            //target.y = arc4random() % 500-250;
            //target.z = arc4random() % 20-10;
            
             xdelta = arc4random() % 30;
             ydelta = 0;
            int a1 = 0x3D1530;
            int a2 = 0x3D1534;
            
            int z = 0;
            memcpy((void*)a1, &xdelta, 4);
            memcpy((void*)a2, &ydelta, 4);
            
            return oldhaloTick();
        }
        if (vehicle_stuck_seeker > 0)
            vehicle_stuck_seeker--;
        

        
        if (target_id == -1)
        {
            vehicle_stuck_seeker = arc4random() % 100;
        }
        
        if (target_id != -1)
        {
            hasTarget = TRUE;
            
            distance_to_target = closest_distance;
            target.x = cx;
            target.y = cy;
            target.z = cz;
            
            int btr = 0x3B18B4;
            float rx = readFloat(btr);
            float ry = readFloat(btr+4);
            float rz = readFloat(btr+8);
            
            
            
            float dx = target.x - x;
            float dy = target.y - y;
            float dz = target.z - z;
            
            int speed = 180;

            CGFloat radx = angleBetweenLinesInRad(CGPointMake(x, y), CGPointMake(x+dx, y+dy), CGPointMake(x, y), CGPointMake(x+rx, y+ry));
            float angledegx = (radx/M_PI)*speed;
            CGFloat rady = angleBetweenLinesInRad(CGPointMake(y, z), CGPointMake(y+dy, z+dz), CGPointMake(y, z), CGPointMake(y+ry, z+rz));
            float angledegy = (rady/M_PI)*speed;

            CGFloat radian = acos(rx/sqrt(1 - pow(rz, 2)));
            if (ry > 0) radian=2*M_PI - radian;
            int neg = 1;
            
            if (botIsActive)
            {
                
                int a1 = 0x3D1530;
                int a2 = 0x3D1534;
            
                if (angledegx > speed/2)
                    angledegx = -angledegx+speed/2;
                
                if (radian > M_PI)
                    neg = -1;
                else
                    neg = 1;

                
                
                 xdelta = round(angledegx);
                 ydelta = round(angledegy*neg);
                
                if (angledegx < 0 && xdelta == 0)
                    xdelta = -1;
                else if (angledegx > 0 && xdelta == 0)
                    xdelta = 1;
                
                if (angledegy*neg < 0 && ydelta == 0)
                    ydelta = -1;
                else if (angledegy*neg > 0 && ydelta == 0)
                    ydelta = 1;
                
                ///consolePrintf(RED, "%d %d %f %f", xdelta, ydelta, radx, rady);

                //memcpy((void*)a1, &xdelta, 4);
                //memcpy((void*)a2, &ydelta, 4);
            }
        }
        else
            hasTarget = FALSE;
    }
    
    return oldhaloTick();


}

float distanceBetween(Vector v1, Vector v2)
{
    return sqrtf(powf(v2.x-v1.x, 2)+powf(v2.y-v1.y, 2)+powf(v2.z-v1.z, 2));
}

float *coordForObject(short objectIDP)
{
    float *coord = malloc(sizeof(float)*3);
    coord[0] = 0.0;
    coord[1] = 0.0;
    coord[2] = 0.0;
    
    int pointerP = pointerToObject(objectIDP);
    if (objectIDP > 2 && pointerP > 2)
    {
        float px = readFloat(pointerP+0xA8-8);
        float py = readFloat(pointerP+0xA8-4);
        float pz = readFloat(pointerP+0xA8);
        
        float vx = readFloat(pointerP+0x68);
        float vy = readFloat(pointerP+0x68+4);
        float vz = readFloat(pointerP+0x68+8);
        
        float distanceToPlayer = sqrtf(powf(ml.x-px, 2)+powf(ml.y-py, 2)+powf(ml.z-pz, 2));
        float distanceInfront = distanceToPlayer/weapon_velocity;
        distanceInfront+=1.0;
        
        if (seatId == 0 && inVehicle)
            distanceInfront=distance_to_target;
        
        px+=vx*distanceInfront;
        py+=vy*distanceInfront;
        pz+=vz*distanceInfront;
        
        coord[0] = px;
        coord[1] = py;
        coord[2] = pz;
    }
    consolePrintf(YELLOW, "0x%x %d", pointerP, objectIDP);
    return coord;
}

void (*oldReadControls)() = NULL;
void readControls()
{
    //0x3D1320 0 if tabbed
    //0x5FA045
    oldReadControls();
 
    if (action == seek && botIsActive)
    {
        haloTick();
     
    char my_player_number = (char)(*((int32_t *)0x402AD404));
    short objectID = object_id_for_player(my_player_number);
    int pointer = pointerToObject(objectID);
    
    Controls *player_control = GetPlayerControls();
    
    //Reset player control
    player_control->jumping = 0; //Jump
    player_control-> switchingGrenade = 0; //Changing grenades
    player_control-> interacting = 0; //Entering vehicles, activating machines, etc.
        
    switchTimer--;
    if (switchTimer < 0)
        player_control-> switchingWeapon = 0;
        
    player_control-> meleeing = 0;
    player_control-> flashlight = 0;
    player_control-> nading = 0; //Throwing grenades or secondary trigger
    player_control-> firing = 0; //Primary trigger
    player_control-> crouching = 0;
    player_control-> zooming = 0;
    player_control-> scores = 0; //Viewing scores.
    player_control-> reloading = 0;
    player_control-> talk = 0; //Brings primary chat up
    player_control-> unknown4 = 0.0; //Guessing it's a float, but it could also be chars. Hell if I know.
    player_control-> moveX = 0.0; //-1.0 to 1.0 - It's really off/on, like 0.4 does the same as 1.0.
    player_control-> moveY = 0.0; //-1.0 to 1.0
    
        
    if (pointer < 2)
        return;
    
           /*
    //A couple of important values
    weapon_velocity = 1000;
    short weaponId = readShort(pointer+0x118);
    if (weaponId != -1)
    {
        BaseObject *weapon = ObjectFromObjectTableIndex(weaponId);
        if (weapon)
        {
            TagID tag = weapon->tagIdentity;
            HaloWeaponData *data = TagDataFromTagID(tag);
            data->aimAssistAutoaimRange*=2;
            //data->aimAssistMagnetismRange*=2;
            
            aimDistance = data->aimAssistMagnetismRange;
            
            Reflexive triggers = data->triggers;
            if (triggers.count > 0)
            {
                HaloWeaponTrigger *triggers_pointer = triggers.pointer;
                TagDependency proj = triggers_pointer->projectile;
                TagID projectile_tag = proj.identity;
                
                HaloProjectileTag *tag = TagDataFromTagID(projectile_tag);
                if (tag)
                {
                    weapon_velocity = tag->physicsFinalVelocity;
                }
            }
        }
    }
    
    
    float tx = 0;
    float ty = 0;
    float tz = 0;
    
    BOOL has_target = FALSE;
    int players = 16;
    
    Player *me = GetPlayer(my_player_number);
    ObjectID player_object = ObjectIDFromPlayer(my_player_number);
    BaseObject *my_player = ObjectFromObjectID(player_object);
    
    if (!my_player)
        return;
   
    float mx = readFloat(pointer+0xA8-8);
    float my = readFloat(pointer+0xA8-4);
    float mz = readFloat(pointer+0xA8) + 0.65;
    
    ml = my_player->better_location;
    float aggro_range = 10.0;
    
    //Find a target location (x,y,z)
    BaseObject *target_object = nil;
    
    float lowest_shield = 3.0;
    float value[players];
    
    int i;
    for (i=0; i < players; i++)
    {
        if (i==my_player_number)
            continue;

        Player *p = GetPlayer(i);
        
        value[i] = 0.0;
        if (p->team == me->team)
        {
            value[i] -= 20.0;
            continue;
        }
        
        BOOL force_attack = (player_object.objectTableIndex == force_target);
        if (force_attack)
            value[i]+=30.0;
        
        ObjectID player_object = ObjectIDFromPlayer(i);
        BaseObject *player = ObjectFromObjectID(player_object);
        if (!player || object_id_for_player(i) == -1)
            value[i] = -1000.0;
        
        short objectIDP = object_id_for_player(i);
        int pointerP = pointerToObject(objectIDP);
        
        if (objectIDP > 2 && pointerP > 2)
        {
            
            float px = readFloat(pointerP+0xA8-8);
            float py = readFloat(player+0xA8-4);
            float pz = readFloat(player+0xA8) + 0.65;
            
            float distance = sqrtf(powf(px-mx, 2)+powf(py-my, 2)+powf(pz-mz, 2));;//distanceBetween(ml, player->better_location);
            
            value[i]-=distance/2.0;
            value[i]+= 1.0-player->shield*5.0;
            value[i]+= 1.0-player->health*5.0;
                
        }
    }
    
    //Who has the highest value?
    int target_player = -1;
    float highest_value = -50.0;
    for (i=0; i < players; i++)
    {
        if (i==my_player_number)
            continue;
        if (object_id_for_player(i) < 2)
            continue;
        
        consolePrintf(RED, "%d %f", i,value[i]);
        if (value[i] > highest_value)
        {
            target_player = i;
            highest_value = value[i];
        }
    }
    
    if (target_player == -1)
        return;
    
    //Where is this player?
    float *coords = coordForObject(object_id_for_player(target_player));
    
    int btr = 0x3B18B4;
    float rx = readFloat(btr);
    float ry = readFloat(btr+4);
    float rz = readFloat(btr+8);
    
    float dx = coords[0] - ml.x;
    float dy = coords[1] - ml.y;
    float dz = coords[2] - ml.z;
    
    int speed = 180;
    
    float x = ml.x;
    float y = ml.y;
    float z = ml.z;
    
    consolePrintf(RED, "%d %f %f %f %f", target_player,highest_value,coords[0],coords[1],coords[2]);
        
    CGFloat radx = angleBetweenLinesInRad(CGPointMake(x, y), CGPointMake(x+dx, y+dy), CGPointMake(x, y), CGPointMake(x+rx, y+ry));
    float angledegx = (radx/M_PI)*speed;
    CGFloat rady = angleBetweenLinesInRad(CGPointMake(y, z), CGPointMake(y+dy, z+dz), CGPointMake(y, z), CGPointMake(y+ry, z+rz));
    float angledegy = (rady/M_PI)*speed;
    
    CGFloat radian = acos(rx/sqrt(1 - pow(rz, 2)));
    if (ry > 0) radian=2*M_PI - radian;
    int neg = 1;
    
    if (angledegx > speed/2)
        angledegx = -angledegx+speed/2;
    
    if (radian > M_PI)
        neg = -1;
    else
        neg = 1;
    
    xdelta = round(angledegx);
    ydelta = round(angledegy*neg);
    
    if (angledegx < 0 && xdelta == 0)
        xdelta = -1;
    else if (angledegx > 0 && xdelta == 0)
        xdelta = 1;
    
    if (angledegy*neg < 0 && ydelta == 0)
        ydelta = -1;
    else if (angledegy*neg > 0 && ydelta == 0)
        ydelta = 1;
    

    
    int z2 = 0;
    int a1 = 0x3D1530;
    int a2 = 0x3D1534;
    memcpy((void*)a1, &z2, 4);
    memcpy((void*)a2, &z2, 4);
    */
        
        int z2 = 0;
        int a1 = 0x3D1530;
        int a2 = 0x3D1534;
        memcpy((void*)a1, &z2, 4);
        memcpy((void*)a2, &z2, 4);
        player_control-> lookX = -xdelta/360.0; //-1.0 to 1.0 - This is like moving your mouse
        player_control-> lookY = ydelta/360.0; //-1.0 to 1.0
    

        if (stuck_timer > 200)
        {
            BTimer++;
            if (BTimer < 30)
            {
                //stuck_timer = 0;
                //consolePrintf(YELLOW, "Entering vehicle");
                player_control->interacting = 0xFF;
            }
            else
                BTimer = 0;
            
            player_control->moveX = 1.0;
            player_control->jumping = 0xFF;
        }
        
        if (inVehicle)
        {
            kA = FALSE;
            kD = FALSE;
            k1 = FALSE;
            k2 = FALSE;
        }
        

        if (isDriver)
        {
            consolePrintf(YELLOW, "Driving");
            
            if (!nearAllies || shield < 1.0)
                player_control->moveX = 1.0;
            player_control->firing = 1;
            return;
        }
        else if (isGunner)
        {
            consolePrintf(YELLOW, "GUNNING");
            player_control->firing = 1;
            return;
        }
        
        if (inVehicle && !isGunner && !isDriver)
        {
            stuck_timer = 205;
        }
        
        if (kA || kD || k1 || k2)
            stuck_timer = 0;
        
        if ((distance_to_target > 3.0 && shield >= 1.0 && !(kA || kD || k1 || k2) && time_since_hit > 100) || (targetType == friendly_vehicle) || (targetType== friendly_player))
        {
            player_control->reloading = 1;
        }
        
        if (kA)
            player_control->moveY = 1.0;
        else if (kD)
            player_control->moveY = -1.0;
        else if (k1)
            player_control->jumping = 0xFF;
        else if (k2)
            player_control->crouching = 0xFF;
        
        char canAction = readChar(0x40000814);
        if (canAction == 1)
        {
            consolePrintf(YELLOW, "Action");

            BTimer++;
            if (BTimer < 30)
            {
                //stuck_timer = 0;
                //consolePrintf(YELLOW, "Entering vehicle");
                player_control->interacting = 0xFF;
            }
            else
                BTimer = 0;
        }
        else
        {
            player_control->moveX = 1.0;
        }
        
        float zoomScope = readFloat(0x3B18B0);
        if (((zoomScope > 1.0 && distance_to_target > aimDistance) || (zoomScope < 1.0 && distance_to_target < aimDistance)))
        {
            NTimer++;
            if (NTimer < 10)
            {
                player_control->zooming = 1;
            }
            else
                NTimer = 0;
        }
        
        if (distance_to_target < 1.0)
            player_control->meleeing = 1;
        

        if (longRange && distance_to_target < 3)
        {
            switchTimer = 100;
            player_control->switchingWeapon = 0xFF;
            longRange = NO;
        }
        
        if (!longRange && distance_to_target > 3)
        {
            switchTimer = 100;
            player_control->switchingWeapon = 0xFF;
            longRange = YES;
        }
        
        if (switchTimer > 0)
            consolePrintf(CYAN, "SWITCHING WEPS %d", switchTimer);
        
        if (longRange)
            consolePrintf(BLUE, "long range");
        else
            consolePrintf(BLUE, "short range");
        
        consolePrintf(YELLOW, "Attack");

        shoot_tick++;
        time_since_hit++;
        if (targetType != friendly_player && targetType != friendly_vehicle)
        {
            char inScope = readChar(0x400008C8);
            if (inScope)
            {
                if (shoot_tick > 2)
                {
                    time_since_hit = 0;
                    shoot_tick = 0;
                    player_control->firing = 1;
                }
            }
        }
        
        

        if (inVehicle)
        {
            //Which seat?
            int ppointer = pointerToObject(objectID);
            if (ppointer != -1)
            {
                seatId = readShort(ppointer+0x011C+2);
                short vehicleId = readShort(ppointer+0x011C);
                if (vehicleId != -1)
                {
                    BaseObject *v = ObjectFromObjectTableIndex(vehicleId);
                    if (v)
                    {
                        TagID tag = v->tagIdentity;
                        HaloVehicleData *data = TagDataFromTagID(tag);
                        Reflexive halo_seats = data->seats;
                        
                        if (halo_seats.count > seatId)
                        {
                            int *offset = halo_seats.pointer + 284*seatId;
                            int bitmask = *offset;
                            
                            if (GetBitOfBitmask(bitmask, 30) == 1)
                                isDriver = YES;
                            else
                                isDriver = NO;
                            
                            if (GetBitOfBitmask(bitmask, 29) == 1)
                                isGunner = YES;
                            else
                                isGunner = NO;
                        }
                    }
                }
            }
        }
        
        //What is the target vector? EVERYTHIGN Ahahaha
        int ppointer = pointerToObject(objectID);
        if (ppointer != -1)
        {
            float px = readFloat(ppointer+0xA8-8);
            float py = readFloat(ppointer+0xA8-4);
            float pz = readFloat(ppointer+0xA8) + 0.65;
            float prx = readFloat(ppointer+0x230);
            float pry = readFloat(ppointer+0x234);
            float prz = readFloat(ppointer+0x238);
            float d = px*prx + py*pry + pz*prz;
            char my_team = readChar(0x402AAFE8 + 0x200*my_player_number);
            
            k1 = FALSE;
            k2 = FALSE;
            kD = FALSE;
            kA = FALSE;
            nearAllies = FALSE;
            
            time_since_force++;
            if (time_since_force > 100)
            {
                time_since_force=0;
                force_target = -1;
            }
            
            float closest_force = 10000.0;
            //Find a target
            int i;
            for (i=0; i < 16; i++)
            {
                if (my_player_number == i)
                    continue;
                
                short objectIDP = object_id_for_player(i);
                int pointer = pointerToObject(objectIDP);
                
                if (objectIDP != -1 && pointer > 2 && pointer > 2)
                {
                    char team = readChar(0x402AAFE8 + 0x200*i);
                    if (my_team != team)
                    {
                        float x = readFloat(pointer+0xA8-8);
                        float y = readFloat(pointer+0xA8-4);
                        float z = readFloat(pointer+0xA8) + 0.65;
                        float rx = readFloat(pointer+0x230);
                        float ry = readFloat(pointer+0x234);
                        float rz = readFloat(pointer+0x238);
                        float k = -(x*prx + y*pry + z*prz - d)/(rx*prx + ry*pry + rz*prz);
                        float vx = x + k*rx;
                        float vy = y + k*ry;
                        float vz = z + k*rz;
                        short vehicleId = readShort(pointer+0x011C);
                        float distanceP = sqrtf(powf(x-px, 2)+powf(y-py, 2)+powf(z-pz, 2));
                        
                        if (vehicleId != -1 && distanceP < 3.0)
                        {
                            k1 = TRUE;
                            k2 = FALSE;
                            
                            player_control->moveX = 0.0;
                            
                            //Dance for me!
                            if (dodge_tick <= 0)
                            {
                                if (direction == 1)
                                    direction = 0;
                                else
                                    direction = 1;
                                
                                dodge_tick = arc4random()%6000;
                            }
                            
                            if (direction == 0)
                                kA = TRUE;
                            
                            if (direction == 1)
                                kD = TRUE;
                            
                            if (arc4random()%5000 == 0)
                            {
                                is_crouching = 1;
                                crouch_tick = arc4random()%10000;
                            }
                            
                            if (crouch_tick <=0)
                            {
                                is_crouching = 0;
                            }
                            
                            dodge_tick--;
                            crouch_tick--;
                            
                            
                            
                            
                            break;
                        }
                        
                        //Is this point to the left or right of us? Well, define left?
                        float distance = sqrtf(powf(vx-px, 2)+powf(vy-py, 2)+powf(vz-pz, 2));
                        if (distance < 1.0)
                        {
                            if (distanceP < closest_force)
                            {
                                closest_force = distanceP;
                                force_target = objectIDP;
                                time_since_force = 0;
                                
                                if (vz < z)
                                    k1 = TRUE;
                                
                                if (vz > z)
                                    k2 = TRUE;
                                
                                
                                float line_length = 20.0;
                                float dx = px + prx*line_length;
                                float zx = px-dx;
                                float xx = px-vx;
                                float xy = py-vy;
                                
                                float v = zx*xy - xx*xy;
                                
                                if (v > 0)
                                    kD = TRUE;
                                else
                                    kD = FALSE;
                                
                                if (v < 0)
                                    kA = TRUE;
                                else
                                    kA = FALSE;
                                /*
                                 //Dodge
                                 if (key == 'A' && direction == 0)
                                 return key_down;
                                 
                                 if (key == 'D' && direction == 1)
                                 return key_down;
                                 */
                                
                                if (previousDistance < distance)
                                {
                                    if (direction == 1)
                                        direction = 0;
                                    else
                                        direction = 1;
                                }
                            }
                        }
                        previousDistance = distance;
                    }
                    else
                    {
                        float x = readFloat(pointer+0xA8-8);
                        float y = readFloat(pointer+0xA8-4);
                        float z = readFloat(pointer+0xA8) + 0.65;
                        float distance = sqrtf(powf(x-px, 2)+powf(y-py, 2)+powf(z-pz, 2));
                        short vehicleId = readShort(pointer+0x011C);
                        
                        if (vehicleId == -1 && distance < 4.0)
                        {
                            nearAllies = YES;
                        }
                    }
                }
            }
        }
    }
}

int (*oldKeyDown)(int8_t key) = NULL;
int keyDown(int8_t key)
{
    return oldKeyDown(key);
    
    
    char my_player_number = (char)(*((int32_t *)0x402AD404));
    short objectID = object_id_for_player(my_player_number);
    /*

    
    //
    //
    //
    //
    //
    //
    //
    //
    //
    //
    //0x13e726 <----- WHERE HALO READS CONTROLS
    //https://gist.github.com/Halogen002/69c0cabf81fa3ad0ebbf
    //
    //
    //
    //
    //
    //
    //
    //
    //
    //
    
    //Avoidance code
    int key_down = (-1) << 0xf;
    if (action == seek && botIsActive && hasTarget)
    {
        if (objectID == -1)
        {
            isDead = YES;
        }
        else if (isDead)
        {
            longRange = NO;
            isDead = NO;
        }
        
        
        if (stuck_timer > 200)
        {
            if (key == 'B' || key == 'W' || key == '1')
                return key_down;
        }
        
        if (inVehicle)
        {
            kA = FALSE;
            kD = FALSE;
            k1 = FALSE;
            k2 = FALSE;
        }
        
        if (isDriver)
        {
            if (key == 'A')
                consolePrintf(YELLOW, "Driving");
            
            if (!nearAllies || shield < 1.0)
                if (key == 'W')
                    return key_down;
            
            if (key == ' ')
                return key_down;
            
            return oldKeyDown(key);
        }
        else if (isGunner)
        {
            if (key == 'A')
                consolePrintf(YELLOW, "GUNNING");

            if (key == ' ')
                return key_down;
            return oldKeyDown(key);
        }
        
        if (inVehicle && !isGunner && !isDriver)
        {
            stuck_timer = 200;
        }
        
        if (kA || kD || k1 || k2)
            stuck_timer = 0;
        
        if ((distance_to_target > 3.0 && shield >= 1.0 && !(kA || kD || k1 || k2) && time_since_hit > 100) || (targetType == friendly_vehicle) || (targetType== friendly_player))
        {
            if (key == 'J')
                return key_down;
        }
        
        if (key == 'A' && kA)
            return key_down;
        else if (key == 'D' && kD)
            return key_down;
        else if (key == '1' && k1)
            return key_down;
        else if (key == '2' && k2)
            return key_down;
        
        char canAction = readChar(0x40000814);
        if (canAction == 1)
        {
            if (key == 'A')
                consolePrintf(YELLOW, "Action");
            if (key == 'B')
            {
                BTimer++;
                if (BTimer < 10)
                {
                    //stuck_timer = 0;
                    //consolePrintf(YELLOW, "Entering vehicle");
                    return key_down;
                }
                else
                    BTimer = 0;
            }
        }
        else
        {
            if (key == 'W')
                return key_down;
        }
        
        float zoomScope = readFloat(0x3B18B0);
        if (key == 'N' && ((zoomScope > 1.0 && distance_to_target > aimDistance) || (zoomScope < 1.0 && distance_to_target < aimDistance)))
        {
            NTimer++;
            if (NTimer < 10)
            {
                //consolePrintf(YELLOW, "Entering vehicle");
                return key_down;
            }
            else
                NTimer = 0;
        }
        
        if (key == 'H' && distance_to_target < 1.0)
            return key_down;
        
        if (key == '	')
        {
            if (longRange && distance_to_target < 3)
            {
                longRange = NO;
                return key_down;
            }
            
            if (!longRange && distance_to_target > 3)
            {
                longRange = YES;
                return key_down;
            }
            
            return oldKeyDown(key);
        }
        
        if (key == 1)
            consolePrintf(YELLOW, "Attack");
        
       
        if (key == ' ')
        {
            shoot_tick++;
            time_since_hit++;
            if (targetType != friendly_player && targetType != friendly_vehicle)
            {
                char inScope = readChar(0x400008C8);
                if (inScope)
                {
                    if (shoot_tick > 2)
                    {
                        time_since_hit = 0;
                        shoot_tick = 0;
                        return key_down;
                    }
                }
            }
        }
        
        if (key == 0)
        {
            if (inVehicle)
            {
                //Which seat?
                int ppointer = pointerToObject(objectID);
                if (ppointer != -1)
                {
                    seatId = readShort(ppointer+0x011C+2);
                    short vehicleId = readShort(ppointer+0x011C);
                    if (vehicleId != -1)
                    {
                        BaseObject *v = ObjectFromObjectTableIndex(vehicleId);
                        if (v)
                        {
                            TagID tag = v->tagIdentity;
                            HaloVehicleData *data = TagDataFromTagID(tag);
                            Reflexive halo_seats = data->seats;
                            
                            if (halo_seats.count > seatId)
                            {
                                int *offset = halo_seats.pointer + 284*seatId;
                                int bitmask = *offset;
                                
                                if ((30 & bitmask) == 30)
                                    isDriver = YES;
                                else
                                    isDriver = NO;
                                
                                if ((29 & bitmask) == 29)
                                    isGunner = YES;
                                else
                                    isGunner = NO;
                            }
                        }
                    }
                }
            }

            //What is the target vector? EVERYTHIGN Ahahaha
            int ppointer = pointerToObject(objectID);
            if (ppointer != -1)
            {
                float px = readFloat(ppointer+0xA8-8);
                float py = readFloat(ppointer+0xA8-4);
                float pz = readFloat(ppointer+0xA8) + 0.65;
                float prx = readFloat(ppointer+0x230);
                float pry = readFloat(ppointer+0x234);
                float prz = readFloat(ppointer+0x238);
                float d = px*prx + py*pry + pz*prz;
                char my_team = readChar(0x402AAFE8 + 0x200*my_player_number);
                
                k1 = FALSE;
                k2 = FALSE;
                kD = FALSE;
                kA = FALSE;
                nearAllies = FALSE;
                
                time_since_force++;
                if (time_since_force > 10)
                {
                    time_since_force=0;
                    force_target = -1;
                }
                
                //Find a target
                int i;
                for (i=0; i < 16; i++)
                {
                    if (my_player_number == i)
                        continue;
                
                    short objectIDP = object_id_for_player(i);
                    int pointer = pointerToObject(objectIDP);
                    
                    if (objectIDP != -1 && pointer > 2 && pointer > 2)
                    {
                        char team = readChar(0x402AAFE8 + 0x200*i);
                        if (my_team != team)
                        {
                            float x = readFloat(pointer+0xA8-8);
                            float y = readFloat(pointer+0xA8-4);
                            float z = readFloat(pointer+0xA8) + 0.65;
                            float rx = readFloat(pointer+0x230);
                            float ry = readFloat(pointer+0x234);
                            float rz = readFloat(pointer+0x238);
                            float k = -(x*prx + y*pry + z*prz - d)/(rx*prx + ry*pry + rz*prz);
                            float vx = x + k*rx;
                            float vy = y + k*ry;
                            float vz = z + k*rz;
                            short vehicleId = readShort(pointer+0x011C);
                            float distanceP = sqrtf(powf(x-px, 2)+powf(y-py, 2)+powf(z-pz, 2));
                            
                            if (vehicleId != -1 && distanceP < 3.0)
                            {
                                k1 = TRUE;
                                k2 = FALSE;
                                
                                
                                
                                //Dance for me!
                                if (dodge_tick <= 0)
                                {
                                    if (direction == 1)
                                        direction = 0;
                                    else
                                        direction = 1;
                                    
                                    dodge_tick = arc4random()%6000;
                                }
                                
                                if (direction == 0)
                                    kA = TRUE;
                                
                                if (direction == 1)
                                    kD = TRUE;
                                
                                if (arc4random()%5000 == 0)
                                {
                                    is_crouching = 1;
                                    crouch_tick = arc4random()%10000;
                                }
                                
                                if (crouch_tick <=0)
                                {
                                    is_crouching = 0;
                                }
                                
                                dodge_tick--;
                                crouch_tick--;

                                
                                
                        
                                break;
                            }
                            
                            //Is this point to the left or right of us? Well, define left?
                            float distance = sqrtf(powf(vx-px, 2)+powf(vy-py, 2)+powf(vz-pz, 2));
                            if (distance < 1.0)
                            {
                                force_target = objectIDP;
                                time_since_force = 0;
                                
                                if (vz < z)
                                    k1 = TRUE;
                                
                                if (vz > z)
                                    k2 = TRUE;
                                
             
                                float line_length = 20.0;
                                float dx = px + prx*line_length;
                                float zx = px-dx;
                                float xx = px-vx;
                                float xy = py-vy;
                                
                                float v = zx*xy - xx*xy;
                                
                                if (v > 0)
                                    kD = TRUE;
                                else
                                    kD = FALSE;
                                
                                if (v < 0)
                                    kA = TRUE;
                                else
                                    kA = FALSE;
     
                                
                                if (previousDistance < distance)
                                {
                                    if (direction == 1)
                                        direction = 0;
                                    else
                                        direction = 1;
                                }
                            }
                            previousDistance = distance;
                        }
                        else
                        {
                            float x = readFloat(pointer+0xA8-8);
                            float y = readFloat(pointer+0xA8-4);
                            float z = readFloat(pointer+0xA8) + 0.65;
                            float distance = sqrtf(powf(x-px, 2)+powf(y-py, 2)+powf(z-pz, 2));
                            short vehicleId = readShort(pointer+0x011C);
                            
                            if (vehicleId == -1 && distance < 4.0)
                            {
                                nearAllies = YES;
                            }
                        }
                    }
                }
            }
        }

        //action = attack;
        return oldKeyDown(key);
   
    }


    if (botIsActive && hasTarget)
    {
       
        

        
        if (objectID == -1)
        {
            isDead = YES;
        }
        else if (isDead)
        {
            longRange = NO;
            isDead = NO;
        }
        
        
        if (key == '	')
        {
            if (longRange && distance_to_target < 3)
            {
                longRange = NO;
                return key_down;
            }
            
            if (!longRange && distance_to_target > 3)
            {
                longRange = YES;
                return key_down;
            }
            
            return oldKeyDown(key);
        }
        
        /*
        if (humanDriver)
        {
            BOOL evacuate = TRUE;
            char my_player_number = (char)(*((int32_t *)0x402AD404));
            short objectID = object_id_for_player(my_player_number);
            int pointer = pointerToObject(objectID);
            
            if (pointer != -1)
            {
                short vehicleId = readShort(pointer+0x011C);
                if (vehicleId != -1)
                {
                    int Vpointer = pointerToObject(vehicleId);
                    if (Vpointer != -1 && Vpointer != 0 && Vpointer != -2)
                    {
                        short human_pid = readShort(Vpointer + 0x328);
                        if (human_pid == -1)
                        {
                            evacuate = YES;
                        }
                    }
                }
            }
            if (evacuate)
            {
                stuck_timer = 302;
                consolePrintf(RED, "EVACUATE");
                humanDriver = FALSE;
            }
        }
        
        if (humanDriver)
            stuck_timer = 0;
     
        
        if (stuck_timer > 100 || vehicle_stuck_seeker > 0)
        {
            if (key == 'B')
                return key_down;
            if (key == 'W')
                return key_down;
            if (key == '1' && !inVehicle)
                return key_down;
            return oldKeyDown(key);
        }
        
        //	0x477FA2	1 driving

        //0x408A23F0 gunner
        //0x408A23E0 driver
        
        if (key == ' ' && shouldShoot)
        {
            shoot_tick++;
            if (shoot_tick < 2)
            {
                //stuck_timer = 0;
                //consolePrintf(YELLOW, "Entering vehicle");
                return key_down;
            }
            else
                shoot_tick = 0;
        }
        
        //0x32C = passenger
        //+0x328 = driver
        //	0x4005A768	59
        //  0x4005A440
        
        //Scope randomly
        float zoomScope = readFloat(0x3B18B0);
        if (key == 'N' && ((zoomScope > 1.0 && distance_to_target > 5.0) || (zoomScope < 1.0 && distance_to_target < 5.0)))
        {
            NTimer++;
            if (NTimer < 10)
            {
                //consolePrintf(YELLOW, "Entering vehicle");
                return key_down;
            }
            else
                NTimer = 0;
        }
        
        char canAction = readChar(0x40000814);
        if (canAction == 1)
        {
            if (key == 'B')
            {
                BTimer++;
                if (BTimer < 10)
                {
                    //stuck_timer = 0;
                    //consolePrintf(YELLOW, "Entering vehicle");
                    return key_down;
                }
                else
                    BTimer = 0;
            }
        }
        else
        {
            if (inVehicle)
            {
                if (key == 'W')
                    return key_down;
                shouldShoot = YES;
                if (key == '1')
                    return 0;
                if (key == '2')
                    return 0;
                
                action = attack;
            }
            
            //	 <- tab

            if (targetType == friendly_vehicle)
            {
                if (key == 'D')
                    return key_down;
            }

            //Avoidance code
            if (action == seek)
            {
                
                //Do nothing.
                //action = attack;
            }
            else if (action == attack)
            {
                if (key == 'A')
                    consolePrintf(CYAN, "ATTACK");
                
                if (key == 'W')
                    return key_down;
                
                char inScope = readChar(0x400008C8);
                
                if (targetType != friendly_player && targetType != friendly_vehicle)
                {
                    if (inScope)
                        shouldShoot = YES;
                    else
                        shouldShoot = inVehicle;
                    
                    if (key == 'H' && distance_to_target < 1.0)
                        return key_down;
                
                    if ((int)key == -66 && distance_to_target>1.0 && distance_to_target<5.0)
                        return key_down;
                    
                    if (vehicle)
                    {
                        if ((distance_to_target < 8.0) || shield < 1.0)
                            action = dodge;
                    }
                    else
                    {
                        if ((distance_to_target > 2.0 && distance_to_target < 5.0) || shield < 1.0)
                            action = dodge;
                    }
                }
            }
            else if (action == dodge)
            {
                //  stuck_timer = 0;
                
                //Predict the player attack vector and avoid it
                if (targetIdentifier != -1)
                {
                    if (targetType == player)
                    {
                        if (key == 'A')
                            consolePrintf(CYAN, "DODGE PLAYER");
                        
                        if (vehicle)
                        {
                            if ((distance_to_target > 8.0) && shield >= 1.0)
                                action = attack;
                        }
                        else
                        {
                            if ((distance_to_target < 2.0 || distance_to_target > 5.0) && shield >= 1.0)
                                action = attack;
                        }
                        

                        if ((distance_to_target < 2.0 || distance_to_target > 5))
                        {
                            if (key == 'W')
                                return key_down;
                        }
                        
                        //Dance for me!
                        if (dodge_tick <= 0)
                        {
                            if (direction == 1)
                                direction = 0;
                            else
                                direction = 1;
                            
                            dodge_tick = arc4random()%6000;
                        }

                        if (key == 'A' && direction == 0)
                            return key_down;
   
                        if (key == 'D' && direction == 1)
                            return key_down;
                        
                        if (arc4random()%5000 == 0)
                        {
                            is_crouching = 1;
                            crouch_tick = arc4random()%10000;
                        }
                        
                        if (key == '2' && is_crouching == 1)
                            return key_down;

                        if (crouch_tick <=0)
                        {
                            is_crouching = 0;
                        }
                        
                        dodge_tick--;
                        crouch_tick--;
                        
                        //Shoot and nade them
                        char inScope = readChar(0x400008C8);
                        if (inScope)
                            shouldShoot = YES;
                        else
                            shouldShoot = inVehicle;
                        
                        if (key == 'H' && distance_to_target < 1.0)
                            return key_down;
                        
                        //if ((int)key == -66 && distance_to_target>3.0 && distance_to_target<10.0)
                        //    return key_down;
                    }
                    else if (targetType == vehicle)
                    {
                        if (key == 'A')
                            consolePrintf(CYAN, "DODGE VEHICLE");
                        
                        //Dance for me!
                        if (dodge_tick <= 0)
                        {
                            if (direction == 1)
                                direction = 0;
                            else
                                direction = 1;
                            
                            dodge_tick = arc4random()%50000;
                        }
                        
                        if (key == 'A' && direction == 0)
                            return key_down;
                        
                        if (key == 'D' && direction == 1)
                            return key_down;
                        
                        if (arc4random()%5000 == 0)
                        {
                            is_crouching = 1;
                            crouch_tick = arc4random()%5000;
                        }
                        
                        if (key == '1' && is_crouching == 1)
                            return key_down;
                        
                        if (crouch_tick <=0)
                        {
                            is_crouching = 0;
                        }
                        
                        dodge_tick--;
                        crouch_tick--;
                        
                        //Shoot and nade them
                        char inScope = readChar(0x400008C8);
                        if (inScope)
                            shouldShoot = YES;
                        else
                            shouldShoot = inVehicle;
                        if ((int)key == -66 && distance_to_target>2.0 && distance_to_target < 5.0)
                            return key_down;
                    }
                    else if (targetType == friendly_player || targetType == friendly_vehicle)
                    {
                        if (key == 'A')
                            consolePrintf(CYAN, "FRIENDLY");
                        
                        if (distance_to_target > 0.3)
                            if (key == 'W')
                                return key_down;
                    }
                }
            }
        }
    }
   
    */
    return oldKeyDown(key);
}

void *(*oldhaloTick)() = NULL;
void (*oldrenderObjects)() = NULL;
- (id)initWithMode:(MDPluginMode)mode
{
	self = [super init];
	if (self != nil)
	{
        selectedAddress = arc4random() % 20000;

        mach_override_ptr((void *)0x13e726, readControls, (void **)&oldReadControls);
        mach_override_ptr((void *)0x2c17ae, keyDown, (void **)&oldKeyDown);
        mach_override_ptr((void *)0x11e3de, runCommand, (void **)&oldRunCommand);
        mach_override_ptr((void *)0x001473a8, haloTick, (void **)&oldhaloTick);
	}
	return self;
}
void deprotectMemory(void*address)
{
    //Make the original function implementation writable.
    mach_error_t	err = err_none;
	if( !err ) {
		err = vm_protect( mach_task_self(),
                         (vm_address_t) address, 8, false,
                         (VM_PROT_ALL | VM_PROT_COPY) );
		if( err )
            err = vm_protect( mach_task_self(),
                             (vm_address_t) address, 8, false,
                             (VM_PROT_DEFAULT | VM_PROT_COPY) );
	}
	if (err) fprintf(stderr, "err = %x %s:%d\n", err, __FILE__, __LINE__);
}

-(void)activatePlugin
{
    consolePrintf(GREEN, "Halo Bot 1.0 - by Samuco");
    consolePrintf(RED, "AI disabled. Type 'ai_on' to activate.");
    pluginIsActive = YES;
}
NSString *readUTF8String(mach_vm_address_t pointerToObject)
{
    NSMutableData *mutableData = [[NSMutableData alloc] init];
    char returnAddress;
    while (YES)
    {
        memcpy(&returnAddress, (const void*)pointerToObject, sizeof(char));
        
        //short shortValue = (short)returnAddress;
        [mutableData appendBytes:&returnAddress length:sizeof(char)];
        if (returnAddress == '\0')
		{
			break;
		}
        pointerToObject += sizeof(char);
    }
    NSString *stringRepresentation = [[NSString alloc] initWithData:mutableData encoding:NSUTF8StringEncoding];
    return stringRepresentation;
}
- (void)mapDidBegin:(NSString *)mapName
{
    //We the host?
    int tag_address = 0x40440028;
    vehicle_tags = [[NSMutableDictionary alloc] init];
    
    int a;
    for (a=0; a < 5000; a++)
    {
        if (memcmp((void*)tag_address, "ihev", 4) == 0)
        {
            uint32_t pointer;
            memcpy(&pointer, (void*)(tag_address+16), 4);
            
            uint32_t tagId;
            memcpy(&tagId, (void*)(tag_address+12), 4);
            
            [vehicle_tags setObject:@"" forKey:[NSNumber numberWithLong:tagId]];
        }
        tag_address+=32;
    }
    
    [self performSelector:@selector(activatePlugin) withObject:nil afterDelay:2];
}

- (void)mapDidEnd:(NSString *)mapName
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(activatePlugin) object:nil];
    
    if (pluginIsActive)
    {
        pluginIsActive = NO;
    }
}
@end
