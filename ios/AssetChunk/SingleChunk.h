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

-(id) initWithIndex:(long int)index;

@end

long int FirstByteOfChunk(long int chunk);
long int LastByteOfChunk(long int chunk);
long int ByteToContainingChunk(long int byte);
long int StartAndLengthToLastByte(long int start, long int length);
long int InclusiveBytesToLength(long int start, long int end);

#endif /* SingleChunk_h */
