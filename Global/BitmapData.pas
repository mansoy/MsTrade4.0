unit BitmapData;

//
// 位图数据处理，主要用于位图的找图找色
// 作者：yeye55　2009年5月29日
//
// 版权 2009，由 yeye55 拥有，保留所有权利。
// 本文件中的代码是免费程序，无需任何授权或许可即可用于个人和商业目的。使用者一切后果自负。
//
// 如果你转载了本文件中的代码，请注明代码出处和代码作者；
// 如果你修改了本文件中的代码，请注明修改位置和修改作者。
//
// 本文件最早在http://www.programbbs.com/bbs/上发布
//

interface

uses
  Windows, Classes, SysUtils, Graphics;

const
  BD_COLORLESS = -1; // 无色
  BD_BITCOUNT = 24; // 图象位数
  BD_BYTECOUNT = BD_BITCOUNT shr 3; // 每象素占用字节数
  BD_LINEWIDTH = 32; // 每行数据对齐宽度（位）

type
  // 字节数组
  TByteAry = array [0 .. 0] of Byte;
  PByteAry = ^TByteAry;

  // 颜色变化范围，R、G、B三个通道的绝对差值
  TBDColorRange = record
    R: Integer;
    G: Integer;
    B: Integer;
  end;

  TBDColor = Integer; // BGR格式颜色

  // 转换函数
function BGR(B, G, R: Byte): TBDColor;
function RGBtoBGR(C: TColor): TBDColor;
function BGRtoRGB(C: TBDColor): TColor;
// 比较颜色
function BDCompareColor(C1, C2: TBDColor; const Range: TBDColorRange): Boolean;

type
  TBDBitmapData = class; // 位图数据

  // 枚举子图回调函数，查找多个子图时回调，返回是否继续枚举，
  // Left：找到子图的左边距；
  // Top：找到子图的顶边距；
  // Bmp：找到子图数据；
  // lParam：调用时设置的参数。
  TBDEnumImageProc = function(Left, Top: Integer; Bmp: TBDBitmapData;
    lParam: Integer): Boolean;

  // 枚举颜色回调函数，查找多个颜色时回调，返回是否继续枚举，
  // Left：找到颜色的左边距；
  // Top：找到颜色的顶边距；
  // Color：找到的颜色；
  // lParam：调用时设置的参数。
  TBDEnumColorProc = function(Left, Top: Integer; Color: TBDColor;
    lParam: Integer): Boolean;

  // 位图数据
  TBDBitmapData = class
  private
    FName: String; // 位图名称
    FWidth: Integer; // 位图宽度（象素）
    FHeight: Integer; // 位图高度（象素）
    FBackColor: TBDColor; // 背景颜色（BGR格式）
    FLineWidth: Integer; // 对齐后每行数据宽度（字节）
    FSpareWidth: Integer; // 对齐后每行数据多余宽度（字节）
    FSize: Integer; // 位图数据长度
    FBufSize: Integer; // 缓冲区实际长度
    FBits: PByteAry; // 位图数据缓冲区
    function InitData(AWidth, AHeight: Integer): Boolean;
    function GetPixels(Left, Top: Integer): TBDColor;
    procedure SetPixels(Left, Top: Integer; Value: TBDColor);
  public
    Error: String;
    constructor Create(const AName: String = '');
    destructor Destroy; override;
    procedure Clear;
    function LoadFromStream(Stream: TStream;
      ABackColor: TBDColor = BD_COLORLESS): Boolean;
    function SaveToStream(Stream: TStream): Boolean;
    function LoadFromFile(const FileName: string;
      ABackColor: TBDColor = BD_COLORLESS): Boolean;
    function SaveToFile(const FileName: string): Boolean;
    function LoadFromBitmap(Bitmap: TBitmap): Boolean;
    function SaveToBitmap(Bitmap: TBitmap): Boolean;
    function CopyFormScreen(Left: Integer = -1; Top: Integer = -1;
      AWidth: Integer = -1; AHeight: Integer = -1): Boolean;
    function CopyFormCursor: Boolean;
    function Compare(Bmp: TBDBitmapData; Left: Integer = 0; Top: Integer = 0)
      : Boolean; overload;
    function Compare(Bmp: TBDBitmapData; const Range: TBDColorRange;
      Left: Integer = 0; Top: Integer = 0): Boolean; overload;
    //function FindImage(Bmp: TBDBitmapData; var Left, Top: Integer): TPoint; overload;
    function FindImage(Bmp: TBDBitmapData; var Left, Top: Integer): Boolean; overload;
    function FindImage(Bmp: TBDBitmapData; const Range: TBDColorRange;
      var Left, Top: Integer): Boolean; overload;
    function FindCenterImage(Bmp: TBDBitmapData; var Left, Top: Integer)
      : Boolean; overload;
    function FindCenterImage(Bmp: TBDBitmapData; const Range: TBDColorRange;
      var Left, Top: Integer): Boolean; overload;
    function EnumImage(Bmp: TBDBitmapData; EnumImageProc: TBDEnumImageProc;
      lParam: Integer = 0): Boolean; overload;
    function EnumImage(Bmp: TBDBitmapData; const Range: TBDColorRange;
      EnumImageProc: TBDEnumImageProc; lParam: Integer = 0): Boolean; overload;
    function FindColor(Color: TBDColor; var Left, Top: Integer)
      : Boolean; overload;
    function FindColor(Color: TBDColor; const Range: TBDColorRange;
      var Left, Top: Integer): Boolean; overload;
    function FindCenterColor(Color: TBDColor; var Left, Top: Integer)
      : Boolean; overload;
    function FindCenterColor(Color: TBDColor; const Range: TBDColorRange;
      var Left, Top: Integer): Boolean; overload;
    function EnumColor(Color: TBDColor; EnumColorProc: TBDEnumColorProc;
      lParam: Integer = 0): Boolean; overload;
    function EnumColor(Color: TBDColor; const Range: TBDColorRange;
      EnumColorProc: TBDEnumColorProc; lParam: Integer = 0): Boolean; overload;
    property Name: String read FName write FName; // 位图名称
    property Width: Integer read FWidth; // 位图宽度（象素）
    property Height: Integer read FHeight; // 位图高度（象素）
    property BackColor: TBDColor read FBackColor write FBackColor;
    // 背景颜色（BGR格式）
    property LineWidth: Integer read FLineWidth; // 对齐后每行数据宽度（字节）
    property SpareWidth: Integer read FSpareWidth; // 对齐后每行数据多余宽度（字节）
    property Size: Integer read FSize; // 位图数据长度
    property Bits: PByteAry read FBits; // 位图数据缓冲区
    property Pixels[Left, Top: Integer]: TBDColor read GetPixels
      write SetPixels; default;
  end;

