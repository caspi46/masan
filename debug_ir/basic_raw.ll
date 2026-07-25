; ModuleID = 'tests/stack_overflow/basic.c'
source_filename = "tests/stack_overflow/basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

@.str = private unnamed_addr constant [4 x i8] c"%c\0A\00", align 1, !dbg !0

; Function Attrs: noinline nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !17 {
entry:
  %retval = alloca i32, align 4
  %buf = alloca [8 x i8], align 1
  store i32 0, ptr %retval, align 4
    #dbg_declare(ptr %buf, !22, !DIExpression(), !26)
  %arrayidx = getelementptr inbounds [8 x i8], ptr %buf, i64 0, i64 10, !dbg !27
  store i8 88, ptr %arrayidx, align 1, !dbg !28
  %arrayidx1 = getelementptr inbounds [8 x i8], ptr %buf, i64 0, i64 10, !dbg !29
  %0 = load i8, ptr %arrayidx1, align 1, !dbg !29
  %conv = sext i8 %0 to i32, !dbg !29
  %call = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %conv), !dbg !30
  ret i32 0, !dbg !31
}

declare i32 @printf(ptr noundef, ...) #1

attributes #0 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }

!llvm.module.flags = !{!7, !8, !9, !10, !11, !12, !13}
!llvm.dbg.cu = !{!14}
!llvm.ident = !{!16}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(scope: null, file: !2, line: 7, type: !3, isLocal: true, isDefinition: true)
!2 = !DIFile(filename: "tests/stack_overflow/basic.c", directory: "/Users/kennykim/Documents/masan")
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
!14 = distinct !DICompileUnit(language: DW_LANG_C11, file: !2, producer: "Homebrew clang version 22.1.8", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, globals: !15, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk", sdk: "MacOSX14.sdk")
!15 = !{!0}
!16 = !{!"Homebrew clang version 22.1.8"}
!17 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 3, type: !18, scopeLine: 4, spFlags: DISPFlagDefinition, unit: !14, retainedNodes: !21)
!18 = !DISubroutineType(types: !19)
!19 = !{!20}
!20 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!21 = !{}
!22 = !DILocalVariable(name: "buf", scope: !17, file: !2, line: 5, type: !23)
!23 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 64, elements: !24)
!24 = !{!25}
!25 = !DISubrange(count: 8)
!26 = !DILocation(line: 5, column: 10, scope: !17)
!27 = !DILocation(line: 6, column: 5, scope: !17)
!28 = !DILocation(line: 6, column: 13, scope: !17)
!29 = !DILocation(line: 7, column: 20, scope: !17)
!30 = !DILocation(line: 7, column: 5, scope: !17)
!31 = !DILocation(line: 8, column: 5, scope: !17)
