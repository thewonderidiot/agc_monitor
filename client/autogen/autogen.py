#!/usr/bin/env python3
import argparse
import json
import glob
import os

HEADER_TEMPLATE = '''from collections import namedtuple
import struct

DATA_FMT = '>BHH'
READ_FMT = '>BH'
WRITE_FLAG = 0x80

def pack(msg):
    return globals()['_pack_' + type(msg).__name__](msg)

'''

TYPE_TEMPLATE = '''%s = namedtuple('%s', %s)
'''

GROUP_ENUM_TEMPLATE = '''class AddressGroup(object):
'''

REG_ENUM_TEMPLATE = '''class %s(object):
'''

PACK_WRITE_TEMPLATE = '''def _pack_%s(msg):
    data = 0x0000
%s
    return _pack_write_msg(AddressGroup.%s, %s.%s, data)
'''

FOOTER_TEMPLATE = '''def _pack_write_msg(group, addr, data):
    return struct.pack(DATA_FMT, WRITE_FLAG | group, addr, data)

'''

def load_specs(specs_dir):
    specs = {}
    files = glob.glob(os.path.join(specs_dir, '*.json'))
    for filename in files:
        with open(filename, 'r') as f:
            data = json.load(f)

        specs[data['name']] = data

    return specs

def generate_message_type(name, reg, include_fields):
    fields = []
    if include_fields:
        for field in reg['fields']:
            fields.append(field['name'])

    return TYPE_TEMPLATE % (name, name, str(fields))

def generate_message_types(specs):
    output = ''
    for group, spec in specs.items():
        if 'registers' in spec:
            for reg in spec['registers']:
                name = reg['name']
                msg_suffix = group + name
                if 'r' in reg['type']:
                    output += generate_message_type('Read' + msg_suffix, reg, False)
                    output += generate_message_type(msg_suffix, reg, True)
                if 'w' in reg['type']:
                    output += generate_message_type('Write' + msg_suffix, reg, True)
        else:
            pass

    return output

def generate_group_enum(specs):
    output = GROUP_ENUM_TEMPLATE
    for group, spec in specs.items():
        output += '    %s = 0x%02X\n' % (group, spec['id'])

    return output

def generate_reg_enums(specs):
    output = ''
    for group, spec in specs.items():
        if 'registers' in spec:
            output += REG_ENUM_TEMPLATE % group
            for reg in spec['registers']:
                output += '    %s = 0x%04X\n' % (reg['name'], reg['addr'])
        else:
            pass

    return output

def generate_pack_funcs(specs):
    output = ''
    for group, spec in specs.items():
        if 'registers' in spec:
            for reg in spec['registers']:
                if 'w' in reg['type']:
                    output += generate_pack_write_func(group, reg) + '\n'
                elif 'r' in reg['type']:
                    #output += generate_pack_read_func(group, reg)
                    pass
        else:
            pass

    return output

def generate_pack_write_func(group, reg):
    field_sets = ''
    offset = 0
    for field in reg['fields']:
        if field['name'] != 'spare':
            field_sets += '    data |= (msg.%s & 0x%04X) << %u\n' % (field['name'], 2**field['width']-1, offset)

        offset += field['width']

    return PACK_WRITE_TEMPLATE % ('Write'+group+reg['name'], field_sets, group, group, reg['name'])

def generate_interface(specs_dir, output_filename):
    specs = load_specs(specs_dir)
    
    output = HEADER_TEMPLATE
    output += generate_message_types(specs) + '\n'
    output += generate_group_enum(specs) + '\n'
    output += generate_reg_enums(specs) + '\n'
    output += generate_pack_funcs(specs) + '\n'
    output += FOOTER_TEMPLATE

    print(output)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate Monitor USB message handling code from JSON spec')
    parser.add_argument('-s', '--specs', default='../spec', help='Folder containing JSON specs')
    parser.add_argument('-o', '--output', default='../agc_monitor/usb_msgs.py', help='Output python file')
    args = parser.parse_args()

    generate_interface(args.specs, args.output)
