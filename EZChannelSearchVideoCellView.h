//
//  EZChannelSearchVideoCellView.h
//  EZ Tube
//
//  Created by dan mullaguru on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EZChannelSearchVideoCellViewDelegate <NSObject>
-(void) popVideo:(NSString *)videoId title:(NSString *)title;
-(void) popVideo:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId;
-(void) loadAllVideosInExternalPlayerStartingWithVideoIndex:(int)index;
@end


@interface EZChannelSearchVideoCellView : UIView
{
     id<EZChannelSearchVideoCellViewDelegate>	delegate;
     dispatch_queue_t channelSearchVideoFeedDownloadQueue;
}
@property (nonatomic, assign) id<EZChannelSearchVideoCellViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIImageView *videoImageView;
@property (retain, nonatomic) IBOutlet UILabel *videoTitleLbl;
@property (retain, nonatomic) IBOutlet UILabel *videoUploadDateLbl;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *videoDownloadIndicator;
@property int videoIndex;
@property (retain, nonatomic) NSString * videoId;
@property (retain, nonatomic) NSString * videoTitle;
@property (retain, nonatomic) NSString * channelId;
@property (retain, nonatomic) NSString * videoThumbNailURLString;
@property (retain, nonatomic) NSString * videoURL;
@property (nonatomic) dispatch_queue_t channelSearchVideoFeedDownloadQueue;
@property BOOL imageDownloaded;

-(void) loadImageView;

@end
