; ModuleID = 'heap_overflow.ll'
source_filename = "/Users/kennykim/Documents/masan/tests/heap_overflow/heap_overflow.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

@.str = private unnamed_addr constant [20 x i8] c"Buffer content: %c\0A\00", align 1, !dbg !0

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !22 {
entry:
  %alloca_retval = alloca <{ [32 x i8], [8 x i8], [32 x i8] }>, align 8
  %left_rz_ptr = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_retval, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_retval, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_retval, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
  %alloca_buf = alloca <{ [32 x i8], [8 x i8], [32 x i8] }>, align 8
  %left_rz_ptr1 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_buf, i32 0, i32 0
  %inst_ptr2 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_buf, i32 0, i32 1
  %right_rz_ptr3 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_buf, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr1, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr2, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr3, i64 32, i8 -15)
  %alloca_i = alloca <{ [32 x i8], [8 x i8], [32 x i8] }>, align 8
  %left_rz_ptr4 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_i, i32 0, i32 0
  %inst_ptr5 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_i, i32 0, i32 1
  %right_rz_ptr6 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_i, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr4, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr5, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr6, i64 32, i8 -15)
  call void @__check_memory_access(ptr %inst_ptr, i64 4)
  store i32 0, ptr %inst_ptr, align 4
    #dbg_declare(ptr %inst_ptr2, !27, !DIExpression(), !28)
  %alloca_call = alloca <{ [32 x i8], [10 x i8], [32 x i8] }>, align 8, !dbg !29
  %left_rz_ptr7 = getelementptr inbounds nuw <{ [32 x i8], [10 x i8], [32 x i8] }>, ptr %alloca_call, i32 0, i32 0, !dbg !29
  %inst_ptr8 = getelementptr inbounds nuw <{ [32 x i8], [10 x i8], [32 x i8] }>, ptr %alloca_call, i32 0, i32 1, !dbg !29
  %right_rz_ptr9 = getelementptr inbounds nuw <{ [32 x i8], [10 x i8], [32 x i8] }>, ptr %alloca_call, i32 0, i32 2, !dbg !29
  call void @__poison_memory(ptr %left_rz_ptr7, i64 32, i8 -6), !dbg !29
  call void @__unpoison_memory(ptr %inst_ptr8, i64 10), !dbg !29
  call void @__poison_memory(ptr %right_rz_ptr9, i64 32, i8 -6), !dbg !29
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !28
  store ptr %inst_ptr8, ptr %inst_ptr2, align 8, !dbg !28
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !30
  %0 = load ptr, ptr %inst_ptr2, align 8, !dbg !30
  %tobool = icmp ne ptr %0, null, !dbg !30
  br i1 %tobool, label %if.end, label %if.then, !dbg !32

if.then:                                          ; preds = %entry
  call void @__check_memory_access(ptr %inst_ptr, i64 4), !dbg !33
  store i32 1, ptr %inst_ptr, align 4, !dbg !33
  br label %return, !dbg !33

if.end:                                           ; preds = %entry
    #dbg_declare(ptr %inst_ptr5, !35, !DIExpression(), !37)
  call void @__check_memory_access(ptr %inst_ptr5, i64 4), !dbg !37
  store i32 0, ptr %inst_ptr5, align 4, !dbg !37
  br label %for.cond, !dbg !38

for.cond:                                         ; preds = %for.inc, %if.end
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !39
  %1 = load i32, ptr %inst_ptr5, align 4, !dbg !39
  %cmp = icmp slt i32 %1, 10, !dbg !41
  br i1 %cmp, label %for.body, label %for.end, !dbg !42

for.body:                                         ; preds = %for.cond
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !43
  %2 = load ptr, ptr %inst_ptr2, align 8, !dbg !43
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !45
  %3 = load i32, ptr %inst_ptr5, align 4, !dbg !45
  %idxprom = sext i32 %3 to i64, !dbg !43
  %arrayidx = getelementptr inbounds i8, ptr %2, i64 %idxprom, !dbg !43
  call void @__check_memory_access(ptr %arrayidx, i64 1), !dbg !46
  store volatile i8 65, ptr %arrayidx, align 1, !dbg !46
  br label %for.inc, !dbg !47

for.inc:                                          ; preds = %for.body
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !48
  %4 = load i32, ptr %inst_ptr5, align 4, !dbg !48
  %inc = add nsw i32 %4, 1, !dbg !48
  call void @__check_memory_access(ptr %inst_ptr5, i64 4), !dbg !48
  store i32 %inc, ptr %inst_ptr5, align 4, !dbg !48
  br label %for.cond, !dbg !49, !llvm.loop !50

for.end:                                          ; preds = %for.cond
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !53
  %5 = load ptr, ptr %inst_ptr2, align 8, !dbg !53
  %arrayidx1 = getelementptr inbounds i8, ptr %5, i64 10, !dbg !53
  call void @__check_memory_access(ptr %arrayidx1, i64 1), !dbg !54
  store volatile i8 88, ptr %arrayidx1, align 1, !dbg !54
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !55
  %6 = load ptr, ptr %inst_ptr2, align 8, !dbg !55
  %arrayidx2 = getelementptr inbounds i8, ptr %6, i64 0, !dbg !55
  call void @__check_memory_access(ptr %arrayidx2, i64 8), !dbg !55
  %7 = load volatile i8, ptr %arrayidx2, align 1, !dbg !55
  %conv = sext i8 %7 to i32, !dbg !55
  %call3 = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %conv), !dbg !56
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !57
  %8 = load ptr, ptr %inst_ptr2, align 8, !dbg !57
  call void @free(ptr noundef %8), !dbg !58
  call void @__check_memory_access(ptr %inst_ptr, i64 4), !dbg !59
  store i32 0, ptr %inst_ptr, align 4, !dbg !59
  br label %return, !dbg !59