implementation

type
  // 矩阵遍历方向
  TAspect = (asLeft, asRight, asUp, asDown);

const
  // 移动坐标差，用于矩阵遍历
  MoveVal: array [asLeft .. asDown] of TPoint = ((X: - 1; Y: 0), // asLeft
    (X: 1; Y: 0), // asRight
    (X: 0; Y: - 1), // asUp
    (X: 0; Y: 1) // asDown
    );

var
  ScreenWidth: Integer;
  ScreenHeight: Integer;
  IconWidth: Integer;
  IconHeight: Integer;

  // 根据B、G、R三个通道的值生成一个BGR格式颜色。
function BGR(B, G, R: Byte): TBDColor;
begin
  result := (B or (G shl 8) or (R shl 16));
end;

// RGB颜色格式转换到BGR颜色格式。
function RGBtoBGR(C: TColor): TBDColor;
begin
  result := ((C and $FF0000) shr 16) or (C and $00FF00) or
    ((C and $0000FF) shl 16);
end;

// BGR颜色格式转换到RGB颜色格式。
function BGRtoRGB(C: TBDColor): TColor;
begin
  result := ((C and $FF0000) shr 16) or (C and $00FF00) or
    ((C and $0000FF) shl 16);
end;

// 根据颜色范围Range比较颜色C1和C2，返回C1和C2是否相似，
// C1,C2：BGR格式颜色；
// Range：为颜色变化范围。
function BDCompareColor(C1, C2: TBDColor; const Range: TBDColorRange): Boolean;
var
  C: Integer;
begin
  result := false;
  // B
  C := (C1 and $FF) - (C2 and $FF);
  if (C > Range.B) or (C < -Range.B) then
    exit;
  // G
  C := ((C1 and $FF00) shr 8) - ((C2 and $FF00) shr 8);
  if (C > Range.G) or (C < -Range.G) then
    exit;
  // R
  C := ((C1 and $FF0000) shr 16) - ((C2 and $FF0000) shr 16);
  if (C > Range.R) or (C < -Range.R) then
    exit;
  //
  result := true;
end;

{ TBDBitmapData } // 位图数据

constructor TBDBitmapData.Create(const AName: String);
begin
  self.FName := AName;
  self.FWidth := 0;
  self.FHeight := 0;
  self.FBackColor := BD_COLORLESS;
  self.FLineWidth := 0;
  self.FSize := 0;
  self.FBufSize := 0;
  self.FBits := nil;
  self.Error := '';
end;

destructor TBDBitmapData.Destroy;
begin
  self.Clear;
end;

// 根据当前的AWidth和AHeight初始化数据，分配内存，返回是否成功，
// 如果失败将设置self.Error说明情况，
// AWidth：位图的宽度；
// AHeight：位图的高度。
function TBDBitmapData.InitData(AWidth, AHeight: Integer): Boolean;
var
  Align: Integer;
begin
  self.Error := '';
  result := true;
  if (self.FWidth = AWidth) and (self.FHeight = AHeight) then
    exit;
  // 计算对齐后的每行数据宽度
  self.FWidth := AWidth;
  self.FHeight := AHeight;
  Align := BD_LINEWIDTH - 1;
  self.FLineWidth := (((self.FWidth * BD_BITCOUNT) + Align) and
    ($7FFFFFFF - Align)) shr 3;
  self.FSpareWidth := self.FLineWidth - (self.FWidth * BD_BYTECOUNT);
  self.FSize := self.FLineWidth * self.FHeight;
  // 分配内存
  if self.FSize <= self.FBufSize then
    exit;
  if self.FBits <> nil then
    FreeMem(self.FBits);
  try
    GetMem(self.FBits, self.FSize);
  except
    on EOutOfMemory do
    begin
      self.FSize := 0;
      self.FBufSize := 0;
      self.FBits := nil;
      self.Error := '内存不足！';
      result := false;
      exit;
    end;
  end;
  self.FBufSize := self.FSize;
end;

