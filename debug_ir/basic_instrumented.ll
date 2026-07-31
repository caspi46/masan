; ModuleID = 'debug_ir/basic_raw.ll'
source_filename = "tests/valid/basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test() #0 !dbg !10 {
entry:
  %alloca_buf = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 8)
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
  %alloca_x = alloca { [32 x i8], [4 x i8], [32 x i8] }, align 8
  %left_rz_ptr1 = getelementptr inbounds nuw { [32 x i8], [4 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 0
  %inst_ptr2 = getelementptr inbounds nuw { [32 x i8], [4 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 1
  %right_rz_ptr3 = getelementptr inbounds nuw { [32 x i8], [4 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr1, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr2, i64 4)
  call void @__poison_memory(ptr %right_rz_ptr3, i64 32, i8 -15)
  %alloca_p = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr4 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 0
  %inst_ptr5 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 1
  %right_rz_ptr6 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr4, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr5, i64 8)
  call void @__poison_memory(ptr %right_rz_ptr6, i64 32, i8 -15)
    #dbg_declare(ptr %inst_ptr, !14, !DIExpression(), !19)
  %arrayidx = getelementptr inbounds [8 x i8], ptr %inst_ptr, i64 0, i64 0, !dbg !20
  call void @__check_memory_access(ptr %arrayidx, i64 1), !dbg !21
  store i8 65, ptr %arrayidx, align 1, !dbg !21
  %arrayidx1 = getelementptr inbounds [8 x i8], ptr %inst_ptr, i64 0, i64 7, !dbg !22
  call void @__check_memory_access(ptr %arrayidx1, i64 1), !dbg !23
  store i8 90, ptr %arrayidx1, align 1, !dbg !23
    #dbg_declare(ptr %inst_ptr2, !24, !DIExpression(), !26)
  call void @__check_memory_access(ptr %inst_ptr2, i64 4), !dbg !26
  store i32 42, ptr %inst_ptr2, align 4, !dbg !26
    #dbg_declare(ptr %inst_ptr5, !27, !DIExpression(), !29)
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !29
  store ptr %inst_ptr2, ptr %inst_ptr5, align 8, !dbg !29
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !30
  %0 = load ptr, ptr %inst_ptr5, align 8, !dbg !30
  call void @__check_memory_access(ptr %0, i64 4), !dbg !31
  store i32 99, ptr %0, align 4, !dbg !31
  call void @__poison_memory(ptr %inst_ptr5, i64 8, i8 -13), !dbg !32
  call void @__poison_memory(ptr %inst_ptr, i64 8, i8 -13), !dbg !32
  call void @__poison_memory(ptr %inst_ptr2, i64 4, i8 -13), !dbg !32
  ret void, !dbg !32
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !33 {
entry:
  call void @test(), !dbg !36
  ret i32 0, !dbg !37
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
!7 = distinct !DICompileUnit(language: DW_LANG_C11, file: !8, producer: "Homebrew clang version 22.1.8", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk", sdk: "MacOSX14.sdk")
!8 = !DIFile(filename: "tests/valid/basic.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = distinct !DISubprogram(name: "test", scope: !8, file: !8, line: 2, type: !11, scopeLine: 3, spFlags: DISPFlagDefinition, unit: !7, retainedNodes: !13)
!11 = !DISubroutineType(types: !12)
!12 = !{null}
!13 = !{}
!14 = !DILocalVariable(name: "buf", scope: !10, file: !8, line: 4, type: !15)
!15 = !DICompositeType(tag: DW_TAG_array_type, baseType: !16, size: 64, elements: !17)
!16 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!17 = !{!18}
!18 = !DISubrange(count: 8)
!19 = !DILocation(line: 4, column: 10, scope: !10)
!20 = !DILocation(line: 5, column: 5, scope: !10)
!21 = !DILocation(line: 5, column: 12, scope: !10)
!22 = !DILocation(line: 6, column: 5, scope: !10)
!23 = !DILocation(line: 6, column: 12, scope: !10)
!24 = !DILocalVariable(name: "x", scope: !10, file: !8, line: 8, type: !25)
!25 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!26 = !DILocation(line: 8, column: 9, scope: !10)
!27 = !DILocalVariable(name: "p", scope: !10, file: !8, line: 9, type: !28)
!28 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !25, size: 64)
!29 = !DILocation(line: 9, column: 10, scope: !10)
!30 = !DILocation(line: 10, column: 6, scope: !10)
!31 = !DILocation(line: 10, column: 8, scope: !10)
!32 = !DILocation(line: 11, column: 1, scope: !10)
!33 = distinct !DISubprogram(name: "main", scope: !8, file: !8, line: 12, type: !34, scopeLine: 12, spFlags: DISPFlagDefinition, unit: !7)
!34 = !DISubroutineType(types: !35)
!35 = !{!25}
!36 = !DILocation(line: 12, column: 14, scope: !33)
!37 = !DILocation(line: 12, column: 22, scope: !33)
