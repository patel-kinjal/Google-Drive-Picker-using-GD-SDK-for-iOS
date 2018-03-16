//
//  GDFolderFileCollectionViewCell.m
//  GDPicker
//
//  Created by Kinjal Patel on 12/07/17.
//  Copyright © 2017 Kinjal Patel. All rights reserved.
//

#import "GDFolderFileCollectionViewCell.h"

@implementation GDFolderFileCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"GDFolderFileCollectionViewCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }
    
    return self;
}

@end
