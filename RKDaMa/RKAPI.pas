unit RKAPI;

interface

uses SysUtils, Classes, IdHTTP;

function HTTPGetImage(const AImageURL: string; AResponse: TStream): Boolean;

function HTTPRequestRKRegisterAccount(const AUser, APass, AEMail: string): string;
function RKRegisterAccount(const AUser, APass, AEMail: string;
  var AResultText: string): Boolean;

function HTTPRequestRKInfo(): string;
function RKInfo(var AScore, AResultText: string): Boolean;

function HTTPRequestRKRecharge(const ARechargeId, ARechargePassword: string): string;
function RKRecharge(const ARechargeId, ARechargePassword: string;
  var AResultText: string): Boolean;

function HTTPRequestRKReportError(const AErrorId: string): string;
function RKReportError(const AErrorId: string; var AResultText: string): Boolean;

function HTTPRequestRKCreate(const ATypeId: string; AImageStream: TMemoryStream): string; overload;
function RKCreate(const ATypeId, AImageFile: string;
  var AResultCode, AResultId, AResultText: string): Boolean; overload;
function HTTPRequestRKCreate(const ATypeId, AImageFile: string): string; overload;
function RKCreate(const ATypeId: string; AImageStream: TMemoryStream;
  var AResultCode, AResultId, AResultText: string): Boolean; overload;

{$ifdef debug}
var
  OnHTTPRespEvent: procedure(const AResponseXMLString: string) = nil;

{$endif}
implementation

uses RKUtils, QJson;

function HTTPGetImage(const AImageURL: string; AResponse: TStream): Boolean;
var
  HTTP: TIdHTTP;
begin
  Result := False;
  AResponse.Size := 0;
  HTTP := TIdHTTP.Create(nil);
  try
  {$ifdef unicode}
    HTTP.Request.UserAgent := 'API-HTTP-Delphi-unicode';
  {$else}
    HTTP.Request.UserAgent := 'API-HTTP-Delphi-ansi';
  {$endif}
    HTTP.ReadTimeout := 60000;
    HTTP.HandleRedirects := true;
    try
      HTTP.Get(AImageURL, AResponse);
      Result := AResponse.Size > 0;
    except
      on E: Exception do
        ; // TODO: log exception to file
    end;
  finally
    HTTP.Free;
  end;
end;

function HTTPPost(const AURL: string; AParams: TStringStream;
  AContentType: string = ''; AOptions: TIdHTTPOptions = [];
  AHTTPTimeout: Integer = 60000): string; overload;
var
  HTTP: TIdHTTP;
  //RespText: string;
begin
  Result := '';
  HTTP := TIdHTTP.Create(nil);
  try
  {$ifdef unicode}
    HTTP.Request.UserAgent := 'API-HTTP-Delphi-unicode';
  {$else}
    HTTP.Request.UserAgent := 'API-HTTP-Delphi-ansi';
  {$endif}
    if AContentType = '' then
      HTTP.Request.ContentType := 'application/x-www-form-urlencoded'
    else
      HTTP.Request.ContentType := AContentType;
    if AOptions <> [] then
    begin
      HTTP.HTTPOptions := AOptions;
      if hoKeepOrigProtocol in AOptions then
        HTTP.ProtocolVersion := pv1_1;
    end;
    HTTP.ReadTimeout := AHTTPTimeout;
    HTTP.HandleRedirects := true;
    try
      AParams.Position := 0;
      Result := HTTP.Post(AURL, AParams);
    {$ifdef debug}
      if Assigned(OnHTTPRespEvent) then
      {$ifdef unicode}
        OnHTTPRespEvent(Result);
      {$else}
        OnHTTPRespEvent(UTF8Decode(Result))
      {$endif}
    {$endif}
    except
      on E: Exception do
        ; // TODO: log exception to file
    end;
  finally
    HTTP.Free;
  end;
end;

function HTTPRequestRKRegisterAccount(const AUser, APass, AEMail: string): string;
const
  SFormat = 'username=%s&password=%s&email=%s';
var
  ParamList: TStringStream;
begin
  ParamList := TStringStream.Create(Format(SFormat, [AUser, APass, AEMail]));
  try
    Result := HTTPPost('http://api.ruokuai.com/register.xml', ParamList);
  finally
    ParamList.Free;
  end;
end;

function RKRegisterAccount(const AUser, APass, AEMail: string;
  var AResultText: string): Boolean;
