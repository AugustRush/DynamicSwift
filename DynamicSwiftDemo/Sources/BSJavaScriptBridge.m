//
//  BSJavaScriptBridge.m
//  SwiftComplierDemo
//
//  Created by AugustRush on 12/3/16.
//  Copyright © 2016 August. All rights reserved.
//

#import "BSJavaScriptBridge.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "_BSMethod.h"

/////////////

NS_INLINE void _methodCallingForwarding(ffi_cif* cif,void*ret,void**args,void*userdata) {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    _BSMethod *method = (__bridge _BSMethod *)userdata;
    JSContext *context = [[BSJavaScriptBridge sharedInstance] context];
    JSValue *function = [context objectForKeyedSubscript:method.jsMethodName];
    NSMutableArray *argValues = [NSMutableArray array];
    for (int i = 0; i < method.argsCount; i++) {
        BSVarType type = method.varTypes[i];
        void *value = args[i];
        id target = [method convertValue:value type:type];
        [argValues addObject:target];
    }
    
    id result = [[function callWithArguments:argValues] toObject];
    [method copyValue:result toPointer:ret type:method.returnType];
}

typedef void(^ArgumentTransfer) (NSInvocation *invocation, id argument, NSUInteger argumentIndex);
//
typedef id (^ReturnTransfer) (NSInvocation *invocation);

NS_INLINE id _BS_OBJC_CALL(id target, NSString *sel, NSArray *paramaters) {
    SEL selector = NSSelectorFromString(sel);
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    if (signature) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        //
        const char *returnTypeC = signature.methodReturnType;
        __autoreleasing id returnValue = nil;
        //
        static NSMutableDictionary<NSString *,ArgumentTransfer> *transfers = nil;
        //
        static NSMutableDictionary<NSString *,ReturnTransfer> *transferR = nil;
        static dispatch_once_t onceToken;
#define BSENCODESTR(typeC) [NSString stringWithUTF8String:typeC]
        dispatch_once(&onceToken, ^{
            transfers = [NSMutableDictionary dictionary];
#define TRANSFERBLOCKPREFIX ^(NSInvocation *invocation, id argument, NSUInteger argumentIndex)
#define ADDTRANSFER(type,trans) {\
        const char *typeC = @encode(type);\
        NSString *typeStr = BSENCODESTR(typeC);\
        ArgumentTransfer transfer = TRANSFERBLOCKPREFIX{\
            type value = trans;\
            [invocation setArgument:&value atIndex:argumentIndex];\
        };\
        transfers[typeStr] = transfer;\
        }
            
            ADDTRANSFER(char, [argument charValue])
            ADDTRANSFER(int, [argument intValue])
            ADDTRANSFER(BOOL, [argument boolValue])
            ADDTRANSFER(short, [argument shortValue])
            ADDTRANSFER(unsigned char, [argument unsignedCharValue])
            ADDTRANSFER(unsigned int, [argument unsignedIntValue])
            ADDTRANSFER(unsigned short, [argument unsignedShortValue])
            ADDTRANSFER(long, [argument longValue])
            ADDTRANSFER(long long, [argument longLongValue])
            ADDTRANSFER(unsigned long, [argument unsignedLongValue])
            ADDTRANSFER(unsigned long long, [argument unsignedLongLongValue])
            ADDTRANSFER(float, [argument floatValue])
            ADDTRANSFER(double, [argument doubleValue])
            ADDTRANSFER(char *, (char *)[argument UTF8String])
            ADDTRANSFER(id,argument)
            ADDTRANSFER(Class, [argument class])
            /////////////////////// return value
            transferR = [NSMutableDictionary dictionary];
#define ADDRETURNTRANSFER1(type,block) {\
        NSString *typeStr = BSENCODESTR(@encode(type));\
        transferR[typeStr] = block;\
        }
            
#define RETURNTRANSFERPREFIX ^id(NSInvocation *invocation)
            
#define ADDRETURNTRANSFER2(type,invocation) {\
        NSString *typeStr = BSENCODESTR(@encode(type));\
        ReturnTransfer transfer = RETURNTRANSFERPREFIX{\
            type value;\
            [invocation getReturnValue:&value];\
            return @(value);\
        };\
        transferR[typeStr] = transfer;\
    }
            
            ADDRETURNTRANSFER2(char,invocation);
            ADDRETURNTRANSFER2(int,invocation);
            ADDRETURNTRANSFER2(short,invocation);
            ADDRETURNTRANSFER2(long,invocation);
            ADDRETURNTRANSFER2(long long,invocation);
            ADDRETURNTRANSFER2(unsigned char,invocation);
            ADDRETURNTRANSFER2(unsigned int,invocation);
            ADDRETURNTRANSFER2(unsigned long,invocation);
            ADDRETURNTRANSFER2(unsigned short,invocation);
            ADDRETURNTRANSFER2(unsigned long long,invocation);
            ADDRETURNTRANSFER2(float,invocation);
            ADDRETURNTRANSFER2(double,invocation);
            ADDRETURNTRANSFER2(BOOL,invocation);
            ADDRETURNTRANSFER1(char *, RETURNTRANSFERPREFIX{
                const char *value;
                [invocation getReturnValue:&value];
                return [NSString stringWithUTF8String:value];
            });
            ADDRETURNTRANSFER1(CGPoint, RETURNTRANSFERPREFIX{
                CGPoint value;
                [invocation getReturnValue:&value];
                return [NSValue valueWithCGPoint:value];
            });
            ADDRETURNTRANSFER1(CGRect, RETURNTRANSFERPREFIX{
                CGRect value;
                [invocation getReturnValue:&value];
                return [NSValue valueWithCGRect:value];
            });
            ADDRETURNTRANSFER1(CGSize, RETURNTRANSFERPREFIX{
                CGSize value;
                [invocation getReturnValue:&value];
                return [NSValue valueWithCGSize:value];
            });
            ADDRETURNTRANSFER1(UIEdgeInsets, RETURNTRANSFERPREFIX{
                UIEdgeInsets value;
                [invocation getReturnValue:&value];
                return [NSValue valueWithUIEdgeInsets:value];
            });
            ADDRETURNTRANSFER1(id, RETURNTRANSFERPREFIX{
                id value;
                [invocation getReturnValue:&value];
                return value;
            });
            
        });
        
        for (NSUInteger i = 0; i < paramaters.count; i++) {
            NSUInteger index = i+2;
            const char *argumentTypeC = [signature getArgumentTypeAtIndex:i+2];
            id argument = paramaters[i];
            ArgumentTransfer transfer = transfers[BSENCODESTR(argumentTypeC)];
            if (transfer != nil) {
                transfer(invocation,argument,index);
            } else {
                // need add new transfer
            }
        }
        //
        invocation.target = target;
        invocation.selector = selector;
        [invocation invoke];
        ////
        ReturnTransfer returnTransfer = transferR[BSENCODESTR(returnTypeC)];
        if (returnTransfer) {
            returnValue = returnTransfer(invocation);
        } else {
            // need add new return transfer
        }
        
        return returnValue;
    } else {
        return nil;
    }
}

