// RUN: llvm-tblgen -gen-disassembler  -I %p/../../include %s | FileCheck %s
// RUN: llvm-tblgen -gen-disassembler --large-decoder-table -I %p/../../include %s | FileCheck %s --check-prefix=CHECK-LARGE

// Test for OPC_ExtractField/OPC_CheckField with start bit > 255.
// These large start values may arise for architectures with long instruction
// words.

include "llvm/Target/Target.td"

def archInstrInfo : InstrInfo { }

def arch : Target {
  let InstructionSet = archInstrInfo;
}

class TestInstruction : Instruction {
  let Size = 64;
  let OutOperandList = (outs);
  let InOperandList = (ins);
  field bits<512> Inst;
  field bits<512> SoftFail = 0;
}

def InstA : TestInstruction {
  let Inst{509-502} = {0,0,0,0,?,?,?,?};
  let AsmString = "InstA";
}

def InstB : TestInstruction {
  let Inst{509-502} = {0,0,0,0,0,0,?,?};
  let AsmString = "InstB";
  let DecoderMethod = "DecodeInstB";
  let hasCompleteDecoder = 0;
}

// CHECK:      /* 0 */       MCD::OPC_ExtractField, 250, 3, 4,  // Inst{509-506} ...
// CHECK-NEXT: /* 4 */       MCD::OPC_FilterValue, 0, 17, 0, // Skip to: 25
// CHECK-NEXT: /* 8 */       MCD::OPC_CheckField, 248, 3, 2, 0, 6, 0, // Skip to: 21
// CHECK-NEXT: /* 15 */      MCD::OPC_TryDecode, {{[0-9]+}}, {{[0-9]+}}, 0, 0, 0, // Opcode: InstB, skip to: 21
// CHECK-NEXT: /* 21 */      MCD::OPC_Decode, {{[0-9]+}}, {{[0-9]+}}, 1, // Opcode: InstA
// CHECK-NEXT: /* 25 */      MCD::OPC_Fail,

// CHECK: if (!Check(S, DecodeInstB(MI, insn, Address, Decoder))) { DecodeComplete = false; return MCDisassembler::Fail; }


// CHECK-LARGE:      /* 0 */       MCD::OPC_ExtractField, 250, 3, 4,  // Inst{509-506} ...
// CHECK-LARGE-NEXT: /* 4 */       MCD::OPC_FilterValue, 0, 19, 0, 0, // Skip to: 28
// CHECK-LARGE-NEXT: /* 9 */       MCD::OPC_CheckField, 248, 3, 2, 0, 7, 0, 0, // Skip to: 24
// CHECK-LARGE-NEXT: /* 17 */      MCD::OPC_TryDecode, {{[0-9]+}}, {{[0-9]+}}, 0, 0, 0, 0, // Opcode: InstB, skip to: 24
// CHECK-LARGE-NEXT: /* 24 */      MCD::OPC_Decode, {{[0-9]+}}, {{[0-9]+}}, 1, // Opcode: InstA
// CHECK-LARGE-NEXT: /* 28 */      MCD::OPC_Fail,

// CHECK-LARGE: if (!Check(S, DecodeInstB(MI, insn, Address, Decoder))) { DecodeComplete = false; return MCDisassembler::Fail; }