// 获取指定位置象素的颜色值，
// Left：象素的左边距；
// Top：象素的顶边距。
function TBDBitmapData.GetPixels(Left, Top: Integer): TBDColor;
begin
  if (Left < 0) or (Left >= self.FWidth) or (Top < 0) or (Top >= self.FHeight)
  then
  begin
    result := 0;
    exit;
  end;
  result := ((PInteger(@(self.FBits[((self.FHeight - Top - 1) * self.FLineWidth)
    + (Left * BD_BYTECOUNT)])))^ and $FFFFFF);
end;

// 设置指定位置象素的颜色值，
// Left：象素的左边距；
// Top：象素的顶边距；
// Value：BGR格式颜色。
procedure TBDBitmapData.SetPixels(Left, Top: Integer; Value: TBDColor);
var
  Off: Integer;
begin
  if (Left < 0) or (Left >= self.FWidth) or (Top < 0) or (Top >= self.FHeight)
  then
    exit;
  Off := ((self.FHeight - Top - 1) * self.FLineWidth) + (Left * BD_BYTECOUNT);
  // B
  self.FBits[Off] := Byte(Value and $FF);
  // G
  self.FBits[Off + 1] := Byte((Value and $FF00) shr 8);
  // R
  self.FBits[Off + 2] := Byte((Value and $FF0000) shr 16);
end;

// 清除当前的位图数据。
procedure TBDBitmapData.Clear;
begin
  self.FWidth := 0;
  self.FHeight := 0;
  self.FBackColor := BD_COLORLESS;
  self.FLineWidth := 0;
  self.FSize := 0;
  self.FBufSize := 0;
  if self.FBits <> nil then
  begin
    FreeMem(self.FBits);
    self.FBits := nil;
  end;
  self.Error := '';
end;

// 从数据流中导入位图数据，返回是否成功，
// 如果失败将设置self.Error说明情况，
// 数据流中的数据必需是24位BMP格式文件数据，
// Stream：数据流；
// ABackColor：位图的背景颜色，可省略。
function TBDBitmapData.LoadFromStream(Stream: TStream;
  ABackColor: TBDColor): Boolean;
var
  FileHeader: TBitmapFileHeader;
  InfoHeader: TBitmapInfoHeader;
begin
  if Stream = nil then
  begin
    self.Error := '没有指定数据流！';
    result := false;
    exit;
  end;
  // 读取文件头
  Stream.Read(FileHeader, SizeOf(TBitmapFileHeader));
  Stream.Read(InfoHeader, SizeOf(TBitmapInfoHeader));
  with FileHeader, InfoHeader do
  begin
    // 确定位图格式
    if (bfType <> $4D42) or (biSize <> SizeOf(TBitmapInfoHeader)) or
      (biBitCount <> BD_BITCOUNT) or (biCompression <> BI_RGB) then
    begin
      self.Error := '错误的数据格式！';
      result := false;
      exit;
    end;
    // 数据初始化
    self.FBackColor := ABackColor;
    if not self.InitData(biWidth, biHeight) then
    begin
      result := false;
      exit;
    end;
  end;
  // 读入数据
  result := Stream.Read((self.FBits)^, self.FSize) = self.FSize;
  if result then
    self.Error := ''
  else
    self.Error := '读取的数据不完整！';
end;

// 将当前的位图数据导出到数据流中，返回是否成功，
// 如果失败将设置self.Error说明情况，
// 数据按24位BMP文件数据格式导出到数据流中，
// Stream：数据流。
function TBDBitmapData.SaveToStream(Stream: TStream): Boolean;
var
  FileHeader: TBitmapFileHeader;
  InfoHeader: TBitmapInfoHeader;
  HeaderLen, n: Integer;
begin
  if Stream = nil then
  begin
    self.Error := '没有指定数据流！';
    result := false;
    exit;
  end;
  // 初始化文件头
  HeaderLen := SizeOf(TBitmapFileHeader) + SizeOf(TBitmapInfoHeader);
  with FileHeader, InfoHeader do
  begin
    bfType := $4D42;
    bfSize := self.FSize + HeaderLen;
    bfReserved1 := 0;
    bfReserved2 := 0;
    bfOffBits := HeaderLen;
    biSize := SizeOf(TBitmapInfoHeader);
    biWidth := self.FWidth;
    biHeight := self.FHeight;
    biPlanes := 1;
    biBitCount := BD_BITCOUNT;
    biCompression := BI_RGB;
    biSizeImage := self.FSize;
    biXPelsPerMeter := $EC4;
    biYPelsPerMeter := $EC4;
    biClrUsed := 0;
    biClrImportant := 0;
  end;
  // 写入数据
  n := 0;
  n := n + Stream.Write(FileHeader, SizeOf(TBitmapFileHeader));
  n := n + Stream.Write(InfoHeader, SizeOf(TBitmapInfoHeader));
  n := n + Stream.Write((self.FBits)^, self.FSize);
  result := n = (self.FSize + HeaderLen);
  if result then
    self.Error := ''
  else
    self.Error := '写入的数据不完整！';
end;

// 从文件中导入位图数据，返回是否成功，
// 如果失败将设置self.Error说明情况，
// 文件必需是24位BMP格式文件，
// FileName：BMP文件名；
// ABackColor：位图的背景颜色，可省略。
function TBDBitmapData.LoadFromFile(const FileName: string;
  ABackColor: TBDColor): Boolean;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  result := self.LoadFromStream(Stream, ABackColor);
  Stream.Free;
