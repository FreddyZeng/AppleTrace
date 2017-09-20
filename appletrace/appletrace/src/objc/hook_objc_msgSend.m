/**
 *    Copyright 2017 jmpews
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#include "HookZz/include/hookzz.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import "appletrace.h"

#define KENABLE 1

struct section_64 *zz_macho_get_section_64_via_name(struct mach_header_64 *header, char *sect_name);
zpointer zz_macho_get_section_64_address_via_name(struct mach_header_64 *header, char *sect_name);
struct segment_command_64 *zz_macho_get_segment_64_via_name(struct mach_header_64 *header, char *segment_name);

Class zz_macho_object_get_class(id object_addr);

zpointer log_sel_start_addr = 0;
zpointer log_sel_end_addr = 0;
zpointer log_class_start_addr = 0;
zpointer log_class_end_addr = 0;
char decollators[128] = {0};

int LOG_ALL_SEL = 0;
int LOG_ALL_CLASS = 0;

@interface HookZz : NSObject

@end

@implementation HookZz

+ (void)load {
#if !(KENABLE)
    return;
#endif
    
    const struct mach_header *header = _dyld_get_image_header(0);
    struct segment_command_64 *seg_cmd_64_text = zz_macho_get_segment_64_via_name((struct mach_header_64 *)header, (char *)"__TEXT");
    zsize slide = (zaddr)header - (zaddr)seg_cmd_64_text->vmaddr;
    struct section_64 *sect_64_1 = zz_macho_get_section_64_via_name((struct mach_header_64 *)header, (char *)"__objc_methname");
    log_sel_start_addr = slide + (zaddr)sect_64_1->addr;
    log_sel_end_addr = log_sel_start_addr + sect_64_1->size;
    
    struct section_64 *sect_64_2 = zz_macho_get_section_64_via_name((struct mach_header_64 *)header, (char *)"__objc_data");
    log_class_start_addr = slide + (zaddr)sect_64_2->addr;
    log_class_end_addr = log_class_start_addr + sect_64_2->size;
    
    
    [self hook_objc_msgSend];
}

void objc_msgSend_pre_call(RegState *rs, ThreadStack *threadstack, CallStack *callstack) {
    char *sel_name = (char *)rs->general.regs.x1;
    // No More Work Here!!! it will be slow.
    if(LOG_ALL_SEL || (sel_name > log_sel_start_addr && sel_name < log_sel_end_addr)) {
        // bad code! correct-ref: https://github.com/DavidGoldman/InspectiveC/blob/299cef1c40e8a165c697f97bcd317c5cfa55c4ba/logging.mm#L27
        void *object_addr = (void *)rs->general.regs.x0;
        void *class_addr = zz_macho_object_get_class((id)object_addr);
        if(!class_addr)
            return;
        
        void *super_class_addr = class_getSuperclass(class_addr);
        // KVO 2333
        if(LOG_ALL_CLASS || ((object_addr > log_class_start_addr && object_addr < log_class_end_addr) || (class_addr > log_class_start_addr && class_addr < log_class_end_addr) || (super_class_addr > log_class_start_addr && super_class_addr < log_class_end_addr))) {
            memset(decollators, 45, 128);
            if(threadstack->size * 3 >= 128)
                return;
            decollators[threadstack->size * 3] = '\0';
//            char *class_name = class_getName(object_addr);
            char *class_name = object_getClassName(object_addr);
            unsigned int class_name_length = strlen(class_name);
            
            char *repl_name = malloc(256);
            snprintf(repl_name, 256, "[%s]%s",class_name,sel_name);
            STACK_SET(callstack, "repl_name", repl_name, char*);
            
            NSLog(@"pre %s",repl_name);
            APTBeginSection(repl_name);
        }
    }
}

void objc_msgSend_post_call(RegState *rs, ThreadStack *threadstack, CallStack *callstack) {
    if(STACK_CHECK_KEY(callstack, "repl_name")){
        char *repl_name = STACK_GET(callstack, "repl_name", char*);
        NSLog(@"post %s",repl_name);
        APTEndSection(repl_name);
        
        free(repl_name);
    }
}

+ (void)hook_objc_msgSend {
    ZzBuildHook((void *)objc_msgSend, NULL, NULL, objc_msgSend_pre_call, objc_msgSend_post_call);
    ZzEnableHook((void *)objc_msgSend);
}
@end

Class zz_macho_object_get_class(id object_addr) {
    if(!object_addr)
        return NULL;
#if 0
    if(object_isClass(object_addr)) {
        return object_addr;
    } else {
        return object_getClass(object_addr);
    }
#elif 1
    return object_getClass(object_addr);
#elif 0
    Class kind = object_getClass(object_addr);
    
    if (class_isMetaClass(kind))
        return object_addr;
    return kind;
#endif
}

