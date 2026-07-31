; ModuleID = 'tests/use_after_scope/loop.c'
source_filename = "tests/use_after_scope/loop.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: nounwind ssp uwtable(sync)
define void @test() #0 !dbg !14 {
entry:
  %p = alloca ptr, align 8
  %i = alloca i32, align 4
  %x = alloca i32, align 4
  call void @llvm.lifetime.start.p0(ptr %p) #2, !dbg !26
    #dbg_declare(ptr %p, !18, !DIExpression(), !27)
  call void @llvm.lifetime.start.p0(ptr %i) #2, !dbg !28
    #dbg_declare(ptr %i, !21, !DIExpression(), !29)
  store i32 0, ptr %i, align 4, !dbg !30, !tbaa !10
  br label %for.cond, !dbg !28

for.cond:                                         ; preds = %for.inc, %entry
  %0 = load i32, ptr %i, align 4, !dbg !31, !tbaa !10
  %cmp = icmp slt i32 %0, 3, !dbg !32
  br i1 %cmp, label %for.body, label %for.cond.cleanup, !dbg !33

for.cond.cleanup:                                 ; preds = %for.cond
  call void @llvm.lifetime.end.p0(ptr %i) #2, !dbg !34
  br label %for.end

for.body:                                         ; preds = %for.cond
  call void @llvm.lifetime.start.p0(ptr %x) #2, !dbg !35
    #dbg_declare(ptr %x, !23, !DIExpression(), !36)
  %1 = load i32, ptr %i, align 4, !dbg !37, !tbaa !10
  store i32 %1, ptr %x, align 4, !dbg !38, !tbaa !10
  store ptr %x, ptr %p, align 8, !dbg !39, !tbaa !40
  call void @llvm.lifetime.end.p0(ptr %x) #2, !dbg !43
  br label %for.inc, !dbg !44

for.inc:                                          ; preds = %for.body
  %2 = load i32, ptr %i, align 4, !dbg !45, !tbaa !10
  %inc = add nsw i32 %2, 1, !dbg !46
  store i32 %inc, ptr %i, align 4, !dbg !47, !tbaa !10
  br label %for.cond, !dbg !34, !llvm.loop !48

for.end:                                          ; preds = %for.cond.cleanup
  %3 = load ptr, ptr %p, align 8, !dbg !53, !tbaa !40
  store i32 99, ptr %3, align 4, !dbg !54, !tbaa !10
  call void @llvm.lifetime.end.p0(ptr %p) #2, !dbg !55
  ret void, !dbg !56
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !57 {
entry:
  call void @test(), !dbg !60
  ret i32 0, !dbg !61
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
!8 = !DIFile(filename: "tests/use_after_scope/loop.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = !{!11, !11, i64 0}
!11 = !{!"int", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C/C++ TBAA"}
!14 = distinct !DISubprogram(name: "test", scope: !8, file: !8, line: 2, type: !15, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, retainedNodes: !17, keyInstructions: true)
!15 = !DISubroutineType(types: !16)
!16 = !{null}
!17 = !{!18, !21, !23}
!18 = !DILocalVariable(name: "p", scope: !14, file: !8, line: 4, type: !19)
!19 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !20, size: 64)
!20 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!21 = !DILocalVariable(name: "i", scope: !22, file: !8, line: 5, type: !20)
!22 = distinct !DILexicalBlock(scope: !14, file: !8, line: 5, column: 5)
!23 = !DILocalVariable(name: "x", scope: !24, file: !8, line: 7, type: !20)
!24 = distinct !DILexicalBlock(scope: !25, file: !8, line: 6, column: 5)
!25 = distinct !DILexicalBlock(scope: !22, file: !8, line: 5, column: 5)
!26 = !DILocation(line: 4, column: 5, scope: !14)
!27 = !DILocation(line: 4, column: 10, scope: !14)
!28 = !DILocation(line: 5, column: 10, scope: !22)
!29 = !DILocation(line: 5, column: 14, scope: !22)
!30 = !DILocation(line: 5, column: 14, scope: !22, atomGroup: 1, atomRank: 1)
!31 = !DILocation(line: 5, column: 21, scope: !25)
!32 = !DILocation(line: 5, column: 23, scope: !25, atomGroup: 2, atomRank: 1)
!33 = !DILocation(line: 5, column: 5, scope: !22, atomGroup: 3, atomRank: 1)
!34 = !DILocation(line: 5, column: 5, scope: !25)
!35 = !DILocation(line: 7, column: 9, scope: !24)
!36 = !DILocation(line: 7, column: 13, scope: !24)
!37 = !DILocation(line: 7, column: 17, scope: !24, atomGroup: 4, atomRank: 2)
!38 = !DILocation(line: 7, column: 13, scope: !24, atomGroup: 4, atomRank: 1)
!39 = !DILocation(line: 8, column: 11, scope: !24, atomGroup: 5, atomRank: 1)
!40 = !{!41, !41, i64 0}
!41 = !{!"p1 int", !42, i64 0}
!42 = !{!"any pointer", !12, i64 0}
!43 = !DILocation(line: 9, column: 5, scope: !25)
!44 = !DILocation(line: 9, column: 5, scope: !24, atomGroup: 7, atomRank: 1)
!45 = !DILocation(line: 5, column: 29, scope: !25)
!46 = !DILocation(line: 5, column: 29, scope: !25, atomGroup: 6, atomRank: 2)
!47 = !DILocation(line: 5, column: 29, scope: !25, atomGroup: 6, atomRank: 1)
!48 = distinct !{!48, !49, !50, !51, !52}
!49 = !DILocation(line: 5, column: 5, scope: !22)
!50 = !DILocation(line: 9, column: 5, scope: !22)
!51 = !{!"llvm.loop.mustprogress"}
!52 = !{!"llvm.loop.unroll.disable"}
!53 = !DILocation(line: 10, column: 6, scope: !14)
!54 = !DILocation(line: 10, column: 8, scope: !14, atomGroup: 8, atomRank: 1)
!55 = !DILocation(line: 11, column: 1, scope: !14)
!56 = !DILocation(line: 11, column: 1, scope: !14, atomGroup: 9, atomRank: 1)
!57 = distinct !DISubprogram(name: "main", scope: !8, file: !8, line: 12, type: !58, scopeLine: 12, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, keyInstructions: true)
!58 = !DISubroutineType(types: !59)
!59 = !{!20}
!60 = !DILocation(line: 12, column: 14, scope: !57)
!61 = !DILocation(line: 12, column: 22, scope: !57, atomGroup: 1, atomRank: 1)