end;

// 将当前的位图数据导出到文件中，返回是否成功，
// 如果失败将设置self.Error说明情况，
// 数据按24位BMP文件数据格式导出到文件中，
// FileName：BMP文件名。
function TBDBitmapData.SaveToFile(const FileName: string): Boolean;
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  result := self.SaveToStream(Stream);
  Stream.Free;
end;

// 从一个TBitmap对象中导入数据，返回是否成功，位图的背景颜色由
// TBitmap.Transparent和TBitmap.TransparentColor决定，
// 如果失败将设置self.Error说明情况，
// Bitmap：TBitmap对象。
function TBDBitmapData.LoadFromBitmap(Bitmap: TBitmap): Boolean;
var
  Stream: TMemoryStream;
  ABackColor: TBDColor;
begin
  if Bitmap = nil then
  begin
    self.Error := '没有指定位图！';
    result := false;
    exit;
  end;
  if Bitmap.Transparent then
    ABackColor := RGBtoBGR(Bitmap.TransparentColor)
  else
    ABackColor := BD_COLORLESS;
  Stream := TMemoryStream.Create;
  Bitmap.SaveToStream(Stream);
  Stream.Position := 0;
  result := self.LoadFromStream(Stream, ABackColor);
  Stream.Free;
end;

// 将当前的位图数据导出到一个TBitmap对象中，返回是否成功，根据当前
// 的背景颜色设置TBitmap.Transparent和TBitmap.TransparentColor成员，
// 如果失败将设置self.Error说明情况，
// Bitmap：TBitmap对象。
function TBDBitmapData.SaveToBitmap(Bitmap: TBitmap): Boolean;
var
  Stream: TMemoryStream;
begin
  if Bitmap = nil then
  begin
    self.Error := '没有指定位图！';
    result := false;
    exit;
  end;
  Stream := TMemoryStream.Create;
  result := self.SaveToStream(Stream);
  if not result then
  begin
    Stream.Free;
    exit;
  end;
  Stream.Position := 0;
  Bitmap.LoadFromStream(Stream);
  if self.FBackColor <> BD_COLORLESS then
  begin
    Bitmap.TransparentColor := BGRtoRGB(self.FBackColor);
    Bitmap.Transparent := true;
  end
  else
    Bitmap.Transparent := false;
  Stream.Free;
end;

// 从屏幕上的指定范围中截图，并导入数据，返回是否成功，
// 如果失败将设置self.Error说明情况，
// Left：截图的左边距，可省略；
// Top：截图的顶边距，可省略；
// AWidth：截图的宽度，可省略；
// AHeight：截图的高度，可省略。
function TBDBitmapData.CopyFormScreen(Left, Top, AWidth,
  AHeight: Integer): Boolean;
var
  Wnd: HWND;
  DC, MemDC: HDC;
  Bitmap, OldBitmap: HBITMAP;
  BitInfo: TBitmapInfo;
begin
  // 参数调整
  if (Left < 0) or (Left >= ScreenWidth) then
    Left := 0;
  if (Top < 0) or (Top >= ScreenHeight) then
    Top := 0;
  if AWidth <= 0 then
    AWidth := ScreenWidth - Left;
  if AHeight <= 0 then
    AHeight := ScreenHeight - Top;
  // 数据初始化
  self.FBackColor := BD_COLORLESS;
  if not self.InitData(AWidth, AHeight) then
  begin
    result := false;
    exit;
  end;
  // 截图
  Wnd := GetDesktopWindow();
  DC := GetWindowDC(Wnd);
  MemDC := CreateCompatibleDC(DC);
  Bitmap := CreateCompatibleBitmap(DC, self.FWidth, self.FHeight);
  OldBitmap := SelectObject(MemDC, Bitmap);
  result := BitBlt(MemDC, 0, 0, self.FWidth, self.FHeight, DC, Left,
    Top, SRCCOPY);
  Bitmap := SelectObject(MemDC, OldBitmap);
  if not result then
  begin
    DeleteDC(MemDC);
    DeleteObject(Bitmap);
    ReleaseDC(Wnd, DC);
    self.Error := '截图失败！';
    exit;
  end;
  // 位图信息初始化
  with BitInfo.bmiHeader do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biWidth := self.FWidth;
    biHeight := self.FHeight;
    biPlanes := 1;
    biBitCount := BD_BITCOUNT;
    biCompression := BI_RGB;
    biSizeImage := 0;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    biClrUsed := 0;
    biClrImportant := 0;
  end;
  // 提取数据
  result := GetDIBits(DC, Bitmap, 0, self.FHeight, Pointer(self.FBits), BitInfo,
    DIB_RGB_COLORS) <> 0;
  if result then
    self.Error := ''
  else
    self.Error := '提取数据失败！';
  DeleteDC(MemDC);
  DeleteObject(Bitmap);
  ReleaseDC(Wnd, DC);
end;

// 截取鼠标指针的位图，并导入数据，返回是否成功，
// 如果失败将设置self.Error说明情况，
// 如果鼠标指针是动画指针，默认截取第一帧画面。
function TBDBitmapData.CopyFormCursor: Boolean;
var
  Wnd: HWND;
  DC, MemDC: HDC;
  Bitmap, OldBitmap: HBITMAP;
  CurInfo: TCursorInfo;
  BitInfo: TBitmapInfo;
