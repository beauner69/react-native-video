//
//  ChunkLoader.h
//  RCTVideo
//

#ifndef ChunkLoader_h
#define ChunkLoader_h


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ChunkLoader : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *chunkData;
@property (nonatomic, strong) AVAssetResourceLoadingRequest * loadingRequest;

- (void)LoadChunk: (NSURL*)url startAt:(long long)offset loadBytes:(long long)size resource:(AVAssetResourceLoadingRequest *)loadingRequest;

@end

#endif /* ChunkLoader_h */
