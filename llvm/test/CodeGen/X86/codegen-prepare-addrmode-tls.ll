; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 4
; RUN: llc -o - %s | FileCheck %s --check-prefix=NOPIC
; RUN: llc -o - %s -relocation-model=pic | FileCheck %s --check-prefix=PIC
; RUN: llc -o - %s -relocation-model=pic -enable-tlsdesc | FileCheck %s --check-prefix=TLSDESC

target triple = "x86_64--linux-gnu"

declare void @effect()
declare nonnull ptr @llvm.threadlocal.address.p0(ptr nonnull)

@foo_local = dso_local thread_local(localexec) global i32 0, align 4

define i32 @func_local_tls(i32 %arg0, i64 %arg1) nounwind {
; NOPIC-LABEL: func_local_tls:
; NOPIC:       # %bb.0: # %entry
; NOPIC-NEXT:    pushq %rbp
; NOPIC-NEXT:    pushq %rbx
; NOPIC-NEXT:    pushq %rax
; NOPIC-NEXT:    movl %fs:foo_local@TPOFF, %ebp
; NOPIC-NEXT:    testl %edi, %edi
; NOPIC-NEXT:    movl %ebp, %eax
; NOPIC-NEXT:    jne .LBB0_2
; NOPIC-NEXT:  # %bb.1: # %if.then
; NOPIC-NEXT:    movq %rsi, %rbx
; NOPIC-NEXT:    callq effect@PLT
; NOPIC-NEXT:    movl %fs:foo_local@TPOFF+168(,%rbx,4), %eax
; NOPIC-NEXT:  .LBB0_2: # %if.end
; NOPIC-NEXT:    addl %ebp, %eax
; NOPIC-NEXT:    addq $8, %rsp
; NOPIC-NEXT:    popq %rbx
; NOPIC-NEXT:    popq %rbp
; NOPIC-NEXT:    retq
;
; PIC-LABEL: func_local_tls:
; PIC:       # %bb.0: # %entry
; PIC-NEXT:    pushq %rbp
; PIC-NEXT:    pushq %r14
; PIC-NEXT:    pushq %rbx
; PIC-NEXT:    movl %fs:.Lfoo_local$local@TPOFF, %ebp
; PIC-NEXT:    testl %edi, %edi
; PIC-NEXT:    movl %ebp, %eax
; PIC-NEXT:    jne .LBB0_2
; PIC-NEXT:  # %bb.1: # %if.then
; PIC-NEXT:    movq %rsi, %rbx
; PIC-NEXT:    movq %fs:0, %rax
; PIC-NEXT:    leaq .Lfoo_local$local@TPOFF(%rax), %r14
; PIC-NEXT:    callq effect@PLT
; PIC-NEXT:    movl 168(%r14,%rbx,4), %eax
; PIC-NEXT:  .LBB0_2: # %if.end
; PIC-NEXT:    addl %ebp, %eax
; PIC-NEXT:    popq %rbx
; PIC-NEXT:    popq %r14
; PIC-NEXT:    popq %rbp
; PIC-NEXT:    retq
;
; TLSDESC-LABEL: func_local_tls:
; TLSDESC:       # %bb.0: # %entry
; TLSDESC-NEXT:    pushq %rbp
; TLSDESC-NEXT:    pushq %r14
; TLSDESC-NEXT:    pushq %rbx
; TLSDESC-NEXT:    movl %fs:.Lfoo_local$local@TPOFF, %ebp
; TLSDESC-NEXT:    testl %edi, %edi
; TLSDESC-NEXT:    movl %ebp, %eax
; TLSDESC-NEXT:    jne .LBB0_2
; TLSDESC-NEXT:  # %bb.1: # %if.then
; TLSDESC-NEXT:    movq %rsi, %rbx
; TLSDESC-NEXT:    movq %fs:0, %rax
; TLSDESC-NEXT:    leaq .Lfoo_local$local@TPOFF(%rax), %r14
; TLSDESC-NEXT:    callq effect@PLT
; TLSDESC-NEXT:    movl 168(%r14,%rbx,4), %eax
; TLSDESC-NEXT:  .LBB0_2: # %if.end
; TLSDESC-NEXT:    addl %ebp, %eax
; TLSDESC-NEXT:    popq %rbx
; TLSDESC-NEXT:    popq %r14
; TLSDESC-NEXT:    popq %rbp
; TLSDESC-NEXT:    retq
entry:
  %addr = tail call ptr @llvm.threadlocal.address.p0(ptr @foo_local)
  %load0 = load i32, ptr %addr, align 4
  %cond = icmp eq i32 %arg0, 0
  br i1 %cond, label %if.then, label %if.end

if.then:
  tail call void @effect()
  %x = add i64 %arg1, 42
  %addr1 = getelementptr inbounds i32, ptr %addr, i64 %x
  %load1 = load i32, ptr %addr1, align 4
  br label %if.end

if.end:
  %phi = phi i32 [ %load1, %if.then ], [ %load0, %entry ]
  %ret = add i32 %phi, %load0
  ret i32 %ret
}

@foo_nonlocal = thread_local global i32 0, align 4

