//
//利用SendInput模拟鼠标键盘的输入
//作者：yeye55　2010年1月31日
//
//版权 2010，由 yeye55 拥有，保留所有权利。
//本文件中的代码是免费程序，无需任何授权或许可即可用于个人和商业目的。使用者一切后果自负。
//
//如果你转载了本文件中的代码，请注明代码出处和代码作者；
//如果你修改了本文件中的代码，请注明修改位置和修改作者。
//
//本文件最早在http://www.programbbs.com/bbs/上发布
//

unit SIMouseKeyboard;

interface

uses
    Windows;

const
    //虚键码定义
    VK_LBUTTON        = $01;
    VK_RBUTTON        = $02;
    VK_CANCEL         = $03;
    VK_MBUTTON        = $04;    //* NOT contiguous with L & RBUTTON */

    VK_BACK           = $08;
    VK_TAB            = $09;

    VK_CLEAR          = $0C;
    VK_RETURN         = $0D;

    VK_SHIFT          = $10;
    VK_CONTROL        = $11;
    VK_MENU           = $12;
    VK_PAUSE          = $13;
    VK_CAPITAL        = $14;

    VK_KANA           = $15;
    VK_HANGEUL        = $15;  //* old name - should be here for compatibility */
    VK_HANGUL         = $15;
    VK_JUNJA          = $17;
    VK_FINAL          = $18;
    VK_HANJA          = $19;
    VK_KANJI          = $19;

    VK_ESCAPE         = $1B;

    VK_CONVERT        = $1C;
    VK_NONCONVERT     = $1D;
    VK_ACCEPT         = $1E;
    VK_MODECHANGE     = $1F;

    VK_SPACE          = $20;
    VK_PRIOR          = $21;
    VK_NEXT           = $22;
    VK_END            = $23;
    VK_HOME           = $24;
    VK_LEFT           = $25;
    VK_UP             = $26;
    VK_RIGHT          = $27;
    VK_DOWN           = $28;
    VK_SELECT         = $29;
    VK_PRINT          = $2A;
    VK_EXECUTE        = $2B;
    VK_SNAPSHOT       = $2C;
    VK_INSERT         = $2D;
    VK_DELETE         = $2E;
    VK_HELP           = $2F;

    VK_C0             = $C0; //“`”和“~”
    VK_BD             = $BD; //“-”和“_”
    VK_BB             = $BB; //“=”和“+”
    VK_DC             = $DC; //“\”和“|”
    VK_DB             = $DB; //“[”和“{”
    VK_DD             = $DD; //“]”和“}”
    VK_BA             = $BA; //“;”和“:”
    VK_DE             = $DE; //“'”和“"”
    VK_BC             = $BC; //“,”和“<”
    VK_BE             = $BE; //“.”和“>”
    VK_BF             = $BF; //“/”和“?”

{* VK_0 thru VK_9 are the same as ASCII '0' thru '9' (0x30 - 0x39) *}
    VK_0              = $30;
    VK_1              = $31;
    VK_2              = $32;
    VK_3              = $33;
    VK_4              = $34;
    VK_5              = $35;
    VK_6              = $36;
    VK_7              = $37;
    VK_8              = $38;
    VK_9              = $39;

{* VK_A thru VK_Z are the same as ASCII 'A' thru 'Z' (0x41 - 0x5A) *}
    VK_A              = $41;
    VK_B              = $42;
    VK_C              = $43;
    VK_D              = $44;
    VK_E              = $45;
    VK_F              = $46;
    VK_G              = $47;
    VK_H              = $48;
    VK_I              = $49;
    VK_J              = $4A;
    VK_K              = $4B;
    VK_L              = $4C;
    VK_M              = $4D;
    VK_N              = $4E;
    VK_O              = $4F;
    VK_P              = $50;
    VK_Q              = $51;
    VK_R              = $52;
    VK_S              = $53;
    VK_T              = $54;
    VK_U              = $55;
    VK_V              = $56;
    VK_W              = $57;
    VK_X              = $58;
    VK_Y              = $59;
    VK_Z              = $5A;

    VK_LWIN           = $5B;
    VK_RWIN           = $5C;
    VK_APPS           = $5D;

    VK_NUMPAD0        = $60;
    VK_NUMPAD1        = $61;
    VK_NUMPAD2        = $62;
    VK_NUMPAD3        = $63;
    VK_NUMPAD4        = $64;
    VK_NUMPAD5        = $65;
    VK_NUMPAD6        = $66;
    VK_NUMPAD7        = $67;
    VK_NUMPAD8        = $68;
    VK_NUMPAD9        = $69;
    VK_MULTIPLY       = $6A;
    VK_ADD            = $6B;
    VK_SEPARATOR      = $6C;
    VK_SUBTRACT       = $6D;
    VK_DECIMAL        = $6E;
    VK_DIVIDE         = $6F;
    VK_F1             = $70;
    VK_F2             = $71;
    VK_F3             = $72;
    VK_F4             = $73;
    VK_F5             = $74;
    VK_F6             = $75;
    VK_F7             = $76;
    VK_F8             = $77;
    VK_F9             = $78;
    VK_F10            = $79;
    VK_F11            = $7A;
    VK_F12            = $7B;
    VK_F13            = $7C;
    VK_F14            = $7D;
    VK_F15            = $7E;
    VK_F16            = $7F;
    VK_F17            = $80;
    VK_F18            = $81;
    VK_F19            = $82;
    VK_F20            = $83;
    VK_F21            = $84;
    VK_F22            = $85;
    VK_F23            = $86;
    VK_F24            = $87;

    VK_NUMLOCK        = $90;
    VK_SCROLL         = $91;