//var
//  RespXML: string;
//  Doc: IXMLDocument;
//  RootNode, ResultNode, ErrorNode: IXMLNode;
begin
  Result := False;
  {
  AResultText := '未知原因(网络可能有错误)';
  RespXML := HTTPRequestRKRegisterAccount(AUser, APass, AEMail);
  if RespXML = '' then Exit;

  Doc := TXMLDocument.Create(nil);
  try
    Doc.LoadFromXML(RespXML);
    RootNode := Doc.ChildNodes.FindNode('Root');
    if (RootNode <> nil) and (RootNode.HasChildNodes) then
    begin
      ResultNode := RootNode.ChildNodes.FindNode('Result');
      Result := (ResultNode <> nil);
      if Result then
        AResultText := ResultNode.Text
      else
      begin
        ErrorNode := RootNode.ChildNodes.FindNode('Error');
        if ErrorNode <> nil then
          AResultText := ErrorNode.Text;
      end;
    end;
  finally
    Doc := nil;
  end;
  }
end;

function HTTPRequestRKInfo(): string;
const
  SFormat = 'username=%s&password=%s';
var
  ParamList: TStringStream;
begin
  ParamList := TStringStream.Create(Format(SFormat, [RKConfig.User, RKConfig.Pass]));
  try
    Result := HTTPPost('http://api.ruokuai.com/info.xml', ParamList);
  finally
    ParamList.Free;
  end;
end;

function RKInfo(var AScore, AResultText: string): Boolean;
//var
//  RespXML: string;
//  Doc: IXMLDocument;
//  RootNode, ScoreNode, ErrorNode: IXMLNode;
begin
  Result := False;
  {
  AResultText := '未知原因(网络可能有错误)';
  RespXML := HTTPRequestRKInfo();
  if RespXML = '' then Exit;

  Doc := TXMLDocument.Create(nil);
  try
    Doc.LoadFromXML(RespXML);
    RootNode := Doc.ChildNodes.FindNode('Root');
    if (RootNode <> nil) and (RootNode.HasChildNodes) then
    begin
      ScoreNode := RootNode.ChildNodes.FindNode('Score');
      Result := (ScoreNode <> nil);
      if Result then
        AScore := ScoreNode.Text
      else
      begin
        ErrorNode := RootNode.ChildNodes.FindNode('Error');
        if ErrorNode <> nil then
          AResultText := ErrorNode.Text;
      end;
    end;
  finally
    Doc := nil;
  end;
  }
end;

function HTTPRequestRKRecharge(const ARechargeId, ARechargePassword: string): string;
const
  SFormat = 'username=%s&password=%s&id=%s';
var
  ParamList: TStringStream;
begin
  ParamList := TStringStream.Create(Format(SFormat, [RKConfig.User, ARechargePassword, ARechargeId]));
  try
    Result := HTTPPost('http://api.ruokuai.com/recharge.xml', ParamList);
  finally
    ParamList.Free;
  end;
end;

function RKRecharge(const ARechargeId, ARechargePassword: string;
  var AResultText: string): Boolean;
//var
//  RespXML: string;
//  Doc: IXMLDocument;
//  RootNode, ResultNode, ErrorNode: IXMLNode;
begin
  Result := False;
  {
  AResultText := '未知原因(网络可能有错误)';
  RespXML := HTTPRequestRKRecharge(ARechargeId, ARechargePassword);
  if RespXML = '' then Exit;

  Doc := TXMLDocument.Create(nil);
  try
    Doc.LoadFromXML(RespXML);
    RootNode := Doc.ChildNodes.FindNode('Root');
    if (RootNode <> nil) and (RootNode.HasChildNodes) then
    begin
      ResultNode := RootNode.ChildNodes.FindNode('Result');
      Result := (ResultNode <> nil);
      if Result then
        AResultText := ResultNode.Text
      else
      begin
        ErrorNode := RootNode.ChildNodes.FindNode('Error');
        if ErrorNode <> nil then
          AResultText := ErrorNode.Text;
      end;
    end;
  finally
    Doc := nil;
  end;
  }
end;

function HTTPRequestRKReportError(const AErrorId: string): string;
const
  SFormat = 'username=%s&password=%s&softid=%s&softkey=%s&id=%s';
var
  ParamList: TStringStream;
begin
  ParamList := TStringStream.Create(Format(SFormat, [RKConfig.User, RKConfig.Pass,
    RKConfig.SoftId, RKConfig.SoftKey, AErrorId]));
  try
    Result := HTTPPost('http://api.ruokuai.com/reporterror.xml', ParamList);
  finally
    ParamList.Free;
  end;
end;

function RKReportError(const AErrorId: string; var AResultText: string): Boolean;
//var
//  RespXML: string;
//  Doc: IXMLDocument;
//  RootNode, ResultNode, ErrorNode: IXMLNode;
begin
  Result := False;
  {
  AResultText := '未知原因(网络可能有错误)';
  RespXML := HTTPRequestRKReportError(AErrorId);
  if RespXML = '' then Exit;

  Doc := TXMLDocument.Create(nil);
  try
    Doc.LoadFromXML(RespXML);
    RootNode := Doc.ChildNodes.FindNode('Root');
    if (RootNode <> nil) and (RootNode.HasChildNodes) then
    begin
      ResultNode := RootNode.ChildNodes.FindNode('Result');
      Result := (ResultNode <> nil);
      if Result then
        AResultText := ResultNode.Text
      else
      begin
        ErrorNode := RootNode.ChildNodes.FindNode('Error');
        if ErrorNode <> nil then
          AResultText := ErrorNode.Text;
      end;
    end;
  finally
    Doc := nil;
  end;
  }