//
NSString *const BSRegisteClassBlockJavaScriptName = @"_bs_registeClass";
NSString *const BSCallingObjectCMethodJsvaScriptName = @"_bs_calling_objc_method";
//Method Info
NSString *const BSFunctionObjcNameKey = @"objcName";
NSString *const BSFunctionTypeKey = @"type";
NSString *const BSFunctionJSNameKey = @"jsName";
NSString *const BSFunctionObjcEncodeKey = @"objcEncode";
NSString *const BSFunctionArgsCountKey = @"argsCount";

@interface BSJavaScriptBridge ()

@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) NSMutableDictionary<NSString*,_BSMethod *> *methods;
@property (nonatomic, strong) NSMutableSet *registedClasses;

@end

@implementation BSJavaScriptBridge

+ (instancetype)sharedInstance {
    static BSJavaScriptBridge *bridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bridge = [[BSJavaScriptBridge alloc] init];
    });
    
    return bridge;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _setUp];
    }
    return self;
}

#pragma mark - Private methods

- (void)_setUp {
    _methods = [NSMutableDictionary dictionary];
    _registedClasses = [NSMutableSet set];
    _context = [[JSContext alloc] init];
    
    [_context setExceptionHandler:^(JSContext *context, JSValue *value) {
        NSLog(@"current context is %@, value is %@",context,value);
    }];
#warning need to fix / find a way to import needed class
    _context[@"UIColor"] = NSClassFromString(@"UIColor");
    
    __weak typeof(self) wself = self;
    id(^registeClass)(NSString *,NSString *, JSValue *) = ^id(NSString *name,NSString *superName, JSValue *funcsValue) {
        if ([wself.registedClasses containsObject:name]) {
            NSLog(@"has registed class %@",name);
            return nil;
        }
        // record for registed class
        [wself.registedClasses addObject:name];
        Class superClass = NSClassFromString(superName);
        Class class = objc_allocateClassPair(superClass, [name UTF8String], 0);
        objc_registerClassPair(class);
        NSArray<NSDictionary *> *methods = [funcsValue toArray];
        NSLog(@"name is %@, superName is %@, funs is %@",name,superName,methods);
        [wself registerClassWithClass:class superClass:superClass methods:methods];
        return class;
    };
    _context[BSRegisteClassBlockJavaScriptName] = registeClass;
    
    id(^callingObjectCMethod)(JSValue *,JSValue *,JSValue *) = ^id(JSValue *caller,JSValue *selector,JSValue *paramaters) {
        id cal = [caller toObject];
        NSString *selVal = [selector toString];
        NSArray *paras = [paramaters toArray];
        return _BS_OBJC_CALL(cal, selVal, paras);
    };
    _context[BSCallingObjectCMethodJsvaScriptName] = callingObjectCMethod;
}

