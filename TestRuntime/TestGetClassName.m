//
//  TestGetClassName.m
//  TestRuntime
//
//  Created by 冷求慧 on 17/3/21.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "TestGetClassName.h"

#import <objc/runtime.h>

@implementation TestGetClassName
-(NSString *)calculateAllValue:(NSString *)ageValue needMoney:(NSNumber *)moneyValue other:(NSNumber *)other{
    return @"小冷同学";
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super init]){
    }
    return self;
}
+(void)load{
    NSLog(@"load方法中");
}
+(void)initialize{
    NSLog(@"initialize方法中");
}

// 本类中某个实例方法没有实现,就进入这个方法
+(BOOL)resolveInstanceMethod:(SEL)sel{
    
    if (sel==@selector(unIPMMethod)) {   // 判断具体的方法没有实现
        
        SEL selName=NSSelectorFromString(@"addANewMethodWithTest:");
        Method methodName=class_getInstanceMethod([TestGetClassName class], selName);
        IMP impName=method_getImplementation(methodName);
        const char *charName=method_getTypeEncoding(methodName);
        BOOL isSuccessWithAdd=class_addMethod([TestGetClassName class], sel, impName, charName);
        NSLog(@"添加实例方法是否成功:%zi",isSuccessWithAdd);
    }
    return YES;
}
// 本类中某个类方法没有实现,就进入这个方法
+(BOOL)resolveClassMethod:(SEL)sel{
    
    if (sel==@selector(unIPMClassMethod)) {
        SEL selName=NSSelectorFromString(@"addANewMethodWithClass");
        Method methodName=class_getClassMethod([TestGetClassName class], selName);
        IMP impName=method_getImplementation(methodName);
        const char *typeName=method_getTypeEncoding(methodName);
        BOOL isSuccessAdd=class_addMethod([TestGetClassName class], sel, impName, typeName);
        NSLog(@"添加类方式是否成功:%zi",isSuccessAdd);
    }
    return YES;
}

//BOOL isSuccessWithAdd=class_addMethod([TestGetClassName class], sel,(IMP)dynamicMethodIMP, "v@:");
//NSLog(@"添加方法是否成功:%zi",isSuccessWithAdd);

-(void)addANewMethodWithTest:(NSString *)value{
    NSLog(@"本类的实例方法(unIPMMethod)没有实现,就进来这个方法");
}
+(void)addANewMethodWithClass{
    NSLog(@"本类的类方法(unIPMClassMethod)没有实现,就进来这个方法");
}
@end
