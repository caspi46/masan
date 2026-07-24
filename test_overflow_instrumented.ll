; ModuleID = 'test_overflow.ll'
source_filename = "/Users/kennykim/Documents/masan/tests/test_overflow.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

@.str = private unnamed_addr constant [4 x i8] c"%c\0A\00", align 1, !dbg !0

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !18 {
entry:
  %alloca_retval = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_retval, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_retval, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_retval, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
  %alloca_buf = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr1 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 0
  %inst_ptr2 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 1
  %right_rz_ptr3 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr1, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr2, i64 ptrtoint (ptr getelementptr ([8 x i8], ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr3, i64 32, i8 -15)
  call void @__check_memory_access(ptr %inst_ptr, i64 4)
  store i32 0, ptr %inst_ptr, align 4
    #dbg_declare(ptr %inst_ptr2, !23, !DIExpression(), !27)
  %arrayidx = getelementptr inbounds [8 x i8], ptr %inst_ptr2, i64 0, i64 10, !dbg !28
  call void @__check_memory_access(ptr %arrayidx, i64 1), !dbg !29
  store i8 88, ptr %arrayidx, align 1, !dbg !29
  %arrayidx1 = getelementptr inbounds [8 x i8], ptr %inst_ptr2, i64 0, i64 10, !dbg !30
  call void @__check_memory_access(ptr %arrayidx1, i64 8), !dbg !30
  %0 = load i8, ptr %arrayidx1, align 1, !dbg !30
  %conv = sext i8 %0 to i32, !dbg !30
  %call = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %conv), !dbg !31
  ret i32 0, !dbg !32
}

declare i32 @printf(ptr noundef, ...) #1

declare void @__poison_memory(ptr, i64, i8)

declare void @__unpoison_memory(ptr, i64)

declare void @__check_memory_access(ptr, i64)

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }

!llvm.module.flags = !{!7, !8, !9, !10, !11, !12, !13}
!llvm.dbg.cu = !{!14}
!llvm.ident = !{!17}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 7, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "tests/test_overflow.c", directory: "/Users/kennykim/Documents/masan")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 32, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 4)
!7 = !{i32 2, !"SDK Version", [2 x i32] [i32 14, i32 4]}
!8 = !{i32 7, !"Dwarf Version", i32 4}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{i32 1, !"wchar_size", i32 4}
!11 = !{i32 8, !"PIC Level", i32 2}
!12 = !{i32 7, !"uwtable", i32 1}
!13 = !{i32 7, !"frame-pointer", i32 4}
!14 = distinct !DICompileUnit(language: DW_LANG_C11, file: !15, producer: "Homebrew clang version 22.1.8", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !16, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk", sdk: "MacOSX.sdk")
!15 = !DIFile(filename: "/Users/kennykim/Documents/masan/tests/test_overflow.c", directory: "/Users/kennykim/Documents/masan")
!16 = !{!0}
!17 = !{!"Homebrew clang version 22.1.8"}
!18 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 3, type: !19, scopeLine: 4, spFlags: DISPFlagDefinition, unit: !14, retainedNodes: !22)
!19 = !DISubroutineType(types: !20)
!20 = !{!21}
!21 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!22 = !{}
!23 = !DILocalVariable(name: "buf", scope: !18, file: !2, line: 5, type: !24)
!24 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 64, elements: !25)
!25 = !{!26}
!26 = !DISubrange(count: 8)
!27 = !DILocation(line: 5, column: 10, scope: !18)
!28 = !DILocation(line: 6, column: 5, scope: !18)
!29 = !DILocation(line: 6, column: 13, scope: !18)
!30 = !DILocation(line: 7, column: 20, scope: !18)
!31 = !DILocation(line: 7, column: 5, scope: !18)
!32 = !DILocation(line: 8, column: 5, scope: !18)
