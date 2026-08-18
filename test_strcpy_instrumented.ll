; ModuleID = 'test_strcpy.ll'
source_filename = "/Users/kennykim/Documents/masan/tests/heap_overflow/test_strcpy.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

@.str = private unnamed_addr constant [9 x i8] c"OVERFLOW\00", align 1, !dbg !0

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !21 {
entry:
  %alloca_retval = alloca <{ [32 x i8], [8 x i8], [32 x i8] }>, align 8
  %left_rz_ptr = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_retval, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_retval, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_retval, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
  %alloca_buffer = alloca <{ [32 x i8], [8 x i8], [32 x i8] }>, align 8
  %left_rz_ptr1 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_buffer, i32 0, i32 0
  %inst_ptr2 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_buffer, i32 0, i32 1
  %right_rz_ptr3 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_buffer, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr1, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr2, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr3, i64 32, i8 -15)
  %alloca_too_much_data = alloca <{ [32 x i8], [8 x i8], [32 x i8] }>, align 8
  %left_rz_ptr4 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_too_much_data, i32 0, i32 0
  %inst_ptr5 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_too_much_data, i32 0, i32 1
  %right_rz_ptr6 = getelementptr inbounds nuw <{ [32 x i8], [8 x i8], [32 x i8] }>, ptr %alloca_too_much_data, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr4, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr5, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr6, i64 32, i8 -15)
  call void @__check_memory_access(ptr %inst_ptr, i64 4)
  store i32 0, ptr %inst_ptr, align 4
    #dbg_declare(ptr %inst_ptr2, !26, !DIExpression(), !27)
  %alloca_call = alloca <{ [32 x i8], [4 x i8], [32 x i8] }>, align 8, !dbg !28
  %left_rz_ptr7 = getelementptr inbounds nuw <{ [32 x i8], [4 x i8], [32 x i8] }>, ptr %alloca_call, i32 0, i32 0, !dbg !28
  %inst_ptr8 = getelementptr inbounds nuw <{ [32 x i8], [4 x i8], [32 x i8] }>, ptr %alloca_call, i32 0, i32 1, !dbg !28
  %right_rz_ptr9 = getelementptr inbounds nuw <{ [32 x i8], [4 x i8], [32 x i8] }>, ptr %alloca_call, i32 0, i32 2, !dbg !28
  call void @__poison_memory(ptr %left_rz_ptr7, i64 32, i8 -6), !dbg !28
  call void @__unpoison_memory(ptr %inst_ptr8, i64 4), !dbg !28
  call void @__poison_memory(ptr %right_rz_ptr9, i64 32, i8 -6), !dbg !28
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !27
  store ptr %inst_ptr8, ptr %inst_ptr2, align 8, !dbg !27
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !29
  %0 = load ptr, ptr %inst_ptr2, align 8, !dbg !29
  %cmp = icmp eq ptr %0, null, !dbg !31
  br i1 %cmp, label %if.then, label %if.end, !dbg !31

if.then:                                          ; preds = %entry
  call void @__check_memory_access(ptr %inst_ptr, i64 4), !dbg !32
  store i32 1, ptr %inst_ptr, align 4, !dbg !32
  br label %return, !dbg !32

if.end:                                           ; preds = %entry
    #dbg_declare(ptr %inst_ptr5, !33, !DIExpression(), !34)
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !34
  store ptr @.str, ptr %inst_ptr5, align 8, !dbg !34
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !35
  %1 = load ptr, ptr %inst_ptr2, align 8, !dbg !35
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !36
  %2 = load ptr, ptr %inst_ptr5, align 8, !dbg !36
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !35
  %3 = load ptr, ptr %inst_ptr2, align 8, !dbg !35
  %4 = call i64 @llvm.objectsize.i64.p0(ptr %3, i1 false, i1 true, i1 false), !dbg !37
  %call1 = call ptr @__strcpy_chk(ptr noundef %1, ptr noundef %2, i64 noundef %4) #5, !dbg !37
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !38
  %5 = load ptr, ptr %inst_ptr2, align 8, !dbg !38
  call void @free(ptr noundef %5), !dbg !39
  call void @__check_memory_access(ptr %inst_ptr2, i64 8), !dbg !40
  store ptr null, ptr %inst_ptr2, align 8, !dbg !40
  call void @__check_memory_access(ptr %inst_ptr, i64 4), !dbg !41
  store i32 0, ptr %inst_ptr, align 4, !dbg !41
  br label %return, !dbg !41

