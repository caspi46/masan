; ModuleID = 'tests/use_after_scope/nested.c'
source_filename = "tests/use_after_scope/nested.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: nounwind ssp uwtable(sync)
define void @test() #0 !dbg !14 {
entry:
  %p = alloca ptr, align 8
  %x = alloca i32, align 4
  call void @llvm.lifetime.start.p0(ptr %p) #2, !dbg !23
    #dbg_declare(ptr %p, !18, !DIExpression(), !24)
  call void @llvm.lifetime.start.p0(ptr %x) #2, !dbg !25
    #dbg_declare(ptr %x, !21, !DIExpression(), !26)
  store i32 42, ptr %x, align 4, !dbg !27, !tbaa !10
  store ptr %x, ptr %p, align 8, !dbg !28, !tbaa !29
  call void @llvm.lifetime.end.p0(ptr %x) #2, !dbg !32
  %0 = load ptr, ptr %p, align 8, !dbg !33, !tbaa !29
  store i32 99, ptr %0, align 4, !dbg !34, !tbaa !10
  call void @llvm.lifetime.end.p0(ptr %p) #2, !dbg !35
  ret void, !dbg !36
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !37 {
entry:
  call void @test(), !dbg !40
  ret i32 0, !dbg !41
}

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
!8 = !DIFile(filename: "tests/use_after_scope/nested.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = !{!11, !11, i64 0}
!11 = !{!"int", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C/C++ TBAA"}
!14 = distinct !DISubprogram(name: "test", scope: !8, file: !8, line: 2, type: !15, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, retainedNodes: !17, keyInstructions: true)
!15 = !DISubroutineType(types: !16)
!16 = !{null}
!17 = !{!18, !21}
!18 = !DILocalVariable(name: "p", scope: !14, file: !8, line: 4, type: !19)
!19 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !20, size: 64)
!20 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!21 = !DILocalVariable(name: "x", scope: !22, file: !8, line: 6, type: !20)
!22 = distinct !DILexicalBlock(scope: !14, file: !8, line: 5, column: 5)
!23 = !DILocation(line: 4, column: 5, scope: !14)
!24 = !DILocation(line: 4, column: 10, scope: !14)
!25 = !DILocation(line: 6, column: 9, scope: !22)
!26 = !DILocation(line: 6, column: 13, scope: !22)
!27 = !DILocation(line: 6, column: 13, scope: !22, atomGroup: 1, atomRank: 1)
!28 = !DILocation(line: 7, column: 11, scope: !22, atomGroup: 2, atomRank: 1)
!29 = !{!30, !30, i64 0}
!30 = !{!"p1 int", !31, i64 0}
!31 = !{!"any pointer", !12, i64 0}
!32 = !DILocation(line: 8, column: 5, scope: !14)
!33 = !DILocation(line: 9, column: 6, scope: !14)
!34 = !DILocation(line: 9, column: 8, scope: !14, atomGroup: 3, atomRank: 1)
!35 = !DILocation(line: 10, column: 1, scope: !14)
!36 = !DILocation(line: 10, column: 1, scope: !14, atomGroup: 4, atomRank: 1)
!37 = distinct !DISubprogram(name: "main", scope: !8, file: !8, line: 11, type: !38, scopeLine: 11, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, keyInstructions: true)
!38 = !DISubroutineType(types: !39)
!39 = !{!20}
!40 = !DILocation(line: 11, column: 14, scope: !37)
!41 = !DILocation(line: 11, column: 22, scope: !37, atomGroup: 1, atomRank: 1)
