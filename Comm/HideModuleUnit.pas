unit HideModuleUnit;

interface

uses Windows, Messages, SysUtils, Classes, TlHelp32;

type
  TVirtualAlloc = function (lpvAddress: Pointer; dwSize, flAllocationType, flProtect: DWORD): Pointer; stdcall;
  TVirtualProtect = function (lpAddress: Pointer; dwSize, flNewProtect: DWORD; var OldProtect: DWORD): BOOL; stdcall;
  TVirtualFree = function (lpAddress: Pointer; dwSize, dwFreeType: DWORD): BOOL; stdcall;
  TWriteProcessMemory = function (hProcess: THandle; const lpBaseAddress: Pointer; lpBuffer: Pointer; nSize: DWORD; var lpNumberOfBytesWritten: DWORD): BOOL; stdcall;
  TGetCurrentProcess = function : THandle; stdcall;
  TFreeLibrary = function (hLibModule: HMODULE): BOOL; stdcall;

  THideModuleRec = record
    pModule: pointer;
    pVirtualAlloc: TVirtualAlloc;
    pVirtualProtect: TVirtualProtect;
    pVirtualFree: TVirtualFree;
    pWriteProcessMemory: TWriteProcessMemory;
    pGetCurrentProcess: TGetCurrentProcess;
    pFreeLibrary: TFreeLibrary;
  end;
  PHideModuleRec = ^THideModuleRec;

  procedure HideModule(hModule: THandle);

implementation

procedure ExecuteHide(HM: THideModuleRec);
var
  pBakMemory: pointer;
  ImageOptionalHeader: TImageOptionalHeader32;
  ImageDosHeader: TImageDosHeader;
  td: dword;
  i: Integer;
begin
  { 取得映象数据 }
  ImageDosHeader := PImageDosHeader(HM.pModule)^;
  ImageOptionalHeader := PImageOptionalHeader32(Pointer(integer(HM.pModule) + ImageDosHeader._lfanew + SizeOf(dword) + SizeOf(TImageFileHeader)))^;
  { 申请内存以备份原始模块数据 }
  pBakMemory := HM.pVirtualAlloc(nil, ImageOptionalHeader.SizeOfImage, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if pBakMemory = nil then
    exit;
  { 修改原始内存为可读写属性 }
  HM.pVirtualProtect(HM.pModule, ImageOptionalHeader.SizeOfImage,
    PAGE_EXECUTE_READWRITE, td);
  { 备份原始模块数据 }
  HM.pWriteProcessMemory(HM.pGetCurrentProcess, pBakMemory, HM.pModule,
    ImageOptionalHeader.SizeOfImage, td);
  { 修改原DllEntryPoint为retn,防止FreeLibrary时的一些卸载操作 }
  pByte(integer(HM.pModule) + ImageOptionalHeader.AddressOfEntryPoint)^ := $C3;
  { 卸载原模块,这里多次卸载防止因为LoadCount的关系一次卸载不掉 }
  //HM.pFreeLibrary(integer(HM.pModule));
  i := 0;
  repeat
    Inc(i);
  until not HM.pFreeLibrary(integer(HM.pModule)) or (i >= 30);
  { 申请dll原始加载地址空间 }
  HM.pModule := HM.pVirtualAlloc(HM.pModule, ImageOptionalHeader.SizeOfImage,
    MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if HM.pModule = nil then
    exit;
  { 写回原始数据 }
  HM.pWriteProcessMemory(HM.pGetCurrentProcess, HM.pModule, pBakMemory,
    ImageOptionalHeader.SizeOfImage, td);
  { 释放备份时用的内存 }
  HM.pVirtualFree(pBakMemory, 0, MEM_RELEASE);
end;
(*注意该间隔处不能添加任何代码, 且不能改变上下2个函数位置
  因为下面使用了2个函数入口来计算上一函数Size*)
procedure LockedAllModule(CurrentModuleHandle: THandle);
var
  ModuleList: THandle;
  pm: tagMODULEENTRY32;
begin
  pm.dwSize := sizeof(tagMODULEENTRY32);
  ModuleList := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, 0);
  if not Module32First(ModuleList, pm) then
  begin
    CloseHandle(ModuleList);
    exit;
  end;
  //不处理第一个模块,因为那是主模块
  { 对每个模块LoadLibrary一次,是为了把LoadCount加1 }
  while Module32Next(ModuleList, pm) do
  begin
    if pm.hModule <> CurrentModuleHandle then
      LoadLibrary(PWideChar(@GetModuleName(pm.hModule)[1]));
  end;
  CloseHandle(ModuleList);
end;

type
  TExecuteHide = procedure (HM: THideModuleRec);

procedure HideModule(hModule: THandle);
var
  HM: THideModuleRec;
  pExecuteHide: pointer;
  ExecuteHideSize: integer;
  MyExecuteHide: TExecuteHide;
  td: dword;
  Module_kernel32: integer;
begin
  Module_kernel32 := GetModuleHandle('kernel32.dll');
  HM.pModule := pointer(hModule);
  HM.pVirtualAlloc := GetProcAddress(Module_kernel32, 'VirtualAlloc');
  HM.pVirtualProtect := GetProcAddress(Module_kernel32, 'VirtualProtect');
  HM.pVirtualFree := GetProcAddress(Module_kernel32, 'VirtualFree');
  HM.pWriteProcessMemory := GetProcAddress(Module_kernel32, 'WriteProcessMemory');
  HM.pGetCurrentProcess := GetProcAddress(Module_kernel32, 'GetCurrentProcess');
  HM.pFreeLibrary := GetProcAddress(Module_kernel32, 'FreeLibrary');
  ExecuteHideSize := integer(@LockedAllModule) - Integer(@ExecuteHide);
  pExecuteHide := VirtualAlloc(nil, ExecuteHideSize, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  if pExecuteHide = nil then
    Exit;
  { 防止系统将需要的Dll卸载掉 }
  LockedAllModule(integer(HM.pModule));
  CopyMemory(pExecuteHide, @ExecuteHide, ExecuteHideSize);
  MyExecuteHide := pExecuteHide;
  MyExecuteHide(HM);
end;

end.
