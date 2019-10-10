//
//  HunkLoad.h
//  RCTVideo
//
//  A single http request to load one or more chunks, which is a hunk of chunks.
//

#ifndef HunkLoad_h
#define HunkLoad_h

#import <Foundation/Foundation.h>
#import "ChunkAssetLoaderDelegate.h"

@interface HunkLoad : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) ChunkAssetLoaderDelegate* owner;
@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSURLSessionDataTask * task;

@property (nonatomic) long int firstChunk;
@property (nonatomic) long int lastChunk;

@property (nonatomic) long int nextByte; // next byte to arrive will be this position in the file

@property (nonatomic) bool cancelled;

//- (void)LoadChunk: (NSURL*)url startAt:(long long)offset loadBytes:(long long)size resource:(AVAssetResourceLoadingRequest *)loadingRequest;

-(id) initWithChunkRange:(long int)firstChunk to:(long int)lastChunk ownedBy:(ChunkAssetLoaderDelegate*)owner;
- (long int)getTotalSizeFromHeaders;
-(void)cleanup;

@end

#endif /* ChunkLoad_h */
