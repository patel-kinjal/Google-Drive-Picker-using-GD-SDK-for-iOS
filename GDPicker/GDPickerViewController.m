//
//  GDPickerViewController.m
//  GDPicker
//
//  Created by Kinjal Patel on 11/07/17.
//  Copyright © 2017 Kinjal Patel. All rights reserved.
//

#import "GDPickerViewController.h"
#import "GDFolderFileCollectionViewCell.h"

#import "GTMSessionFetcherService.h"
#import "GTMSessionFetcherLogging.h"

#import "SVProgressHUD.h"

@interface GDPickerViewController () <GIDSignInDelegate, GIDSignInUIDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) GTLRDriveService *service;

@end

@implementation GDPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    GIDGoogleUser *currentUser = [GIDSignIn sharedInstance].currentUser;
    
    if (!currentUser) {
        [[GIDSignIn sharedInstance] signIn];
    }
}

- (void) setUp {
    
    self.googleFilesCollectionView.delegate = self;
    self.googleFilesCollectionView.dataSource = self;
    
    self.lastIndexPath = 0;
    self.lastGDFileSelected = [[GTLRDrive_File alloc] init];
    self.gdFileStack = [[NSMutableArray alloc] init];
    [self.gdFileStack insertObject:@"ROOT" atIndex:self.lastIndexPath];
    
    self.folderNameLabel.text = @"ROOT";
    self.backButton.hidden = YES;
    
    [self.googleFilesCollectionView registerClass:[GDFolderFileCollectionViewCell class] forCellWithReuseIdentifier:@"GDFolderFileCollectionViewCell"];
    
    GIDSignIn* signIn = [GIDSignIn sharedInstance];
    signIn.delegate = self;
    signIn.uiDelegate = self;
    signIn.scopes = [NSArray arrayWithObjects:kGTLRAuthScopeDrive, nil];
    [signIn signInSilently];
    
    self.service = [[GTLRDriveService alloc] init];
    self.service.shouldFetchNextPages = YES;
    self.service.retryEnabled = YES;
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GTLRDrive_File *file = [self.driveFiles objectAtIndex:indexPath.row];
    
    if ([file.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
        
        self.lastIndexPath++;
        self.folderNameLabel.text = file.name;
        self.backButton.hidden = NO;
        self.lastGDFileSelected = file;
        [self.gdFileStack insertObject:file atIndex:self.lastIndexPath];
        
        [self listAllFilesInFolder:file.identifier];
    }
    
    else if ([file.mimeType isEqualToString:@"image/jpeg"] || [file.mimeType isEqualToString:@"image/png"] || [file.mimeType isEqualToString:@"image/jpg"] ) {
        
        GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:file.identifier];
        [SVProgressHUD show];
        [self.service executeQuery:query
                 completionHandler:^(GTLRServiceTicket *callbackTicket,
                                     GTLRDataObject *dataObject,
                                     NSError *error) {
                     
                     [SVProgressHUD dismiss];
                     if (error == nil) {
                         file.contentImage = [UIImage imageWithData:dataObject.data];;
                         [self.gdPickerDelegate gd_filePickerViewController:self didFinishSelectingFile:file];
                     }
                     
                     else {
                         [self showAlert:@"Error" message:@"Google media file download error"];
                     }
                 }];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.driveFiles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GDFolderFileCollectionViewCell *cell= [collectionView dequeueReusableCellWithReuseIdentifier:@"GDFolderFileCollectionViewCell" forIndexPath:indexPath];
    
    cell.googleFileImageView.image = [UIImage imageNamed:@"Google Drive Folder Icon"];
    
    GTLRDrive_File *file = [self.driveFiles objectAtIndex:indexPath.row];
    self.lastGDFileSelected = file;
    
    if ([file.mimeType isEqualToString:@"application/vnd.google-apps.folder"]) {
        
        cell.googleFileImageView.image = [UIImage imageNamed:@"Google Drive Folder Icon"];
        cell.googleFileImageView.userInteractionEnabled = YES;
    }
    
    else if ([file.mimeType isEqualToString:@"image/jpeg"] || [file.mimeType isEqualToString:@"image/png"] || [file.mimeType isEqualToString:@"image/jpg"] ) {
        
        [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
        [SVProgressHUD show];
        GTLRQuery *query = [GTLRDriveQuery_FilesGet queryForMediaWithFileId:file.identifier];
        [self.service executeQuery:query
                 completionHandler:^(GTLRServiceTicket *callbackTicket,
                                     GTLRDataObject *dataObject,
                                     NSError *error) {
                     
                     [SVProgressHUD dismiss];
                     if (error == nil) {
                         cell.googleFileImageView.image = [UIImage imageWithData:dataObject.data];
                     }
                     
                     else {
                         NSLog(@"Google media file download error occurred: %@", error);
                     }
                 }];
        
        cell.googleFileImageView.userInteractionEnabled = YES;
    }
    
    cell.fileNameLabel.text = file.name;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(167, 170);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 10.0;
}
- (IBAction)backButtonTapped:(id)sender {
    
    [self.gdFileStack removeObjectAtIndex:self.lastIndexPath];
    self.lastIndexPath--;
    
    if (self.lastIndexPath > 0) {
        
        self.lastGDFileSelected = [self.gdFileStack objectAtIndex:self.lastIndexPath];
        self.folderNameLabel.text = self.lastGDFileSelected.name;
        self.backButton.hidden = NO;
        [self listAllFilesInFolder:self.lastGDFileSelected.identifier];
    }
    
    else if (self.lastIndexPath == 0) {
        self.backButton.hidden = YES;
        self.folderNameLabel.text = @"ROOT";
        [self listAllFilesInRootFolder];
    }
}

- (IBAction)signOutTapped:(id)sender {
    
    [[GIDSignIn sharedInstance] signOut];
    
    [self.driveFiles removeAllObjects];
    [self.googleFilesCollectionView reloadData];
    
    [[GIDSignIn sharedInstance] signIn];
}

#pragma mark - GIDSignInDelegate methods

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    GIDGoogleUser *currentUser = [GIDSignIn sharedInstance].currentUser;
    
    if (currentUser) {
        self.service.authorizer = currentUser.authentication.fetcherAuthorizer;
        [self listAllFilesInRootFolder];
    }
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
}

#pragma mark - GIDSignInUIDelegate methods

//- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
//
//}
//
//- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
//
//}
//
//- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
//
//}

#pragma mark - Internal methods

- (void)listAllFilesInRootFolder {
    
    GTLRDriveQuery_FilesList *query = [GTLRDriveQuery_FilesList query];
    query.pageSize = 1000;
    query.q = [NSString stringWithFormat:@" (mimeType = 'application/vnd.google-apps.folder' or mimeType = 'image/jpeg' or mimeType = 'image/jpg' or mimeType = 'image/png') and '%@' IN parents and trashed=false ", @"root"];
    query.fields = @"kind,nextPageToken,files(id, md5Checksum, trashed, name, mimeType, modifiedTime, thumbnailLink, webViewLink, iconLink, webContentLink, size, teamDriveId)";
    
    [SVProgressHUD show];
    [self.service executeQuery:query
             completionHandler:^(GTLRServiceTicket *ticket,
                                 GTLRDrive_FileList *files,
                                 NSError *error) {
                 
                 [SVProgressHUD dismiss];
                 
                 if (error == nil) {
                     if (self.driveFiles == nil) {
                         self.driveFiles = [[NSMutableArray alloc] init];
                     }
                     [self.driveFiles removeAllObjects];
                     [self.driveFiles addObjectsFromArray:files.files];
                     // Sort Drive Files by modified date (descending order).
                     [self.driveFiles sortUsingComparator:^NSComparisonResult(GTLRDrive_File *lhs,
                                                                              GTLRDrive_File *rhs) {
                         return [rhs.modifiedTime.date compare:lhs.modifiedTime.date];
                     }];
                     [self.googleFilesCollectionView reloadData];
                 }
                 
                 else {
                     NSMutableString *message = [[NSMutableString alloc] init];
                     [message appendFormat:@"Error getting presentation data: %@\n", error.localizedDescription];
                     [self showAlert:@"Error" message:message];
                 }
             }];
}

- (void)listAllFilesInFolder:(NSString *)folderId {
    
    GTLRDriveQuery_FilesList *query2 = [GTLRDriveQuery_FilesList query];
    query2.pageSize = 100;
    query2.fields = @"kind,nextPageToken,files(id, md5Checksum, trashed, name, mimeType, modifiedTime, thumbnailLink, webViewLink, iconLink, webContentLink, size, teamDriveId)";
    query2.q = [NSString stringWithFormat:@" (mimeType = 'application/vnd.google-apps.folder' or mimeType = 'image/jpeg' or mimeType = 'image/jpg' or mimeType = 'image/png')  and '%@' in parents and trashed=false ", folderId ];
    
    [SVProgressHUD show];
    [self.service executeQuery:query2
             completionHandler:^(GTLRServiceTicket *ticket,
                                 GTLRDrive_FileList *files,
                                 NSError *error) {
                 
                 [SVProgressHUD dismiss];
                 
                 if (error == nil) {
                     if (self.driveFiles == nil) {
                         self.driveFiles = [[NSMutableArray alloc] init];
                     }
                     [self.driveFiles removeAllObjects];
                     [self.driveFiles addObjectsFromArray:files.files];
                     // Sort Drive Files by modified date (descending order).
                     [self.driveFiles sortUsingComparator:^NSComparisonResult(GTLRDrive_File *lhs, GTLRDrive_File *rhs) {
                         return [rhs.modifiedTime.date compare:lhs.modifiedTime.date];
                     }];
                     [self.googleFilesCollectionView reloadData];
                 }
                 
                 else {
                     NSMutableString *message = [[NSMutableString alloc] init];
                     [message appendFormat:@"Error getting presentation data: %@\n", error.localizedDescription];
                     [self showAlert:@"Error" message:message];
                 }
                 
             }];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
