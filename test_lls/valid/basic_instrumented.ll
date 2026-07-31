; ModuleID = 'test_lls/valid/basic_raw.ll'
source_filename = "tests/valid/basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: nounwind ssp uwtable(sync)
define void @test() #0 !dbg !14 {
entry:
  %alloca_buf = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_buf, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr ([8 x i8], ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
  %alloca_x = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr1 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 0
  %inst_ptr2 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 1
  %right_rz_ptr3 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr1, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr2, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr3, i64 32, i8 -15)
  %alloca_p = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr4 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 0
  %inst_ptr5 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 1
  %right_rz_ptr6 = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr4, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr5, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr6, i64 32, i8 -15)
  call void @llvm.lifetime.start.p0(ptr %inst_ptr) #2, !dbg !27
    #dbg_declare(ptr %inst_ptr, !18, !DIExpression(), !28)
  %arrayidx = getelementptr inbounds [8 x i8], ptr %inst_ptr, i64 0, i64 0, !dbg !29
  call void @__check_memory_access(ptr %arrayidx, i64 1), !dbg !30
  store i8 65, ptr %arrayidx, align 1, !dbg !30, !tbaa !31
  %arrayidx1 = getelementptr inbounds [8 x i8], ptr %inst_ptr, i64 0, i64 7, !dbg !32
  call void @__check_memory_access(ptr %arrayidx1, i64 1), !dbg !33
  store i8 90, ptr %arrayidx1, align 1, !dbg !33, !tbaa !31
  call void @llvm.lifetime.start.p0(ptr %inst_ptr2) #2, !dbg !34
    #dbg_declare(ptr %inst_ptr2, !23, !DIExpression(), !35)
  call void @__check_memory_access(ptr %inst_ptr2, i64 4), !dbg !36
  store i32 42, ptr %inst_ptr2, align 4, !dbg !36, !tbaa !10
  call void @llvm.lifetime.start.p0(ptr %inst_ptr5) #2, !dbg !37
    #dbg_declare(ptr %inst_ptr5, !25, !DIExpression(), !38)
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !39
  store ptr %inst_ptr2, ptr %inst_ptr5, align 8, !dbg !39, !tbaa !40
  call void @__check_memory_access(ptr %inst_ptr5, i64 8), !dbg !43
  %0 = load ptr, ptr %inst_ptr5, align 8, !dbg !43, !tbaa !40
  call void @__check_memory_access(ptr %0, i64 4), !dbg !44
  store i32 99, ptr %0, align 4, !dbg !44, !tbaa !10
  call void @llvm.lifetime.end.p0(ptr %inst_ptr5) #2, !dbg !45
  call void @llvm.lifetime.end.p0(ptr %inst_ptr2) #2, !dbg !45
  call void @llvm.lifetime.end.p0(ptr %inst_ptr) #2, !dbg !45
  ret void, !dbg !46
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !47 {
entry:
  call void @test(), !dbg !50
  ret i32 0, !dbg !51
}

declare void @__poison_memory(ptr, i64, i8)

declare void @__unpoison_memory(ptr, i64)

declare void @__check_memory_access(ptr, i64)

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6}
!llvm.dbg.cu = !{!7}
!llvm.ident = !{!9}
!llvm.errno.tbaa = !{!10}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 14, i32 4]}
!1 = !{i32 7, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 1}
!6 = !{i32 7, !"frame-pointer", i32 4}
!7 = distinct !DICompileUnit(language: DW_LANG_C11, file: !8, producer: "Homebrew clang version 22.1.8", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk", sdk: "MacOSX14.sdk")
!8 = !DIFile(filename: "tests/valid/basic.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = !{!11, !11, i64 0}
!11 = !{!"int", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C/C++ TBAA"}
!14 = distinct !DISubprogram(name: "test", scope: !8, file: !8, line: 2, type: !15, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, retainedNodes: !17, keyInstructions: true)
!15 = !DISubroutineType(types: !16)
!16 = !{null}
!17 = !{!18, !23, !25}
!18 = !DILocalVariable(name: "buf", scope: !14, file: !8, line: 4, type: !19)
!19 = !DICompositeType(tag: DW_TAG_array_type, baseType: !20, size: 64, elements: !21)
!20 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!21 = !{!22}
!22 = !DISubrange(count: 8)
!23 = !DILocalVariable(name: "x", scope: !14, file: !8, line: 8, type: !24)
!24 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!25 = !DILocalVariable(name: "p", scope: !14, file: !8, line: 9, type: !26)
!26 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !24, size: 64)
!27 = !DILocation(line: 4, column: 5, scope: !14)
!28 = !DILocation(line: 4, column: 10, scope: !14)
!29 = !DILocation(line: 5, column: 5, scope: !14)
!30 = !DILocation(line: 5, column: 12, scope: !14, atomGroup: 1, atomRank: 1)
!31 = !{!12, !12, i64 0}
!32 = !DILocation(line: 6, column: 5, scope: !14)
!33 = !DILocation(line: 6, column: 12, scope: !14, atomGroup: 2, atomRank: 1)
!34 = !DILocation(line: 8, column: 5, scope: !14)
!35 = !DILocation(line: 8, column: 9, scope: !14)
!36 = !DILocation(line: 8, column: 9, scope: !14, atomGroup: 3, atomRank: 1)
!37 = !DILocation(line: 9, column: 5, scope: !14)
!38 = !DILocation(line: 9, column: 10, scope: !14)
!39 = !DILocation(line: 9, column: 10, scope: !14, atomGroup: 4, atomRank: 1)
!40 = !{!41, !41, i64 0}
!41 = !{!"p1 int", !42, i64 0}
!42 = !{!"any pointer", !12, i64 0}
!43 = !DILocation(line: 10, column: 6, scope: !14)
!44 = !DILocation(line: 10, column: 8, scope: !14, atomGroup: 5, atomRank: 1)
!45 = !DILocation(line: 11, column: 1, scope: !14)
!46 = !DILocation(line: 11, column: 1, scope: !14, atomGroup: 6, atomRank: 1)
!47 = distinct !DISubprogram(name: "main", scope: !8, file: !8, line: 12, type: !48, scopeLine: 12, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, keyInstructions: true)
!48 = !DISubroutineType(types: !49)
!49 = !{!24}
!50 = !DILocation(line: 12, column: 14, scope: !47)
!51 = !DILocation(line: 12, column: 22, scope: !47, atomGroup: 1, atomRank: 1)
