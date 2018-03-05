unit dm_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// $Rev: 52393 $
// File generated on 2014/8/19 13:14:17 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Users\ManSoy\Desktop\【大漠上传】5.1423\5.1423\dm.dll (1)
// LIBID: {84288AAD-BA02-4EF2-85EC-3FAD4D11354D}
// LCID: 0
// Helpfile: 
// HelpString: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// SYS_KIND: SYS_WIN32
// Errors:
//   Hint: Parameter 'file' of Idmsoft.Capture changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.Play changed to 'file_'
//   Hint: Parameter 'type' of Idmsoft.SetMouseDelay changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.SetKeypadDelay changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.ReadInt changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.FindInt changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.FindString changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.WriteInt changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.WriteString changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.ReadString changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.ExitOs changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.GetDir changed to 'type_'
//   Hint: Parameter 'file' of Idmsoft.CaptureJpg changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.SaveDict changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.CapturePng changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.CaptureGif changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.CapturePre changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.ReadIni changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.WriteIni changed to 'file_'
//   Hint: Parameter 'type' of Idmsoft.ExcludePos changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.FindNearestPos changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.SortPosDistance changed to 'type_'
//   Hint: Parameter 'file' of Idmsoft.WriteFile changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.ReadIniPwd changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.WriteIniPwd changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.DecodeFile changed to 'file_'
//   Hint: Parameter 'type' of Idmsoft.DmGuard changed to 'type_'
//   Hint: Parameter 'file' of Idmsoft.FaqCaptureFromFile changed to 'file_'
//   Hint: Parameter 'type' of Idmsoft.FindIntEx changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.FindStringEx changed to 'type_'
//   Hint: Parameter 'file' of Idmsoft.EncodeFile changed to 'file_'
//   Hint: Parameter 'type' of Idmsoft.GetCursorShapeEx changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.IntToData changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.StringToData changed to 'type_'
//   Hint: Parameter 'file' of Idmsoft.SetMemoryFindResultToFile changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.IsFileExist changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.DeleteFile changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.GetFileLength changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.ReadFile changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.DeleteIni changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.DeleteIniPwd changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.FoobarSetSave changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.ReadFileData changed to 'file_'
//   Hint: Parameter 'type' of Idmsoft.VirtualAllocEx changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.ReadIntAddr changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.ReadStringAddr changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.WriteIntAddr changed to 'type_'
//   Hint: Parameter 'type' of Idmsoft.WriteStringAddr changed to 'type_'
//   Hint: Parameter 'file' of Idmsoft.EnumIniSection changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.EnumIniSectionPwd changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.EnumIniKey changed to 'file_'
//   Hint: Parameter 'file' of Idmsoft.EnumIniKeyPwd changed to 'file_'
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
{$ALIGN 4}

interface

uses Winapi.Windows, System.Classes, System.Variants, System.Win.StdVCL, Vcl.Graphics, Vcl.OleServer, Winapi.ActiveX;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  dmMajorVersion = 1;
  dmMinorVersion = 0;

  LIBID_dm: TGUID = '{84288AAD-BA02-4EF2-85EC-3FAD4D11354D}';

  IID_Idmsoft: TGUID = '{F3F54BC2-D6D1-4A85-B943-16287ECEA64C}';
  CLASS_dmsoft: TGUID = '{26037A0E-7CBD-4FFF-9C63-56F2D0770214}';
type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  Idmsoft = interface;
  IdmsoftDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  dmsoft = Idmsoft;


