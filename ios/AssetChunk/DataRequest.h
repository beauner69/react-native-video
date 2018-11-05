//
//  DataRequest.h
//  RCTVideo
//
//  Represent a single asset delegate data request
//

#ifndef DataRequest_h
#define DataRequest_h

#import <AVFoundation/AVFoundation.h>

@interface DataRequest : NSObject

@property (nonatomic,strong) AVAssetResourceLoadingRequest *DR;

- (id) initWithDR:(AVAssetResourceLoadingRequest *) DR;

@end


#endif /* DataRequest_h */
