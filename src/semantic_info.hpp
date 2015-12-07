/*
 * Copyright (c) 2015 Andrew Kelley
 *
 * This file is part of zig, which is MIT licensed.
 * See http://opensource.org/licenses/MIT
 */

#ifndef ZIG_SEMANTIC_INFO_HPP
#define ZIG_SEMANTIC_INFO_HPP

#include "codegen.hpp"
#include "hash_map.hpp"
#include "zig_llvm.hpp"
#include "errmsg.hpp"

struct FnTableEntry;

struct TypeTableEntry {
    LLVMTypeRef type_ref;
    LLVMZigDIType *di_type;

    TypeTableEntry *pointer_child;
    bool pointer_is_const;
    int user_defined_id;
    Buf name;
    TypeTableEntry *pointer_const_parent;
    TypeTableEntry *pointer_mut_parent;
};

struct ImportTableEntry {
    AstNode *root;
    Buf *path; // relative to root_source_dir
    LLVMZigDIFile *di_file;
    Buf *source_code;
    ZigList<int> *line_offsets;

    // reminder: hash tables must be initialized before use
    HashMap<Buf *, FnTableEntry *, buf_hash, buf_eql_buf> fn_table;
};

struct LabelTableEntry {
    AstNode *label_node;
    LLVMBasicBlockRef basic_block;
    bool used;
    bool entered_from_fallthrough;
};

struct FnTableEntry {
    LLVMValueRef fn_value;
    AstNode *proto_node;
    AstNode *fn_def_node;
    bool is_extern;
    bool internal_linkage;
    unsigned calling_convention;
    ImportTableEntry *import_entry;

    // reminder: hash tables must be initialized before use
    HashMap<Buf *, LabelTableEntry *, buf_hash, buf_eql_buf> label_table;
};

struct CodeGen {
    LLVMModuleRef module;
    ZigList<ErrorMsg*> errors;
    LLVMBuilderRef builder;
    LLVMZigDIBuilder *dbuilder;
    LLVMZigDICompileUnit *compile_unit;

    // reminder: hash tables must be initialized before use
    HashMap<Buf *, FnTableEntry *, buf_hash, buf_eql_buf> fn_table;
    HashMap<Buf *, LLVMValueRef, buf_hash, buf_eql_buf> str_table;
    HashMap<Buf *, TypeTableEntry *, buf_hash, buf_eql_buf> type_table;
    HashMap<Buf *, bool, buf_hash, buf_eql_buf> link_table;
    HashMap<Buf *, ImportTableEntry *, buf_hash, buf_eql_buf> import_table;

    struct {
        TypeTableEntry *entry_bool;
        TypeTableEntry *entry_u8;
        TypeTableEntry *entry_i32;
        TypeTableEntry *entry_string_literal;
        TypeTableEntry *entry_void;
        TypeTableEntry *entry_unreachable;
        TypeTableEntry *entry_invalid;
    } builtin_types;

    LLVMTargetDataRef target_data_ref;
    unsigned pointer_size_bytes;
    bool is_static;
    bool strip_debug_symbols;
    CodeGenBuildType build_type;
    LLVMTargetMachineRef target_machine;
    bool is_native_target;
    Buf *root_source_dir;
    Buf *root_out_name;
    ZigList<LLVMZigDIScope *> block_scopes;

    // The function definitions this module includes. There must be a corresponding
    // fn_protos entry.
    ZigList<FnTableEntry *> fn_defs;
    // The function prototypes this module includes. In the case of external declarations,
    // there will not be a corresponding fn_defs entry.
    ZigList<FnTableEntry *> fn_protos;

    OutType out_type;
    FnTableEntry *cur_fn;
    LLVMBasicBlockRef cur_basic_block;
    bool c_stdint_used;
    AstNode *root_export_decl;
    int version_major;
    int version_minor;
    int version_patch;
    bool verbose;
    ErrColor err_color;
    ImportTableEntry *root_import;
};

struct LocalVariableTableEntry {
    Buf name;
    TypeTableEntry *type;
    LLVMValueRef value_ref;
    bool is_const;
    AstNode *decl_node;
};

struct BlockContext {
    AstNode *node; // either NodeTypeFnDef or NodeTypeBlock
    BlockContext *root; // always points to the BlockContext with the NodeTypeFnDef
    BlockContext *parent; // nullptr when this is the root
    HashMap<Buf *, LocalVariableTableEntry *, buf_hash, buf_eql_buf> variable_table;
};

struct TypeNode {
    TypeTableEntry *entry;
};

struct FnProtoNode {
    FnTableEntry *fn_table_entry;
};

struct FnDefNode {
    TypeTableEntry *implicit_return_type;
    BlockContext *block_context;
    bool skip;
    ZigList<BlockContext *> all_block_contexts;
};

struct ExprNode {
    TypeTableEntry *type_entry;
    // the context in which this expression is evaluated.
    // for blocks, this points to the containing scope, not the block's own scope for its children.
    BlockContext *block_context;
};

struct AssignNode {
    LocalVariableTableEntry *var_entry;
};

struct CodeGenNode {
    union {
        TypeNode type_node; // for NodeTypeType
        FnDefNode fn_def_node; // for NodeTypeFnDef
        FnProtoNode fn_proto_node; // for NodeTypeFnProto
        LabelTableEntry *label_entry; // for NodeTypeGoto and NodeTypeLabel
        AssignNode assign_node; // for NodeTypeBinOpExpr where op is BinOpTypeAssign
    } data;
    ExprNode expr_node; // for all the expression nodes
};

static inline Buf *hack_get_fn_call_name(CodeGen *g, AstNode *node) {
    // Assume that the expression evaluates to a simple name and return the buf
    // TODO after type checking works we should be able to remove this hack
    assert(node->type == NodeTypeSymbol);
    return &node->data.symbol;
}

#endif