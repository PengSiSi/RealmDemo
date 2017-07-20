//
//  ViewController.m
//  RealmDemo
//
//  Created by 思 彭 on 2017/7/20.
//  Copyright © 2017年 思 彭. All rights reserved.

// 注意区别默认的和自己自定义realm的

#import "ViewController.h"
#import "PersonModel.h"
#import <Realm.h>
#import <RLMRealm.h>

@interface ViewController () {
    
    RLMRealm *_customRealm;
}

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *sexTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;

@property (nonatomic, strong) RLMResults *locArray;
@property (nonatomic, strong) RLMNotificationToken *token;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    可以使用默认的
//    _customRealm = [RLMRealm defaultRealm];
    
    //自己创建一个新的RLMRealm
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathStr = paths.firstObject;
    // pathStr = /Users/sipeng/Library/Developer/CoreSimulator/Devices/59E51096-9523-4845-84E8-2BB5360FB50E/data/Containers/Data/Application/A20B045E-6C86-4872-99DF-A52541FB1104/Documents

    NSLog(@"pathStr = %@",pathStr);
    _customRealm = [RLMRealm realmWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",pathStr,@"person.realm"]]];
}

/**
 增

 @param sender <#sender description#>
 */
- (IBAction)addAction:(id)sender {
    
    // 获取默认的 Realm 实例
//    RLMRealm *realm = [RLMRealm defaultRealm];
    
    PersonModel *person = [[PersonModel alloc]init];
    person.name = self.nameTextField.text;
    person.sex = self.sexTextField.text;
    person.age = [self.ageTextField.text integerValue];
    NSLog(@"name - %@ sex = %@ age = %ld",person.name, person.sex, person.age);
    // 数据持久化
    [_customRealm transactionWithBlock:^{
        [_customRealm addObject:person];
    }];
    // 通过事务将数据添加到 Realm 中
//    [_customRealm beginWriteTransaction];
//    [_customRealm addObject:person];
//    [_customRealm commitWriteTransaction];
    NSLog(@"增加成功啦");
    [self findAction:nil];
}

/**
 删

 @param sender <#sender description#>
 */
- (IBAction)deleteAction:(id)sender {
    
    // 获取默认的 Realm 实例
//    RLMRealm *realm = [RLMRealm defaultRealm];
    [_customRealm beginWriteTransaction];
    [_customRealm deleteAllObjects];
    [_customRealm commitWriteTransaction];
    [self findAction:nil];
}

/**
 改

 @param sender <#sender description#>
 */
- (IBAction)updateAction:(id)sender {
    
    for (PersonModel *person in self.locArray) {
        NSLog(@"name - %@ sex = %@ age = %ld",person.name, person.sex, person.age);
    }
    
    // 获取默认的 Realm 实例
//    RLMRealm *realm = [RLMRealm defaultRealm];
    PersonModel *model = self.locArray[0];
    [_customRealm beginWriteTransaction];
    model.name = @"思思棒棒哒";
    [_customRealm commitWriteTransaction];
    
    NSLog(@"修改成功");
    for (PersonModel *person in self.locArray) {
        NSLog(@"name - %@ sex = %@ age = %ld",person.name, person.sex, person.age);
    }
}

/**
 查

 @param sender <#sender description#>
 */
- (IBAction)findAction:(id)sender {
    
    //自己创建一个新的RLMRealm
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *pathStr = paths.firstObject;
    NSLog(@"pathStr = %@",pathStr);

    // 查询指定的 Realm 数据库
    RLMRealm *personRealm = [RLMRealm realmWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",pathStr,@"person.realm"]]];
    // 获得一个指定的 Realm 数据库
    self.locArray = [PersonModel allObjectsInRealm:personRealm]; // 从该 Realm 数据库中，检索所有model
    
    // 这是默认查询默认的realm
//    self.locArray = [PersonModel allObjects];
    NSLog(@"self.locArray.count = %ld",self.locArray.count);
}

// 创建数据库
- (void)creatDataBaseWithName:(NSString *)databaseName{
    
    NSArray *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [docPath objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:databaseName];
    NSLog(@"数据库目录 = %@",filePath);
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.fileURL = [NSURL URLWithString:filePath];
//    config.objectClasses = @[MyClass.class, MyOtherClass.class];
    config.readOnly = NO;
    int currentVersion = 1.0;
    config.schemaVersion = currentVersion;
    
    config.migrationBlock = ^(RLMMigration *migration , uint64_t oldSchemaVersion) {       // 这里是设置数据迁移的block
        if (oldSchemaVersion < currentVersion) {
        }
    };
    
    [RLMRealmConfiguration setDefaultConfiguration:config];
}

@end