begin
  // 数据初始化
  self.FBackColor := BD_COLORLESS;
  self.InitData(IconWidth, IconHeight);
  // 获取鼠标指针信息
  FillChar(CurInfo, SizeOf(TCursorInfo), 0);
  CurInfo.cbSize := SizeOf(TCursorInfo);
  if not GetCursorInfo(CurInfo) then
  begin
    self.Error := '获取鼠标指针信息失败！';
    result := false;
    exit;
  end;
  // 截取鼠标指针位图
  Wnd := GetDesktopWindow();
  DC := GetWindowDC(Wnd);
  MemDC := CreateCompatibleDC(DC);
  Bitmap := CreateCompatibleBitmap(DC, self.FWidth, self.FHeight);
  OldBitmap := SelectObject(MemDC, Bitmap);
  result := DrawIconEx(MemDC, 0, 0, CurInfo.hCursor, 0, 0, 0, 0, DI_IMAGE);
  Bitmap := SelectObject(MemDC, OldBitmap);
  if not result then
  begin
    DeleteDC(MemDC);
    DeleteObject(Bitmap);
    ReleaseDC(Wnd, DC);
    self.Error := '截取鼠标指针位图失败！';
    exit;
  end;
  // 位图信息初始化
  with BitInfo.bmiHeader do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biWidth := self.FWidth;
    biHeight := self.FHeight;
    biPlanes := 1;
    biBitCount := BD_BITCOUNT;
    biCompression := BI_RGB;
    biSizeImage := 0;
    biXPelsPerMeter := 0;
    biYPelsPerMeter := 0;
    biClrUsed := 0;
    biClrImportant := 0;
  end;
  // 提取数据
  result := GetDIBits(DC, Bitmap, 0, self.FHeight, Pointer(self.FBits), BitInfo,
    DIB_RGB_COLORS) <> 0;
  if result then
    self.Error := ''
  else
    self.Error := '提取数据失败！';
  DeleteDC(MemDC);
  DeleteObject(Bitmap);
  ReleaseDC(Wnd, DC);
end;

// 在当前位图的指定位置比较Bmp位图，返回是否一致，
// 无论是否一致都不会修改self.Error，
// Bmp位图面幅要小于等于当前位图的面幅，Bmp位图不能超出当前位图，
// Bmp：位图数据；
// Left：比较时的左边距，可省略；
// Top：比较时的顶边距，可省略。
function TBDBitmapData.Compare(Bmp: TBDBitmapData; Left, Top: Integer): Boolean;
var
  X, Y, Off1, Off2: Integer;
  C1, C2: TBDColor;
begin
  if ((Left + Bmp.FWidth) > self.FWidth) or ((Top + Bmp.FHeight) > self.FHeight)
  then
  begin
    result := false;
    exit;
  end;
  Off1 := ((self.FHeight - Bmp.FHeight - Top) * self.FLineWidth) +
    (Left * BD_BYTECOUNT);
  Off2 := 0;
  result := true;
  for Y := 0 to Bmp.FHeight - 1 do
  begin
    for X := 0 to Bmp.FWidth - 1 do
    begin
      C1 := ((PInteger(@(self.FBits[Off1])))^ and $FFFFFF);
      C2 := ((PInteger(@(Bmp.FBits[Off2])))^ and $FFFFFF);
      if (C1 <> self.FBackColor) and (C2 <> Bmp.FBackColor) and (C1 <> C2) then
      begin
        result := false;
        break;
      end;
      Off1 := Off1 + 3;
      Off2 := Off2 + 3;
    end;
    if not result then
      break;
    Off1 := Off1 + (self.FLineWidth - Bmp.FLineWidth) + Bmp.FSpareWidth;
    Off2 := Off2 + Bmp.FSpareWidth;
  end;
end;

// 在当前位图的指定位置模糊比较Bmp位图，返回是否一致，
// 无论是否一致都不会修改self.Error，
// Bmp位图面幅要小于等于当前位图的面幅，Bmp位图不能超出当前位图，
// Bmp：位图数据；
// Range：为颜色变化范围
// Left：比较时的左边距，可省略；
// Top：比较时的顶边距，可省略。
function TBDBitmapData.Compare(Bmp: TBDBitmapData; const Range: TBDColorRange;
  Left, Top: Integer): Boolean;
var
  X, Y, Off1, Off2: Integer;
  C1, C2: TBDColor;
begin
  if ((Left + Bmp.FWidth) > self.FWidth) or ((Top + Bmp.FHeight) > self.FHeight)
  then
  begin
    result := false;
    exit;
  end;
  Off1 := ((self.FHeight - Bmp.FHeight - Top) * self.FLineWidth) +
    (Left * BD_BYTECOUNT);
  Off2 := 0;
  result := true;
  for Y := 0 to Bmp.FHeight - 1 do
  begin
    for X := 0 to Bmp.FWidth - 1 do
    begin
      C1 := ((PInteger(@(self.FBits[Off1])))^ and $FFFFFF);
      C2 := ((PInteger(@(Bmp.FBits[Off2])))^ and $FFFFFF);
      if (C1 <> self.FBackColor) and (C2 <> Bmp.FBackColor) and
        (not BDCompareColor(C1, C2, Range)) then
      begin
        result := false;
        break;
      end;
      Off1 := Off1 + 3;
      Off2 := Off2 + 3;
    end;
    if not result then
      break;
    Off1 := Off1 + (self.FLineWidth - Bmp.FLineWidth) + Bmp.FSpareWidth;
    Off2 := Off2 + Bmp.FSpareWidth;
  end;
