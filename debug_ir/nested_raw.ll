; ModuleID = 'tests/use_after_scope/nested.c'
source_filename = "tests/use_after_scope/nested.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define void @test() #0 !dbg !10 {
entry:
  %p = alloca ptr, align 8
  %x = alloca i32, align 4
    #dbg_declare(ptr %p, !14, !DIExpression(), !17)
    #dbg_declare(ptr %x, !18, !DIExpression(), !20)
  store i32 42, ptr %x, align 4, !dbg !20
  store ptr %x, ptr %p, align 8, !dbg !21
  %0 = load ptr, ptr %p, align 8, !dbg !22
  store i32 99, ptr %0, align 4, !dbg !23
  ret void, !dbg !24
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !25 {
entry:
  call void @test(), !dbg !28
  ret i32 0, !dbg !29
}

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
!8 = !DIFile(filename: "tests/use_after_scope/nested.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = distinct !DISubprogram(name: "test", scope: !8, file: !8, line: 2, type: !11, scopeLine: 3, spFlags: DISPFlagDefinition, unit: !7, retainedNodes: !13)
!11 = !DISubroutineType(types: !12)
!12 = !{null}
!13 = !{}
!14 = !DILocalVariable(name: "p", scope: !10, file: !8, line: 4, type: !15)
!15 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !16, size: 64)
!16 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!17 = !DILocation(line: 4, column: 10, scope: !10)
!18 = !DILocalVariable(name: "x", scope: !19, file: !8, line: 6, type: !16)
!19 = distinct !DILexicalBlock(scope: !10, file: !8, line: 5, column: 5)
!20 = !DILocation(line: 6, column: 13, scope: !19)
!21 = !DILocation(line: 7, column: 11, scope: !19)
!22 = !DILocation(line: 9, column: 6, scope: !10)
!23 = !DILocation(line: 9, column: 8, scope: !10)
!24 = !DILocation(line: 10, column: 1, scope: !10)
!25 = distinct !DISubprogram(name: "main", scope: !8, file: !8, line: 11, type: !26, scopeLine: 11, spFlags: DISPFlagDefinition, unit: !7)
!26 = !DISubroutineType(types: !27)
!27 = !{!16}
!28 = !DILocation(line: 11, column: 14, scope: !25)
!29 = !DILocation(line: 11, column: 22, scope: !25)
