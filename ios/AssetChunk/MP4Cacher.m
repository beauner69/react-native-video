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

void CacheMP4BasedOffChunk(ChunkAssetLoaderDelegate * owner, SingleChunk * chunk) {
    for (int n = 0; n < 36; n++) {
        SingleChunk * chunk = owner.chunks[Chonks[n]];
        if (chunk.state == EMPTY){
        chunk.state = WANTED;
            
        }
    }
}