end;

// 从当前位图中查找与Bmp一致的子图，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 按从左到右，从上到下的顺序查找，
// 找到返回true，设置Left和Top为找到子图的位置，
// 没找到返回false，设置Left和Top为-1。
// Bmp：子图数据；
// Left：找到子图的左边距；
// Top：找到子图的顶边距。
function TBDBitmapData.FindImage(Bmp: TBDBitmapData;
  var Left, Top: Integer): Boolean;
var
  X, Y: Integer;
begin
  result := false;
  X := 0;
  for Y := 0 to self.FHeight - Bmp.FHeight - 1 do
  begin
    for X := 0 to self.FWidth - Bmp.FWidth - 1 do
    begin
      if self.Compare(Bmp, X, Y) then
      begin
        result := true;
        break;
      end;
    end;
    if result then
      break;
  end;
  if result then
  begin
    Left := X;
    Top := Y;
  end
  else
  begin
    Left := -1;
    Top := -1;
  end;
end;

// 从当前位图中模糊查找与Bmp一致的子图，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 按从左到右，从上到下的顺序查找，
// 找到返回true，设置Left和Top为找到的位置，
// 没找到返回false，设置Left和Top为-1。
// Bmp：子图数据；
// Range：为颜色变化范围；
// Left：找到子图的左边距；
// Top：找到子图的顶边距。
function TBDBitmapData.FindImage(Bmp: TBDBitmapData; const Range: TBDColorRange;
  var Left, Top: Integer): Boolean;
var
  X, Y: Integer;
begin
  result := false;
  X := 0;
  for Y := 0 to self.FHeight - Bmp.FHeight - 1 do
  begin
    for X := 0 to self.FWidth - Bmp.FWidth - 1 do
    begin
      if self.Compare(Bmp, Range, X, Y) then
      begin
        result := true;
        break;
      end;
    end;
    if result then
      break;
  end;
  if result then
  begin
    Left := X;
    Top := Y;
  end
  else
  begin
    Left := -1;
    Top := -1;
  end;
end;

// 从当前位图中查找与Bmp一致的子图，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 以（Left，Top）为基点，从中心向四周查找，
// 找到返回true，设置Left和Top为找到子图的位置，
// 没找到返回false，设置Left和Top为-1。
// Bmp：子图数据；
// Left：找到子图的左边距；
// Top：找到子图的顶边距。
function TBDBitmapData.FindCenterImage(Bmp: TBDBitmapData;
  var Left, Top: Integer): Boolean;
var
  Aspect: TAspect;
  VisitCount, Count, i: Integer;
begin
  result := false;
  VisitCount := 0;
  Aspect := asUp;
  Count := 1;
  while VisitCount < (self.FWidth * self.FHeight) do
  begin
    for i := 0 to Count - 1 do
    begin
      if (Left >= 0) and (Left < self.FWidth) and (Top >= 0) and
        (Top < self.FHeight) then
      begin
        if self.Compare(Bmp, Left, Top) then
        begin
          result := true;
          break;
        end;
        VisitCount := VisitCount + 1;
      end;
      Left := Left + MoveVal[Aspect].X;
      Top := Top + MoveVal[Aspect].Y;
    end;
    if result then
      break;
    case Aspect of
      asLeft:
        begin
          Aspect := asUp;
          Count := Count + 1;
        end;
      asRight:
        begin
          Aspect := asDown;
          Count := Count + 1;
        end;
      asUp:
        begin
          Aspect := asRight;
        end;
      asDown:
        begin
          Aspect := asLeft;
        end;
    end;
  end;
  if not result then
  begin
    Left := -1;
    Top := -1;
  end;
end;

// 从当前位图中模糊查找与Bmp一致的子图，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 以（Left，Top）为基点，从中心向四周查找，
// 找到返回true，设置Left和Top为找到子图的位置，
// 没找到返回false，设置Left和Top为-1。
// Bmp：子图数据；
// Range：为颜色变化范围；
// Left：找到子图的左边距；
// Top：找到子图的顶边距。
function TBDBitmapData.FindCenterImage(Bmp: TBDBitmapData;
  const Range: TBDColorRange; var Left, Top: Integer): Boolean;
var
  Aspect: TAspect;
  VisitCount, Count, i: Integer;
begin
  result := false;
  VisitCount := 0;
  Aspect := asUp;
  Count := 1;
  while VisitCount < (self.FWidth * self.FHeight) do
  begin
    for i := 0 to Count - 1 do
    begin
      if (Left >= 0) and (Left < self.FWidth) and (Top >= 0) and
        (Top < self.FHeight) then
      begin
        if self.Compare(Bmp, Range, Left, Top) then
        begin
          result := true;
          break;
        end;
        VisitCount := VisitCount + 1;
      end;
      Left := Left + MoveVal[Aspect].X;
      Top := Top + MoveVal[Aspect].Y;
    end;
    if result then
      break;
    case Aspect of
      asLeft:
        begin
          Aspect := asUp;
          Count := Count + 1;
        end;
      asRight:
        begin
          Aspect := asDown;
          Count := Count + 1;
        end;
      asUp:
        begin
          Aspect := asRight;
        end;
      asDown:
        begin
          Aspect := asLeft;
        end;
    end;
  end;
  if not result then
  begin
    Left := -1;
    Top := -1;
  end;