end;

//
// http://api.ruokuai.com/create.json(扩展名支持.txt|.xml)
// username	true	string	用户名。
// password	true	string	用户密码。(支持32位MD5)
// typeid	true	int	题目类型，参考(代码表)。
// timeout	false	int	任务超时时间，默认与最小值为60秒。
// softid	true	int	软件ID，开发者可自行申请。
// softkey	true	string	软件KEY，开发者可自行申请。
// image	true	byte	题目截图或原始图二进制数据。
//
function HTTPRequestRKCreate(const ATypeId: string; AImageStream: TMemoryStream): string; overload;
const
  SContentTypeFormat =
    'multipart/form-data; boundary=---------------------------%s';
  SPartFormat =
    '-----------------------------%s'#13#10 +
    'Content-Disposition: form-data; name="%s"'#13#10#13#10 +
    '%s'#13#10;
  SImagePartFormat =
    '-----------------------------%s'#13#10 +
    'Content-Disposition: form-data; name="image"; filename="System.Byte[]"'#13#10 +
    'Content-Type: image/gif'#13#10#13#10;
  SPartEnd = #13#10'-----------------------------%s--'#13#10;
var
  PartKey, CntType: string;
  ParamList: TStringStream;
begin
  ParamList := TStringStream.Create('');
  try
    PartKey := GetRandomPartKey;
    ParamList.WriteString(Format(SPartFormat, [PartKey, 'username', 'zdfhyzm']));
    ParamList.WriteString(Format(SPartFormat, [PartKey, 'password', '123456aaa']));
    ParamList.WriteString(Format(SPartFormat, [PartKey, 'typeid', ATypeId]));
    // timeout时间
    ParamList.WriteString(Format(SPartFormat, [PartKey, 'timeout', '90']));
    ParamList.WriteString(Format(SPartFormat, [PartKey, 'softid', '101707']));
    ParamList.WriteString(Format(SPartFormat, [PartKey, 'softkey', 'd566ec6b71ae4e83ace82d33827db751']));
    ParamList.WriteString(Format(SImagePartFormat, [PartKey]));
    ParamList.Write(AImageStream.Memory^, AImageStream.Size);
    ParamList.WriteString(Format(SPartEnd, [PartKey]));
    CntType := Format(SContentTypeFormat, [PartKey]);
    Result := HTTPPost('http://api.ruokuai.com/create.json', ParamList, CntType,
      [hoForceEncodeParams, hoKeepOrigProtocol], 95000);
  finally
    ParamList.Free;
  end;
end;

function HTTPRequestRKCreate(const ATypeId, AImageFile: string): string; overload;
var
  Stream: TMemoryStream;
begin
  if FileExists(AImageFile) then
  begin
    Stream := TMemoryStream.Create;
    try
      Stream.LoadFromFile(AImageFile);
      if Stream.Size > 0 then
        Result := HTTPRequestRKCreate(ATypeId, Stream)
      else
        Result := '';
    finally
      Stream.Free;
    end;
  end else
    Result := '';
end;

function RKCreate(const ATypeId: string; AImageStream: TMemoryStream;
  var AResultCode, AResultId, AResultText: string): Boolean; overload;
var
  RespXML: string;
  vJson, vIdNode, vErrorNode, vResultNode: TQJson;
begin
  Result := False;
  AResultText := '未知原因(网络可能有错误)';
  RespXML := HTTPRequestRKCreate(ATypeId, AImageStream);
  if RespXML = '' then Exit;
  vJson := TQJson.Create;
  try
    vJson.Parse(RespXML);
    vResultNode := vJson.ItemByName('Result');
    vIdNode := vJson.ItemByName('Id');
    Result := (vIdNode <> nil) and (vResultNode <> nil);
    if Result then
    begin
      AResultCode := vResultNode.AsString;
      AResultId := vIdNode.AsString;
    end else
    begin
      vErrorNode := vJson.ItemByName('Error');
        if vErrorNode <> nil then
          AResultText := vErrorNode.AsString;
    end;
  finally
    FreeAndNil(vJson);
  end;
end;

function RKCreate(const ATypeId, AImageFile: string;
  var AResultCode, AResultId, AResultText: string): Boolean; overload;
var
  Stream: TMemoryStream;
begin
  Result := False;
  if FileExists(AImageFile) then
  begin
    Stream := TMemoryStream.Create;
    try
      Stream.LoadFromFile(AImageFile);
      if Stream.Size > 0 then
        Result := RKCreate(ATypeId, Stream, AResultCode, AResultId, AResultText);
    finally
      Stream.Free;
    end;
  end;
end;

end.
