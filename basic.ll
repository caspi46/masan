; ModuleID = '/Users/kennykim/Documents/masan/tests/use_after_scope/basic.c'
source_filename = "/Users/kennykim/Documents/masan/tests/use_after_scope/basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

; Function Attrs: noinline nounwind ssp uwtable(sync)
define ptr @get_ptr() #0 !dbg !10 {
entry:
  %x = alloca i32, align 4
    #dbg_declare(ptr %x, !17, !DIExpression(), !18)
  store i32 42, ptr %x, align 4, !dbg !18
  ret ptr %x, !dbg !19
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !20 {
entry:
  %p = alloca ptr, align 8
    #dbg_declare(ptr %p, !23, !DIExpression(), !24)
  %call = call ptr @get_ptr(), !dbg !25
  store ptr %call, ptr %p, align 8, !dbg !24
  %0 = load ptr, ptr %p, align 8, !dbg !26
  store i32 99, ptr %0, align 4, !dbg !27
  ret i32 0, !dbg !28
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
!7 = distinct !DICompileUnit(language: DW_LANG_C11, file: !8, producer: "Homebrew clang version 22.1.8", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk", sdk: "MacOSX.sdk")
!8 = !DIFile(filename: "/Users/kennykim/Documents/masan/tests/use_after_scope/basic.c", directory: "/Users/kennykim/Documents/masan")
!9 = !{!"Homebrew clang version 22.1.8"}
!10 = distinct !DISubprogram(name: "get_ptr", scope: !11, file: !11, line: 2, type: !12, scopeLine: 3, spFlags: DISPFlagDefinition, unit: !7, retainedNodes: !16)
!11 = !DIFile(filename: "tests/use_after_scope/basic.c", directory: "/Users/kennykim/Documents/masan")
!12 = !DISubroutineType(types: !13)
!13 = !{!14}
!14 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !15, size: 64)
!15 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!16 = !{}
!17 = !DILocalVariable(name: "x", scope: !10, file: !11, line: 4, type: !15)
!18 = !DILocation(line: 4, column: 9, scope: !10)
!19 = !DILocation(line: 5, column: 5, scope: !10)
!20 = distinct !DISubprogram(name: "main", scope: !11, file: !11, line: 7, type: !21, scopeLine: 8, spFlags: DISPFlagDefinition, unit: !7, retainedNodes: !16)
!21 = !DISubroutineType(types: !22)
!22 = !{!15}
!23 = !DILocalVariable(name: "p", scope: !20, file: !11, line: 9, type: !14)
!24 = !DILocation(line: 9, column: 10, scope: !20)
!25 = !DILocation(line: 9, column: 14, scope: !20)
!26 = !DILocation(line: 10, column: 6, scope: !20)
!27 = !DILocation(line: 10, column: 8, scope: !20)
!28 = !DILocation(line: 11, column: 1, scope: !20)
