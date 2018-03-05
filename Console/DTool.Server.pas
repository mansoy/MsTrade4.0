unit DTool.Server;

interface

uses
  Winapi.Windows, Winapi.Messages, Classes, blcksock, synsock, uSharedInfo;

type
  TTCPEchoDaemon = class(TThread)
  private
    Sock:TTCPBlockSocket;
  public
    Constructor Create;
    Destructor Destroy; override;
    procedure Execute; override;
  end;

  TTCPEchoThrd = class(TThread)
  private
    Sock:TTCPBlockSocket;
    CSock: TSocket;
  public
    Constructor Create (hsock:tSocket);
    procedure Execute; override;
  end;

var
  SocketLst: TThreadList;   //发货机列表

implementation

{ TEchoDaemon }

Constructor TTCPEchoDaemon.Create;
begin
  inherited create(false);
  sock:=TTCPBlockSocket.create;
  FreeOnTerminate:=true;
end;

Destructor TTCPEchoDaemon.Destroy;
begin
  Sock.free;
end;

procedure TTCPEchoDaemon.Execute;
var
  ClientSock:TSocket;
begin
  with Sock do
    begin
      CreateSocket;
      setLinger(true,10000);
      bind('0.0.0.0','8008');
      listen;
      repeat
        if terminated then break;
        if canread(1000) then
          begin
            ClientSock := Accept;
            if lastError=0 then begin
              TTCPEchoThrd.create(ClientSock);
            end;
          end;
      until false;
    end;
end;

{ TEchoThrd }

Constructor TTCPEchoThrd.Create(Hsock:TSocket);
begin
  inherited create(false);
  Csock := Hsock;
  FreeOnTerminate:=true;
end;

procedure TTCPEchoThrd.Execute;
var
  sRec: AnsiString;
  sIP : string;
  iPort : Integer;
  SendMachineInfo: TSendMachineInfo;
begin
  Sock:=TTCPBlockSocket.create;
  try
    Sock.Socket:=CSock;
    Sock.GetSins;
    //--远程连接的信息
    sIP := Sock.GetRemoteSinIP;
    iPort := Sock.GetRemoteSinPort;
    //--
    if Sock.LastError <> 0 then begin
      Exit;
    end;
    while not Terminated do begin
      sRec := Sock.RecvPacket(60000);
      Sock.RecvBuffer(@SendMachineInfo, SizeOf(SendMachineInfo));
      if Sock.LastError <> 0 then Break;
      //Move(BytesOf(sRec)[0], PAnsiChar(@SendMachineInfo)[0], SizeOf(TSendMachineInfo));
      Sock.SendString('收到结构体信息');
      uSharedInfo.AddLogMes(sRec);
    end;
  finally
    Sock.Free;
  end;
end;

end.
