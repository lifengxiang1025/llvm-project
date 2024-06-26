; RUN: opt %loadNPMPolly -polly-ignore-aliasing -polly-invariant-load-hoisting=true '-passes=print<polly-detect>,print<polly-function-scops>' -disable-output < %s 2>&1 | FileCheck %s
; RUN: opt %loadNPMPolly -polly-ignore-aliasing -polly-invariant-load-hoisting=true -passes=polly-codegen -disable-output < %s
;
; %tmp is added to the list of required hoists by -polly-scops and just
; assumed to be hoisted. Only -polly-scops recognizes it to be unhoistable
; because ir depends on %call which cannot be executed speculatively.
;
; CHECK-NOT:       Invariant Accesses:
;
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

; Function Attrs: nounwind uwtable
define void @cli_hex2int() {
entry:
  br label %if.end

if.end:                                           ; preds = %entry
  %call = call ptr @__ctype_b_loc() #0
  %tmp = load ptr, ptr %call, align 8
  %tmp1 = load i16, ptr %tmp, align 2
  store i16 3, ptr %tmp, align 2
  br i1 false, label %if.then.2, label %if.end.3

if.then.2:                                        ; preds = %if.end
  br label %cleanup

if.end.3:                                         ; preds = %if.end
  br label %cleanup

cleanup:                                          ; preds = %if.end.3, %if.then.2
  ret void
}

; Function Attrs: nounwind readnone
declare ptr @__ctype_b_loc() #0

attributes #0 = { nounwind readnone }
