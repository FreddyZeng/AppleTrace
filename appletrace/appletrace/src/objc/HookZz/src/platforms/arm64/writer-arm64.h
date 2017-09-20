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

#ifndef platforms_x86_writer_h
#define platforms_x86_writer_h

#include "hookzz.h"

#include "instructions.h"
#include "writer.h"

typedef struct _ZzArm64RegInfo {
    zuint index;
    zuint meta;
    zuint width;
    bool is_integer;
} ZzArm64RegInfo;

void writer_put_ldr_reg_address(ZzWriter *self, arm64_reg reg, zaddr address);

void writer_put_ldr_br_b_reg_address(ZzWriter *self, arm64_reg reg,
                                     zaddr address);

void writer_put_b_cond_imm(ZzWriter *self, arm64_cc cc, zsize imm);

void writer_put_ldr_reg_reg_offset(ZzWriter *self, arm64_reg dst_reg,
                                   arm64_reg src_reg, zsize src_offset);

void writer_put_str_reg_reg_offset(ZzWriter *self, arm64_reg src_reg,
                                   arm64_reg dst_reg, zsize dst_offset);

void writer_put_sub_reg_reg_imm(ZzWriter *self, arm64_reg dst_reg,
                                arm64_reg left_reg, zsize right_value);

void writer_put_add_reg_reg_imm(ZzWriter *self, arm64_reg dst_reg,
                                arm64_reg left_reg, zsize right_value);

void writer_put_ldr_reg_imm(ZzWriter *self, arm64_reg reg, zsize imm);

void writer_put_br_reg(ZzWriter *self, arm64_reg reg);


void writer_put_blr_reg(ZzWriter *self, arm64_reg reg);

void writer_put_bytes(ZzWriter *self, zbyte *data, zuint data_size);

void writer_put_instruction(ZzWriter *self, uint32_t insn);

void writer_describe_reg(arm64_reg reg, ZzArm64RegInfo *ri);

void writer_put_b_imm(ZzWriter *self, zsize imm);

#endif