//
//  EditVideoFeedViewController.h
//  TSVideos
//
//  Created by dan mullaguru on 11/14/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"
#import "LocalizationSystem.h"


@protocol EditVideoFeedViewControllerDelegate <NSObject>

-(void) editVideoFeedRecord ;
-(void) editActiveStatusForFeed:(NSString *) sourceId changed:(BOOL)changed toStatus:(BOOL)isMadeActive;

@end

@interface EditVideoFeedViewController : UIViewController
{
    id<EditVideoFeedViewControllerDelegate> delegate;
    Feed * feedObject;
    NSMutableDictionary * videoFeed;
}
@property (nonatomic, retain) LocalizationSystem * ls;
@property (strong, nonatomic) id<EditVideoFeedViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UILabel *displayName;


@property (retain, nonatomic) IBOutlet UISwitch *isActive;

@property (retain, nonatomic) IBOutlet UILabel *sourceSite;


@property (strong, nonatomic) Feed * feedObject;
@property (strong, nonatomic) NSMutableDictionary * videoFeed;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property BOOL isMadeActive; 
@property BOOL isActiveStatusChanged;
@property (retain, nonatomic) IBOutlet UIImageView *flagImage;
@property (retain, nonatomic) IBOutlet UIImageView *categoryImage;

@property (retain, nonatomic) IBOutlet UIButton *saveButton;

- (IBAction)editVideoFeedLocal:(id)sender;

-(IBAction)activeStatusChanged:(id)sender;

@end

