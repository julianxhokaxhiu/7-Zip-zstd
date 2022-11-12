@echo on
REM Build signed setups for 7-Zip ZS /TR

set /p APPVEYOR_BUILD_FOLDER=".."
SET COPTS=-m0=lzma -mx9 -ms=on -mf=bcj2
SET VERSION=19.00
SET WD=%APPVEYOR_BUILD_FOLDER%
SET X32=%WD%\bin-12.0-x32
SET X64=%WD%\bin-12.0-x64
SET ARM=%WD%\bin-12.0-arm

SET COPYCMD=/Y /B

REM these are our skeleton zip files with README.md and so on
FOR %%f IN (x32 x64 codecs totalcmd) DO (
  rd /S /Q %%f 2>NUL
  7z x %%f.zip
)

REM 7-zip
copy %X32%\7-zip.dll x64\7-zip32.dll
FOR %%f IN (7-zip.dll 7z.dll 7z.exe 7za.dll 7za.exe 7zG.exe 7zFM.exe 7z.sfx 7zCon.sfx Uninstall.exe) DO (
  copy %X32%\%%f x32\%%f
  copy %X64%\%%f x64\%%f
  copy %ARM%\%%f arm\%%f
)

REM totalcmd
copy %X32%\7zxa.dll totalcmd\tc7z.dll
copy %X64%\7zxa.dll totalcmd\tc7z64.dll
copy %ARM%\7zxa.dll totalcmd\tc7zarm.dll

REM codecs
FOR %%f IN (brotli flzma2 lizard lz4 lz5 zstd) DO (
  copy %X32%\%%f-x32.dll  codecs\%%f-x32.dll
  copy %X64%\%%f-x64.dll  codecs\%%f-x64.dll
  copy %ARM%\%%f-arm.dll  codecs\%%f-arm.dll
)

REM create 7-zip setup.exe
del *.7z 7z*.exe 2>NUL

cd %WD%\x32
%X64%\7z a ..\x32.7z  %COPTS%
cd %WD%\x64
%X64%\7z a ..\x64.7z  %COPTS%

cd %WD%\codecs
%X64%\7z a ..\Codecs.7z %COPTS%

cd %WD%\totalcmd
%X64%\7z a ..\TotalCmd.7z %COPTS%

cd %WD%
copy %X32%\Install-x32.exe  + x32.7z  7z%VERSION%-zstd-x32.exe
copy %X64%\Install-x64.exe  + x64.7z  7z%VERSION%-zstd-x64.exe

cd %WD%
