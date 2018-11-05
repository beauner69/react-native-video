//
//  SingleChunk.h
//  RCTVideo
//
// Represents a single chunk of data being loaded in
//

#ifndef SingleChunk_h
#define SingleChunk_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ChunkAssetLoaderDelegate.h"

#define CHUNK_SIZE 65536

typedef enum : NSUInteger {
    EMPTY,
    WANTED,
    LOADING,
    READY,
} ChunkState;

@interface SingleChunk : NSObject

@property (nonatomic, strong) NSMutableData *chunkData;
@property (nonatomic) bool keystone;
@property (nonatomic) ChunkState state;
@property (nonatomic) long int index;
@property (nonatomic) long int loaded;

-(id) initWithIndex:(long int)index;
-(long int) loadBytesFrom:(NSData*)data maximum:(long int)bytesLeft filePos:(long int)filePos dataPos:(long int)dataPos owner:(ChunkAssetLoaderDelegate*)_owner hunk:(HunkLoad*)hunk finishing:(bool)finishing;

@end

long int FirstByteOfChunk(long int chunk);
long int LastByteOfChunk(long int chunk);
long int ByteToContainingChunk(long int byte);
long int StartAndLengthToLastByte(long int start, long int length);
long int InclusiveBytesToLength(long int start, long int end);
long int ByteToByteInsideChunk(long int byte);

#endif /* SingleChunk_h */
