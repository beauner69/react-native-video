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

@interface ChunkAssetLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic,strong) NSURL *fileUrl;

@property (nonatomic, strong) NSMutableArray<DataRequest*> *dataRequests;
@property (nonatomic, strong) NSMutableArray<SingleChunk*> *chunks;
@property (nonatomic, strong) NSMutableArray<HunkLoad*> *hunkLoads;

@property (nonatomic) long int totalSize;


-(id) initWithUrl:(NSURL *)url;
- (void)chunkFinishedLoading:(SingleChunk*)who fromHunkLoad:(HunkLoad*)hunk;

@end

#endif /* ChunkAssetLoaderDelegate_h */
