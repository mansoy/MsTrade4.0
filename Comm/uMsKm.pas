unit uMsKm;

interface

uses
  Winapi.Windows;

function MsKmKeyPress(VirtualKey: USHORT; bShift: Boolean = False; dwDelay: DWORD = 100): Boolean; stdcall; external 'MsKm.dll' name 'MsKmKeyPress';
function MsKmPressPassword(hGame: HWND; szPassWord: PAnsiChar; dwDelay: DWORD = 100): Boolean; stdcall; external 'MsKm.dll' name 'MsKmPressPassword';

implementation

end.
