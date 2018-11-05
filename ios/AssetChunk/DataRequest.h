//
//  DataRequest.h
//  RCTVideo
//
//  Represent a single asset delegate data request
//

#ifndef DataRequest_h
#define DataRequest_h

#import <AVFoundation/AVFoundation.h>
#import "ChunkAssetLoaderDelegate.h"

@interface DataRequest : NSObject

@property (nonatomic,strong) AVAssetResourceLoadingRequest *DR;

@property (nonatomic) long int firstChunk;
@property (nonatomic) long int lastChunk;

@property (nonatomic) long int nextByteToSend;
@property (nonatomic) long int bytesRemaining;
@property (nonatomic) long int nextChunkToSendFrom;

- (id) initWithDR:(AVAssetResourceLoadingRequest *) DR owner:(ChunkAssetLoaderDelegate*)owner;
- (bool) chanceToSendData:(ChunkAssetLoaderDelegate*)owner;
@end


#endif /* DataRequest_h */
