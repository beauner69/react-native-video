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

#import "SingleChunk.h"
#import "HunkLoad.h"
#import "DataRequest.h"

@interface ChunkAssetLoaderDelegate : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic,strong) NSURL *fileUrl;

@property (nonatomic, strong) NSMutableArray<DataRequest*> *dataRequests;
@property (nonatomic, strong) NSMutableArray<SingleChunk*> *chunks;
@property (nonatomic, strong) NSMutableArray<HunkLoad*> *hunkLoads;


-(id) initWithUrl:(NSURL *)url;

@end

#endif /* ChunkAssetLoaderDelegate_h */
