; ModuleID = 'basic.ll'
source_filename = "/Users/kennykim/Documents/masan/tests/use_after_scope/basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define ptr @get_ptr() #0 !dbg !10 {
entry:
  %alloca_x = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
    #dbg_declare(ptr %inst_ptr, !17, !DIExpression(), !18)
  call void @__check_memory_access(ptr %inst_ptr, i64 4), !dbg !18
  store i32 42, ptr %inst_ptr, align 4, !dbg !18
  ret ptr %inst_ptr, !dbg !19
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !20 {
entry:
  %alloca_p = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
    #dbg_declare(ptr %inst_ptr, !23, !DIExpression(), !24)
  %call = call ptr @get_ptr(), !dbg !25
  call void @__check_memory_access(ptr %inst_ptr, i64 8), !dbg !24
  store ptr %call, ptr %inst_ptr, align 8, !dbg !24
  call void @__check_memory_access(ptr %inst_ptr, i64 8), !dbg !26
  %0 = load ptr, ptr %inst_ptr, align 8, !dbg !26
  call void @__check_memory_access(ptr %0, i64 4), !dbg !27
  store i32 99, ptr %0, align 4, !dbg !27
  ret i32 0, !dbg !28
}

declare void @__poison_memory(ptr, i64, i8)

declare void @__unpoison_memory(ptr, i64)

declare void @__check_memory_access(ptr, i64)

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6}
!llvm.dbg.cu = !{!7}
!llvm.ident = !{!9}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 14, i32 4]}
!1 = !{i32 7, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 1}
!6 = !{i32 7, !"frame-pointer", i32 4}
!7 = distinct !DICompileUnit(language: DW_LANG_C11, file: !8, producer: "Homebrew clang version 22.1.8", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk", sdk: "MacOSX.sdk")
!8 = !DIFile(filename: "/Users/kennykim/Documents/masan/tests/use_after_scope/basic.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = distinct !DISubprogram(name: "get_ptr", scope: !11, file: !11, line: 2, type: !12, scopeLine: 3, spFlags: DISPFlagDefinition, unit: !7, retainedNodes: !16)
!11 = !DIFile(filename: "tests/use_after_scope/basic.c", directory: "/Users/kennykim/Documents/masan")
!12 = !DISubroutineType(types: !13)
!13 = !{!14}
!14 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !15, size: 64)
!15 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!16 = !{}
!17 = !DILocalVariable(name: "x", scope: !10, file: !11, line: 4, type: !15)
!18 = !DILocation(line: 4, column: 9, scope: !10)
!19 = !DILocation(line: 5, column: 5, scope: !10)
!20 = distinct !DISubprogram(name: "main", scope: !11, file: !11, line: 7, type: !21, scopeLine: 8, spFlags: DISPFlagDefinition, unit: !7, retainedNodes: !16)
!21 = !DISubroutineType(types: !22)
!22 = !{!15}
!23 = !DILocalVariable(name: "p", scope: !20, file: !11, line: 9, type: !14)
!24 = !DILocation(line: 9, column: 10, scope: !20)
!25 = !DILocation(line: 9, column: 14, scope: !20)
!26 = !DILocation(line: 10, column: 6, scope: !20)
!27 = !DILocation(line: 10, column: 8, scope: !20)
!28 = !DILocation(line: 11, column: 1, scope: !20)