{*
 * VK_L* & VK_R* - left and right Alt, Ctrl and Shift virtual keys.
 * Used only as parameters to GetAsyncKeyState() and GetKeyState().
 * No other API or message will distinguish left and right keys in this way.
 *}
    VK_LSHIFT         = $A0;
    VK_RSHIFT         = $A1;
    VK_LCONTROL       = $A2;
    VK_RCONTROL       = $A3;
    VK_LMENU          = $A4;
    VK_RMENU          = $A5;

    VK_PROCESSKEY     = $E5;

    VK_ATTN           = $F6;
    VK_CRSEL          = $F7;
    VK_EXSEL          = $F8;
    VK_EREOF          = $F9;
    VK_PLAY           = $FA;
    VK_ZOOM           = $FB;
    VK_NONAME         = $FC;
    VK_PA1            = $FD;
    VK_OEM_CLEAR      = $FE;

    //功能函数
    procedure SIKeyDown(Key : WORD);
    procedure SIKeyUp(Key : WORD);
    procedure SIKeyPress(Key : WORD; Interval : Cardinal = 0);
    procedure SIKeyInput(const Text : AnsiString; Interval : Cardinal = 0);
    procedure SIMouseDown(Key : WORD);
    procedure SIMouseUp(Key : WORD);
    procedure SIMouseClick(Key : WORD; Interval : Cardinal = 0);
    procedure SIMouseWheel(dZ : Integer);
    procedure SIMouseMoveTo(X,Y : Integer; MaxMove : Integer = 20; Interval : Cardinal = 0);

implementation

var
    PerWidth : Integer; //每象素宽度单位
    PerHeight : Integer; //每象素高度单位

{功能函数}

//按下指定的键。
procedure SIKeyDown(Key : WORD);
var
    Input : TInput;
begin
    Input.Itype:=INPUT_KEYBOARD;
    with Input.ki do
    begin
        wVk:=Key;
        wScan:=0;
        dwFlags:=0;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
end;

//放开指定的键。
procedure SIKeyUp(Key : WORD);
var
    Input : TInput;
begin
    Input.Itype:=INPUT_KEYBOARD;
    with Input.ki do
    begin
        wVk:=Key;
        wScan:=0;
        dwFlags:=KEYEVENTF_KEYUP;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
end;

//按下并放开指定的键，Interval为按下和放开之间的时间间隔。
procedure SIKeyPress(Key : WORD; Interval : Cardinal);
var
    Input : TInput;
begin
    Input.Itype:=INPUT_KEYBOARD;
    with Input.ki do
    begin
        wVk:=Key;
        wScan:=0;
        dwFlags:=0;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
    if Interval<>0 then Sleep(Interval);
    Input.Itype:=INPUT_KEYBOARD;
    with Input.ki do
    begin
        wVk:=Key;
        wScan:=0;
        dwFlags:=KEYEVENTF_KEYUP;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
end;

//模拟键盘输入指定的文本，文本中只能是单字节字符（#32~#126）
//以及Tab（#9）键和回车键（#13），其它字符会被忽略，
//Interval为输入每个字符之间的时间间隔。
procedure SIKeyInput(const Text : AnsiString; Interval : Cardinal);
type
    TCharTable = record
        Key : WORD;
        Char : array [0..1] of AnsiChar;
    end;

