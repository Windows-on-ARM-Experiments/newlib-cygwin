import struct

imp_sym_addr = 0x790003
pc = 0x800000
rs = 0x10  # x16 register
rd = 0x10  # x16 register

def sign_extend(value, n, m):
    mask = (1 << m) - 1
    sign = (0 - (value >> (n - 1))) << n
    if sign:
      return (value | sign) & mask
    else:
      return (value & (sign | mask >> 1)) & mask

# Calculate adr immediate (offset from PC)
imm = imp_sym_addr - pc

# Encode: adr x16, $imp_sym
immhi = sign_extend(imm >> 2, 64, 19)
immlo = imm & 0x3
adr = 0x10000000 | (immlo << 29) | (immhi << 5) | rd

# Encode: ldr x16, [x16]
imm12 = 0x00000000
ldr = 0xf9400000 | ((imm12 & 0xFFF) << 10) | (rs << 5) | rs

print("Binary: 0b" + format(adr & 0xffffffffffffffff, '064b') + ", 0b" + format(ldr & 0xffffffffffffffff, '064b'))
print("Hex: 0x" + format(adr & 0xffffffffffffffff, '016x') + ", 0x" + format(ldr & 0xffffffffffffffff, '016x'))
print("  imm:   0x" + format(imm & 0xffffffffffffffff, '016x') + ", 0b" + format(imm & 0xffffffffffffffff, '064b'))
print("  immhi: 0x" + format(immhi & 0xffffffffffffffff, '016x') + ", 0b" + format(immhi & 0xffffffffffffffff, '064b'))
print("  immlo: 0x" + format(immlo & 0xffffffffffffffff, '016x') + ", 0b" + format(immlo & 0xffffffffffffffff, '064b'))
print("  imp_sym_addr: 0x" + format(imp_sym_addr & 0xffffffffffffffff, '016x'))

# Decode adr back to immlo, immhi, imm, imp_sym_addr
#   immhi = (opcode >> 5) & 0x7ffff;
#   immlo = (opcode >> 29) & 0x3;
#   sign_extend = (0l - (immhi >> 18)) << 21;
#   imm = sign_extend | (immhi << 2) | immlo;
#   jmpto = *(uintptr_t *) ((uint8_t *) imp + imm);
decoded_immhi = (adr >> 5) & 0x7ffff
decoded_immlo = (adr >> 29) & 0x3
decoded_imm = sign_extend((decoded_immhi << 2) | decoded_immlo, 21, 64)
decoded_imp_sym_addr = decoded_imm + pc

print("Decoded ADR:")
print("  imm:   0x" + format(decoded_imm & 0xffffffffffffffff, '016x') + ", 0b" + format(decoded_imm & 0xffffffffffffffff, '064b'))
print("  immhi: 0x" + format(decoded_immhi & 0xffffffffffffffff, '016x') + ", 0b" + format(decoded_immhi & 0xffffffffffffffff, '064b'))
print("  immlo: 0x" + format(decoded_immlo & 0xffffffffffffffff, '016x') + ", 0b" + format(decoded_immlo & 0xffffffffffffffff, '064b'))
print("  imp_sym_addr: 0x" + format(decoded_imp_sym_addr & 0xffffffffffffffff, '016x'))

# Decode ldr (for offset, should be 0 in this case)
decoded_imm12 = (ldr >> 10) & 0xFFF
print("Decoded LDR:")
print("  imm12: 0x" + format(decoded_imm12, '08x'))
print("")

# Calculate adrp immediate (page offset from PC)
page_addr = imp_sym_addr & ~0xfff
page_pc = pc & ~0xfff
imm = (page_addr - page_pc) >> 12

# Encode: adrp x16, $imp_sym
immhi = sign_extend(imm >> 2, 64, 19)
immlo = imm & 0x3
adrp = 0x90000000 | (immlo << 29) | (immhi << 5) | rs

# Encode: ldr x16, [x16, #:lo12:$imp_sym]
imm12 = imp_sym_addr & 0xfff
ldr = 0xf9400200 | ((imm12 & 0xfff) << 10) | (rs << 5) | rs

print("Binary: 0b" + format(adrp & 0xffffffffffffffff, '064b') + ", 0b" + format(ldr & 0xffffffffffffffff, '064b'))
print("Hex: 0x" + format(adrp & 0xffffffffffffffff, '016x') + ", 0x" + format(ldr & 0xffffffffffffffff, '016x'))
print("  imm: 0x" + format(imm & 0xffffffffffffffff, '016x') + ", 0b" + format(imm & 0xffffffffffffffff, '064b'))
print("  immhi: 0x" + format(immhi & 0xffffffffffffffff, '016x') + ", 0b" + format(immhi & 0xffffffffffffffff, '064b'))
print("  immlo: 0x" + format(immlo & 0xffffffffffffffff, '016x') + ", 0b" + format(immlo & 0xffffffffffffffff, '064b'))
print("  imp_sym_addr: 0x" + format(imp_sym_addr & 0xffffffffffffffff, '016x') + ", 0b" + format(imp_sym_addr & 0xffffffffffffffff, '064b'))

# Decode adrp back to immlo, immhi, imm, imp_sym_addr
decoded_immhi = (adrp >> 5) & 0x7FFFF
decoded_immlo = (adrp >> 29) & 0x3
decoded_imm = sign_extend(((decoded_immhi << 2) | decoded_immlo) << 12, 33, 64)
decoded_imm = (pc & ~0xFFF) + decoded_imm

print("Decoded ADRP:")
print("  imm: 0x" + format(decoded_imm & 0xffffffffffffffff, '016x') + ", 0b" + format(decoded_imm & 0xffffffffffffffff, '064b'))
print("  immhi: 0x" + format(decoded_immhi & 0xffffffffffffffff, '016x') + ", 0b" + format(decoded_immhi & 0xffffffffffffffff, '064b'))
print("  immlo: 0x" + format(decoded_immlo & 0xffffffffffffffff, '016x') + ", 0b" + format(decoded_immlo & 0xffffffffffffffff, '064b'))
print("  imp_sym_addr: 0x" + format(decoded_imp_sym_addr & 0xffffffffffffffff, '016x') + ", 0b" + format(decoded_imp_sym_addr & 0xffffffffffffffff, '064b'))

# Decode ldr (for offset, should be lo12 of imp_sym_addr)
decoded_imm12 = (ldr >> 10) & 0xFFF
decoded_imp_sym_addr = decoded_imm | decoded_imm12
print("Decoded LDR:")
print("  imm12: 0x" + format(decoded_imm12, '016x'))
print("  imp_sym_addr: 0x" + format(decoded_imp_sym_addr, '016x'))


mask = (1 << 21) - 1
print("mask: 0x" + format(mask, '016x') + ", 0b" + format(mask, '064b'))
