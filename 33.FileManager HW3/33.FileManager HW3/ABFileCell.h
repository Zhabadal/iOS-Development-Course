//
//  ABFileCell.h
//  33.FileManager HW3
//
//  Created by Александр on 18.02.2020.
//  Copyright © 2020 Badmaev. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ABFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel* fileName;
@property (weak, nonatomic) IBOutlet UILabel* fileSize;

@end

NS_ASSUME_NONNULL_END
