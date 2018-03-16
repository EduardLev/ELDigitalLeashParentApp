//
//  ViewController.h
//  DigitalLeashParentApp
//
//  Created by Eduard Lev on 2/16/18.
//  Copyright © 2018 Eduard Levshteyn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "NSURL+ELWIthUserName.h"

@interface ViewController : UIViewController

// YES if internet is available, NO if not available
@property (nonatomic) BOOL internet;

// NSDictionary that will eventually hold the JSON
@property (nonatomic) NSDictionary *dict;

// Where radius, latitude, longitude and username is stored
@property (nonatomic) User *user;

// Properties for Error View and Error Text
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UITextField *errorTextField;

// Properties for checking child location from JSON
@property (nonatomic) double current_latitude;
@property (nonatomic) double current_longitude;
@property (nonatomic) double distance;

// Label outlets to change color during error
@property (weak, nonatomic) IBOutlet UILabel *zoneLongitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *zoneLatitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *radiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

// Button outlets: Create, Update, Status
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

// Text Field outlets: Username, Radius, Longitude, Latitude
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *radiusTextField;
@property (weak, nonatomic) IBOutlet UITextField *parentLongitudeTextFieldInput;
@property (weak, nonatomic) IBOutlet UITextField *parentLatitudeTextFieldInput;
@property (weak, nonatomic) NSString *username;
@property (weak, nonatomic) NSNumber *radius;
@property (weak, nonatomic) NSNumber *latitude;
@property (weak, nonatomic) NSNumber *longitude;

// GRAPHICS METHODS
- (void)finishUpdatingUI;
- (void)createRoundedButtons;
- (void)addRoundedCornersToButton:(UIButton*)button;
- (void)createIndentedTextInput;
- (void)addIndentToTextField:(UITextField*)textField;
- (void)setLabelToErrorColor:(UILabel*)label andTextField:(UITextField*)field;
- (void)setLabelToWhiteColor:(UILabel*)label andTextField:(UITextField*)field;
- (UIColor *)colorFromHexString:(NSString*)hexString;
- (UIColor*)getErrorColor;

// VALIDATION FUNCTIONS
- (BOOL)validateInput;
- (BOOL)validateUsername:(NSString*)username;
- (BOOL)validateRadius:(NSNumber*)radius;
- (BOOL)validateLatitude:(NSNumber*)latitude;
- (BOOL)validateLongitude:(NSNumber*)longitude;

// USER AND NETWORKING FUNCTIONS
- (void)createUser;
- (void)sendUserToFirebase;
- (void)createURLRequestToFirebase:(NSData*)userData;
- (NSDictionary*)createDictionaryFromCurrentUser;
- (NSData*)putDictionaryIntoJSON:(NSDictionary*)dict;
- (BOOL)updateUser;
- (void)checkChildLocationAndSegue;
- (void)getJSONFromFirebase;


@end

