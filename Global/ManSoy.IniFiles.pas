unit ManSoy.IniFiles;

interface

uses Winapi.Windows, System.IniFiles, System.RTLConsts;

type
  TMSIniFile= class(TIniFile)
  public
    procedure WriteStruct(const Section, Ident: string; Value: Pointer; Size: Cardinal);
    procedure ReadStruct(const Section, Ident: string; Value: Pointer; Size: Cardinal);
  end;
implementation

{ TMSIniFile }

procedure TMSIniFile.ReadStruct(const Section, Ident: string; Value: Pointer; Size: Cardinal);
begin
  GetPrivateProfileStruct(PChar(Section), PChar(Ident), Value, Size, PChar(FileName))
end;

procedure TMSIniFile.WriteStruct(const Section, Ident: string; Value: Pointer; Size: Cardinal);
begin
  if not WritePrivateProfileStruct(PChar(Section), PChar(Ident),
                                   Value, Size, PChar(FileName)) then
    raise EIniFileException.CreateResFmt(@SIniFileWriteError, [FileName]);
end;

end.
