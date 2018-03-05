unit ManSoy.MsgBox;

interface

uses
  Winapi.Windows, System.SysUtils;

function InfoMsg(hWnd: HWND; const Format: string; const Args: array of const): Integer;
function WarnMsg(hWnd: HWND; const Format: string; const Args: array of const): Integer;
function ErrMsg(hWnd: HWND; const Format: string; const Args: array of const): Integer;
function AskMsg(hWnd: HWND; const Format: string; const Args: array of const): Integer;

implementation

function InfoMsg(hWnd: HWND; const Format: string; const Args: array of const): Integer;
var
  sMsg: string;
begin
  sMsg := System.SysUtils.Format(Format, Args, FormatSettings);
  Result := MessageBox(hWnd, PWideChar(sMsg), '提示', MB_ICONINFORMATION);
end;

function WarnMsg(hWnd: HWND; const Format: string; const Args: array of const): Integer;
var
  sMsg: string;
begin
  sMsg := System.SysUtils.Format(Format, Args, FormatSettings);
  Result := MessageBox(hWnd, PWideChar(sMsg), '警告', MB_ICONWARNING);
end;

function ErrMsg(hWnd: HWND; const Format: string; const Args: array of const): Integer;
var
  sMsg: string;
begin
  sMsg := System.SysUtils.Format(Format, Args, FormatSettings);
  Result := MessageBox(hWnd, PWideChar(sMsg), '错误', MB_ICONERROR);
end;

function AskMsg(hWnd: HWND; const Format: string; const Args: array of const): Integer;
var
  sMsg: string;
begin
  sMsg := System.SysUtils.Format(Format, Args, FormatSettings);
  Result := MessageBox(hWnd, PWideChar(sMsg), '询问', MB_YESNO or MB_ICONQUESTION);
end;

end.
