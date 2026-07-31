; ModuleID = 'tests/stack_overflow/int_var.c'
source_filename = "tests/stack_overflow/int_var.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: nounwind ssp uwtable(sync)
define void @test() #0 !dbg !14 {
entry:
  %x = alloca i32, align 4
  %p = alloca ptr, align 8
  call void @llvm.lifetime.start.p0(ptr %x) #2, !dbg !22
    #dbg_declare(ptr %x, !18, !DIExpression(), !23)
  call void @llvm.lifetime.start.p0(ptr %p) #2, !dbg !24
    #dbg_declare(ptr %p, !20, !DIExpression(), !25)
  store ptr %x, ptr %p, align 8, !dbg !26, !tbaa !27
  %0 = load ptr, ptr %p, align 8, !dbg !30, !tbaa !27
  %add.ptr = getelementptr inbounds i32, ptr %0, i64 2, !dbg !31
  store i32 99, ptr %add.ptr, align 4, !dbg !32, !tbaa !10
  call void @llvm.lifetime.end.p0(ptr %p) #2, !dbg !33
  call void @llvm.lifetime.end.p0(ptr %x) #2, !dbg !33
  ret void, !dbg !34
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !35 {
entry:
  call void @test(), !dbg !38
  ret i32 0, !dbg !39
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
!8 = !DIFile(filename: "tests/stack_overflow/int_var.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = !{!11, !11, i64 0}
!11 = !{!"int", !12, i64 0}
!12 = !{!"omnipotent char", !13, i64 0}
!13 = !{!"Simple C/C++ TBAA"}
!14 = distinct !DISubprogram(name: "test", scope: !8, file: !8, line: 2, type: !15, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, retainedNodes: !17, keyInstructions: true)
!15 = !DISubroutineType(types: !16)
!16 = !{null}
!17 = !{!18, !20}
!18 = !DILocalVariable(name: "x", scope: !14, file: !8, line: 4, type: !19)
!19 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!20 = !DILocalVariable(name: "p", scope: !14, file: !8, line: 5, type: !21)
!21 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !19, size: 64)
!22 = !DILocation(line: 4, column: 5, scope: !14)
!23 = !DILocation(line: 4, column: 9, scope: !14)
!24 = !DILocation(line: 5, column: 5, scope: !14)
!25 = !DILocation(line: 5, column: 10, scope: !14)
!26 = !DILocation(line: 5, column: 10, scope: !14, atomGroup: 1, atomRank: 1)
!27 = !{!28, !28, i64 0}
!28 = !{!"p1 int", !29, i64 0}
!29 = !{!"any pointer", !12, i64 0}
!30 = !DILocation(line: 6, column: 7, scope: !14)
!31 = !DILocation(line: 6, column: 5, scope: !14)
!32 = !DILocation(line: 6, column: 14, scope: !14, atomGroup: 2, atomRank: 1)
!33 = !DILocation(line: 7, column: 1, scope: !14)
!34 = !DILocation(line: 7, column: 1, scope: !14, atomGroup: 3, atomRank: 1)
!35 = distinct !DISubprogram(name: "main", scope: !8, file: !8, line: 8, type: !36, scopeLine: 8, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !7, keyInstructions: true)
!36 = !DISubroutineType(types: !37)
!37 = !{!19}
!38 = !DILocation(line: 8, column: 14, scope: !35)
!39 = !DILocation(line: 8, column: 22, scope: !35, atomGroup: 1, atomRank: 1)