- (void)registerClassWithClass:(Class)class superClass:(Class)superClass methods:(NSArray<NSDictionary *> *)methods {
    for (NSDictionary *dict in methods) {
        NSString *methodName = dict[BSFunctionObjcNameKey];
        NSArray *types = dict[BSFunctionObjcEncodeKey];
        int argsCount = [dict[BSFunctionArgsCountKey] intValue] + 2;// oc add self. selector.
        NSString *jsMethodName = dict[BSFunctionJSNameKey];
        // build imp
        void* methodIMP = NULL;
        const char rvEncode = [types[0] UTF8String][0];
        ffi_type *returnType = ffiTypeWithEncodingChar(rvEncode);
        ffi_closure *closure = ffi_closure_alloc(sizeof(ffi_closure), (void**)&methodIMP);
        
        ffi_cif* cif = malloc(sizeof(ffi_cif));
        ffi_type **args = malloc(sizeof(ffi_type *) * argsCount);
        BSVarType *varTypes = malloc(sizeof(BSVarType) * argsCount);
        
        for (int i = 0; i < argsCount; i++) {
            NSString *encodeStr = types[i+1];
            const char encode = [encodeStr UTF8String][0];
            ffi_type *type = ffiTypeWithEncodingChar(encode);
            args[i] = type;
            BSVarType varType = bsVarTypeWithChar(encode);
            varTypes[i] = varType;
        }
        
        _BSMethod *method = [[_BSMethod alloc] init];
        method.methodIMP = methodIMP;
        method.typesEncode = [types copy];
        method.argsCount = argsCount;
        method.jsMethodName = jsMethodName;
        method.varTypes = varTypes;
        method.cif = cif;
        method.closure = closure;
        method.argTypes = args;
        method.returnType = returnType;
        
        if (ffi_prep_cif(cif, FFI_DEFAULT_ABI, argsCount, returnType, args) == FFI_OK) {
            if (ffi_prep_closure_loc(closure, cif, _methodCallingForwarding, (__bridge void *)method, methodIMP) == FFI_OK) {
                // strong reference for method
                self.methods[jsMethodName] = method;
                // add method for class
                SEL selector = NSSelectorFromString(methodName);
                //
                const char *typesC = [[types componentsJoinedByString:@""] UTF8String];
                NSAssert(class_addMethod(class, selector, (IMP)method.methodIMP, typesC), @"class_addMethod failed!!");
            } else {
                NSAssert(0, @"ffi_prep_closure_loc isn't OK!");
            }
        } else {
            NSAssert(0, @"ffi_prep_cif isn't OK!");
        }
        
    }
    
}

#pragma mark - public methods

- (id)getInstanceForClassWithName:(NSString *)name {
    Class class = NSClassFromString(name);
    if (!class) {
        return nil;
    }
    //    SEL selector = NSSelectorFromString(@"init");
    id target = [[class alloc] init];
    NSLog(@"instance value is %@",target);
    return target;
}

@end
