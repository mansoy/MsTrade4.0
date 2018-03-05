unit uLogger;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  uJsonClass,
  uGlobal,
  uCommand,
  SuperObject;

type
  TLogthread = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TLogManager = class
  private
    Items: TQueue<TLogItem>;
    Cs: TRTLCriticalSection;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddItem(ALogType: Integer; ALogLevel: string; AOrderNo: string; ADetailNo: Integer; AAccFlag: string; Aip: string; AContent: string); overload;
    procedure AddItem(ALogItem: TLogItem); overload;
    function GetItem: TLogItem;
    //property Items: TQueue<TLogItem> read FItems write FItems;
    property Count: Integer read GetCount;
  end;

var
  LogManager: TLogManager;
  LogThread: TLogthread;

implementation

//uses
//  uTradeClient;

{ TLogthread }

constructor TLogthread.Create;
begin
  FreeOnTerminate := True;
  inherited;
end;

destructor TLogthread.Destroy;
begin

  inherited;
end;

procedure TLogthread.Execute;
var
  vLogItem: TLogItem;
  sJson: string;
begin
  //inherited;
  while True do
  try
    Sleep(100);
    if GAppQuit then Break;
    if LogManager.Count = 0 then Continue;
    vLogItem := LogManager.GetItem;
    if vLogItem = nil then Continue;
    { TODO : 在这里提交日志 }
    uCommand.PostLog(vLogItem, GConsoleSet.LogInterface);
    FreeAndNil(vLogItem);
  except
  end;
end;

{ TLogManager }

procedure TLogManager.AddItem(ALogType: Integer; ALogLevel, AOrderNo: string; ADetailNo: Integer; AAccFlag, Aip,
  AContent: string);
var
  vLogItem: TLogItem;
begin
  EnterCriticalSection(Cs);
  try
    vLogItem := TLogItem.Create;
    vLogItem.groupName := GSharedInfo.ClientSet.GroupName;
    vLogItem.logType := IntToStr(ALogType);
    vLogItem.logLevel := ALogLevel;
    vLogItem.orderNo := AOrderNo;
    vLogItem.detailNo := ADetailNo;
    vLogItem.accFlag := AAccFlag;
    vLogItem.iP := Aip;
    vLogItem.content := AContent;
    Items.Enqueue(vLogItem);
  finally
    LeaveCriticalSection(Cs);
  end;
end;

procedure TLogManager.AddItem(ALogItem: TLogItem);
begin
  EnterCriticalSection(Cs);
  try
    Items.Enqueue(ALogItem);
  finally
    LeaveCriticalSection(Cs);
  end;
end;

constructor TLogManager.Create;
begin
  Items := TQueue<TLogItem>.Create;
  InitializeCriticalSection(Cs);
end;

destructor TLogManager.Destroy;
begin
  DeleteCriticalSection(Cs);
  Items.Free;
  inherited;
end;

function TLogManager.GetCount: Integer;
begin
  Result := Items.Count;
end;

function TLogManager.GetItem: TLogItem;
begin
  Result := nil;
  EnterCriticalSection(Cs);
  try
    if Count = 0 then Exit;
    Result := Items.Dequeue;
  finally
    LeaveCriticalSection(Cs);
  end;
end;

initialization
  LogManager := TLogManager.Create;
  Logthread := TLogthread.Create;

finalization
  FreeAndNil(LogManager);

end.
