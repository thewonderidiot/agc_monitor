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

def unpack(msg_bytes):
    if len(msg_bytes) != struct.calcsize(DATA_FMT):
        raise RuntimeError('Cannot unpack data with unexpected length %u' % len(msg_bytes))

    group, addr, data = struct.unpack(DATA_FMT, msg_bytes)
    if group in _unpack_mem_fns:
        return _unpack_mem_fns[group](addr, data)
    else:
        return _unpack_reg_fns[(group, addr)](data)

'''

TYPE_TEMPLATE = '''{name} = namedtuple('{name}', {fields})
'''

GROUP_ENUM_TEMPLATE = '''class AddressGroup(object):
{groups}'''

REG_ENUM_TEMPLATE = '''class {group}(object):
{regs}'''

PACK_WRITE_REG_TEMPLATE = '''def _pack_Write{group}{reg}(msg):
    data = 0x0000
{fields}    return _pack_write_msg(AddressGroup.{group}, {group}.{reg}, data)
'''

PACK_READ_REG_TEMPLATE = '''def _pack_Read{group}{reg}(msg):
    return _pack_read_msg(AddressGroup.{group}, {group}.{reg})
'''

PACK_WRITE_MEM_TEMPLATE = '''def _pack_Write{group}(msg):
    return _pack_write_msg(AddressGroup.{group}, msg.addr, msg.data)
'''

PACK_READ_MEM_TEMPLATE = '''def _pack_Read{group}(msg):
    return _pack_read_msg(AddressGroup.{group}, msg.addr)
'''

UNPACK_DICTS_TEMPLATE = '''_unpack_reg_fns = {{
{reg_fns}}}

_unpack_mem_fns = {{
{mem_fns}}}
'''

UNPACK_REG_ENTRY_TEMPLATE = '''    (AddressGroup.{group}, {group}.{reg}): _unpack_{group}{reg},
'''

UNPACK_MEM_ENTRY_TEMPLATE = '''    (AddressGroup.{group}): _unpack_{group},
'''

UNPACK_REG_TEMPLATE = '''def _unpack_{group}{reg}(data):
    return {group}{reg}(
{fields}    )

'''

UNPACK_MEM_TEMPLATE = '''def _unpack_{group}(addr, data):
    return {group}(addr=addr, data=data)

'''

FOOTER_TEMPLATE = '''def _pack_write_msg(group, addr, data):
    return struct.pack(DATA_FMT, WRITE_FLAG | group, addr, data)

def _pack_read_msg(group, addr):
    return struct.pack(READ_FMT, group, addr)

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
    if reg is None:
        fields.append('addr')
        if include_fields:
            fields.append('data')
    elif include_fields:
        for field in reg['fields']:
            fields.append(field['name'])

    return TYPE_TEMPLATE.format(name=name, fields=str(fields))

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
            if 'r' in spec['type']:
                output += generate_message_type('Read' + group, None, False)
                output += generate_message_type(group, None, True)
            if 'w' in spec['type']:
                output += generate_message_type('Write' + group, None, True)

    return output

def generate_group_enum(specs):
    groups = ''
    for group, spec in specs.items():
        groups += '    %s = 0x%02X\n' % (group, spec['id'])

    return GROUP_ENUM_TEMPLATE.format(groups=groups)

def generate_reg_enums(specs):
    output = ''
    for group, spec in specs.items():
        if 'registers' in spec:
            regs = ''
            for reg in spec['registers']:
                regs += '    %s = 0x%04X\n' % (reg['name'], reg['addr'])
            output += REG_ENUM_TEMPLATE.format(group=group, regs=regs)

    return output

def generate_pack_fns(specs):
    output = ''
    for group, spec in specs.items():
        if 'registers' in spec:
            for reg in spec['registers']:
                if 'r' in reg['type']:
                    output += generate_pack_read_reg_fn(group, reg) + '\n'
                if 'w' in reg['type']:
                    output += generate_pack_write_reg_fn(group, reg) + '\n'
        else:
            if 'r' in spec['type']:
                output += generate_pack_read_mem_fn(group) + '\n'
            if 'w' in spec['type']:
                output += generate_pack_write_mem_fn(group) + '\n'

    return output

def generate_pack_write_reg_fn(group, reg):
    field_sets = ''
    offset = 0
    for field in reg['fields']:
        if field['name'] != 'spare':
            field_sets += '    data |= (msg.%s & 0x%04X) << %u\n' % (field['name'], 2**field['width']-1, offset)

        offset += field['width']

    return PACK_WRITE_REG_TEMPLATE.format(group=group, reg=reg['name'], fields=field_sets)

def generate_pack_read_reg_fn(group, reg):
    return PACK_READ_REG_TEMPLATE.format(group=group, reg=reg['name'])

def generate_pack_write_mem_fn(group):
    return PACK_WRITE_MEM_TEMPLATE.format(group=group)

def generate_pack_read_mem_fn(group):
    return PACK_READ_MEM_TEMPLATE.format(group=group)

def generate_unpack_fns(specs):
    output = ''
    for group, spec in specs.items():
        if 'registers' in spec:
            for reg in spec['registers']:
                if 'r' in reg['type']:
                    output += generate_unpack_reg_fn(group, reg)
        else:
            if 'r' in spec['type']:
                output += generate_unpack_mem_fn(group)

    return output

def generate_unpack_reg_fn(group, reg):
    field_gets = ''
    offset = 0
    for field in reg['fields']:
        if field['name'] != 'spare':
            field_gets += '        %s = (data >> %u) & 0x%04X,\n' % (field['name'], offset, 2**field['width']-1)
        offset += field['width']
    return UNPACK_REG_TEMPLATE.format(group=group, reg=reg['name'], fields=field_gets)

def generate_unpack_mem_fn(group):
    return UNPACK_MEM_TEMPLATE.format(group=group)

def generate_unpack_dicts(specs):
    reg_entries = ''
    mem_entries = ''
    for group, spec in specs.items():
        if 'registers' in spec:
            for reg in spec['registers']:
                if 'r' in reg['type']:
                    reg_entries += UNPACK_REG_ENTRY_TEMPLATE.format(group=group, reg=reg['name'])
        else:
            if 'r' in spec['type']:
                mem_entries += UNPACK_MEM_ENTRY_TEMPLATE.format(group=group)

    return UNPACK_DICTS_TEMPLATE.format(reg_fns=reg_entries, mem_fns=mem_entries)

def generate_interface(specs_dir, output_filename):
    specs = load_specs(specs_dir)
    
    output = HEADER_TEMPLATE
    output += generate_message_types(specs) + '\n'
    output += generate_group_enum(specs) + '\n'
    output += generate_reg_enums(specs) + '\n'
    output += generate_pack_fns(specs) + '\n'
    output += generate_unpack_fns(specs) + '\n'
    output += generate_unpack_dicts(specs) + '\n'
    output += FOOTER_TEMPLATE

    print(output)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate Monitor USB message handling code from JSON spec')
    parser.add_argument('-s', '--specs', default='../spec', help='Folder containing JSON specs')
    parser.add_argument('-o', '--output', default='../agc_monitor/usb_msgs.py', help='Output python file')
    args = parser.parse_args()

    generate_interface(args.specs, args.output)
