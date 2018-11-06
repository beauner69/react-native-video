//
//  ChunkAssetLoaderDelegate.h
//  RCTVideo
//
//  The delegate, and the defacto boss of the whole process
//

#ifndef ChunkAssetLoaderDelegate_h
#define ChunkAssetLoaderDelegate_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class DataRequest;
@class SingleChunk;
@class HunkLoad;

typedef enum : NSUInteger {
    VIDEO,
    AUDIO
} CALGFormat;



@interface ChunkAssetLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic,strong) NSURL *fileUrl;

@property (nonatomic, strong) NSMutableArray<DataRequest*> *dataRequests;
@property (nonatomic, strong) NSMutableArray<SingleChunk*> *chunks;
@property (nonatomic, strong) NSMutableArray<HunkLoad*> *hunkLoads;

@property (nonatomic) CALGFormat format;
@property (nonatomic) long int totalSize;
@property (nonatomic) long int highestChunkRequestedSoFar;


-(id) initWithUrl:(NSURL *)url format:(CALGFormat)format;
- (void)chunkFinishedLoading:(SingleChunk*)who fromHunkLoad:(HunkLoad*)hunk;

@end

#endif /* ChunkAssetLoaderDelegate_h */
