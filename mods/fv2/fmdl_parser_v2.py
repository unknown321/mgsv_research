#!/usr/bin/python
# fmdl parser v2 by unknown
# originally made by Jayveerk 
# https://github.com/Jayveerk/FMDL/blob/master/MGSV%20FMDL%20PC.ms

import binascii
import array
import struct
import os
import shutil

texture_magic = "782a0d778e800000"
mesh_root = "35d648f974580000"

offsets = {
	"mgo_male_to_ddmale": [0, 0.0235138, -0.1111658],
	"cat": [0, -0.496358, 0],
	"signs": [0, -0.103511, 0],
	"male_eyewear": [0, -0.088452, -0.12453378],
	"ddmale_to_snake": [0, 0, 0.02813875],
	"ddmale_to_ddfemale": [0, 0, -0.01513875]
}

def long_to_int(s,start):
	#redlong, 4 bytes
	longstring = s[start:start+8]
	x = binascii.unhexlify(longstring)
	return array.array('l',x)[0]

def byte_to_int(s,start):
	#readbyte, 1 byte
	bytestring = s[start:start+2]
	x = binascii.unhexlify(bytestring)
	return array.array('b',x)[0]

def long_to_float(s,start):
	#readfloat, 4 bytes
	floatstring = s[start:start+8]
	x = binascii.unhexlify(floatstring)
	return array.array('f',x)[0]

def short_to_int(s,start):
	#readshort, 2 bytes
	shortstring = s[start:start+4]
	x = binascii.unhexlify(shortstring)
	return array.array('h',x)[0]

def read_half_float(s,start):
	#float - 4 bytes, halffloat - 2 bytes
	hf = short_to_int(s,start)
	start = start + 4
	sign = bool(hf & 0x80000000)
	exponent = int((hf & 31744) >> 10) - 16
	fraction = hf & 1023
	exponentF = exponent + 127
	o1 = fraction <<  13 | exponentF << 23
	o2 = sign << 31
	out = o1 | o2
	s = struct.pack('>L', out)
   	return (struct.unpack('>f', s)[0])*2

def move_vertex(coord, offset):
	#x, y, z
	return [x + y for x,y in zip(coord, offset)]

