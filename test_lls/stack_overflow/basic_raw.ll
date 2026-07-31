; ModuleID = 'tests/stack_overflow/basic.c'
source_filename = "tests/stack_overflow/basic.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx14.0.0"

@.str = private unnamed_addr constant [4 x i8] c"%c\0A\00", align 1, !dbg !0

; Function Attrs: nounwind ssp uwtable(sync)
define i32 @main() #0 !dbg !21 {
entry:
  %retval = alloca i32, align 4
  %buf = alloca [8 x i8], align 1
  store i32 0, ptr %retval, align 4
  call void @llvm.lifetime.start.p0(ptr %buf) #3, !dbg !30
    #dbg_declare(ptr %buf, !26, !DIExpression(), !31)
  %arrayidx = getelementptr inbounds [8 x i8], ptr %buf, i64 0, i64 10, !dbg !32
  store i8 88, ptr %arrayidx, align 1, !dbg !33, !tbaa !34
  %arrayidx1 = getelementptr inbounds [8 x i8], ptr %buf, i64 0, i64 10, !dbg !35
  %0 = load i8, ptr %arrayidx1, align 1, !dbg !35, !tbaa !34
  %conv = sext i8 %0 to i32, !dbg !35
  %call = call i32 (ptr, ...) @printf(ptr noundef @.str, i32 noundef %conv), !dbg !36
  call void @llvm.lifetime.end.p0(ptr %buf) #3, !dbg !37
  ret i32 0, !dbg !38
}

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #1

declare !dbg !39 i32 @printf(ptr noundef, ...) #2

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #1

attributes #0 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #2 = { "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
attributes #3 = { nounwind }

!llvm.module.flags = !{!7, !8, !9, !10, !11, !12, !13}
!llvm.dbg.cu = !{!14}
!llvm.ident = !{!16}
!llvm.errno.tbaa = !{!17}

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
!14 = distinct !DICompileUnit(language: DW_LANG_C11, file: !2, producer: "Homebrew clang version 22.1.8", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, globals: !15, splitDebugInlining: false, nameTableKind: Apple, sysroot: "/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk", sdk: "MacOSX14.sdk")
!15 = !{!0}
!16 = !{!"Homebrew clang version 22.1.8"}
!17 = !{!18, !18, i64 0}
!18 = !{!"int", !19, i64 0}
!19 = !{!"omnipotent char", !20, i64 0}
!20 = !{!"Simple C/C++ TBAA"}
!21 = distinct !DISubprogram(name: "main", scope: !2, file: !2, line: 3, type: !22, scopeLine: 4, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !14, retainedNodes: !25, keyInstructions: true)
!22 = !DISubroutineType(types: !23)
!23 = !{!24}
!24 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!25 = !{!26}
!26 = !DILocalVariable(name: "buf", scope: !21, file: !2, line: 5, type: !27)
!27 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 64, elements: !28)
!28 = !{!29}
!29 = !DISubrange(count: 8)
!30 = !DILocation(line: 5, column: 5, scope: !21)
!31 = !DILocation(line: 5, column: 10, scope: !21)
!32 = !DILocation(line: 6, column: 5, scope: !21)
!33 = !DILocation(line: 6, column: 13, scope: !21, atomGroup: 1, atomRank: 1)
!34 = !{!19, !19, i64 0}
!35 = !DILocation(line: 7, column: 20, scope: !21)
!36 = !DILocation(line: 7, column: 5, scope: !21)
!37 = !DILocation(line: 9, column: 1, scope: !21)
!38 = !DILocation(line: 8, column: 5, scope: !21, atomGroup: 3, atomRank: 1)
!39 = !DISubprogram(name: "printf", scope: !40, file: !40, line: 167, type: !41, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized)
!40 = !DIFile(filename: "/Library/Developer/CommandLineTools/SDKs/MacOSX14.sdk/usr/include/stdio.h", directory: "")
!41 = !DISubroutineType(types: !42)
!42 = !{!24, !43, null}
!43 = !DIDerivedType(tag: DW_TAG_restrict_type, baseType: !44)
!44 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !45, size: 64)
!45 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !4)
