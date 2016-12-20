//
//  _BSMethod.m
//  DynamicSwiftDemo
//
//  Created by AugustRush on 12/9/16.
//  Copyright © 2016 August. All rights reserved.
//

#import "_BSMethod.h"

ffi_type *ffiTypeWithEncodingChar(const char c) {
    switch (c) {
        case 'v':
            return &ffi_type_void;
        case ':':
            return &ffi_type_pointer;
        case 'c':
            return &ffi_type_schar;
        case 'C':
            return &ffi_type_uchar;
        case 's':
            return &ffi_type_sshort;
        case 'S':
            return &ffi_type_ushort;
        case 'i':
            return &ffi_type_sint;
        case 'I':
            return &ffi_type_uint;
        case 'l':
            return &ffi_type_slong;
        case 'L':
            return &ffi_type_ulong;
        case 'q':
            return &ffi_type_sint64;
        case 'Q':
            return &ffi_type_uint64;
        case 'f':
            return &ffi_type_float;
        case 'd':
            return &ffi_type_double;
        case 'B':
            return &ffi_type_uint8;
        case '^':
            return &ffi_type_pointer;
        case '@':
            return &ffi_type_pointer;
        case '#':
            return &ffi_type_pointer;
    }
    return NULL;
}

BSVarType bsVarTypeWithChar(const char c) {
    static NSDictionary *types = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = @{@('v'):@(BSVarTypeVoid),
                  @(':'):@(BSVarTypePointer),
                  @('@'):@(BSVarTypeObject)};
    });
    
    NSNumber *value = types[@(c)];
    if (value != nil) {
        return [value intValue];
    }
    
    return BSVarTypeUndefine;
}

@implementation _BSMethod

- (id)convertValue:(void *)value type:(BSVarType)type {
    
    switch (type) {
        case BSVarTypeObject:
            return (__bridge id)(*(void**)value);
            break;
        case BSVarTypePointer:
            return [NSValue value:value withObjCType:@encode(SEL)];
            break;

        default:
            break;
    }
    NSAssert(0, @"undefined var type");
    return @(BSVarTypeUndefine);
}

- (void)copyValue:(id)value toPointer:(void *)pointer type:(ffi_type *)type {
    switch (type->type) {
        case FFI_TYPE_VOID:
            break;
            
        default:
            break;
    }
}

- (void)dealloc {
    _methodIMP = nil;
    ffi_closure_free(_closure);
    free(_varTypes);
    free(_argTypes);
    free(_cif);
}

@end
