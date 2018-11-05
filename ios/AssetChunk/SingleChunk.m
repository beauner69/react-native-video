//
//  SingleChunk.m
//  RCTVideo
//
//

#import <Foundation/Foundation.h>
#import "SingleChunk.h"

@implementation SingleChunk

-(id) initWithIndex:(int)index {
    if (self = [super init]) {
        _index = index;
        _keystone = false;
        _state = EMPTY;
    }
    
    return self;

}


@end


long int FirstByteOfChunk(long int chunk){
    return chunk * CHUNK_SIZE;
}

long int LastByteOfChunk(long int chunk){
    return chunk * CHUNK_SIZE + (CHUNK_SIZE-1);

}

long int ByteToContainingChunk(long int byte){
    return byte / CHUNK_SIZE; // I hope it auto floors...
}

long int StartAndLengthToLastByte(long int start, long int length){
    return start + length - 1;
}

long int InclusiveBytesToLength(long int start, long int end){
    return end - start + 1;
}

