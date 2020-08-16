
# python3 generator.py -std=c++1z ../main.cpp
# python3, castxml and pygccxml should be installed

import os
import sys

# Find out the file location within the sources tree
this_module_dir_path = os.path.abspath(
    os.path.dirname(sys.modules[__name__].__file__))
# Add pygccxml package to Python path
#sys.path.append(os.path.join(this_module_dir_path, '..', '..'))


from pygccxml import parser  # nopep8
from pygccxml import declarations  # nopep8
from pygccxml import utils  # nopep8

# Find out the xml generator (gccxml or castxml)
generator_path, generator_name = utils.find_xml_generator()

flags = filter(lambda x: x.startswith("-"), sys.argv[1:])

# Configure the xml generator
config = parser.xml_generator_configuration_t(
    xml_generator_path=generator_path,
    xml_generator=generator_name,
    cflags=" ".join(flags),
   # start_with_declarations="test",
   #compiler="gcc",
)

# Parsing source file

filenames = list(filter(lambda x: not x.startswith("-"), sys.argv[1:]))
full_filenames =  [os.path.abspath(filename) for filename in filenames ]

decls = parser.parse(full_filenames, 
                     config,
                     compilation_mode=parser.COMPILATION_MODE.ALL_AT_ONCE 

)
global_ns = declarations.get_global_namespace(decls)

write_hdrs = True

if write_hdrs:
    for filename in filenames:
        print('#include "%s"' % filename)


def get_prefix(member, duplicates):
    p = []
    try:
        if member.name in duplicates:
            p.append("overload")
        if member.is_artificial:
            p.append("implicit")
        if member.access_type != "public":
            p.append(member.access_type)
    except AttributeError:
        pass
    if p == []:
        duplicates.append(member.name)
        return ""
    return "// " + ", ".join(p) + ": "


def get_arg_types(fn):
    return ", ".join([x.decl_string for x in fn.argument_types])

def get_addr(fn):
    #return "static_cast<" + fn.decl_string + ">(&" + declarations.declaration_utils.full_name(fn) + ")"
    return "&" + declarations.declaration_utils.full_name(fn)



write_fn = True

if write_fn:
    print('void qjs_glue(qjs::Context::Module& m) {')

dump_all = False

# print free functions
free_dups = []
for fn in global_ns.free_functions(allow_empty=True):
    if not dump_all and not fn.location.file_name in full_filenames:
        continue

    print('%sm.function<%s>("%s"); // (%s)' % (get_prefix(fn, free_dups), get_addr(fn), fn.name, get_arg_types(fn)))


visited = []

def dump_class(class_):
    if class_ in visited:
        return
    visited.append(class_)
    duplicates = []
    print('m.class_<%s>("%s")' % (declarations.declaration_utils.full_name(class_), class_.name))
    # print('\tbase classes   : ', repr([
    for base in class_.bases:
        print('\t//.base<%s>()' % declarations.declaration_utils.full_name(base.related_class));
    for fn in class_.constructors(allow_empty=True):
        print('\t%s.constructor<%s>()' % (get_prefix(fn, duplicates), get_arg_types(fn)))
    for fn in class_.member_functions(allow_empty=True):
        print('\t%s.fun<%s>("%s") // (%s)' % (get_prefix(fn, duplicates), get_addr(fn), fn.name, get_arg_types(fn)))
    for fn in class_.variables(allow_empty=True):
        print('\t%s.fun<%s>("%s") // %s' % (get_prefix(fn, duplicates), get_addr(fn), fn.name, fn.decl_type.decl_string))
    print(';\n')
    
# Print all classes
for class_ in global_ns.classes():
    if not dump_all and not class_.location.file_name in full_filenames:
        continue
    dump_class(class_)

if write_fn:
    print('} // qjs_glue')