end;

// 从当前位图中查找所有与Bmp一致的子图，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 按从左到右，从上到下的顺序查找，
// 每找到一个子图，就调用回调函数EnumImageProc，如果EnumImageProc
// 返回false就停止查找，结束函数，
// Bmp：子图数据；
// EnumImageProc：回调函数；
// lParam：调用回调函数时发出的参数，可省略。
function TBDBitmapData.EnumImage(Bmp: TBDBitmapData;
  EnumImageProc: TBDEnumImageProc; lParam: Integer): Boolean;
var
  X, Y: Integer;
  Res: Boolean;
begin
  result := false;
  Res := true;
  for Y := 0 to self.FHeight - Bmp.FHeight - 1 do
  begin
    for X := 0 to self.FWidth - Bmp.FWidth - 1 do
    begin
      if self.Compare(Bmp, X, Y) then
      begin
        result := true;
        Res := EnumImageProc(X, Y, Bmp, lParam);
        if not Res then
          break;
      end;
    end;
    if not Res then
      break;
  end;
end;

// 从当前位图中模糊查找所有与Bmp一致的子图，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 按从左到右，从上到下的顺序查找，
// 每找到一个子图，就调用回调函数EnumImageProc，如果EnumImageProc
// 返回false就停止查找，结束函数，
// Bmp：子图数据；
// Range：为颜色变化范围；
// EnumImageProc：回调函数；
// lParam：调用回调函数时发出的参数，可省略。
function TBDBitmapData.EnumImage(Bmp: TBDBitmapData; const Range: TBDColorRange;
  EnumImageProc: TBDEnumImageProc; lParam: Integer): Boolean;
var
  X, Y: Integer;
  Res: Boolean;
begin
  result := false;
  Res := true;
  for Y := 0 to self.FHeight - Bmp.FHeight - 1 do
  begin
    for X := 0 to self.FWidth - Bmp.FWidth - 1 do
    begin
      if self.Compare(Bmp, Range, X, Y) then
      begin
        result := true;
        Res := EnumImageProc(X, Y, Bmp, lParam);
        if not Res then
          break;
      end;
    end;
    if not Res then
      break;
  end;
end;

// 从当前位图中查找指定的颜色，忽略self.FBackColor设置，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 按从左到右，从上到下的顺序查找，
// 找到返回true，设置Left和Top为找到颜色的位置，
// 没找到返回false，设置Left和Top为-1。
// Color：BGR格式颜色；
// Left：找到颜色的左边距；
// Top：找到颜色的顶边距。
function TBDBitmapData.FindColor(Color: TBDColor;
  var Left, Top: Integer): Boolean;
var
  X, Y, LineOff, Off: Integer;
begin
  result := false;
  LineOff := self.FSize;
  X := 0;
  for Y := 0 to self.FHeight - 1 do
  begin
    LineOff := LineOff - self.FLineWidth;
    Off := LineOff;
    for X := 0 to self.FWidth - 1 do
    begin
      result := ((PInteger(@(self.FBits[Off])))^ and $FFFFFF) = Color;
      if result then
        break;
      Off := Off + 3;
    end;
    if result then
      break;
  end;
  if result then
  begin
    Left := X;
    Top := Y;
  end
  else
  begin
    Left := -1;
    Top := -1;
  end;
end;

// 从当前位图中模糊查找指定的颜色，忽略self.FBackColor设置，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 按从左到右，从上到下的顺序查找，
// 找到返回true，设置Left和Top为找到颜色的位置，
// 没找到返回false，设置Left和Top为-1。
// Color：BGR格式颜色；
// Range：为颜色变化范围；
// Left：找到颜色的左边距；
// Top：找到颜色的顶边距。
function TBDBitmapData.FindColor(Color: TBDColor; const Range: TBDColorRange;
  var Left, Top: Integer): Boolean;
var
  X, Y, LineOff, Off: Integer;
begin
  result := false;
  LineOff := self.FSize;
  X := 0;
  for Y := 0 to self.FHeight - 1 do
  begin
    LineOff := LineOff - self.FLineWidth;
    Off := LineOff;
    for X := 0 to self.FWidth - 1 do
    begin
      result := BDCompareColor(((PInteger(@(self.FBits[Off])))^ and $FFFFFF),
        Color, Range);
      if result then
        break;
      Off := Off + 3;
    end;
    if result then
      break;
  end;
  if result then
  begin
    Left := X;
    Top := Y;
  end
  else
  begin
    Left := -1;
    Top := -1;
  end;
end;

// 从当前位图中查找指定的颜色，忽略self.FBackColor设置，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 以（Left，Top）为基点，从中心向四周查找，
// 找到返回true，设置Left和Top为找到颜色的位置，
// 没找到返回false，设置Left和Top为-1。
// Color：BGR格式颜色；
// Left：找到颜色的左边距；
// Top：找到颜色的顶边距。
function TBDBitmapData.FindCenterColor(Color: TBDColor;
  var Left, Top: Integer): Boolean;
var
  Aspect: TAspect;
  VisitCount, Count, i: Integer;