return:                                           ; preds = %for.end, %if.then
  call void @__check_memory_access(ptr %inst_ptr, i64 8), !dbg !60
  %9 = load i32, ptr %inst_ptr, align 4, !dbg !60
  call void @__poison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64), i8 -13), !dbg !60
  call void @__poison_memory(ptr %inst_ptr2, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64), i8 -13), !dbg !60
  call void @__poison_memory(ptr %inst_ptr5, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64), i8 -13), !dbg !60
  ret i32 %9, !dbg !60
}

; Function Attrs: allocsize(0)
declare ptr @malloc(i64 noundef) #1

declare i32 @printf(ptr noundef, ...) #2

declare void @free(ptr noundef) #2

declare void @__poison_memory(ptr, i64, i8)

declare void @__unpoison_memory(ptr, i64)

declare void @__check_memory_access(ptr, i64)

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { allocsize(0) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #2 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }

!llvm.module.flags = !{!7, !8, !9, !10, !11, !12, !13}
!llvm.dbg.cu = !{!14}
!llvm.ident = !{!21}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 23, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "tests/heap_overflow/heap_overflow.c", directory: "/Users/kennykim/Documents/masan")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 160, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 20)
!7 = !{i32 2, !"SDK Version", [2 x i32] [i32 14, i32 4]}
!8 = !{i32 7, !"Dwarf Version", i32 4}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{i32 1, !"wchar_size", i32 4}
!11 = !{i32 8, !"PIC Level", i32 2}
!12 = !{i32 7, !"uwtable", i32 1}
!13 = !{i32 7, !"frame-pointer", i32 4}
!14 = distinct !DICompileUnit(language: DW_LANG_C11, file: !15, producer: "Homebrew clang version 22.1.8", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !16, globals: !20, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk", sdk: "MacOSX.sdk")
!15 = !DIFile(filename: "/Users/kennykim/Documents/masan/tests/heap_overflow/heap_overflow.c", directory: "/Users/kennykim/Documents/masan")
!16 = !{!17, !19}
!17 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !18, size: 64)
!18 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !4)
!19 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!20 = !{!0}
!21 = !{!"Homebrew clang version 22.1.8"}
!22 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 4, type: !23, scopeLine: 5, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !14, retainedNodes: !26)
!23 = !DISubroutineType(types: !24)
!24 = !{!25}
!25 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!26 = !{}
!27 = !DILocalVariable(name: "buf", scope: !22, file: !2, line: 7, type: !17)
!28 = !DILocation(line: 7, column: 20, scope: !22)
!29 = !DILocation(line: 7, column: 43, scope: !22)
!30 = !DILocation(line: 8, column: 10, scope: !31)
!31 = distinct !DILexicalBlock(scope: !22, file: !2, line: 8, column: 9)
!32 = !DILocation(line: 8, column: 9, scope: !31)
!33 = !DILocation(line: 10, column: 9, scope: !34)
!34 = distinct !DILexicalBlock(scope: !31, file: !2, line: 9, column: 5)
!35 = !DILocalVariable(name: "i", scope: !36, file: !2, line: 14, type: !25)
!36 = distinct !DILexicalBlock(scope: !22, file: !2, line: 14, column: 5)
!37 = !DILocation(line: 14, column: 14, scope: !36)
!38 = !DILocation(line: 14, column: 10, scope: !36)
!39 = !DILocation(line: 14, column: 21, scope: !40)
!40 = distinct !DILexicalBlock(scope: !36, file: !2, line: 14, column: 5)
!41 = !DILocation(line: 14, column: 23, scope: !40)
!42 = !DILocation(line: 14, column: 5, scope: !36)
!43 = !DILocation(line: 16, column: 9, scope: !44)
!44 = distinct !DILexicalBlock(scope: !40, file: !2, line: 15, column: 5)
!45 = !DILocation(line: 16, column: 13, scope: !44)
!46 = !DILocation(line: 16, column: 16, scope: !44)
!47 = !DILocation(line: 17, column: 5, scope: !44)
!48 = !DILocation(line: 14, column: 30, scope: !40)
!49 = !DILocation(line: 14, column: 5, scope: !40)
!50 = distinct !{!50, !42, !51, !52}
!51 = !DILocation(line: 17, column: 5, scope: !36)
!52 = !{!"llvm.loop.mustprogress"}
!53 = !DILocation(line: 21, column: 5, scope: !22)
!54 = !DILocation(line: 21, column: 13, scope: !22)
!55 = !DILocation(line: 23, column: 36, scope: !22)
!56 = !DILocation(line: 23, column: 5, scope: !22)
!57 = !DILocation(line: 25, column: 18, scope: !22)
!58 = !DILocation(line: 25, column: 5, scope: !22)
!59 = !DILocation(line: 26, column: 5, scope: !22)
!60 = !DILocation(line: 27, column: 1, scope: !22)