return:                                           ; preds = %if.end, %if.then
  call void @__check_memory_access(ptr %inst_ptr, i64 8), !dbg !42
  %6 = load i32, ptr %inst_ptr, align 4, !dbg !42
  call void @__poison_memory(ptr %inst_ptr2, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64), i8 -13), !dbg !42
  call void @__poison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64), i8 -13), !dbg !42
  call void @__poison_memory(ptr %inst_ptr5, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64), i8 -13), !dbg !42
  ret i32 %6, !dbg !42
}

; Function Attrs: allocsize(0)
declare ptr @malloc(i64 noundef) #1

; Function Attrs: nounwind
declare ptr @__strcpy_chk(ptr noundef, ptr noundef, i64 noundef) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.objectsize.i64.p0(ptr, i1 immarg, i1 immarg, i1 immarg) #3

declare void @free(ptr noundef) #4

declare void @__poison_memory(ptr, i64, i8)

declare void @__unpoison_memory(ptr, i64)

declare void @__check_memory_access(ptr, i64)

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { allocsize(0) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #2 = { nounwind "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #3 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #4 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #5 = { nounwind }

!llvm.module.flags = !{!7, !8, !9, !10, !11, !12, !13}
!llvm.dbg.cu = !{!14}
!llvm.ident = !{!20}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 13, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "tests/heap_overflow/test_strcpy.c", directory: "/Users/kennykim/Documents/masan")
!3 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 72, elements: !5)
!4 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!5 = !{!6}
!6 = !DISubrange(count: 9)
!7 = !{i32 2, !"SDK Version", [2 x i32] [i32 14, i32 4]}
!8 = !{i32 7, !"Dwarf Version", i32 4}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{i32 1, !"wchar_size", i32 4}
!11 = !{i32 8, !"PIC Level", i32 2}
!12 = !{i32 7, !"uwtable", i32 1}
!13 = !{i32 7, !"frame-pointer", i32 4}
!14 = distinct !DICompileUnit(language: DW_LANG_C11, file: !15, producer: "Homebrew clang version 22.1.8", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, retainedTypes: !16, globals: !19, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk", sdk: "MacOSX.sdk")
!15 = !DIFile(filename: "/Users/kennykim/Documents/masan/tests/heap_overflow/test_strcpy.c", directory: "/Users/kennykim/Documents/masan")
!16 = !{!17, !18}
!17 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !4, size: 64)
!18 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!19 = !{!0}
!20 = !{!"Homebrew clang version 22.1.8"}
!21 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 5, type: !22, scopeLine: 6, spFlags: DISPFlagDefinition, unit: !14, retainedNodes: !25)
!22 = !DISubroutineType(types: !23)
!23 = !{!24}
!24 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!25 = !{}
!26 = !DILocalVariable(name: "buffer", scope: !21, file: !2, line: 8, type: !17)
!27 = !DILocation(line: 8, column: 11, scope: !21)
!28 = !DILocation(line: 8, column: 28, scope: !21)
!29 = !DILocation(line: 9, column: 9, scope: !30)
!30 = distinct !DILexicalBlock(scope: !21, file: !2, line: 9, column: 9)
!31 = !DILocation(line: 9, column: 16, scope: !30)
!32 = !DILocation(line: 10, column: 9, scope: !30)
!33 = !DILocalVariable(name: "too_much_data", scope: !21, file: !2, line: 13, type: !17)
!34 = !DILocation(line: 13, column: 11, scope: !21)
!35 = !DILocation(line: 16, column: 12, scope: !21)
!36 = !DILocation(line: 16, column: 20, scope: !21)
!37 = !DILocation(line: 16, column: 5, scope: !21)
!38 = !DILocation(line: 19, column: 10, scope: !21)
!39 = !DILocation(line: 19, column: 5, scope: !21)
!40 = !DILocation(line: 20, column: 12, scope: !21)
!41 = !DILocation(line: 22, column: 5, scope: !21)
!42 = !DILocation(line: 23, column: 1, scope: !21)