begin
  result := false;
  VisitCount := 0;
  Aspect := asUp;
  Count := 1;
  while VisitCount < (self.FWidth * self.FHeight) do
  begin
    for i := 0 to Count - 1 do
    begin
      if (Left >= 0) and (Left < self.FWidth) and (Top >= 0) and
        (Top < self.FHeight) then
      begin
        if self.GetPixels(Left, Top) = Color then
        begin
          result := true;
          break;
        end;
        VisitCount := VisitCount + 1;
      end;
      Left := Left + MoveVal[Aspect].X;
      Top := Top + MoveVal[Aspect].Y;
    end;
    if result then
      break;
    case Aspect of
      asLeft:
        begin
          Aspect := asUp;
          Count := Count + 1;
        end;
      asRight:
        begin
          Aspect := asDown;
          Count := Count + 1;
        end;
      asUp:
        begin
          Aspect := asRight;
        end;
      asDown:
        begin
          Aspect := asLeft;
        end;
    end;
  end;
  if not result then
  begin
    Left := -1;
    Top := -1;
  end;
end;

// 从当前位图中模糊查找指定的颜色，忽略self.FBackColor设置，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 以（Left，Top）为基点，从中心向四周查找，
// 找到返回true，设置Left和Top为找到颜色的位置，
// 没找到返回false，设置Left和Top为-1。
// Color：BGR格式颜色；
// Range：为颜色变化范围；
// Left：找到颜色的左边距；
// Top：找到颜色的顶边距。
function TBDBitmapData.FindCenterColor(Color: TBDColor;
  const Range: TBDColorRange; var Left, Top: Integer): Boolean;
var
  Aspect: TAspect;
  VisitCount, Count, i: Integer;
begin
  result := false;
  VisitCount := 0;
  Aspect := asUp;
  Count := 1;
  while VisitCount < (self.FWidth * self.FHeight) do
  begin
    for i := 0 to Count - 1 do
    begin
      if (Left >= 0) and (Left < self.FWidth) and (Top >= 0) and
        (Top < self.FHeight) then
      begin
        if BDCompareColor(self.GetPixels(Left, Top), Color, Range) then
        begin
          result := true;
          break;
        end;
        VisitCount := VisitCount + 1;
      end;
      Left := Left + MoveVal[Aspect].X;
      Top := Top + MoveVal[Aspect].Y;
    end;
    if result then
      break;
    case Aspect of
      asLeft:
        begin
          Aspect := asUp;
          Count := Count + 1;
        end;
      asRight:
        begin
          Aspect := asDown;
          Count := Count + 1;
        end;
      asUp:
        begin
          Aspect := asRight;
        end;
      asDown:
        begin
          Aspect := asLeft;
        end;
    end;
  end;
  if not result then
  begin
    Left := -1;
    Top := -1;
  end;
end;

// 从当前位图中查找所有指定的颜色，忽略self.FBackColor设置，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 按从左到右，从上到下的顺序查找，
// 每找到一个颜色，就调用回调函数EnumColorProc，如果EnumColorProc
// 返回false就停止查找，结束函数，
// Color：BGR格式颜色；
// EnumColorProc：回调函数；
// lParam：调用回调函数时发出的参数，可省略。
function TBDBitmapData.EnumColor(Color: TBDColor;
  EnumColorProc: TBDEnumColorProc; lParam: Integer): Boolean;
var
  X, Y, LineOff, Off: Integer;
  Res: Boolean;
  C: TBDColor;
begin
  result := false;
  LineOff := self.FSize;
  Res := true;
  for Y := 0 to self.FHeight - 1 do
  begin
    LineOff := LineOff - self.FLineWidth;
    Off := LineOff;
    for X := 0 to self.FWidth - 1 do
    begin
      C := ((PInteger(@(self.FBits[Off])))^ and $FFFFFF);
      result := C = Color;
      if result then
      begin
        Res := EnumColorProc(X, Y, C, lParam);
        if not Res then
          break;
      end;
      Off := Off + 3;
    end;
    if not Res then
      break;
  end;
end;

// 从当前位图中模糊查找所有指定的颜色，忽略self.FBackColor设置，返回是否找到，
// 无论是否找到都不会修改self.Error，
// 按从左到右，从上到下的顺序查找，
// 每找到一个颜色，就调用回调函数EnumColorProc，如果EnumColorProc
// 返回false就停止查找，结束函数，
// Color：BGR格式颜色；
// Range：为颜色变化范围；
// EnumColorProc：回调函数；
// lParam：调用回调函数时发出的参数，可省略。
function TBDBitmapData.EnumColor(Color: TBDColor; const Range: TBDColorRange;
  EnumColorProc: TBDEnumColorProc; lParam: Integer): Boolean;
var
  X, Y, LineOff, Off: Integer;
  Res: Boolean;
  C: TBDColor;
begin
  result := false;
  LineOff := self.FSize;
  Res := true;
  for Y := 0 to self.FHeight - 1 do
  begin
    LineOff := LineOff - self.FLineWidth;
    Off := LineOff;
    for X := 0 to self.FWidth - 1 do
    begin
      C := ((PInteger(@(self.FBits[Off])))^ and $FFFFFF);
      result := BDCompareColor(C, Color, Range);
      if result then
      begin
        Res := EnumColorProc(X, Y, C, lParam);
        if not Res then
          break;
      end;
      Off := Off + 3;
    end;
    if not Res then
      break;
  end;
end;

// 单元初始化
initialization

begin
  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);
  IconWidth := GetSystemMetrics(SM_CXICON);
  IconHeight := GetSystemMetrics(SM_CYICON);
end;

end.
