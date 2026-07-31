; ModuleID = 'generated_ll/use_after_scope/basic_raw.ll'
source_filename = "tests/use_after_scope/basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: nounwind ssp uwtable(sync)
define ptr @get_ptr() #0 !dbg !14 {
entry:
  %alloca_x = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_x, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (i32, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
  call void @llvm.lifetime.start.p0(ptr %inst_ptr) #2, !dbg !21
    #dbg_declare(ptr %inst_ptr, !20, !DIExpression(), !22)
  call void @__check_memory_access(ptr %inst_ptr, i64 4), !dbg !23
  store i32 42, ptr %inst_ptr, align 4, !dbg !23, !tbaa !10
  call void @llvm.lifetime.end.p0(ptr %inst_ptr) #2, !dbg !24
  ret ptr %inst_ptr, !dbg !25
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !26 {
entry:
  %alloca_p = alloca { [32 x i8], [8 x i8], [32 x i8] }, align 8
  %left_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 0
  %inst_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 1
  %right_rz_ptr = getelementptr inbounds nuw { [32 x i8], [8 x i8], [32 x i8] }, ptr %alloca_p, i32 0, i32 2
  call void @__poison_memory(ptr %left_rz_ptr, i64 32, i8 -15)
  call void @__unpoison_memory(ptr %inst_ptr, i64 ptrtoint (ptr getelementptr (ptr, ptr null, i32 1) to i64))
  call void @__poison_memory(ptr %right_rz_ptr, i64 32, i8 -15)
  call void @llvm.lifetime.start.p0(ptr %inst_ptr) #2, !dbg !31
    #dbg_declare(ptr %inst_ptr, !30, !DIExpression(), !32)
  %call = call ptr @get_ptr(), !dbg !33
  call void @__check_memory_access(ptr %inst_ptr, i64 8), !dbg !34
  store ptr %call, ptr %inst_ptr, align 8, !dbg !34, !tbaa !35
  call void @__check_memory_access(ptr %inst_ptr, i64 8), !dbg !38
  %0 = load ptr, ptr %inst_ptr, align 8, !dbg !38, !tbaa !35
  call void @__check_memory_access(ptr %0, i64 4), !dbg !39
  store i32 99, ptr %0, align 4, !dbg !39, !tbaa !10
  call void @llvm.lifetime.end.p0(ptr %inst_ptr) #2, !dbg !40
  ret i32 0, !dbg !41
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
!8 = !DIFile(filename: "tests/use_after_scope/basic.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = !{!11, !11, i64 0}
!11 = !{!"int", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C/C++ TBAA"}
!14 = distinct !DISubprogram(name: "get_ptr", scope: !8, file: !8, line: 2, type: !15, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, retainedNodes: !19, keyInstructions: true)
!15 = !DISubroutineType(types: !16)
!16 = !{!17}
!17 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !18, size: 64)
!18 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!19 = !{!20}
!20 = !DILocalVariable(name: "x", scope: !14, file: !8, line: 4, type: !18)
!21 = !DILocation(line: 4, column: 5, scope: !14)
!22 = !DILocation(line: 4, column: 9, scope: !14)
!23 = !DILocation(line: 4, column: 9, scope: !14, atomGroup: 1, atomRank: 1)
!24 = !DILocation(line: 6, column: 1, scope: !14)
!25 = !DILocation(line: 5, column: 5, scope: !14, atomGroup: 3, atomRank: 1)
!26 = distinct !DISubprogram(name: "main", scope: !8, file: !8, line: 7, type: !27, scopeLine: 8, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, retainedNodes: !29, keyInstructions: true)
!27 = !DISubroutineType(types: !28)
!28 = !{!18}
!29 = !{!30}
!30 = !DILocalVariable(name: "p", scope: !26, file: !8, line: 9, type: !17)
!31 = !DILocation(line: 9, column: 5, scope: !26)
!32 = !DILocation(line: 9, column: 10, scope: !26)
!33 = !DILocation(line: 9, column: 14, scope: !26, atomGroup: 1, atomRank: 2)
!34 = !DILocation(line: 9, column: 10, scope: !26, atomGroup: 1, atomRank: 1)
!35 = !{!36, !36, i64 0}
!36 = !{!"p1 int", !37, i64 0}
!37 = !{!"any pointer", !12, i64 0}
!38 = !DILocation(line: 10, column: 6, scope: !26)
!39 = !DILocation(line: 10, column: 8, scope: !26, atomGroup: 2, atomRank: 1)
!40 = !DILocation(line: 11, column: 1, scope: !26)
!41 = !DILocation(line: 11, column: 1, scope: !26, atomGroup: 3, atomRank: 1)
