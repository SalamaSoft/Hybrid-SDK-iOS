//
//  IpAddress.h
//  
//
//  Created by XingGu Liu on 12-6-29.
//  Copyright (c) 2012年 Salama. All rights reserved.
//

#ifndef SalamaUtil_IpAddress_h
#define SalamaUtil_IpAddress_h

#define MAXADDRS    32  

extern char *if_names[MAXADDRS];  
extern char *ip_names[MAXADDRS];  
extern char *hw_addrs[MAXADDRS];  
extern unsigned long ip_addrs[MAXADDRS];  

// Function prototypes  

void InitAddresses();  
void FreeAddresses();  
void GetIPAddresses();  
void GetHWAddresses();

#endif