define i32 @func_nonlocal_tls(i32 %arg0, i64 %arg1) nounwind {
; NOPIC-LABEL: func_nonlocal_tls:
; NOPIC:       # %bb.0: # %entry
; NOPIC-NEXT:    pushq %rbp
; NOPIC-NEXT:    pushq %r14
; NOPIC-NEXT:    pushq %rbx
; NOPIC-NEXT:    movq foo_nonlocal@GOTTPOFF(%rip), %r14
; NOPIC-NEXT:    movl %fs:(%r14), %ebp
; NOPIC-NEXT:    testl %edi, %edi
; NOPIC-NEXT:    movl %ebp, %eax
; NOPIC-NEXT:    jne .LBB1_2
; NOPIC-NEXT:  # %bb.1: # %if.then
; NOPIC-NEXT:    movq %rsi, %rbx
; NOPIC-NEXT:    callq effect@PLT
; NOPIC-NEXT:    movl %fs:168(%r14,%rbx,4), %eax
; NOPIC-NEXT:  .LBB1_2: # %if.end
; NOPIC-NEXT:    addl %ebp, %eax
; NOPIC-NEXT:    popq %rbx
; NOPIC-NEXT:    popq %r14
; NOPIC-NEXT:    popq %rbp
; NOPIC-NEXT:    retq
;
; PIC-LABEL: func_nonlocal_tls:
; PIC:       # %bb.0: # %entry
; PIC-NEXT:    pushq %rbp
; PIC-NEXT:    pushq %r15
; PIC-NEXT:    pushq %r14
; PIC-NEXT:    pushq %rbx
; PIC-NEXT:    pushq %rax
; PIC-NEXT:    movq %rsi, %rbx
; PIC-NEXT:    movl %edi, %ebp
; PIC-NEXT:    data16
; PIC-NEXT:    leaq foo_nonlocal@TLSGD(%rip), %rdi
; PIC-NEXT:    data16
; PIC-NEXT:    data16
; PIC-NEXT:    rex64
; PIC-NEXT:    callq __tls_get_addr@PLT
; PIC-NEXT:    movq %rax, %r14
; PIC-NEXT:    movl (%rax), %r15d
; PIC-NEXT:    testl %ebp, %ebp
; PIC-NEXT:    movl %r15d, %eax
; PIC-NEXT:    jne .LBB1_2
; PIC-NEXT:  # %bb.1: # %if.then
; PIC-NEXT:    callq effect@PLT
; PIC-NEXT:    movl 168(%r14,%rbx,4), %eax
; PIC-NEXT:  .LBB1_2: # %if.end
; PIC-NEXT:    addl %r15d, %eax
; PIC-NEXT:    addq $8, %rsp
; PIC-NEXT:    popq %rbx
; PIC-NEXT:    popq %r14
; PIC-NEXT:    popq %r15
; PIC-NEXT:    popq %rbp
; PIC-NEXT:    retq
;
; TLSDESC-LABEL: func_nonlocal_tls:
; TLSDESC:       # %bb.0: # %entry
; TLSDESC-NEXT:    pushq %rbp
; TLSDESC-NEXT:    pushq %r14
; TLSDESC-NEXT:    pushq %rbx
; TLSDESC-NEXT:    leaq foo_nonlocal@tlsdesc(%rip), %rax
; TLSDESC-NEXT:    callq *foo_nonlocal@tlscall(%rax)
; TLSDESC-NEXT:    movl %fs:(%rax), %ebp
; TLSDESC-NEXT:    testl %edi, %edi
; TLSDESC-NEXT:    movl %ebp, %ecx
; TLSDESC-NEXT:    jne .LBB1_2
; TLSDESC-NEXT:  # %bb.1: # %if.then
; TLSDESC-NEXT:    movq %rsi, %rbx
; TLSDESC-NEXT:    addq %fs:0, %rax
; TLSDESC-NEXT:    movq %rax, %r14
; TLSDESC-NEXT:    callq effect@PLT
; TLSDESC-NEXT:    movl 168(%r14,%rbx,4), %ecx
; TLSDESC-NEXT:  .LBB1_2: # %if.end
; TLSDESC-NEXT:    addl %ebp, %ecx
; TLSDESC-NEXT:    movl %ecx, %eax
; TLSDESC-NEXT:    popq %rbx
; TLSDESC-NEXT:    popq %r14
; TLSDESC-NEXT:    popq %rbp
; TLSDESC-NEXT:    retq
entry:
  %addr = tail call ptr @llvm.threadlocal.address.p0(ptr @foo_nonlocal)
  %load0 = load i32, ptr %addr, align 4
  %cond = icmp eq i32 %arg0, 0
  br i1 %cond, label %if.then, label %if.end

if.then:
  tail call void @effect()
  %x = add i64 %arg1, 42
  %addr1 = getelementptr inbounds i32, ptr %addr, i64 %x
  %load1 = load i32, ptr %addr1, align 4
  br label %if.end

if.end:
  %phi = phi i32 [ %load1, %if.then ], [ %load0, %entry ]
  %ret = add i32 %phi, %load0
  ret i32 %ret
}
