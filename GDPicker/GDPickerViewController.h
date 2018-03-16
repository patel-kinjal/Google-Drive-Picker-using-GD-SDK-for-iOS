//
//  GDPickerViewController.h
//  GDPicker
//
//  Created by Kinjal Patel on 11/07/17.
//  Copyright © 2017 Kinjal Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <GTLRDrive.h>

@class GDPickerViewController;

@protocol GDPickerDelegate <NSObject>

@optional

-(void) dismissPickerViewController:(GDPickerViewController*) pickerVC;
-(void) gd_filePickerViewController:(GDPickerViewController*) pickerVC didFinishSelectingFile:(GTLRDrive_File*) file;
-(void) gd_filePickerViewController:(GDPickerViewController*) pickerVC didFinishSelectingFiles:(NSArray*) files;

@end

@interface GDPickerViewController : UIViewController

@property (nonatomic, weak) id<GDPickerDelegate> gdPickerDelegate;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *folderNameLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *googleFilesCollectionView;

@property (nonatomic, assign) NSInteger lastIndexPath;
@property (nonatomic, strong) NSMutableArray *driveFiles;
@property (nonatomic, strong) NSMutableArray *gdFileStack;
@property (nonatomic, strong) GTLRDrive_File *lastGDFileSelected;

@end
