//
//  MP4Cacher.m
//  RCTVideo
//
//  Created by Beau Ner Chesluk on 05/11/2018.
//  Copyright © 2018 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChunkAssetLoaderDelegate.h"
#import "SingleChunk.h"

NSInteger Chonks[36] = {
    0, // CHONK
    2, // CHONK
    6, // CHONK
    10, // CHONK
    19, // CHONK2018-11-05 20:51:29.208420+0000 wrath[9935:3322689] 23, // CHONK
    31, // CHONK
    38, // CHONK
    42, // CHONK
    53, // CHONK
    58, // CHONK
    67, // CHONK
    70, // CHONK
    79, // CHONK
    85, // CHONK
    94, // CHONK
    100, // CHONK
    103, // CHONK
    107, // CHONK
    116, // CHONK
    126, // CHONK
    136, // CHONK
    137, // CHONK
    144, // CHONK
    147, // CHONK
    152, // CHONK
    158, // CHONK
    165, // CHONK
    173, // CHONK
    184, // CHONK
    193, // CHONK
    199, // CHONK
    215, // CHONK
    229, // CHONK
    241, // CHONK
    258, // CHONK
    270, // CHONK
};

unsigned int const SIDX_TAG = 0x73696478;

void CacheMP4BasedOffChunk(ChunkAssetLoaderDelegate * owner, SingleChunk * chunk) {
    /* Our mission: Scan through this partial MP4 and find the sidx tag in the hopes that it is present. Then cache all the spots that apple are gonna want. */
//    return;
    int pointer = 0;
    unsigned long maxChunk = [owner.chunks count];
    
    while (pointer < chunk.loaded-8) {
        unsigned int length = CFSwapInt32BigToHost(((unsigned int*)&((char*)chunk.chunkData.bytes)[pointer])[0]);
        unsigned int type = CFSwapInt32BigToHost(((unsigned int*)&((char*)chunk.chunkData.bytes)[pointer+4])[0]);
//        NSLog(@"MIFFY LENGTH= %u",length);
//        NSLog(@"MIFFY TYPE= %u",type);
        
        
        unsigned int interestingSpotToIos = pointer + length;
        
        if (type == SIDX_TAG) {
//            NSLog(@"MIFFY IT IS SIDX");
            
            // HURRAH LETS PARSE THE FUCK OUT OF ITQ
            char version = ((char*)chunk.chunkData.bytes)[pointer+8];
//            NSLog(@"MIFFY VERSION %i",version);
            
            int subPointer = pointer+(version == 0? 30:38);
            unsigned short count = CFSwapInt16BigToHost(((unsigned short*)&((char*)chunk.chunkData.bytes)[subPointer])[0]);
            
            subPointer += 2;
            while (count > 0) {
                
                // Mark the interesting spot to ios as a chunk to preload
                unsigned long interestingChunk = ByteToContainingChunk(interestingSpotToIos);
                if (interestingChunk < maxChunk) {
                    SingleChunk * chunk = owner.chunks[interestingChunk];
                    if (chunk.state == EMPTY){
                        chunk.state = WANTED;
                    }
                }
                
                


                // get the size of this chunk thing and advance our interesting spot pointer, so next time around we are on top of it.
                unsigned int referenced_size = CFSwapInt32BigToHost(((unsigned int*)&((char*)chunk.chunkData.bytes)[subPointer])[0]) & 0x7fffffff;
//                NSLog(@"MIFFY REFSIZE %u %i",referenced_size,count);
                subPointer += 12;
                count--;
                interestingSpotToIos += referenced_size;
            }
            
//            NSLog(@"MIFFY COUNT=%i",count);
            return; // We are done
            
        }
        pointer += length;
    }
    
}