const
    CharCount = 50;
    CharTable : array [0..CharCount-1] of TCharTable = (
    (Key : VK_A;  Char : 'aA'), (Key : VK_B;  Char : 'bB'),
    (Key : VK_C;  Char : 'cC'), (Key : VK_D;  Char : 'dD'),
    (Key : VK_E;  Char : 'eE'), (Key : VK_F;  Char : 'fF'),
    (Key : VK_G;  Char : 'gG'), (Key : VK_H;  Char : 'hH'),
    (Key : VK_I;  Char : 'iI'), (Key : VK_J;  Char : 'jJ'),
    (Key : VK_K;  Char : 'kK'), (Key : VK_L;  Char : 'lL'),
    (Key : VK_M;  Char : 'mM'), (Key : VK_N;  Char : 'nN'),
    (Key : VK_O;  Char : 'oO'), (Key : VK_P;  Char : 'pP'),
    (Key : VK_Q;  Char : 'qQ'), (Key : VK_R;  Char : 'rR'),
    (Key : VK_S;  Char : 'sS'), (Key : VK_T;  Char : 'tT'),
    (Key : VK_U;  Char : 'uU'), (Key : VK_V;  Char : 'vV'),
    (Key : VK_W;  Char : 'wW'), (Key : VK_X;  Char : 'xX'),
    (Key : VK_Y;  Char : 'yY'), (Key : VK_Z;  Char : 'zZ'),
    (Key : VK_0;  Char : '0)'), (Key : VK_1;  Char : '1!'),
    (Key : VK_2;  Char : '2@'), (Key : VK_3;  Char : '3#'),
    (Key : VK_4;  Char : '4$'), (Key : VK_5;  Char : '5%'),
    (Key : VK_6;  Char : '6^'), (Key : VK_7;  Char : '7&'),
    (Key : VK_8;  Char : '8*'), (Key : VK_9;  Char : '9('),
    (Key : VK_C0; Char : '`~'), (Key : VK_BD; Char : '-_'),
    (Key : VK_BB; Char : '=+'), (Key : VK_DC; Char : '\|'),
    (Key : VK_DB; Char : '[{'), (Key : VK_DD; Char : ']}'),
    (Key : VK_BA; Char : ';:'), (Key : VK_DE; Char : #39+'"'),
    (Key : VK_BC; Char : ',<'), (Key : VK_BE; Char : '.>'),
    (Key : VK_BF; Char : '/?'), (Key : VK_SPACE; Char : ' '+#0),
    (Key : VK_TAB; Char : #9#0), (Key : VK_RETURN; Char : #13#0));

var
    Input : TInput;
    CapsState,NeedShift : Boolean;
    i,id : Integer;
begin
    CapsState:=((GetKeyState(VK_CAPITAL) and 1)<>0);
    for i:=1 to Length(Text) do
    begin
        for id:=0 to CharCount-1 do
            if (CharTable[id].Char[0]=Text[i]) or
               (CharTable[id].Char[1]=Text[i]) then
                break;
        if id>=CharCount then continue;
        NeedShift:=(CharTable[id].Char[1]=Text[i]);
        if (CharTable[id].Char[0]>='a') and
           (CharTable[id].Char[0]<='z') and CapsState then
            NeedShift:=not NeedShift;
        //按下上档键
        if NeedShift then
        begin
            Input.Itype:=INPUT_KEYBOARD;
            with Input.ki do
            begin
                wVk:=VK_SHIFT;
                wScan:=0;
                dwFlags:=0;
                time:=GetTickCount;
                dwExtraInfo:=GetMessageExtraInfo;
            end;
            SendInput(1,Input,SizeOf(TInput));
        end;
        //按下指定键
        Input.Itype:=INPUT_KEYBOARD;
        with Input.ki do
        begin
            wVk:=CharTable[id].Key;
            wScan:=0;
            dwFlags:=0;
            time:=GetTickCount;
            dwExtraInfo:=GetMessageExtraInfo;
        end;
        SendInput(1,Input,SizeOf(TInput));
        //放开指定键
        Input.Itype:=INPUT_KEYBOARD;
        with Input.ki do
        begin
            wVk:=CharTable[id].Key;
            wScan:=0;
            dwFlags:=KEYEVENTF_KEYUP;
            time:=GetTickCount;
            dwExtraInfo:=GetMessageExtraInfo;
        end;
        SendInput(1,Input,SizeOf(TInput));
        //放开上档键
        if NeedShift then
        begin
            Input.Itype:=INPUT_KEYBOARD;
            with Input.ki do
            begin
                wVk:=VK_SHIFT;
                wScan:=0;
                dwFlags:=KEYEVENTF_KEYUP;
                time:=GetTickCount;
                dwExtraInfo:=GetMessageExtraInfo;
            end;
            SendInput(1,Input,SizeOf(TInput));
        end;
        if Interval<>0 then Sleep(Interval);
    end;
end;

//按下鼠标的指定键。
procedure SIMouseDown(Key : WORD);
var
    Input : TInput;
begin
    Input.Itype:=INPUT_MOUSE;
    with Input.mi do
    begin
        dx:=0;
        dy:=0;
        mouseData:=0;
        case Key of
            VK_LBUTTON : dwFlags:=MOUSEEVENTF_LEFTDOWN;
            VK_RBUTTON : dwFlags:=MOUSEEVENTF_RIGHTDOWN;
            VK_MBUTTON : dwFlags:=MOUSEEVENTF_MIDDLEDOWN;
            else exit;
        end;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
end;

//放开鼠标的指定键。
procedure SIMouseUp(Key : WORD);
var
    Input : TInput;
begin
    Input.Itype:=INPUT_MOUSE;
    with Input.mi do
    begin
        dx:=0;
        dy:=0;
        mouseData:=0;
        case Key of
            VK_LBUTTON : dwFlags:=MOUSEEVENTF_LEFTUP;
            VK_RBUTTON : dwFlags:=MOUSEEVENTF_RIGHTUP;
            VK_MBUTTON : dwFlags:=MOUSEEVENTF_MIDDLEUP;
            else exit;
        end;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
end;

//单击鼠标的指定键，Interval为按下和放开之间的时间间隔。
procedure SIMouseClick(Key : WORD; Interval : Cardinal);
var
    Input : TInput;
begin
    Input.Itype:=INPUT_MOUSE;
    with Input.mi do
    begin
        dx:=0;
        dy:=0;
        mouseData:=0;
        case Key of
            VK_LBUTTON : dwFlags:=MOUSEEVENTF_LEFTDOWN;
            VK_RBUTTON : dwFlags:=MOUSEEVENTF_RIGHTDOWN;
            VK_MBUTTON : dwFlags:=MOUSEEVENTF_MIDDLEDOWN;
            else exit;
        end;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
    if Interval<>0 then Sleep(Interval);
    Input.Itype:=INPUT_MOUSE;
    with Input.mi do
    begin
        dx:=0;
        dy:=0;
        mouseData:=0;
        case Key of
            VK_LBUTTON : dwFlags:=MOUSEEVENTF_LEFTUP;
            VK_RBUTTON : dwFlags:=MOUSEEVENTF_RIGHTUP;
            VK_MBUTTON : dwFlags:=MOUSEEVENTF_MIDDLEUP;
            else exit;
        end;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
end;

//滚动鼠标的滚轮。
procedure SIMouseWheel(dZ : Integer);
var
    Input : TInput;
begin
    Input.Itype:=INPUT_MOUSE;
    with Input.mi do
    begin
        dx:=0;
        dy:=0;
        mouseData:=DWORD(dZ);
        dwFlags:=MOUSEEVENTF_WHEEL;
        time:=GetTickCount;
        dwExtraInfo:=GetMessageExtraInfo;
    end;
    SendInput(1,Input,SizeOf(TInput));
end;

//将鼠标指针移动到指定位置，返回是否成功，
//X和Y为象素值，X和Y的值的范围不能超出屏幕，
//MaxMove为移动时的dX和dY的最大值，
//Interval为两次移动之间的时间间隔，
procedure SIMouseMoveTo(X,Y : Integer; MaxMove : Integer; Interval : Cardinal);
var
    Input : TInput;
    p : TPoint;
    n : Integer;
begin
    if MaxMove<=0 then MaxMove:=$7FFFFFFF;
    GetCursorPos(p);
    while (p.X<>X) or (p.Y<>Y) do
    begin
        n:=X-p.X;
        if Abs(n)>MaxMove then
        begin
            if n>0 then n:=MaxMove
            else        n:=-MaxMove;
        end;
        p.X:=p.X+n;
        //
        n:=Y-p.Y;
        if Abs(n)>MaxMove then
        begin
            if n>0 then n:=MaxMove
            else        n:=-MaxMove;
        end;
        p.Y:=p.Y+n;
        //
        Input.Itype:=INPUT_MOUSE;
        with Input.mi do
        begin
            dx:=p.X*PerWidth;
            dy:=p.Y*PerHeight;
            mouseData:=0;
            dwFlags:=MOUSEEVENTF_MOVE or MOUSEEVENTF_ABSOLUTE;
            time:=GetTickCount;
            dwExtraInfo:=GetMessageExtraInfo;
        end;
        SendInput(1,Input,SizeOf(TInput));
        if Interval<>0 then Sleep(Interval);
    end;
end;

initialization
begin
    PerWidth:=($FFFF div (GetSystemMetrics(SM_CXSCREEN)-1)); //每象素宽度单位
    PerHeight:=($FFFF div (GetSystemMetrics(SM_CYSCREEN)-1)); //每象素高度单位
end;

end.

