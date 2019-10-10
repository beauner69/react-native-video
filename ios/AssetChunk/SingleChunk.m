//
//  SingleChunk.m
//  RCTVideo
//
//

#import <Foundation/Foundation.h>
#import "SingleChunk.h"

@implementation SingleChunk

-(id) initWithIndex:(long int)index {
    if (self = [super init]) {
        _index = index;
        _keystone = false;
        _state = EMPTY;
        _loaded = 0;
        _chunkData = [NSMutableData data];
    }
    
    return self;

}

-(long int) loadBytesFrom:(NSData*)data maximum:(long int)bytesLeft filePos:(long int)filePos dataPos:(long int)dataPos owner:(ChunkAssetLoaderDelegate*)_owner hunk:(HunkLoad*)hunk finishing:(bool)finishing{
    long int targetOffset = ByteToByteInsideChunk(filePos);
    if (_loaded != targetOffset) {
        NSLog(@"ERROR ASSETCHUNK - Stuffing bytes in expected file pos to be %li but its %li",_loaded,targetOffset);
        return 1;
    }
    
    // Check how many bytes we can take
    long int bytesCanTake = CHUNK_SIZE-_loaded;
    long int bytesTaken = 0;
    
    if ((dataPos == 0) && (bytesLeft <= bytesCanTake)) {
        // We can take them all
        [self.chunkData appendData:data];
        bytesTaken = bytesLeft;
    } else {
        // We need to chop out the bytes we are taking
        long int bytesToTake = (bytesLeft < bytesCanTake) ? bytesLeft:bytesCanTake;
        [self.chunkData appendData:[data subdataWithRange:NSMakeRange(dataPos, bytesToTake)]];
        bytesTaken = bytesToTake;
    }
    
    // Check if the chunk is now complete
    _loaded += bytesTaken;
    if ((_loaded >= CHUNK_SIZE) || finishing) {
        _state = READY;
        [_owner chunkFinishedLoading:self fromHunkLoad: hunk];
    }
    
    return bytesTaken;
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

long int ByteToByteInsideChunk(long int byte) {
    return byte % CHUNK_SIZE;
}
