//
//  EZCountryCellViewController.h
//  EZ Tube
//
//  Created by dan mullaguru on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EZCountryCellViewDelegate <NSObject>

-(void) showChangeCountryAlert:(NSString *) newCountry;

@end


@interface EZCountryCellView : UIView
@property (retain, nonatomic) IBOutlet UIImageView *flagImageView;
@property (retain, nonatomic) IBOutlet UIImageView *flagBorderImageView;

@property (retain, nonatomic) IBOutlet UILabel *countryNameLbl;

@property (nonatomic, retain) NSString * countryCode ;
@property (nonatomic, retain) NSString * countryName ;
@property (strong, nonatomic) id<EZCountryCellViewDelegate> delegate;
-(void)refreshToCountryCode:(NSString *)toCountryCode;
@end
