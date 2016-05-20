//
//  EZChannelSearchVideoCellView.h
//  EZ Tube
//
//  Created by dan mullaguru on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol EZFeedDisplayVideoCellViewDelegate <NSObject>
-(void) loadVideoInPage:(NSString *)videoId title:(NSString *)title videoSeqNum:(int)videoSeqNum;
-(void) loadVideoInPage:(NSString *)videoId title:(NSString *)title channelId:(NSString *)channelId videoSeqNum:(int)videoSeqNum;
-(void) loadAllVideosInExternalPlayerStartingWithVideoIndex:(int)index;
@end


@interface EZFeedDisplayVideoCellView : UIView
{
     id<EZFeedDisplayVideoCellViewDelegate>	delegate;
     dispatch_queue_t imagedDownloadQueue;
}
@property (nonatomic, assign) id<EZFeedDisplayVideoCellViewDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIImageView *videoImageView;
@property (retain, nonatomic) IBOutlet UILabel *videoTitleLbl;
@property (retain, nonatomic) IBOutlet UILabel *videoUploadDateLbl;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *videoDownloadIndicator;
@property int videoSeqNoInPage;
@property int videoIndex;
@property (retain, nonatomic) NSString * videoId;
@property (retain, nonatomic) NSString * videoTitle;
@property (retain, nonatomic) NSString * channelId;
@property (retain, nonatomic) NSString * videoThumbNailURLString;
@property (retain, nonatomic) NSString * videoURL;
@property BOOL imageDownloaded;
@property (nonatomic) dispatch_queue_t imagedDownloadQueue;

-(void) loadImageView;

@end
