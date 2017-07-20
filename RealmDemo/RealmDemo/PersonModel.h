//
//  PersonModel.h
//  RealmDemo
//
//  Created by 思 彭 on 2017/7/20.
//  Copyright © 2017年 思 彭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm.h>

@interface PersonModel : RLMObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *sex;
@property (nonatomic, assign) NSInteger age;

@end

RLM_ARRAY_TYPE(PersonModel)
