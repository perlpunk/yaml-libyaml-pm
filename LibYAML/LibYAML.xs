#include <perl_libyaml.h>
/* XXX Make -Wall not complain about 'local_patches' not being used. */
#if !defined(PERL_PATCHLEVEL_H_IMPLICIT)
void xxx_local_patches_xs() { printf("%s", local_patches[0]); }
#endif

MODULE = YAML::XS::LibYAML		PACKAGE = YAML::XS::LibYAML		

PROTOTYPES: DISABLE

void
Load (yaml_sv)
        SV *yaml_sv
        PPCODE:
        PL_markstack_ptr++;
        Load(yaml_sv);
        return;

void
Dump (...)
        PPCODE:
        SV *dummy = NULL;
        PL_markstack_ptr++;
        Dump(dummy);
        return;

SV *
libyaml_version()
    CODE:
    {
        const char *v = yaml_get_version_string();
        RETVAL = newSVpv(v, strlen(v));

    }
    OUTPUT: RETVAL


MODULE = YAML::XS::LibYAML  PACKAGE = YAML::XS::LibYAML

PROTOTYPES: DISABLE

SV *
new(char *class_name, ...)
    PPCODE:
    {
        dXCPT;
        perl_yaml_xs_t *yaml;
        SV *point_sv;
        SV *point_svrv;
        HV *hash;
        SV *object;
        int i;
        int indent;

        XCPT_TRY_START
        {
            yaml = (perl_yaml_xs_t*) malloc(sizeof(perl_yaml_xs_t));
            hash = newHV();

            yaml_parser_initialize(&yaml->parser);
            yaml_emitter_initialize(&yaml->emitter);
            yaml_emitter_set_unicode(&yaml->emitter, 1);

            if (items > 1) {
                for (i = 1; i < items; i+=2) {
                    //fprintf(stderr, "==== %d/%d\n", i, items);
                    if (i+1 >= items)
                        break;
                    if (SvPOK(ST(1))) {
                        char *key = (char *)SvPV_nolen(ST(i));
                        if (strEQ(key, "indent")) {
                            indent = SvIV(ST(i+1));
                            SV *indent_sv = newSViv(indent);
                            //fprintf(stderr, "==== %d: %s=%d\n", i, key, indent);
                            hv_store(hash, "indent", 6, indent_sv, 0);
                            yaml_emitter_set_indent(&yaml->emitter, indent);
                        }
                    }
                }
            }

            //fprintf(stderr, "=============== new p: %p\n", yaml);
            //fprintf(stderr, "=============== new parser: %p\n", &yaml->parser);
            point_sv = newSViv(PTR2IV(yaml));
            hv_store(hash, "ptr", 3, point_sv, 0);

            point_svrv = sv_2mortal(newRV_noinc((SV*)hash));
            object = sv_bless(point_svrv, gv_stashpv(class_name, 1));
        } XCPT_TRY_END

        XCPT_CATCH
        {
            //yaml_parser_delete(&yaml->parser);
            //yaml_parser_delete(&yaml->emitter);
            XCPT_RETHROW;
        }
        XPUSHs(object);
        XSRETURN(1);
    }

SV *
load_string(SV *object, SV *string)
    PPCODE:
    {
        dXCPT;
        perl_yaml_xs_t *yaml;
        HV *hash;
        SV **val;
        STRLEN yaml_len;
        const unsigned char *yaml_str;
        SV *node;

        hash = (HV*)(SvROK(object)? SvRV(object): object);
        val = hv_fetch(hash, "ptr", 3, TRUE);
        yaml_str = (const unsigned char *)SvPV_const(string, yaml_len);

        fprintf(stderr, "=============== load_string '%s'\n", yaml_str);
        XCPT_TRY_START
        {
            if (val && SvOK(*val) && SvIOK(*val)) {
                yaml = INT2PTR(perl_yaml_xs_t*, SvIV(*val));
                fprintf(stderr, "=============== load_string p: %p\n", yaml);
                fprintf(stderr, "=============== load_string parser: %p\n", &yaml->parser);
                yaml_parser_set_input_string(
                    &yaml->parser,
                    yaml_str,
                    yaml_len
                );
                node = oo_load(yaml);

            }
        } XCPT_TRY_END

        XCPT_CATCH
        {
            XCPT_RETHROW;
        }

        XPUSHs(sv_2mortal(node));
        XSRETURN(1);
    }

SV *
dump_string(SV *object, SV *data)
    PPCODE:
    {
        dXCPT;
        perl_yaml_xs_t *yaml;
        HV *hash;
        SV **val;
        yaml_event_t event_stream_start;
        yaml_event_t event_stream_end;
        SV *string = newSVpvn("", 0);

        //fprintf(stderr, "=============== dump_string\n");
        hash = (HV*)(SvROK(object)? SvRV(object): object);
        val = hv_fetch(hash, "ptr", 3, TRUE);

        XCPT_TRY_START
        {
            if (val && SvOK(*val) && SvIOK(*val)) {
                yaml = INT2PTR(perl_yaml_xs_t*, SvIV(*val));
                //fprintf(stderr, "=============== dump_string p: %p\n", yaml);
                //fprintf(stderr, "=============== dump_string parser: %p\n", &yaml->parser);

                yaml_emitter_set_output(&yaml->emitter, &append_output, (void *) string);

                yaml_stream_start_event_initialize(
                    &event_stream_start,
                    YAML_UTF8_ENCODING
                );
                if (!yaml_emitter_emit(&yaml->emitter, &event_stream_start))
                    croak("ERROR: %s", yaml->emitter.problem);

                oo_dump_document(yaml, data);

                yaml_stream_end_event_initialize(&event_stream_end);
                if (!yaml_emitter_emit(&yaml->emitter, &event_stream_end)) {
                    croak("ERROR: %s", yaml->emitter.problem);
                }
                if (string) {
                    SvUTF8_off(string);
                }

            }
        } XCPT_TRY_END

        XCPT_CATCH
        {
            XCPT_RETHROW;
        }

        XPUSHs(string);
        XSRETURN(1);
    }

void
DESTROY(SV *object)
    PPCODE:
    {
        dXCPT;
        perl_yaml_xs_t *yaml;
        HV *hash;
        SV **val;

        //fprintf(stderr, "=============== DESTROY\n");
        hash = (HV*)(SvROK(object)? SvRV(object): object);
        val = hv_fetch(hash, "ptr", 3, TRUE);
        if (val && SvOK(*val) && SvIOK(*val)) {
            yaml = INT2PTR(perl_yaml_xs_t*, SvIV(*val));
            yaml_parser_delete(&yaml->parser);
            yaml_emitter_delete(&yaml->emitter);
            free(yaml);
        }

        XSRETURN(0);
    }

