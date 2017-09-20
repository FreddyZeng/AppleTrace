//    Copyright 2017 jmpews
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

#ifndef stack_h
#define stack_h

#include "hookzz.h"

typedef struct _ZzCallStackItem {
    char *key;
    zpointer value;
} ZzCallStackItem;

typedef struct _ZzCallStack {
    long call_id;
    zsize size;
    zsize capacity;
    zpointer sp;
    zpointer caller_ret_addr;
    ZzCallStackItem *items;
} ZzCallStack;

typedef struct _ZzThreadStack {
    long thread_id;
    zsize size;
    zsize capacity;
    zpointer key_ptr;
    ZzCallStack **callstacks;
} ZzThreadStack;


ZzThreadStack *ZzNewThreadStack(zpointer key_ptr);

ZzThreadStack *ZzGetCurrentThreadStack(zpointer key_ptr);

ZzCallStack *ZzNewCallStack();

void ZzFreeCallStack(ZzCallStack *callstack);

ZzCallStack *ZzPopCallStack(ZzThreadStack *stack);

bool ZzPushCallStack(ZzThreadStack *stack, ZzCallStack *callstack);


#endif