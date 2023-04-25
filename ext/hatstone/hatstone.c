#include <ruby.h>
#include <capstone.h>

static VALUE cInsn;
static VALUE eHatstoneError;

static void dealloc(void * ptr)
{
    cs_close((csh *)ptr);
    free(ptr);
}

static const rb_data_type_t handle_type = {
    "Hatstone/Handle",
    {0, dealloc, 0,},
    0, 0,
#ifdef RUBY_TYPED_FREE_IMMEDIATELY
    RUBY_TYPED_FREE_IMMEDIATELY,
#endif
};

static void raise_cs_err(cs_err err, const char *name) {
    rb_raise(eHatstoneError, "%s: %s", name, cs_strerror(err));
}

static VALUE
hatstone_open(VALUE klass, VALUE arch, VALUE mode)
{
    csh * handle = calloc(sizeof(csh), 1);

    cs_err ret = cs_open(NUM2INT(arch), NUM2INT(mode), handle);
    if (CS_ERR_OK == ret) {
	return TypedData_Wrap_Struct(klass, &handle_type, handle);
    } else {
        raise_cs_err(ret, "cs_open");
        return Qnil;
    }
}

static VALUE
hatstone_disasm(VALUE self, VALUE code_str, VALUE addr)
{
    csh * handle;
    TypedData_Get_Struct(self, csh, &handle_type, handle);

    size_t size = RSTRING_LEN(code_str);
    const uint8_t * code = (uint8_t *)StringValuePtr(code_str);
    uint64_t address = NUM2LONG(addr);

    cs_insn * insn = cs_malloc(*handle);

    VALUE list = rb_ary_new();

    while (cs_disasm_iter(*handle, &code, &size, &address, insn)) {
        VALUE vals = rb_ary_new_from_args(6,
                INT2NUM(insn->id),
                LONG2NUM(insn->address),
                INT2NUM(insn->size),
                rb_str_new((const char *)insn->bytes, insn->size),
                rb_str_new2(insn->mnemonic),
                rb_str_new2(insn->op_str));
        rb_ary_push(list, rb_struct_alloc(cInsn, vals));
    }

    cs_free(insn, 1);
    return list;
}

void Init_hatstone(void)
{
    VALUE klass = rb_define_class("Hatstone", rb_cObject);
    rb_undef_alloc_func(klass);
    rb_define_singleton_method(klass, "new", hatstone_open, 2);
    rb_define_method(klass, "disasm", hatstone_disasm, 2);

    eHatstoneError = rb_define_class_under(klass, "Error", rb_eStandardError);;

    cInsn = rb_struct_define_under(klass, "Insn", "id", "address", "size", "bytes", "mnemonic", "op_str", NULL);

#include "hatstone_enums.inc"
}