// *********************************************************************//
// Interface: Idmsoft
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F3F54BC2-D6D1-4A85-B943-16287ECEA64C}
// *********************************************************************//
  Idmsoft = interface(IDispatch)
    ['{F3F54BC2-D6D1-4A85-B943-16287ECEA64C}']
    function Ver: WideString; safecall;
    function SetPath(const path: WideString): Integer; safecall;
    function Ocr(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString;
                 sim: Double): WideString; safecall;
    function FindStr(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                     const color: WideString; sim: Double; out x: OleVariant; out y: OleVariant): Integer; safecall;
    function GetResultCount(const str: WideString): Integer; safecall;
    function GetResultPos(const str: WideString; index: Integer; out x: OleVariant; 
                          out y: OleVariant): Integer; safecall;
    function StrStr(const s: WideString; const str: WideString): Integer; safecall;
    function SendCommand(const cmd: WideString): Integer; safecall;
    function UseDict(index: Integer): Integer; safecall;
    function GetBasePath: WideString; safecall;
    function SetDictPwd(const pwd: WideString): Integer; safecall;
    function OcrInFile(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                       const pic_name: WideString; const color: WideString; sim: Double): WideString; safecall;
    function Capture(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const file_: WideString): Integer; safecall;
    function KeyPress(vk: Integer): Integer; safecall;
    function KeyDown(vk: Integer): Integer; safecall;
    function KeyUp(vk: Integer): Integer; safecall;
    function LeftClick: Integer; safecall;
    function RightClick: Integer; safecall;
    function MiddleClick: Integer; safecall;
    function LeftDoubleClick: Integer; safecall;
    function LeftDown: Integer; safecall;
    function LeftUp: Integer; safecall;
    function RightDown: Integer; safecall;
    function RightUp: Integer; safecall;
    function MoveTo(x: Integer; y: Integer): Integer; safecall;
    function MoveR(rx: Integer; ry: Integer): Integer; safecall;
    function GetColor(x: Integer; y: Integer): WideString; safecall;
    function GetColorBGR(x: Integer; y: Integer): WideString; safecall;
    function RGB2BGR(const rgb_color: WideString): WideString; safecall;
    function BGR2RGB(const bgr_color: WideString): WideString; safecall;
    function UnBindWindow: Integer; safecall;
    function CmpColor(x: Integer; y: Integer; const color: WideString; sim: Double): Integer; safecall;
    function ClientToScreen(hwnd: Integer; var x: OleVariant; var y: OleVariant): Integer; safecall;
    function ScreenToClient(hwnd: Integer; var x: OleVariant; var y: OleVariant): Integer; safecall;
    function ShowScrMsg(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const msg: WideString; 
                        const color: WideString): Integer; safecall;
    function SetMinRowGap(row_gap: Integer): Integer; safecall;
    function SetMinColGap(col_gap: Integer): Integer; safecall;
    function FindColor(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                       sim: Double; dir: Integer; out x: OleVariant; out y: OleVariant): Integer; safecall;
    function FindColorEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                         const color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function SetWordLineHeight(line_height: Integer): Integer; safecall;
    function SetWordGap(word_gap: Integer): Integer; safecall;
    function SetRowGapNoDict(row_gap: Integer): Integer; safecall;
    function SetColGapNoDict(col_gap: Integer): Integer; safecall;
    function SetWordLineHeightNoDict(line_height: Integer): Integer; safecall;
    function SetWordGapNoDict(word_gap: Integer): Integer; safecall;
    function GetWordResultCount(const str: WideString): Integer; safecall;
    function GetWordResultPos(const str: WideString; index: Integer; out x: OleVariant; 
                              out y: OleVariant): Integer; safecall;
    function GetWordResultStr(const str: WideString; index: Integer): WideString; safecall;
    function GetWords(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                      sim: Double): WideString; safecall;
    function GetWordsNoDict(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const color: WideString): WideString; safecall;
    function SetShowErrorMsg(show: Integer): Integer; safecall;
    function GetClientSize(hwnd: Integer; out width: OleVariant; out height: OleVariant): Integer; safecall;
    function MoveWindow(hwnd: Integer; x: Integer; y: Integer): Integer; safecall;
    function GetColorHSV(x: Integer; y: Integer): WideString; safecall;
    function GetAveRGB(x1: Integer; y1: Integer; x2: Integer; y2: Integer): WideString; safecall;
    function GetAveHSV(x1: Integer; y1: Integer; x2: Integer; y2: Integer): WideString; safecall;
    function GetForegroundWindow: Integer; safecall;
    function GetForegroundFocus: Integer; safecall;
    function GetMousePointWindow: Integer; safecall;
    function GetPointWindow(x: Integer; y: Integer): Integer; safecall;
    function EnumWindow(parent: Integer; const title: WideString; const class_name: WideString; 
                        filter: Integer): WideString; safecall;
    function GetWindowState(hwnd: Integer; flag: Integer): Integer; safecall;
    function GetWindow(hwnd: Integer; flag: Integer): Integer; safecall;
    function GetSpecialWindow(flag: Integer): Integer; safecall;
    function SetWindowText(hwnd: Integer; const text: WideString): Integer; safecall;
    function SetWindowSize(hwnd: Integer; width: Integer; height: Integer): Integer; safecall;
    function GetWindowRect(hwnd: Integer; out x1: OleVariant; out y1: OleVariant; 
                           out x2: OleVariant; out y2: OleVariant): Integer; safecall;
    function GetWindowTitle(hwnd: Integer): WideString; safecall;
    function GetWindowClass(hwnd: Integer): WideString; safecall;
    function SetWindowState(hwnd: Integer; flag: Integer): Integer; safecall;
    function CreateFoobarRect(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer): Integer; safecall;
    function CreateFoobarRoundRect(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer; 
                                   rw: Integer; rh: Integer): Integer; safecall;
    function CreateFoobarEllipse(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer): Integer; safecall;
    function CreateFoobarCustom(hwnd: Integer; x: Integer; y: Integer; const pic: WideString; 
                                const trans_color: WideString; sim: Double): Integer; safecall;
    function FoobarFillRect(hwnd: Integer; x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const color: WideString): Integer; safecall;
    function FoobarDrawText(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer; 
                            const text: WideString; const color: WideString; align: Integer): Integer; safecall;
    function FoobarDrawPic(hwnd: Integer; x: Integer; y: Integer; const pic: WideString; 
                           const trans_color: WideString): Integer; safecall;
    function FoobarUpdate(hwnd: Integer): Integer; safecall;
    function FoobarLock(hwnd: Integer): Integer; safecall;
    function FoobarUnlock(hwnd: Integer): Integer; safecall;
    function FoobarSetFont(hwnd: Integer; const font_name: WideString; size: Integer; flag: Integer): Integer; safecall;
    function FoobarTextRect(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer): Integer; safecall;
    function FoobarPrintText(hwnd: Integer; const text: WideString; const color: WideString): Integer; safecall;
    function FoobarClearText(hwnd: Integer): Integer; safecall;
    function FoobarTextLineGap(hwnd: Integer; gap: Integer): Integer; safecall;
    function Play(const file_: WideString): Integer; safecall;
    function FaqCapture(x1: Integer; y1: Integer; x2: Integer; y2: Integer; quality: Integer; 
                        delay: Integer; time: Integer): Integer; safecall;
    function FaqRelease(handle: Integer): Integer; safecall;
    function FaqSend(const server: WideString; handle: Integer; request_type: Integer; 
                     time_out: Integer): WideString; safecall;
    function Beep(fre: Integer; delay: Integer): Integer; safecall;
    function FoobarClose(hwnd: Integer): Integer; safecall;
    function MoveDD(dx: Integer; dy: Integer): Integer; safecall;
    function FaqGetSize(handle: Integer): Integer; safecall;
    function LoadPic(const pic_name: WideString): Integer; safecall;
    function FreePic(const pic_name: WideString): Integer; safecall;
    function GetScreenData(x1: Integer; y1: Integer; x2: Integer; y2: Integer): Integer; safecall;
    function FreeScreenData(handle: Integer): Integer; safecall;
    function WheelUp: Integer; safecall;
    function WheelDown: Integer; safecall;
    function SetMouseDelay(const type_: WideString; delay: Integer): Integer; safecall;
    function SetKeypadDelay(const type_: WideString; delay: Integer): Integer; safecall;
    function GetEnv(index: Integer; const name: WideString): WideString; safecall;
    function SetEnv(index: Integer; const name: WideString; const value: WideString): Integer; safecall;
    function SendString(hwnd: Integer; const str: WideString): Integer; safecall;
    function DelEnv(index: Integer; const name: WideString): Integer; safecall;
    function GetPath: WideString; safecall;
    function SetDict(index: Integer; const dict_name: WideString): Integer; safecall;
    function FindPic(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                     const pic_name: WideString; const delta_color: WideString; sim: Double; 
                     dir: Integer; out x: OleVariant; out y: OleVariant): Integer; safecall;
    function FindPicEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                       const pic_name: WideString; const delta_color: WideString; sim: Double; 
                       dir: Integer): WideString; safecall;
    function SetClientSize(hwnd: Integer; width: Integer; height: Integer): Integer; safecall;
    function ReadInt(hwnd: Integer; const addr: WideString; type_: Integer): Integer; safecall;
    function ReadFloat(hwnd: Integer; const addr: WideString): Single; safecall;
    function ReadDouble(hwnd: Integer; const addr: WideString): Double; safecall;
    function FindInt(hwnd: Integer; const addr_range: WideString; int_value_min: Integer; 
                     int_value_max: Integer; type_: Integer): WideString; safecall;
    function FindFloat(hwnd: Integer; const addr_range: WideString; float_value_min: Single; 
                       float_value_max: Single): WideString; safecall;
    function FindDouble(hwnd: Integer; const addr_range: WideString; double_value_min: Double; 
                        double_value_max: Double): WideString; safecall;
    function FindString(hwnd: Integer; const addr_range: WideString; 
                        const string_value: WideString; type_: Integer): WideString; safecall;
    function GetModuleBaseAddr(hwnd: Integer; const module_name: WideString): Integer; safecall;
    function MoveToEx(x: Integer; y: Integer; w: Integer; h: Integer): WideString; safecall;
    function MatchPicName(const pic_name: WideString): WideString; safecall;
    function AddDict(index: Integer; const dict_info: WideString): Integer; safecall;
    function EnterCri: Integer; safecall;
    function LeaveCri: Integer; safecall;
    function WriteInt(hwnd: Integer; const addr: WideString; type_: Integer; v: Integer): Integer; safecall;
    function WriteFloat(hwnd: Integer; const addr: WideString; v: Single): Integer; safecall;
    function WriteDouble(hwnd: Integer; const addr: WideString; v: Double): Integer; safecall;
    function WriteString(hwnd: Integer; const addr: WideString; type_: Integer; const v: WideString): Integer; safecall;
    function AsmAdd(const asm_ins: WideString): Integer; safecall;
    function AsmClear: Integer; safecall;
    function AsmCall(hwnd: Integer; mode: Integer): Integer; safecall;
    function FindMultiColor(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const first_color: WideString; const offset_color: WideString; 
                            sim: Double; dir: Integer; out x: OleVariant; out y: OleVariant): Integer; safecall;
    function FindMultiColorEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                              const first_color: WideString; const offset_color: WideString; 
                              sim: Double; dir: Integer): WideString; safecall;
    function AsmCode(base_addr: Integer): WideString; safecall;
    function Assemble(const asm_code: WideString; base_addr: Integer; is_upper: Integer): WideString; safecall;
    function SetWindowTransparent(hwnd: Integer; v: Integer): Integer; safecall;
    function ReadData(hwnd: Integer; const addr: WideString; len: Integer): WideString; safecall;
    function WriteData(hwnd: Integer; const addr: WideString; const data: WideString): Integer; safecall;
    function FindData(hwnd: Integer; const addr_range: WideString; const data: WideString): WideString; safecall;
    function SetPicPwd(const pwd: WideString): Integer; safecall;
    function Log(const info: WideString): Integer; safecall;
    function FindStrE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                      const color: WideString; sim: Double): WideString; safecall;
    function FindColorE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function FindPicE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                      const pic_name: WideString; const delta_color: WideString; sim: Double; 
                      dir: Integer): WideString; safecall;
    function FindMultiColorE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                             const first_color: WideString; const offset_color: WideString; 
                             sim: Double; dir: Integer): WideString; safecall;
    function SetExactOcr(exact_ocr: Integer): Integer; safecall;
    function ReadString(hwnd: Integer; const addr: WideString; type_: Integer; len: Integer): WideString; safecall;
    function FoobarTextPrintDir(hwnd: Integer; dir: Integer): Integer; safecall;
    function OcrEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                   sim: Double): WideString; safecall;
    function SetDisplayInput(const mode: WideString): Integer; safecall;
    function GetTime: Integer; safecall;
    function GetScreenWidth: Integer; safecall;
    function GetScreenHeight: Integer; safecall;
    function BindWindowEx(hwnd: Integer; const display: WideString; const mouse: WideString; 
                          const keypad: WideString; const public_desc: WideString; mode: Integer): Integer; safecall;
    function GetDiskSerial: WideString; safecall;
    function Md5(const str: WideString): WideString; safecall;
    function GetMac: WideString; safecall;
    function ActiveInputMethod(hwnd: Integer; const id: WideString): Integer; safecall;
    function CheckInputMethod(hwnd: Integer; const id: WideString): Integer; safecall;
    function FindInputMethod(const id: WideString): Integer; safecall;
    function GetCursorPos(out x: OleVariant; out y: OleVariant): Integer; safecall;
    function BindWindow(hwnd: Integer; const display: WideString; const mouse: WideString; 
                        const keypad: WideString; mode: Integer): Integer; safecall;
    function FindWindow(const class_name: WideString; const title_name: WideString): Integer; safecall;
    function GetScreenDepth: Integer; safecall;
    function SetScreen(width: Integer; height: Integer; depth: Integer): Integer; safecall;
    function ExitOs(type_: Integer): Integer; safecall;
    function GetDir(type_: Integer): WideString; safecall;
    function GetOsType: Integer; safecall;
    function FindWindowEx(parent: Integer; const class_name: WideString; 
                          const title_name: WideString): Integer; safecall;
    function SetExportDict(index: Integer; const dict_name: WideString): Integer; safecall;
    function GetCursorShape: WideString; safecall;
    function DownCpu(rate: Integer): Integer; safecall;
    function GetCursorSpot: WideString; safecall;
    function SendString2(hwnd: Integer; const str: WideString): Integer; safecall;
    function FaqPost(const server: WideString; handle: Integer; request_type: Integer; 
                     time_out: Integer): Integer; safecall;
    function FaqFetch: WideString; safecall;
    function FetchWord(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                       const word: WideString): WideString; safecall;
    function CaptureJpg(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const file_: WideString; quality: Integer): Integer; safecall;
    function FindStrWithFont(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                             const str: WideString; const color: WideString; sim: Double; 
                             const font_name: WideString; font_size: Integer; flag: Integer; 
                             out x: OleVariant; out y: OleVariant): Integer; safecall;
    function FindStrWithFontE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                              const str: WideString; const color: WideString; sim: Double; 
                              const font_name: WideString; font_size: Integer; flag: Integer): WideString; safecall;
    function FindStrWithFontEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                               const str: WideString; const color: WideString; sim: Double; 
                               const font_name: WideString; font_size: Integer; flag: Integer): WideString; safecall;
    function GetDictInfo(const str: WideString; const font_name: WideString; font_size: Integer; 
                         flag: Integer): WideString; safecall;
    function SaveDict(index: Integer; const file_: WideString): Integer; safecall;
    function GetWindowProcessId(hwnd: Integer): Integer; safecall;
    function GetWindowProcessPath(hwnd: Integer): WideString; safecall;
    function LockInput(lock: Integer): Integer; safecall;
    function GetPicSize(const pic_name: WideString): WideString; safecall;
    function GetID: Integer; safecall;
    function CapturePng(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const file_: WideString): Integer; safecall;
    function CaptureGif(x1: Integer; y1: Integer; x2: Integer; y2: Integer;
                        const file_: WideString; delay: Integer; time: Integer): Integer; safecall;
    function ImageToBmp(const pic_name: WideString; const bmp_name: WideString): Integer; safecall;
    function FindStrFast(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                         const color: WideString; sim: Double; out x: OleVariant; out y: OleVariant): Integer; safecall;
    function FindStrFastEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                           const str: WideString; const color: WideString; sim: Double): WideString; safecall;
    function FindStrFastE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                          const str: WideString; const color: WideString; sim: Double): WideString; safecall;
    function EnableDisplayDebug(enable_debug: Integer): Integer; safecall;
    function CapturePre(const file_: WideString): Integer; safecall;
    function RegEx(const code: WideString; const Ver: WideString; const ip: WideString): Integer; safecall;
    function GetMachineCode: WideString; safecall;
    function SetClipboard(const data: WideString): Integer; safecall;
    function GetClipboard: WideString; safecall;
    function GetNowDict: Integer; safecall;
    function Is64Bit: Integer; safecall;
    function GetColorNum(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                         const color: WideString; sim: Double): Integer; safecall;
    function EnumWindowByProcess(const process_name: WideString; const title: WideString; 
                                 const class_name: WideString; filter: Integer): WideString; safecall;
    function GetDictCount(index: Integer): Integer; safecall;
    function GetLastError: Integer; safecall;
    function GetNetTime: WideString; safecall;
    function EnableGetColorByCapture(en: Integer): Integer; safecall;
    function CheckUAC: Integer; safecall;
    function SetUAC(uac: Integer): Integer; safecall;
    function DisableFontSmooth: Integer; safecall;
    function CheckFontSmooth: Integer; safecall;
    function SetDisplayAcceler(level: Integer): Integer; safecall;
    function FindWindowByProcess(const process_name: WideString; const class_name: WideString; 
                                 const title_name: WideString): Integer; safecall;
    function FindWindowByProcessId(process_id: Integer; const class_name: WideString; 
                                   const title_name: WideString): Integer; safecall;
    function ReadIni(const section: WideString; const key: WideString; const file_: WideString): WideString; safecall;
    function WriteIni(const section: WideString; const key: WideString; const v: WideString; 
                      const file_: WideString): Integer; safecall;
    function RunApp(const path: WideString; mode: Integer): Integer; safecall;
    function delay(mis: Integer): Integer; safecall;
    function FindWindowSuper(const spec1: WideString; flag1: Integer; type1: Integer; 
                             const spec2: WideString; flag2: Integer; type2: Integer): Integer; safecall;
    function ExcludePos(const all_pos: WideString; type_: Integer; x1: Integer; y1: Integer; 
                        x2: Integer; y2: Integer): WideString; safecall;
    function FindNearestPos(const all_pos: WideString; type_: Integer; x: Integer; y: Integer): WideString; safecall;
    function SortPosDistance(const all_pos: WideString; type_: Integer; x: Integer; y: Integer): WideString; safecall;
    function FindPicMem(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const pic_info: WideString; const delta_color: WideString; sim: Double; 
                        dir: Integer; out x: OleVariant; out y: OleVariant): Integer; safecall;
    function FindPicMemEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                          const pic_info: WideString; const delta_color: WideString; sim: Double; 
                          dir: Integer): WideString; safecall;
    function FindPicMemE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                         const pic_info: WideString; const delta_color: WideString; sim: Double; 
                         dir: Integer): WideString; safecall;
    function AppendPicAddr(const pic_info: WideString; addr: Integer; size: Integer): WideString; safecall;
    function WriteFile(const file_: WideString; const content: WideString): Integer; safecall;
    function Stop(id: Integer): Integer; safecall;
    function SetDictMem(index: Integer; addr: Integer; size: Integer): Integer; safecall;
    function GetNetTimeSafe: WideString; safecall;
    function ForceUnBindWindow(hwnd: Integer): Integer; safecall;
    function ReadIniPwd(const section: WideString; const key: WideString; const file_: WideString; 
                        const pwd: WideString): WideString; safecall;
    function WriteIniPwd(const section: WideString; const key: WideString; const v: WideString; 
                         const file_: WideString; const pwd: WideString): Integer; safecall;
    function DecodeFile(const file_: WideString; const pwd: WideString): Integer; safecall;
    function KeyDownChar(const key_str: WideString): Integer; safecall;
    function KeyUpChar(const key_str: WideString): Integer; safecall;
    function KeyPressChar(const key_str: WideString): Integer; safecall;
    function KeyPressStr(const key_str: WideString; delay: Integer): Integer; safecall;
    function EnableKeypadPatch(en: Integer): Integer; safecall;
    function EnableKeypadSync(en: Integer; time_out: Integer): Integer; safecall;
    function EnableMouseSync(en: Integer; time_out: Integer): Integer; safecall;
    function DmGuard(en: Integer; const type_: WideString): Integer; safecall;
    function FaqCaptureFromFile(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                                const file_: WideString; quality: Integer): Integer; safecall;
    function FindIntEx(hwnd: Integer; const addr_range: WideString; int_value_min: Integer; 
                       int_value_max: Integer; type_: Integer; step: Integer; 
                       multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindFloatEx(hwnd: Integer; const addr_range: WideString; float_value_min: Single; 
                         float_value_max: Single; step: Integer; multi_thread: Integer; 
                         mode: Integer): WideString; safecall;
    function FindDoubleEx(hwnd: Integer; const addr_range: WideString; double_value_min: Double; 
                          double_value_max: Double; step: Integer; multi_thread: Integer; 
                          mode: Integer): WideString; safecall;
    function FindStringEx(hwnd: Integer; const addr_range: WideString; 
                          const string_value: WideString; type_: Integer; step: Integer; 
                          multi_thread: Integer; mode: Integer): WideString; safecall;
    function FindDataEx(hwnd: Integer; const addr_range: WideString; const data: WideString; 
                        step: Integer; multi_thread: Integer; mode: Integer): WideString; safecall;
    function EnableRealMouse(en: Integer; mousedelay: Integer; mousestep: Integer): Integer; safecall;
    function EnableRealKeypad(en: Integer): Integer; safecall;
    function SendStringIme(const str: WideString): Integer; safecall;
    function FoobarDrawLine(hwnd: Integer; x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const color: WideString; style: Integer; width: Integer): Integer; safecall;
    function FindStrEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                       const color: WideString; sim: Double): WideString; safecall;
    function IsBind(hwnd: Integer): Integer; safecall;
    function SetDisplayDelay(t: Integer): Integer; safecall;
    function GetDmCount: Integer; safecall;
    function DisableScreenSave: Integer; safecall;
    function DisablePowerSave: Integer; safecall;
    function SetMemoryHwndAsProcessId(en: Integer): Integer; safecall;
    function FindShape(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                       const offset_color: WideString; sim: Double; dir: Integer; 
                       out x: OleVariant; out y: OleVariant): Integer; safecall;
    function FindShapeE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const offset_color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function FindShapeEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                         const offset_color: WideString; sim: Double; dir: Integer): WideString; safecall;
    function FindStrS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                      const color: WideString; sim: Double; out x: OleVariant; out y: OleVariant): WideString; safecall;
    function FindStrExS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                        const color: WideString; sim: Double): WideString; safecall;
    function FindStrFastS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                          const str: WideString; const color: WideString; sim: Double; 
                          out x: OleVariant; out y: OleVariant): WideString; safecall;
    function FindStrFastExS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const str: WideString; const color: WideString; sim: Double): WideString; safecall;
    function FindPicS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                      const pic_name: WideString; const delta_color: WideString; sim: Double; 
                      dir: Integer; out x: OleVariant; out y: OleVariant): WideString; safecall;
    function FindPicExS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const pic_name: WideString; const delta_color: WideString; sim: Double; 
                        dir: Integer): WideString; safecall;
    function ClearDict(index: Integer): Integer; safecall;
    function GetMachineCodeNoMac: WideString; safecall;
    function GetClientRect(hwnd: Integer; out x1: OleVariant; out y1: OleVariant; 
                           out x2: OleVariant; out y2: OleVariant): Integer; safecall;
    function EnableFakeActive(en: Integer): Integer; safecall;
    function GetScreenDataBmp(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                              out data: OleVariant; out size: OleVariant): Integer; safecall;
    function EncodeFile(const file_: WideString; const pwd: WideString): Integer; safecall;
    function GetCursorShapeEx(type_: Integer): WideString; safecall;
    function FaqCancel: Integer; safecall;
    function IntToData(int_value: Integer; type_: Integer): WideString; safecall;
    function FloatToData(float_value: Single): WideString; safecall;
    function DoubleToData(double_value: Double): WideString; safecall;
    function StringToData(const string_value: WideString; type_: Integer): WideString; safecall;
    function SetMemoryFindResultToFile(const file_: WideString): Integer; safecall;
    function EnableBind(en: Integer): Integer; safecall;
    function SetSimMode(mode: Integer): Integer; safecall;
    function LockMouseRect(x1: Integer; y1: Integer; x2: Integer; y2: Integer): Integer; safecall;
    function SendPaste(hwnd: Integer): Integer; safecall;
    function IsDisplayDead(x1: Integer; y1: Integer; x2: Integer; y2: Integer; t: Integer): Integer; safecall;
    function GetKeyState(vk: Integer): Integer; safecall;
    function CopyFile(const src_file: WideString; const dst_file: WideString; over: Integer): Integer; safecall;
    function IsFileExist(const file_: WideString): Integer; safecall;
    function DeleteFile(const file_: WideString): Integer; safecall;
    function MoveFile(const src_file: WideString; const dst_file: WideString): Integer; safecall;
    function CreateFolder(const folder_name: WideString): Integer; safecall;
    function DeleteFolder(const folder_name: WideString): Integer; safecall;
    function GetFileLength(const file_: WideString): Integer; safecall;
    function ReadFile(const file_: WideString): WideString; safecall;
    function WaitKey(key_code: Integer; time_out: Integer): Integer; safecall;
    function DeleteIni(const section: WideString; const key: WideString; const file_: WideString): Integer; safecall;
    function DeleteIniPwd(const section: WideString; const key: WideString; 
                          const file_: WideString; const pwd: WideString): Integer; safecall;
    function EnableSpeedDx(en: Integer): Integer; safecall;
    function EnableIme(en: Integer): Integer; safecall;
    function Reg(const code: WideString; const Ver: WideString): Integer; safecall;
    function SelectFile: WideString; safecall;
    function SelectDirectory: WideString; safecall;
    function LockDisplay(lock: Integer): Integer; safecall;
    function FoobarSetSave(hwnd: Integer; const file_: WideString; en: Integer; 
                           const header: WideString): Integer; safecall;
    function EnumWindowSuper(const spec1: WideString; flag1: Integer; type1: Integer; 
                             const spec2: WideString; flag2: Integer; type2: Integer; sort: Integer): WideString; safecall;
    function DownloadFile(const url: WideString; const save_file: WideString; timeout: Integer): Integer; safecall;
    function EnableKeypadMsg(en: Integer): Integer; safecall;
    function EnableMouseMsg(en: Integer): Integer; safecall;
    function RegNoMac(const code: WideString; const Ver: WideString): Integer; safecall;
    function RegExNoMac(const code: WideString; const Ver: WideString; const ip: WideString): Integer; safecall;
    function SetEnumWindowDelay(delay: Integer): Integer; safecall;
    function FindMulColor(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                          const color: WideString; sim: Double): Integer; safecall;
    function GetDict(index: Integer; font_index: Integer): WideString; safecall;
    function GetBindWindow: Integer; safecall;
    function FoobarStartGif(hwnd: Integer; x: Integer; y: Integer; const pic_name: WideString; 
                            repeat_limit: Integer; delay: Integer): Integer; safecall;
    function FoobarStopGif(hwnd: Integer; x: Integer; y: Integer; const pic_name: WideString): Integer; safecall;
    function FreeProcessMemory(hwnd: Integer): Integer; safecall;
    function ReadFileData(const file_: WideString; start_pos: Integer; end_pos: Integer): WideString; safecall;
    function VirtualAllocEx(hwnd: Integer; addr: Integer; size: Integer; type_: Integer): Integer; safecall;
    function VirtualFreeEx(hwnd: Integer; addr: Integer): Integer; safecall;
    function GetCommandLine(hwnd: Integer): WideString; safecall;
    function TerminateProcess(pid: Integer): Integer; safecall;
    function GetNetTimeByIp(const ip: WideString): WideString; safecall;
    function EnumProcess(const name: WideString): WideString; safecall;
    function GetProcessInfo(pid: Integer): WideString; safecall;
    function ReadIntAddr(hwnd: Integer; addr: Integer; type_: Integer): Integer; safecall;
    function ReadDataAddr(hwnd: Integer; addr: Integer; len: Integer): WideString; safecall;
    function ReadDoubleAddr(hwnd: Integer; addr: Integer): Double; safecall;
    function ReadFloatAddr(hwnd: Integer; addr: Integer): Single; safecall;
    function ReadStringAddr(hwnd: Integer; addr: Integer; type_: Integer; len: Integer): WideString; safecall;
    function WriteDataAddr(hwnd: Integer; addr: Integer; const data: WideString): Integer; safecall;
    function WriteDoubleAddr(hwnd: Integer; addr: Integer; v: Double): Integer; safecall;
    function WriteFloatAddr(hwnd: Integer; addr: Integer; v: Single): Integer; safecall;
    function WriteIntAddr(hwnd: Integer; addr: Integer; type_: Integer; v: Integer): Integer; safecall;
    function WriteStringAddr(hwnd: Integer; addr: Integer; type_: Integer; const v: WideString): Integer; safecall;
    function Delays(min_s: Integer; max_s: Integer): Integer; safecall;
    function FindColorBlock(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const color: WideString; sim: Double; count: Integer; width: Integer; 
                            height: Integer; out x: OleVariant; out y: OleVariant): Integer; safecall;
    function FindColorBlockEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                              const color: WideString; sim: Double; count: Integer; width: Integer; 
                              height: Integer): WideString; safecall;
    function OpenProcess(pid: Integer): Integer; safecall;
    function EnumIniSection(const file_: WideString): WideString; safecall;
    function EnumIniSectionPwd(const file_: WideString; const pwd: WideString): WideString; safecall;
    function EnumIniKey(const section: WideString; const file_: WideString): WideString; safecall;
    function EnumIniKeyPwd(const section: WideString; const file_: WideString; const pwd: WideString): WideString; safecall;
    function SwitchBindWindow(hwnd: Integer): Integer; safecall;
    function InitCri: Integer; safecall;
    function SendStringIme2(hwnd: Integer; const str: WideString; mode: Integer): Integer; safecall;
    function EnumWindowByProcessId(pid: Integer; const title: WideString; 
                                   const class_name: WideString; filter: Integer): WideString; safecall;
    function GetDisplayInfo: WideString; safecall;
    function EnableFontSmooth: Integer; safecall;
    function OcrExOne(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                      sim: Double): WideString; safecall;
    function SetAero(en: Integer): Integer; safecall;
    function FoobarSetTrans(hwnd: Integer; trans: Integer; const color: WideString; sim: Double): Integer; safecall;
    function EnablePicCache(en: Integer): Integer; safecall;
    function GetInfo(const cmd: WideString; const param: WideString): WideString; safecall;
    function FaqIsPosted: Integer; safecall;
    function LoadPicByte(addr: Integer; size: Integer; const name: WideString): Integer; safecall;
    function MiddleDown: Integer; safecall;
    function MiddleUp: Integer; safecall;
  end;

