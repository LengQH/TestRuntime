//
//  TestGetClassName.h
//  TestRuntime
//
//  Created by 冷求慧 on 17/3/21.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestGetClassName : NSObject<NSCoding>
/**
 *  猫
 */
@property (nonatomic,copy)NSString *cat;
/**
 *  狗
 */
@property (nonatomic,copy)NSString *dog;
/**
 *  猪
 */
@property (nonatomic,copy)NSString *pig;
/**
 *  添加动物的数组
 */
@property (nonatomic,strong)NSMutableArray *arrAddAnimal;

-(NSString *)calculateAllValue:(NSString *)ageValue needMoney:(NSNumber *)moneyValue other:(NSNumber *)other;

// 这个实例方法只声明,不实现
-(void)unIPMMethod;

// 这个类方法只声明,不实现
+(void)unIPMClassMethod;

@end
