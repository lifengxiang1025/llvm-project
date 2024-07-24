#ifndef PRESERVENONEUPDATING_H
#define PRESERVENONEUPDATING_H

namespace llvm {

#include "llvm/ADT/IntrusiveRefCntPtr.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Pass.h"
#include "llvm/Support/CommandLine.h"
#include <string>

class Module;

class PreserveNoneUpdatingPass
    : public PassInfoMixin<PreserveNoneUpdatingPass> {
public:
  PreserveNoneUpdatingPass(){};

  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);
};

} // namespace llvm

#endif
