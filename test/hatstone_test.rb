require "helper"

class HatstoneTest < Hatstone::Test
  def test_disasm_x64
    hs = Hatstone.new(Hatstone::ARCH_X86, Hatstone::MODE_64)

    # https://godbolt.org/z/W95G3zTh1
    insns = +""
    insns << "\xb8\x2a\x00\x00\x00" # mov eax, 42
    insns << "\xc3" # mov eax, 42

    disassembled = hs.disasm(insns, 0x0)
    assert_equal "mov", disassembled[0].mnemonic
    assert_equal "eax, 0x2a", disassembled[0].op_str
    assert_equal "ret", disassembled[1].mnemonic
    assert_equal "", disassembled[1].op_str
  end

  def test_disasm_arm
    hs = Hatstone.new(Hatstone::ARCH_ARM64, Hatstone::MODE_ARM)

    # Assemble some instructions
    insns = [
      movz(0, 42),  # mov X0, 42
      ret           # ret
    ].pack("L<L<")

    disassembled = hs.disasm(insns, 0x0)
    assert_equal "movz", disassembled[0].mnemonic
    assert_equal "x0, #0x2a", disassembled[0].op_str
    assert_equal "ret", disassembled[1].mnemonic
    assert_equal "", disassembled[1].op_str
  end

  # ARM instructions
  def movz reg, imm
    insn = 0b0_10_100101_00_0000000000000000_00000
    insn |= (1 << 31)  # 64 bit
    insn |= (imm << 5) # immediate
    insn |= reg        # reg
  end

  def ret xn = 30
    insn = 0b1101011_0_0_10_11111_0000_0_0_00000_00000
    insn |= (xn << 5)
    insn
  end
end
