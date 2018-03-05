unit ManSoy.StrSub;

interface
uses
   windows, SysUtils, StrUtils;
type
  TArrayString = array of string;
//获取SubStr在Str中左边的部分字符串，从左起搜索
function GetLeftStr(SubStr, Str: string): string;

//获取SubStr在Str中右边的部分字符串，从左起搜索
function GetRightStr(SubStr, Str: string): string;

//获取SubStr在Str中左边的部分字符串，从右起搜索
function GetLeftEndStr(SubStr, Str: string): string;

//获取SubStr在Str中右边的部分字符串，从右起搜索
function GetRightEndStr(SubStr, Str: string): string;

//取得在LeftStr和RightStr中间的字符串,从左起搜索
function GetStr(LeftStr, RightStr, Str: string): string;

//取得在LeftStr和RightStr中间的字符串，从右起搜索
function GetEndStr(LeftStr, RightStr, Str: string): string;

//替换LeftStr与RighStr中间的字符串为ReplaceStr
function ReplaceStr(LeftStr,RighStr,ReplaceStr,Str:string) : string;

//取字符串左边长度为count的子串
function LeftStr(SourceStr : string; count : Integer):string;

//取字符串右边长度为count的子串
function RightStr(SourceStr : string; count : Integer):string;

//字符串截头
function _TrimLeft(SourceStr:string;TrimChar:Char):string;

//字符串截尾
function _TrimRight(SourceStr:string;TrimChar:Char):string;

//字符串截头尾
function _Trim(SourceStr:string;TrimChar:Char):string;

//字符串分割
function SplitString(const Source,ch:string):TArrayString;

function unicode2gb( unicodestr:string):string;

implementation

function unicode2gb( unicodestr:string):string;
var
  SourceLength:integer;
  DoneLength:integer;
  AscNo:integer;
  Byte1,Byte2,Byte3:integer;
  GbStr:string;
begin
result:='';
  if Trim(unicodestr)='' then exit;

  SourceLength:=Length(UnicodeStr);
  DoneLength:=1;
  repeat
  AscNo:=ord(UnicodeStr[DoneLength]);
  case (AscNo and $E0) of
  $E0:begin
     Byte1:=(AscNo and $0f) shl 12;
     Inc(DoneLength);
     if DoneLength>SourceLength then break;
     AscNo:=ord(UnicodeStr[DoneLength]);
     Byte2:=(AscNo and $3f) shl 6;
     Inc(DoneLength);
     if DoneLength>SourceLength then break;
     AscNo:=ord(UnicodeStr[DoneLength]);
     Byte3:=AscNo and $3f;
    end;
  $C0:begin
     Byte1:=(AscNo and $1f) shl 6;
     Inc(DoneLength);
     if DoneLength>SourceLength then break;
     AscNo:=ord(UnicodeStr[DoneLength]);
     Byte2:=(AscNo and $3f);
     Byte3:=0;
    end;
  0..$bf:begin
     Byte1:=AscNo;
     Byte2:=0;
     Byte3:=0;
    end;
  end;  //case;
   GbStr:=GBStr+widechar(Byte1+Byte2+Byte3);
   Inc(DoneLength);
   if DoneLength>SourceLength then break;
until DoneLength>SourceLength;
result:=GbStr;
end;


function GetLeftStr(SubStr, Str: string): string;
begin
   Result := Copy(Str, 1, Pos(SubStr, Str) - 1);
end;
//-------------------------------------------

function GetRightStr(SubStr, Str: string): string;
var
   i: integer;
begin
   i := pos(SubStr, Str);
   if i > 0 then
     Result := Copy(Str
       , i + Length(SubStr)
       , Length(Str) - i - Length(SubStr) + 1)
   else
     Result := '';
end;
//-------------------------------------------

function GetLeftEndStr(SubStr, Str: string): string;
var
   i: integer;
   S: string;
begin
   S := Str;
   Result := '';
   repeat
     i := Pos(SubStr, S);
     if i > 0 then
     begin
       if Result <> '' then
         Result := Result + SubStr + GetLeftStr(SubStr, S)
       else
         Result := GetLeftStr(SubStr, S);

       S := GetRightStr(SubStr, S);
     end;
   until i <= 0;
end;
//-------------------------------------------

function GetRightEndStr(SubStr, Str: string): string;
var
   i: integer;
begin
   Result := Str;
   repeat
     i := Pos(SubStr, Result);
     if i > 0 then
     begin
       Result := GetRightStr(SubStr, Result);
     end;
   until i <= 0;
end;
//-------------------------------------------
function GetStr(LeftStr, RightStr, Str: string): string;
begin
   Result := GetLeftStr(RightStr, GetRightStr(LeftStr, Str));
end;
//-------------------------------------------
function GetEndStr(LeftStr, RightStr, Str: string): string;
begin
   Result := GetRightEndStr(LeftStr, GetLeftEndStr(RightStr, Str));
end;

function ReplaceStr(LeftStr,RighStr,ReplaceStr,Str:string) : string;
var
  I : Integer;
  szStr : string;
  szMidStr : string;
begin
  I := Pos(LeftStr,Str);
  if I > 0 then
  begin
    szStr := GetRightStr(LeftStr,Str);
    szMidStr := GetLeftStr(RighStr,szStr);
    if Length(szMidStr) = 0 then
    begin
      Result := '';
    end
    else
    begin
      szStr := LeftStr + szMidStr + RighStr;
      Result := StringReplace(Str,szStr,ReplaceStr,[]);
    end;
  end
  else
  begin
    Result := '';
  end;
end;

//取字符串左边长度为count的子串
function LeftStr(SourceStr : string; count : Integer):string;
var
  subCount : Integer;
begin
  if count > Length(SourceStr) then
  begin
    subCount := Length(SourceStr);
  end
  else
  begin
    subCount := count;
  end;

  Result := Copy(SourceStr,0,subCount);
end;

//取字符串右边长度为count的子串
function RightStr(SourceStr : string; count : Integer):string;
var
  subCount : Integer;
begin
  if count > Length(SourceStr) then
  begin
    subCount := Length(SourceStr);
  end
  else
  begin
    subCount := count;
  end;
  Result := Copy(SourceStr,Length(SourceStr) - subCount + 1,subCount);
end;

function _TrimLeft(SourceStr:string;TrimChar:Char):string;
var
  temStr : string;
begin
  temStr := SourceStr;
  while temStr[1] = TrimChar do
  begin
    temStr := Copy(temStr,2,Length(temStr)-1);
  end;
  Result := temStr;
end;

function _TrimRight(SourceStr:string;TrimChar:Char):string;
var
  temStr : string;
begin
  temStr := SourceStr;
  while temStr[Length(temStr)] = TrimChar do
  begin
    temStr := Copy(temStr,1,Length(temStr)-1);
  end;
  Result := temStr;
end;

function _Trim(SourceStr:string;TrimChar:Char):string;
var
  temStr : string;
begin
  temStr := SourceStr;
  Result := _TrimRight(_TrimLeft(temStr,TrimChar),TrimChar);
end;

function SplitString(const Source,ch:string):TArrayString;
var
  temp:String;
  i,index:Integer;
begin
  index := 0;
  SetLength(Result,0);
  if   Source='' then   exit;
  temp:=Source;
  i:=pos(ch,Source);
  while   i<>0   do
  begin
    SetLength(Result,index + 1);
    Result[index] := copy(temp,0,i-1);
    Delete(temp,1,i+ Length(ch) -1);
    i:=pos(ch,temp);
    Inc(index);
  end;
  SetLength(Result,index + 1);
  Result[index] := temp;
end;

end.
