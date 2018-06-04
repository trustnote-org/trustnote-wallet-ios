//
//  TNVerticalAlignLabel.h
//  TrustNote
//
//  Created by ZENGHAILONG on 2018/6/4.
//  Copyright © 2018年 org.trustnote. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    VerticalAlignmentTop = 0, // default
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface TNVerticalAlignLabel : UILabel

{
@private VerticalAlignment _verticalAlignment;
}

@property (nonatomic) VerticalAlignment verticalAlignment;

@end
