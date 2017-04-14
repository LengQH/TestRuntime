//
//  ViewController.m
//  TestRuntime
//
//  Created by 冷求慧 on 17/2/25.
//  Copyright © 2017年 冷求慧. All rights reserved.
//

#import "ViewController.h"
#import "TestGetClassName.h"
#import <objc/message.h>     //  导入运行时文件
@interface ViewController ()

@property (nonatomic,strong)NSMutableArray *arrayWithTest;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getClassName]; // 获取类名
    [self getIvars];    //  得到类中所有的成员变量
    [self getProperty];//   得到类中所有的属性
    [self getAllMethod]; // 获取所有的方法
    [self getAllProtocol];// 获取所有的协议
    [self addNewMethod];  // 动态添加方法
    [self exchangeMethod]; // 交换方法
    [self replaceMethod]; //  替换方法
    [self performSelector:@selector(unIPMMethod) withObject:@"一个对象"];
    
    TestGetClassName *className=[[TestGetClassName alloc]init];
    [className unIPMMethod];  // 测试没有调用某个实例方法
//    [TestGetClassName unIPMClassMethod];
    
    [self testUseLinkProperty]; // 对应关联的属性
}

#pragma mark 获取类名
-(void)getClassName{
    const char *className=class_getName([TestGetClassName class]);    //  class_getName 获取对应的类名
    NSString *classNameWithString=[NSString stringWithUTF8String:className];
    NSLog(@"得到的类名是: %@",classNameWithString);
}
#pragma mark 得到类中所有的成员变量和其对应的类型
-(void)getIvars{
    NSMutableArray *arrAddIvar=[NSMutableArray array];
    
    unsigned int numberWithIvar;
    Ivar *ivar=class_copyIvarList([TestGetClassName class], &numberWithIvar);   // class_copyIvarList 得到所有的成员变量和对应的长度
    for (unsigned int i=0; i<numberWithIvar; i++) {
        Ivar eachIvar=ivar[i];
        const char *ivarType=ivar_getTypeEncoding(eachIvar);   //  ivar_getTypeEncoding 获取成员变量对应的类型
        const char *ivarName=ivar_getName(eachIvar);          //   ivar_getName 获取对应的名字
        
        NSString *ivarTypeWithString=[NSString stringWithUTF8String:ivarType];  // 分别将对应的类型和名字转为NSString
        NSString *ivarNameWithString=[NSString stringWithUTF8String:ivarName];
        
        NSDictionary *dicValue=[NSDictionary dictionaryWithObject:ivarNameWithString forKey:ivarTypeWithString];
        [arrAddIvar addObject:dicValue];
    }
    free(ivar);   // 释放内存
    NSLog(@"最终的结果是:%@",arrAddIvar);
}
#pragma mark 得到类中所有的属性
-(void)getProperty{
    NSMutableArray *arrAddPro=[NSMutableArray array];
    unsigned int numberWithIvar;
    objc_property_t *allPro=class_copyPropertyList([TestGetClassName class], &numberWithIvar); //  class_copyPropertyList 得到所有的属性和对应的长度
    for (unsigned int i=0; i<numberWithIvar; i++) {
        objc_property_t proValue=allPro[i];
        const char *proName=property_getName(proValue); // property_getName 将属性 objc_property_t类型转为C语言中的字符串char类型
        
        NSString *proNameWithString=[NSString stringWithUTF8String:proName];  // char转为OC中的字符串(NSString)
        [arrAddPro addObject:proNameWithString];
        
        //        [arrAddPro addObject:[NSString stringWithUTF8String:property_getName(allPro[i])]]; // 将上面的代码简写成一句
    }
    free(allPro); // 释放内存
    NSLog(@"得到的所有属性是:%@",arrAddPro);
    
}
#pragma mark 获取类中的方法
-(void)getAllMethod{
    NSMutableArray *arrAddMethod=[NSMutableArray array];
    unsigned int numberWithIvar;
    Method *allMethod=class_copyMethodList([TestGetClassName class], &numberWithIvar); // class_copyMethodList  得到所有的方法和对应的长度
    for (unsigned int i=0; i<numberWithIvar; i++) {
        SEL methodName=method_getName(allMethod[i]);
        [arrAddMethod addObject:NSStringFromSelector(methodName)];
    }
    free(allMethod);
    NSLog(@"得到的所有方法名:%@",arrAddMethod);
}
#pragma mark 获取类中的协议
-(void)getAllProtocol{
    NSMutableArray *arrAllProtocol=[NSMutableArray array];
    
    unsigned int numberWithIvar;
    Protocol * __unsafe_unretained *protocol=class_copyProtocolList([TestGetClassName class], &numberWithIvar); // class_copyProtocolList 得到所有的协议和对应的长度
    for(unsigned int i=0;i<numberWithIvar;i++){
        const char *protocolName=protocol_getName(protocol[i]);
        [arrAllProtocol addObject:[NSString stringWithUTF8String:protocolName]];
    }
    free(protocol);
    NSLog(@"得到的所有的协议是:%@",arrAllProtocol);
}
#pragma mark 动态添加方法
-(void)addNewMethod{
    
    //    SEL startSel=@selector(startSelWithName);
    //    SEL useSel=@selector(useSelWithName);
    SEL startSel=NSSelectorFromString(@"startSelWithName");
    SEL useSel=NSSelectorFromString(@"useSelWithName");
    Method method=class_getInstanceMethod([TestGetClassName class], useSel); // class_getInstanceMethod 得到对应类的实例方法
    IMP methodIMP=method_getImplementation(method);                       // method_getImplementation 方法实现
    const char *methodType=method_getTypeEncoding(method);
    
    BOOL isSuccess=class_addMethod([TestGetClassName class], startSel, methodIMP, methodType); // class_addMethod(Class cls, SEL name, IMP imp,const char *types)   cls:需要添加新方法的类 name:selector的方法名称 imp: 就是implementation,就是我们要添加的方法 *types 表示我们要添加的方法的返回值和参数
    NSLog(@"添加方法是否成功:%zi",isSuccess);
    
}