// *********************************************************************//
// DispIntf:  IdmsoftDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {F3F54BC2-D6D1-4A85-B943-16287ECEA64C}
// *********************************************************************//
  IdmsoftDisp = dispinterface
    ['{F3F54BC2-D6D1-4A85-B943-16287ECEA64C}']
    function Ver: WideString; dispid 1;
    function SetPath(const path: WideString): Integer; dispid 2;
    function Ocr(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                 sim: Double): WideString; dispid 3;
    function FindStr(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                     const color: WideString; sim: Double; out x: OleVariant; out y: OleVariant): Integer; dispid 4;
    function GetResultCount(const str: WideString): Integer; dispid 5;
    function GetResultPos(const str: WideString; index: Integer; out x: OleVariant; 
                          out y: OleVariant): Integer; dispid 6;
    function StrStr(const s: WideString; const str: WideString): Integer; dispid 7;
    function SendCommand(const cmd: WideString): Integer; dispid 8;
    function UseDict(index: Integer): Integer; dispid 9;
    function GetBasePath: WideString; dispid 10;
    function SetDictPwd(const pwd: WideString): Integer; dispid 11;
    function OcrInFile(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                       const pic_name: WideString; const color: WideString; sim: Double): WideString; dispid 12;
    function Capture(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const file_: WideString): Integer; dispid 13;
    function KeyPress(vk: Integer): Integer; dispid 14;
    function KeyDown(vk: Integer): Integer; dispid 15;
    function KeyUp(vk: Integer): Integer; dispid 16;
    function LeftClick: Integer; dispid 17;
    function RightClick: Integer; dispid 18;
    function MiddleClick: Integer; dispid 19;
    function LeftDoubleClick: Integer; dispid 20;
    function LeftDown: Integer; dispid 21;
    function LeftUp: Integer; dispid 22;
    function RightDown: Integer; dispid 23;
    function RightUp: Integer; dispid 24;
    function MoveTo(x: Integer; y: Integer): Integer; dispid 25;
    function MoveR(rx: Integer; ry: Integer): Integer; dispid 26;
    function GetColor(x: Integer; y: Integer): WideString; dispid 27;
    function GetColorBGR(x: Integer; y: Integer): WideString; dispid 28;
    function RGB2BGR(const rgb_color: WideString): WideString; dispid 29;
    function BGR2RGB(const bgr_color: WideString): WideString; dispid 30;
    function UnBindWindow: Integer; dispid 31;
    function CmpColor(x: Integer; y: Integer; const color: WideString; sim: Double): Integer; dispid 32;
    function ClientToScreen(hwnd: Integer; var x: OleVariant; var y: OleVariant): Integer; dispid 33;
    function ScreenToClient(hwnd: Integer; var x: OleVariant; var y: OleVariant): Integer; dispid 34;
    function ShowScrMsg(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const msg: WideString; 
                        const color: WideString): Integer; dispid 35;
    function SetMinRowGap(row_gap: Integer): Integer; dispid 36;
    function SetMinColGap(col_gap: Integer): Integer; dispid 37;
    function FindColor(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                       sim: Double; dir: Integer; out x: OleVariant; out y: OleVariant): Integer; dispid 38;
    function FindColorEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                         const color: WideString; sim: Double; dir: Integer): WideString; dispid 39;
    function SetWordLineHeight(line_height: Integer): Integer; dispid 40;
    function SetWordGap(word_gap: Integer): Integer; dispid 41;
    function SetRowGapNoDict(row_gap: Integer): Integer; dispid 42;
    function SetColGapNoDict(col_gap: Integer): Integer; dispid 43;
    function SetWordLineHeightNoDict(line_height: Integer): Integer; dispid 44;
    function SetWordGapNoDict(word_gap: Integer): Integer; dispid 45;
    function GetWordResultCount(const str: WideString): Integer; dispid 46;
    function GetWordResultPos(const str: WideString; index: Integer; out x: OleVariant; 
                              out y: OleVariant): Integer; dispid 47;
    function GetWordResultStr(const str: WideString; index: Integer): WideString; dispid 48;
    function GetWords(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                      sim: Double): WideString; dispid 49;
    function GetWordsNoDict(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const color: WideString): WideString; dispid 50;
    function SetShowErrorMsg(show: Integer): Integer; dispid 51;
    function GetClientSize(hwnd: Integer; out width: OleVariant; out height: OleVariant): Integer; dispid 52;
    function MoveWindow(hwnd: Integer; x: Integer; y: Integer): Integer; dispid 53;
    function GetColorHSV(x: Integer; y: Integer): WideString; dispid 54;
    function GetAveRGB(x1: Integer; y1: Integer; x2: Integer; y2: Integer): WideString; dispid 55;
    function GetAveHSV(x1: Integer; y1: Integer; x2: Integer; y2: Integer): WideString; dispid 56;
    function GetForegroundWindow: Integer; dispid 57;
    function GetForegroundFocus: Integer; dispid 58;
    function GetMousePointWindow: Integer; dispid 59;
    function GetPointWindow(x: Integer; y: Integer): Integer; dispid 60;
    function EnumWindow(parent: Integer; const title: WideString; const class_name: WideString; 
                        filter: Integer): WideString; dispid 61;
    function GetWindowState(hwnd: Integer; flag: Integer): Integer; dispid 62;
    function GetWindow(hwnd: Integer; flag: Integer): Integer; dispid 63;
    function GetSpecialWindow(flag: Integer): Integer; dispid 64;
    function SetWindowText(hwnd: Integer; const text: WideString): Integer; dispid 65;
    function SetWindowSize(hwnd: Integer; width: Integer; height: Integer): Integer; dispid 66;
    function GetWindowRect(hwnd: Integer; out x1: OleVariant; out y1: OleVariant; 
                           out x2: OleVariant; out y2: OleVariant): Integer; dispid 67;
    function GetWindowTitle(hwnd: Integer): WideString; dispid 68;
    function GetWindowClass(hwnd: Integer): WideString; dispid 69;
    function SetWindowState(hwnd: Integer; flag: Integer): Integer; dispid 70;
    function CreateFoobarRect(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer): Integer; dispid 71;
    function CreateFoobarRoundRect(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer; 
                                   rw: Integer; rh: Integer): Integer; dispid 72;
    function CreateFoobarEllipse(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer): Integer; dispid 73;
    function CreateFoobarCustom(hwnd: Integer; x: Integer; y: Integer; const pic: WideString; 
                                const trans_color: WideString; sim: Double): Integer; dispid 74;
    function FoobarFillRect(hwnd: Integer; x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const color: WideString): Integer; dispid 75;
    function FoobarDrawText(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer; 
                            const text: WideString; const color: WideString; align: Integer): Integer; dispid 76;
    function FoobarDrawPic(hwnd: Integer; x: Integer; y: Integer; const pic: WideString; 
                           const trans_color: WideString): Integer; dispid 77;
    function FoobarUpdate(hwnd: Integer): Integer; dispid 78;
    function FoobarLock(hwnd: Integer): Integer; dispid 79;
    function FoobarUnlock(hwnd: Integer): Integer; dispid 80;
    function FoobarSetFont(hwnd: Integer; const font_name: WideString; size: Integer; flag: Integer): Integer; dispid 81;
    function FoobarTextRect(hwnd: Integer; x: Integer; y: Integer; w: Integer; h: Integer): Integer; dispid 82;
    function FoobarPrintText(hwnd: Integer; const text: WideString; const color: WideString): Integer; dispid 83;
    function FoobarClearText(hwnd: Integer): Integer; dispid 84;
    function FoobarTextLineGap(hwnd: Integer; gap: Integer): Integer; dispid 85;
    function Play(const file_: WideString): Integer; dispid 86;
    function FaqCapture(x1: Integer; y1: Integer; x2: Integer; y2: Integer; quality: Integer; 
                        delay: Integer; time: Integer): Integer; dispid 87;
    function FaqRelease(handle: Integer): Integer; dispid 88;
    function FaqSend(const server: WideString; handle: Integer; request_type: Integer; 
                     time_out: Integer): WideString; dispid 89;
    function Beep(fre: Integer; delay: Integer): Integer; dispid 90;
    function FoobarClose(hwnd: Integer): Integer; dispid 91;
    function MoveDD(dx: Integer; dy: Integer): Integer; dispid 92;
    function FaqGetSize(handle: Integer): Integer; dispid 93;
    function LoadPic(const pic_name: WideString): Integer; dispid 94;
    function FreePic(const pic_name: WideString): Integer; dispid 95;
    function GetScreenData(x1: Integer; y1: Integer; x2: Integer; y2: Integer): Integer; dispid 96;
    function FreeScreenData(handle: Integer): Integer; dispid 97;
    function WheelUp: Integer; dispid 98;
    function WheelDown: Integer; dispid 99;
    function SetMouseDelay(const type_: WideString; delay: Integer): Integer; dispid 100;
    function SetKeypadDelay(const type_: WideString; delay: Integer): Integer; dispid 101;
    function GetEnv(index: Integer; const name: WideString): WideString; dispid 102;
    function SetEnv(index: Integer; const name: WideString; const value: WideString): Integer; dispid 103;
    function SendString(hwnd: Integer; const str: WideString): Integer; dispid 104;
    function DelEnv(index: Integer; const name: WideString): Integer; dispid 105;
    function GetPath: WideString; dispid 106;
    function SetDict(index: Integer; const dict_name: WideString): Integer; dispid 107;
    function FindPic(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                     const pic_name: WideString; const delta_color: WideString; sim: Double; 
                     dir: Integer; out x: OleVariant; out y: OleVariant): Integer; dispid 108;
    function FindPicEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                       const pic_name: WideString; const delta_color: WideString; sim: Double; 
                       dir: Integer): WideString; dispid 109;
    function SetClientSize(hwnd: Integer; width: Integer; height: Integer): Integer; dispid 110;
    function ReadInt(hwnd: Integer; const addr: WideString; type_: Integer): Integer; dispid 111;
    function ReadFloat(hwnd: Integer; const addr: WideString): Single; dispid 112;
    function ReadDouble(hwnd: Integer; const addr: WideString): Double; dispid 113;
    function FindInt(hwnd: Integer; const addr_range: WideString; int_value_min: Integer; 
                     int_value_max: Integer; type_: Integer): WideString; dispid 114;
    function FindFloat(hwnd: Integer; const addr_range: WideString; float_value_min: Single; 
                       float_value_max: Single): WideString; dispid 115;
    function FindDouble(hwnd: Integer; const addr_range: WideString; double_value_min: Double; 
                        double_value_max: Double): WideString; dispid 116;
    function FindString(hwnd: Integer; const addr_range: WideString; 
                        const string_value: WideString; type_: Integer): WideString; dispid 117;
    function GetModuleBaseAddr(hwnd: Integer; const module_name: WideString): Integer; dispid 118;
    function MoveToEx(x: Integer; y: Integer; w: Integer; h: Integer): WideString; dispid 119;
    function MatchPicName(const pic_name: WideString): WideString; dispid 120;
    function AddDict(index: Integer; const dict_info: WideString): Integer; dispid 121;
    function EnterCri: Integer; dispid 122;
    function LeaveCri: Integer; dispid 123;
    function WriteInt(hwnd: Integer; const addr: WideString; type_: Integer; v: Integer): Integer; dispid 124;
    function WriteFloat(hwnd: Integer; const addr: WideString; v: Single): Integer; dispid 125;
    function WriteDouble(hwnd: Integer; const addr: WideString; v: Double): Integer; dispid 126;
    function WriteString(hwnd: Integer; const addr: WideString; type_: Integer; const v: WideString): Integer; dispid 127;
    function AsmAdd(const asm_ins: WideString): Integer; dispid 128;
    function AsmClear: Integer; dispid 129;
    function AsmCall(hwnd: Integer; mode: Integer): Integer; dispid 130;
    function FindMultiColor(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const first_color: WideString; const offset_color: WideString; 
                            sim: Double; dir: Integer; out x: OleVariant; out y: OleVariant): Integer; dispid 131;
    function FindMultiColorEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                              const first_color: WideString; const offset_color: WideString; 
                              sim: Double; dir: Integer): WideString; dispid 132;
    function AsmCode(base_addr: Integer): WideString; dispid 133;
    function Assemble(const asm_code: WideString; base_addr: Integer; is_upper: Integer): WideString; dispid 134;
    function SetWindowTransparent(hwnd: Integer; v: Integer): Integer; dispid 135;
    function ReadData(hwnd: Integer; const addr: WideString; len: Integer): WideString; dispid 136;
    function WriteData(hwnd: Integer; const addr: WideString; const data: WideString): Integer; dispid 137;
    function FindData(hwnd: Integer; const addr_range: WideString; const data: WideString): WideString; dispid 138;
    function SetPicPwd(const pwd: WideString): Integer; dispid 139;
    function Log(const info: WideString): Integer; dispid 140;
    function FindStrE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                      const color: WideString; sim: Double): WideString; dispid 141;
    function FindColorE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const color: WideString; sim: Double; dir: Integer): WideString; dispid 142;
    function FindPicE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                      const pic_name: WideString; const delta_color: WideString; sim: Double; 
                      dir: Integer): WideString; dispid 143;
    function FindMultiColorE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                             const first_color: WideString; const offset_color: WideString; 
                             sim: Double; dir: Integer): WideString; dispid 144;
    function SetExactOcr(exact_ocr: Integer): Integer; dispid 145;
    function ReadString(hwnd: Integer; const addr: WideString; type_: Integer; len: Integer): WideString; dispid 146;
    function FoobarTextPrintDir(hwnd: Integer; dir: Integer): Integer; dispid 147;
    function OcrEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                   sim: Double): WideString; dispid 148;
    function SetDisplayInput(const mode: WideString): Integer; dispid 149;
    function GetTime: Integer; dispid 150;
    function GetScreenWidth: Integer; dispid 151;
    function GetScreenHeight: Integer; dispid 152;
    function BindWindowEx(hwnd: Integer; const display: WideString; const mouse: WideString; 
                          const keypad: WideString; const public_desc: WideString; mode: Integer): Integer; dispid 153;
    function GetDiskSerial: WideString; dispid 154;
    function Md5(const str: WideString): WideString; dispid 155;
    function GetMac: WideString; dispid 156;
    function ActiveInputMethod(hwnd: Integer; const id: WideString): Integer; dispid 157;
    function CheckInputMethod(hwnd: Integer; const id: WideString): Integer; dispid 158;
    function FindInputMethod(const id: WideString): Integer; dispid 159;
    function GetCursorPos(out x: OleVariant; out y: OleVariant): Integer; dispid 160;
    function BindWindow(hwnd: Integer; const display: WideString; const mouse: WideString; 
                        const keypad: WideString; mode: Integer): Integer; dispid 161;
    function FindWindow(const class_name: WideString; const title_name: WideString): Integer; dispid 162;
    function GetScreenDepth: Integer; dispid 163;
    function SetScreen(width: Integer; height: Integer; depth: Integer): Integer; dispid 164;
    function ExitOs(type_: Integer): Integer; dispid 165;
    function GetDir(type_: Integer): WideString; dispid 166;
    function GetOsType: Integer; dispid 167;
    function FindWindowEx(parent: Integer; const class_name: WideString; 
                          const title_name: WideString): Integer; dispid 168;
    function SetExportDict(index: Integer; const dict_name: WideString): Integer; dispid 169;
    function GetCursorShape: WideString; dispid 170;
    function DownCpu(rate: Integer): Integer; dispid 171;
    function GetCursorSpot: WideString; dispid 172;
    function SendString2(hwnd: Integer; const str: WideString): Integer; dispid 173;
    function FaqPost(const server: WideString; handle: Integer; request_type: Integer; 
                     time_out: Integer): Integer; dispid 174;
    function FaqFetch: WideString; dispid 175;
    function FetchWord(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                       const word: WideString): WideString; dispid 176;
    function CaptureJpg(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const file_: WideString; quality: Integer): Integer; dispid 177;
    function FindStrWithFont(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                             const str: WideString; const color: WideString; sim: Double; 
                             const font_name: WideString; font_size: Integer; flag: Integer; 
                             out x: OleVariant; out y: OleVariant): Integer; dispid 178;
    function FindStrWithFontE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                              const str: WideString; const color: WideString; sim: Double; 
                              const font_name: WideString; font_size: Integer; flag: Integer): WideString; dispid 179;
    function FindStrWithFontEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                               const str: WideString; const color: WideString; sim: Double; 
                               const font_name: WideString; font_size: Integer; flag: Integer): WideString; dispid 180;
    function GetDictInfo(const str: WideString; const font_name: WideString; font_size: Integer; 
                         flag: Integer): WideString; dispid 181;
    function SaveDict(index: Integer; const file_: WideString): Integer; dispid 182;
    function GetWindowProcessId(hwnd: Integer): Integer; dispid 183;
    function GetWindowProcessPath(hwnd: Integer): WideString; dispid 184;
    function LockInput(lock: Integer): Integer; dispid 185;
    function GetPicSize(const pic_name: WideString): WideString; dispid 186;
    function GetID: Integer; dispid 187;
    function CapturePng(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const file_: WideString): Integer; dispid 188;
    function CaptureGif(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const file_: WideString; delay: Integer; time: Integer): Integer; dispid 189;
    function ImageToBmp(const pic_name: WideString; const bmp_name: WideString): Integer; dispid 190;
    function FindStrFast(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                         const color: WideString; sim: Double; out x: OleVariant; out y: OleVariant): Integer; dispid 191;
    function FindStrFastEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                           const str: WideString; const color: WideString; sim: Double): WideString; dispid 192;
    function FindStrFastE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                          const str: WideString; const color: WideString; sim: Double): WideString; dispid 193;
    function EnableDisplayDebug(enable_debug: Integer): Integer; dispid 194;
    function CapturePre(const file_: WideString): Integer; dispid 195;
    function RegEx(const code: WideString; const Ver: WideString; const ip: WideString): Integer; dispid 196;
    function GetMachineCode: WideString; dispid 197;
    function SetClipboard(const data: WideString): Integer; dispid 198;
    function GetClipboard: WideString; dispid 199;
    function GetNowDict: Integer; dispid 200;
    function Is64Bit: Integer; dispid 201;
    function GetColorNum(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                         const color: WideString; sim: Double): Integer; dispid 202;
    function EnumWindowByProcess(const process_name: WideString; const title: WideString; 
                                 const class_name: WideString; filter: Integer): WideString; dispid 203;
    function GetDictCount(index: Integer): Integer; dispid 204;
    function GetLastError: Integer; dispid 205;
    function GetNetTime: WideString; dispid 206;
    function EnableGetColorByCapture(en: Integer): Integer; dispid 207;
    function CheckUAC: Integer; dispid 208;
    function SetUAC(uac: Integer): Integer; dispid 209;
    function DisableFontSmooth: Integer; dispid 210;
    function CheckFontSmooth: Integer; dispid 211;
    function SetDisplayAcceler(level: Integer): Integer; dispid 212;
    function FindWindowByProcess(const process_name: WideString; const class_name: WideString; 
                                 const title_name: WideString): Integer; dispid 213;
    function FindWindowByProcessId(process_id: Integer; const class_name: WideString; 
                                   const title_name: WideString): Integer; dispid 214;
    function ReadIni(const section: WideString; const key: WideString; const file_: WideString): WideString; dispid 215;
    function WriteIni(const section: WideString; const key: WideString; const v: WideString; 
                      const file_: WideString): Integer; dispid 216;
    function RunApp(const path: WideString; mode: Integer): Integer; dispid 217;
    function delay(mis: Integer): Integer; dispid 218;
    function FindWindowSuper(const spec1: WideString; flag1: Integer; type1: Integer; 
                             const spec2: WideString; flag2: Integer; type2: Integer): Integer; dispid 219;
    function ExcludePos(const all_pos: WideString; type_: Integer; x1: Integer; y1: Integer; 
                        x2: Integer; y2: Integer): WideString; dispid 220;
    function FindNearestPos(const all_pos: WideString; type_: Integer; x: Integer; y: Integer): WideString; dispid 221;
    function SortPosDistance(const all_pos: WideString; type_: Integer; x: Integer; y: Integer): WideString; dispid 222;
    function FindPicMem(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const pic_info: WideString; const delta_color: WideString; sim: Double; 
                        dir: Integer; out x: OleVariant; out y: OleVariant): Integer; dispid 223;
    function FindPicMemEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                          const pic_info: WideString; const delta_color: WideString; sim: Double; 
                          dir: Integer): WideString; dispid 224;
    function FindPicMemE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                         const pic_info: WideString; const delta_color: WideString; sim: Double; 
                         dir: Integer): WideString; dispid 225;
    function AppendPicAddr(const pic_info: WideString; addr: Integer; size: Integer): WideString; dispid 226;
    function WriteFile(const file_: WideString; const content: WideString): Integer; dispid 227;
    function Stop(id: Integer): Integer; dispid 228;
    function SetDictMem(index: Integer; addr: Integer; size: Integer): Integer; dispid 229;
    function GetNetTimeSafe: WideString; dispid 230;
    function ForceUnBindWindow(hwnd: Integer): Integer; dispid 231;
    function ReadIniPwd(const section: WideString; const key: WideString; const file_: WideString; 
                        const pwd: WideString): WideString; dispid 232;
    function WriteIniPwd(const section: WideString; const key: WideString; const v: WideString; 
                         const file_: WideString; const pwd: WideString): Integer; dispid 233;
    function DecodeFile(const file_: WideString; const pwd: WideString): Integer; dispid 234;
    function KeyDownChar(const key_str: WideString): Integer; dispid 235;
    function KeyUpChar(const key_str: WideString): Integer; dispid 236;
    function KeyPressChar(const key_str: WideString): Integer; dispid 237;
    function KeyPressStr(const key_str: WideString; delay: Integer): Integer; dispid 238;
    function EnableKeypadPatch(en: Integer): Integer; dispid 239;
    function EnableKeypadSync(en: Integer; time_out: Integer): Integer; dispid 240;
    function EnableMouseSync(en: Integer; time_out: Integer): Integer; dispid 241;
    function DmGuard(en: Integer; const type_: WideString): Integer; dispid 242;
    function FaqCaptureFromFile(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                                const file_: WideString; quality: Integer): Integer; dispid 243;
    function FindIntEx(hwnd: Integer; const addr_range: WideString; int_value_min: Integer; 
                       int_value_max: Integer; type_: Integer; step: Integer; 
                       multi_thread: Integer; mode: Integer): WideString; dispid 244;
    function FindFloatEx(hwnd: Integer; const addr_range: WideString; float_value_min: Single; 
                         float_value_max: Single; step: Integer; multi_thread: Integer; 
                         mode: Integer): WideString; dispid 245;
    function FindDoubleEx(hwnd: Integer; const addr_range: WideString; double_value_min: Double; 
                          double_value_max: Double; step: Integer; multi_thread: Integer; 
                          mode: Integer): WideString; dispid 246;
    function FindStringEx(hwnd: Integer; const addr_range: WideString; 
                          const string_value: WideString; type_: Integer; step: Integer; 
                          multi_thread: Integer; mode: Integer): WideString; dispid 247;
    function FindDataEx(hwnd: Integer; const addr_range: WideString; const data: WideString; 
                        step: Integer; multi_thread: Integer; mode: Integer): WideString; dispid 248;
    function EnableRealMouse(en: Integer; mousedelay: Integer; mousestep: Integer): Integer; dispid 249;
    function EnableRealKeypad(en: Integer): Integer; dispid 250;
    function SendStringIme(const str: WideString): Integer; dispid 251;
    function FoobarDrawLine(hwnd: Integer; x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const color: WideString; style: Integer; width: Integer): Integer; dispid 252;
    function FindStrEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                       const color: WideString; sim: Double): WideString; dispid 253;
    function IsBind(hwnd: Integer): Integer; dispid 254;
    function SetDisplayDelay(t: Integer): Integer; dispid 255;
    function GetDmCount: Integer; dispid 256;
    function DisableScreenSave: Integer; dispid 257;
    function DisablePowerSave: Integer; dispid 258;
    function SetMemoryHwndAsProcessId(en: Integer): Integer; dispid 259;
    function FindShape(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                       const offset_color: WideString; sim: Double; dir: Integer; 
                       out x: OleVariant; out y: OleVariant): Integer; dispid 260;
    function FindShapeE(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const offset_color: WideString; sim: Double; dir: Integer): WideString; dispid 261;
    function FindShapeEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                         const offset_color: WideString; sim: Double; dir: Integer): WideString; dispid 262;
    function FindStrS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                      const color: WideString; sim: Double; out x: OleVariant; out y: OleVariant): WideString; dispid 263;
    function FindStrExS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const str: WideString; 
                        const color: WideString; sim: Double): WideString; dispid 264;
    function FindStrFastS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                          const str: WideString; const color: WideString; sim: Double; 
                          out x: OleVariant; out y: OleVariant): WideString; dispid 265;
    function FindStrFastExS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const str: WideString; const color: WideString; sim: Double): WideString; dispid 266;
    function FindPicS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                      const pic_name: WideString; const delta_color: WideString; sim: Double; 
                      dir: Integer; out x: OleVariant; out y: OleVariant): WideString; dispid 267;
    function FindPicExS(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                        const pic_name: WideString; const delta_color: WideString; sim: Double; 
                        dir: Integer): WideString; dispid 268;
    function ClearDict(index: Integer): Integer; dispid 269;
    function GetMachineCodeNoMac: WideString; dispid 270;
    function GetClientRect(hwnd: Integer; out x1: OleVariant; out y1: OleVariant; 
                           out x2: OleVariant; out y2: OleVariant): Integer; dispid 271;
    function EnableFakeActive(en: Integer): Integer; dispid 272;
    function GetScreenDataBmp(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                              out data: OleVariant; out size: OleVariant): Integer; dispid 273;
    function EncodeFile(const file_: WideString; const pwd: WideString): Integer; dispid 274;
    function GetCursorShapeEx(type_: Integer): WideString; dispid 275;
    function FaqCancel: Integer; dispid 276;
    function IntToData(int_value: Integer; type_: Integer): WideString; dispid 277;
    function FloatToData(float_value: Single): WideString; dispid 278;
    function DoubleToData(double_value: Double): WideString; dispid 279;
    function StringToData(const string_value: WideString; type_: Integer): WideString; dispid 280;
    function SetMemoryFindResultToFile(const file_: WideString): Integer; dispid 281;
    function EnableBind(en: Integer): Integer; dispid 282;
    function SetSimMode(mode: Integer): Integer; dispid 283;
    function LockMouseRect(x1: Integer; y1: Integer; x2: Integer; y2: Integer): Integer; dispid 284;
    function SendPaste(hwnd: Integer): Integer; dispid 285;
    function IsDisplayDead(x1: Integer; y1: Integer; x2: Integer; y2: Integer; t: Integer): Integer; dispid 286;
    function GetKeyState(vk: Integer): Integer; dispid 287;
    function CopyFile(const src_file: WideString; const dst_file: WideString; over: Integer): Integer; dispid 288;
    function IsFileExist(const file_: WideString): Integer; dispid 289;
    function DeleteFile(const file_: WideString): Integer; dispid 290;
    function MoveFile(const src_file: WideString; const dst_file: WideString): Integer; dispid 291;
    function CreateFolder(const folder_name: WideString): Integer; dispid 292;
    function DeleteFolder(const folder_name: WideString): Integer; dispid 293;
    function GetFileLength(const file_: WideString): Integer; dispid 294;
    function ReadFile(const file_: WideString): WideString; dispid 295;
    function WaitKey(key_code: Integer; time_out: Integer): Integer; dispid 296;
    function DeleteIni(const section: WideString; const key: WideString; const file_: WideString): Integer; dispid 297;
    function DeleteIniPwd(const section: WideString; const key: WideString; 
                          const file_: WideString; const pwd: WideString): Integer; dispid 298;
    function EnableSpeedDx(en: Integer): Integer; dispid 299;
    function EnableIme(en: Integer): Integer; dispid 300;
    function Reg(const code: WideString; const Ver: WideString): Integer; dispid 301;
    function SelectFile: WideString; dispid 302;
    function SelectDirectory: WideString; dispid 303;
    function LockDisplay(lock: Integer): Integer; dispid 304;
    function FoobarSetSave(hwnd: Integer; const file_: WideString; en: Integer; 
                           const header: WideString): Integer; dispid 305;
    function EnumWindowSuper(const spec1: WideString; flag1: Integer; type1: Integer; 
                             const spec2: WideString; flag2: Integer; type2: Integer; sort: Integer): WideString; dispid 306;
    function DownloadFile(const url: WideString; const save_file: WideString; timeout: Integer): Integer; dispid 307;
    function EnableKeypadMsg(en: Integer): Integer; dispid 308;
    function EnableMouseMsg(en: Integer): Integer; dispid 309;
    function RegNoMac(const code: WideString; const Ver: WideString): Integer; dispid 310;
    function RegExNoMac(const code: WideString; const Ver: WideString; const ip: WideString): Integer; dispid 311;
    function SetEnumWindowDelay(delay: Integer): Integer; dispid 312;
    function FindMulColor(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                          const color: WideString; sim: Double): Integer; dispid 313;
    function GetDict(index: Integer; font_index: Integer): WideString; dispid 314;
    function GetBindWindow: Integer; dispid 315;
    function FoobarStartGif(hwnd: Integer; x: Integer; y: Integer; const pic_name: WideString; 
                            repeat_limit: Integer; delay: Integer): Integer; dispid 316;
    function FoobarStopGif(hwnd: Integer; x: Integer; y: Integer; const pic_name: WideString): Integer; dispid 317;
    function FreeProcessMemory(hwnd: Integer): Integer; dispid 318;
    function ReadFileData(const file_: WideString; start_pos: Integer; end_pos: Integer): WideString; dispid 319;
    function VirtualAllocEx(hwnd: Integer; addr: Integer; size: Integer; type_: Integer): Integer; dispid 320;
    function VirtualFreeEx(hwnd: Integer; addr: Integer): Integer; dispid 321;
    function GetCommandLine(hwnd: Integer): WideString; dispid 322;
    function TerminateProcess(pid: Integer): Integer; dispid 323;
    function GetNetTimeByIp(const ip: WideString): WideString; dispid 324;
    function EnumProcess(const name: WideString): WideString; dispid 325;
    function GetProcessInfo(pid: Integer): WideString; dispid 326;
    function ReadIntAddr(hwnd: Integer; addr: Integer; type_: Integer): Integer; dispid 327;
    function ReadDataAddr(hwnd: Integer; addr: Integer; len: Integer): WideString; dispid 328;
    function ReadDoubleAddr(hwnd: Integer; addr: Integer): Double; dispid 329;
    function ReadFloatAddr(hwnd: Integer; addr: Integer): Single; dispid 330;
    function ReadStringAddr(hwnd: Integer; addr: Integer; type_: Integer; len: Integer): WideString; dispid 331;
    function WriteDataAddr(hwnd: Integer; addr: Integer; const data: WideString): Integer; dispid 332;
    function WriteDoubleAddr(hwnd: Integer; addr: Integer; v: Double): Integer; dispid 333;
    function WriteFloatAddr(hwnd: Integer; addr: Integer; v: Single): Integer; dispid 334;
    function WriteIntAddr(hwnd: Integer; addr: Integer; type_: Integer; v: Integer): Integer; dispid 335;
    function WriteStringAddr(hwnd: Integer; addr: Integer; type_: Integer; const v: WideString): Integer; dispid 336;
    function Delays(min_s: Integer; max_s: Integer): Integer; dispid 337;
    function FindColorBlock(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                            const color: WideString; sim: Double; count: Integer; width: Integer; 
                            height: Integer; out x: OleVariant; out y: OleVariant): Integer; dispid 338;
    function FindColorBlockEx(x1: Integer; y1: Integer; x2: Integer; y2: Integer; 
                              const color: WideString; sim: Double; count: Integer; width: Integer; 
                              height: Integer): WideString; dispid 339;
    function OpenProcess(pid: Integer): Integer; dispid 340;
    function EnumIniSection(const file_: WideString): WideString; dispid 341;
    function EnumIniSectionPwd(const file_: WideString; const pwd: WideString): WideString; dispid 342;
    function EnumIniKey(const section: WideString; const file_: WideString): WideString; dispid 343;
    function EnumIniKeyPwd(const section: WideString; const file_: WideString; const pwd: WideString): WideString; dispid 344;
    function SwitchBindWindow(hwnd: Integer): Integer; dispid 345;
    function InitCri: Integer; dispid 346;
    function SendStringIme2(hwnd: Integer; const str: WideString; mode: Integer): Integer; dispid 347;
    function EnumWindowByProcessId(pid: Integer; const title: WideString; 
                                   const class_name: WideString; filter: Integer): WideString; dispid 348;
    function GetDisplayInfo: WideString; dispid 349;
    function EnableFontSmooth: Integer; dispid 350;
    function OcrExOne(x1: Integer; y1: Integer; x2: Integer; y2: Integer; const color: WideString; 
                      sim: Double): WideString; dispid 351;
    function SetAero(en: Integer): Integer; dispid 352;
    function FoobarSetTrans(hwnd: Integer; trans: Integer; const color: WideString; sim: Double): Integer; dispid 353;
    function EnablePicCache(en: Integer): Integer; dispid 354;
    function GetInfo(const cmd: WideString; const param: WideString): WideString; dispid 355;
    function FaqIsPosted: Integer; dispid 356;
    function LoadPicByte(addr: Integer; size: Integer; const name: WideString): Integer; dispid 357;
    function MiddleDown: Integer; dispid 358;
    function MiddleUp: Integer; dispid 359;
  end;

// *********************************************************************//
// The Class Codmsoft provides a Create and CreateRemote method to          
// create instances of the default interface Idmsoft exposed by              
// the CoClass dmsoft. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  Codmsoft = class
    class function Create: Idmsoft;
    class function CreateRemote(const MachineName: string): Idmsoft;
  end;

implementation

uses System.Win.ComObj;

class function Codmsoft.Create: Idmsoft;
begin
  Result := CreateComObject(CLASS_dmsoft) as Idmsoft;
end;

class function Codmsoft.CreateRemote(const MachineName: string): Idmsoft;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_dmsoft) as Idmsoft;
end;

end.
