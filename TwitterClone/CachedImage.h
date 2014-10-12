//
//  CachedImage.h
//  TwitterClone
//
//  Created by Alex G on 11.10.14.
//  Copyright (c) 2014 Alexey Gordiyenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CachedImage : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSData * data;

@end