#pragma mark 交换方法
-(void)exchangeMethod{
    
    Method playM=class_getInstanceMethod([ViewController class], @selector(playMethod));  // class_getInstanceMethod  得到类中对应的实例方法
    Method lookM=class_getInstanceMethod([ViewController class], @selector(lookMethod));
    
    method_exchangeImplementations(playM, lookM);  // method_exchangeImplementations 交换方法
    
    [self playMethod];
    [self lookMethod];
}
#pragma mark 替换方法()
-(void)replaceMethod{
    
    SEL startSel=@selector(lookMethod);  // 要替换的方法
    SEL endSel=@selector(eatMethod);    //  替换成的方法
    
    Method methodName=class_getInstanceMethod([ViewController class], endSel);
    IMP impName=method_getImplementation(methodName);
    //    IMP impName=[NSString instanceMethodForSelector:endSel];
    const char *charName=method_getTypeEncoding(methodName);
    
    class_replaceMethod([ViewController class], startSel, impName, charName);
    
    [self lookMethod]; // 调用方法
}
-(void)playMethod{
    NSLog(@"玩的方法");
}
-(void)lookMethod{
    NSLog(@"看的方法");
}
-(void)eatMethod{
    NSLog(@"吃的方法");
}
-(void)testUseLinkProperty{
    self.arrayWithTest=[NSMutableArray arrayWithObject:@"我在这里"];
    NSLog(@"数组里面的值:%@",self.arrayWithTest);
}
// 重写数组的set方法(设置关联属性的值)
-(void)setArrayWithTest:(NSMutableArray *)arrayWithTest{
    objc_setAssociatedObject(self, @selector(arrayWithTest), arrayWithTest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
// 重写数组的get方法(返回关联属性的值)
-(NSMutableArray *)arrayWithTest{
    return objc_getAssociatedObject(self, @selector(arrayWithTest));
}
@end