def parse_fmdl(filename, print_sections=False, move_fmdl=False, new_offset=None):
	face_array = []
	uv_array = {}
	normal_array = {}
	vert_array = []
	fmdl_entries = {}
	fmdl_entries2 = {}

	f = open(filename,'rb')
	s = f.read().encode('hex')
	f.close()

	start = 64
	no_entries = long_to_int(s,start)
	no_entries2 = long_to_int(s,start+8)
	start += 16
	fmdl_sections = {
		1:{
			"section_offset":long_to_int(s,start),
			"section_length":long_to_int(s,start+8)
			},
		2:{
			"section_offset":long_to_int(s,start+16),
			"section_length":long_to_int(s,start+24)
			}
		}
	start += 32
	start += 16

	for i in range(1,no_entries+1):
		entry_id = short_to_int(s,start)
		start += 4
		fmdl_entries[entry_id] = {
			"entry_blocks":short_to_int(s,start),
			"entry_offset":long_to_int(s,start+4)}
		start += 12

	for i in range(1, no_entries2+1):
		entry_id = long_to_int(s,start)
		start += 8
		fmdl_entries2[entry_id] = {
			"entry_offset":long_to_int(s,start),
			"entry_size":long_to_int(s,start+8)}
		start += 16

		#id 00 = Bone Table
		#id 01 = Mesh list
		#id 02 = Mesh Group Table
		#id 03 = Vertex + Face index table
		#id 04 = 
		#id 05 = Bone Lookup Table
		#id 06 = Tex list
		#id 07 = Mat list
		#id 08 =
		#id 09 =
		#id 10 = something to do with vdef
		#id 11 = ?? big mystery
		#id 12 = String Def Table
		#id 13 = floats, the same as bones
		#id 14 = Buffer Offset Table
		#id 21 = texture list
		#id 22 = fv2/fmdl commands (options?)

	v_buf_size = {}
	start = (fmdl_sections[1]['section_offset'] + fmdl_entries[10]['entry_offset'])*2
	for i in range(1,fmdl_entries[3]['entry_blocks']+1):
		start += 20
		v_buf_size[i] = byte_to_int(s,start)
		start += 2
		if v_buf_size[i] in [28,20]:
			start += 26
		else:
			start += 42
	
	#bones
	if fmdl_entries.has_key(0):
		#there are boneless models like dd beret
		if fmdl_entries[0]['entry_blocks']:
			start = (fmdl_sections[1]['section_offset'] + fmdl_entries[0]['entry_offset'])*2
			for i in range(1,fmdl_entries[0]["entry_blocks"]+1):
				bone_id = s[start:start+4]
				bone_parent = short_to_int(s,start+4) + 1
				bone_idx = short_to_int(s,start+8)

				start += 16
				# 3 unk values, short-long-long
				start += 16

				b1x = long_to_float(s,start)
				b1y = long_to_float(s,start+8)
				b1z = long_to_float(s,start+16)
				b1w = long_to_float(s,start+24)
				b2x = long_to_float(s,start+32)
				b2y = long_to_float(s,start+40)
				b2z = long_to_float(s,start+48)
				b2w = long_to_float(s,start+56)

				start += 64

				#line 216 in original script, functions for displaying stuff in 3dsmax?
				#ignored

	#vertex index table
	start = (fmdl_sections[1]["section_offset"] + fmdl_entries[3]['entry_offset'])*2
	vert_size = {}
	face_offset = {}
	face_size = {}
	for i in range(1, fmdl_entries[3]['entry_blocks']+1):
		start += 20
		vert_size[i] = long_to_int(s,start)
		uk = short_to_int(s,start+8)
		face_offset[i] = long_to_int(s,start+8+4)
		face_size[i] = long_to_int(s,start+8+4+8)
		start += 28
		start += 48

	#buffer offset table
	fmdl_buffers = {}
	start = (fmdl_sections[1]['section_offset'] + fmdl_entries[14]['entry_offset'])*2
	for i in range(1,fmdl_entries[14]['entry_blocks']+1):
		start += 8
		fmdl_buffers[i] = {}
		fmdl_buffers[i]['buffer_size'] = long_to_int(s,start)
		fmdl_buffers[i]['buffer_offset'] = long_to_int(s,start+8)
		start += 16
		start += 8

	#vertexes + faces
	#id 02 of second index = vertex buffer
	vertex_offset = (fmdl_sections[2]['section_offset'] + fmdl_entries2[2]['entry_offset'])*2
	start = vertex_offset
	#id 02 of second index = vertex buffer + 3rd entry of buffer table = face buffer
	last_face_pos = ((fmdl_sections[2]['section_offset'] + fmdl_entries2[2]['entry_offset']) + fmdl_buffers[3]['buffer_offset'])*2 
	#id 02 of second index = vertex buffer + 2nd entry of buffer table = vdef buffer
	last_uv_pos = ((fmdl_sections[2]['section_offset'] + fmdl_entries2[2]['entry_offset']) + fmdl_buffers[2]['buffer_offset'])*2
	for ent_block in range(1, fmdl_entries[3]['entry_blocks']+1):
		for x in range(1, vert_size[ent_block]+1):
			vx = long_to_float(s,start)
			vy = long_to_float(s,start+8)
			vz = long_to_float(s,start+16)
			if move_fmdl and new_offset:
				new_coords = move_vertex([vx,vy,vz], new_offset)
				for n,i in enumerate(new_coords):
					#python-specific fixes
					if i < 0 and i == 0:
						v = 0.0
					else:
						v = i
					text = hex(struct.unpack('<I', struct.pack('<f', v))[0])[2:].rstrip('L')
					text = "".join(reversed([text[i:i+2] for i in range(0, len(text), 2)]))
					if text == "0":
						text = "00000000"
					#replace vertex coords on the fly
					s = s[:start+n*8] + text + s[start+n*8+8:]
			start += 24


		while start%32 != 0:
			start += 8

		last_vert_pos = start
		start = last_uv_pos

		for i in range(1, vert_size[ent_block]+1):
			nx = read_half_float(s,start)
			ny = read_half_float(s,start+4)
			nz = read_half_float(s,start+8)
			nw = read_half_float(s,start+12)
			start += 16
	
			#4x unknown halfbytes
			start += 16

			if v_buf_size[ent_block] in [32, 28]:
				bw1 = byte_to_int(s,start) / 255 #as unsigned??
				bw2 = byte_to_int(s,start+2) / 255
				bw3= byte_to_int(s,start+4) / 255
				bw4 = byte_to_int(s,start+6) / 255
				bidx1 = byte_to_int(s,start+8)
				bidx2 = byte_to_int(s,start+10)
				bidx3 = byte_to_int(s,start+12)
				bidx4 = byte_to_int(s,start+14)
				start += 16

			if v_buf_size[ent_block] == 32:
				#unknown float
				start += 8

			tu = read_half_float(s,start)
			tv = read_half_float(s,start+4)
			start += 8

		while start%32 != 0:
			start += 8

		last_uv_pos = start
		start = last_face_pos + face_offset[ent_block]*2*2

		#faces array 1+2
		toto = ent_block + 1
		if toto > fmdl_entries[3]['entry_blocks']:
			next_face_pos = (fmdl_sections[2]["section_offset"] + fmdl_sections[2]['section_length'])*2
		else:
			next_face_pos = last_face_pos + (face_offset[toto]*2)
		face_leftover = next_face_pos - (last_face_pos + face_offset[ent_block]*2)

		face_leftover = face_leftover / 2
		while face_leftover%6 != 0 :
			face_leftover = face_leftover - 1
		face_leftover = face_leftover * 2

		for o in range(1, (face_leftover/6)+1):
			try:
				fa = short_to_int(s,start) + 1
				fb = short_to_int(s,start+4) + 1
				fc = short_to_int(s,start+8) + 1
			except Exception as e:
				# print 'no more lod faces!!!'
				break
			else:
				face_array.append([fa,fb,fc])
			start += 12

		# face_array = []
		start = last_vert_pos


	if print_sections:
		file_by_sections = open(filename[:-5] + '_sections.txt','wb')

		# calculate section sizes
		# I forgot why we need them, probably because there was a problem with 
		# reading file in one go
		# it just works
		section_sizes = {}
		lastkey = sorted(fmdl_entries.keys(),reverse=True)[0]
		for k,v in enumerate(fmdl_entries):
			key = v
			nextkey = key + 1
			if nextkey > lastkey:
				break
			else:
				while not fmdl_entries.has_key(nextkey):
					nextkey = nextkey +1
			section_sizes[v] = (fmdl_entries[nextkey]['entry_offset'] - fmdl_entries[key]['entry_offset'])
		section_sizes[lastkey] = fmdl_sections[2]['section_offset'] - fmdl_entries[lastkey]['entry_offset'] - fmdl_sections[1]['section_offset']


		for n, section in enumerate([fmdl_entries.iteritems(),fmdl_entries2.iteritems()]):
			for k, v in section:
				s1pos = (v['entry_offset'] + fmdl_sections[n+1]['section_offset'])*2
				if n == 0:
					s2pos = s1pos + section_sizes[k]*2
				else:
					s2pos = s1pos + v['entry_size']*2
				file_by_sections.write("Section {}.{} ([{}:{}]):\n".format(n+1,k,s1pos/2,s2pos/2))
				text = s[s1pos:s2pos]
				lines = []
				start_position = s1pos
				while s1pos<s2pos:
					lines.append(s[s1pos:s1pos+16])
					s1pos += 16

				s1pos = start_position/2
				for line in lines:
					file_by_sections.write('\t{}: {}\n'.format(s1pos,line))	
					s1pos += 8
				file_by_sections.write('\n')
		file_by_sections.close()

	if move_fmdl:
		f = open(filename[:-5] + '_moved.fmdl','wb')
		f.write(s.decode('hex'))
		f.close()

def batch_parse(path, move_fmdl, print_sections):
	result = {}
	for root, dirs, files in os.walk(path):
		for file in files:
			if file[:-5] == '.fmdl':
				print '\n------------------\n' + file
				a = root + '\\' + file
				a = os.path.normpath(a)
				parse_fmdl(a, print_sections, move_fmdl)

def fmdl_mesh_fix(filename):
	# version 3
	s = open(filename,'rb').read().encode('hex')
	if s.find(mesh_root) > 0:
		s = s.replace(mesh_root, texture_magic)
		f = open(filename,'wb')
		f.write(s.decode('hex'))
		f.close()
	else:
		print "no mesh root"


move_fmdl = False
print_sections = True

# path = r'J:\mgs\fv2\mod_models'
# batch_parse(pathmove_fmdl, print_sections)
# parse_fmdl(filename, print_sections, move_fmdl, offsets['ddmale_to_snake'])
filename = r'J:\mgs\fv2\mod_models\snake\tpp\bioengineer_gls0_main0_def.fmdl'
parse_fmdl(filename, print_sections, move_fmdl)
