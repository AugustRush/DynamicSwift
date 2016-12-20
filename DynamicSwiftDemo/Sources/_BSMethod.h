//
//  _BSMethod.h
//  DynamicSwiftDemo
//
//  Created by AugustRush on 12/9/16.
//  Copyright © 2016 August. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ffi.h"

typedef NS_ENUM(NSUInteger, BSVarType) {
    BSVarTypeObject,
    BSVarTypePointer,
    BSVarTypeVoid,
    BSVarTypeUndefine
};

ffi_type *ffiTypeWithEncodingChar(const char c);
BSVarType bsVarTypeWithChar(const char c);
//// Ineternal c method record object
@interface _BSMethod : NSObject

@property (nonatomic, copy) NSString *jsMethodName;
@property (nonatomic) NSArray* typesEncode;
@property (nonatomic) void *methodIMP;
@property (nonatomic, assign) int argsCount;
@property (nonatomic) BSVarType *varTypes;
@property (nonatomic) ffi_type **argTypes;
@property (nonatomic) ffi_type *returnType;
@property (nonatomic) ffi_cif *cif;
@property (nonatomic) ffi_closure *closure;

- (id)convertValue:(void *)value type:(BSVarType)type;
- (void)copyValue:(id)value toPointer:(void *)pointer type:(ffi_type *)type;

@end
