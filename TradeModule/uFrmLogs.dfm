object FrmLogs: TFrmLogs
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'FrmLogs'
  ClientHeight = 300
  ClientWidth = 396
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object LstLog: TListBox
    Left = 0
    Top = 0
    Width = 396
    Height = 265
    Align = alClient
    ImeName = #20013#25991'('#31616#20307') - '#24517#24212' Bing '#36755#20837#27861
    ItemHeight = 13
    Items.Strings = (
      'asfaf'
      'sfsagsag')
    MultiSelect = True
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 0
    Top = 265
    Width = 396
    Height = 35
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      396
      35)
    object btnClear: TButton
      Left = 202
      Top = 5
      Width = 57
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #28165#38500
      TabOrder = 0
      OnClick = btnClearClick
    end
    object btnSelAll: TButton
      Left = 265
      Top = 5
      Width = 57
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #20840#36873
      TabOrder = 1
      OnClick = btnSelAllClick
    end
    object btnCopy: TButton
      Left = 328
      Top = 5
      Width = 57
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #22797#21046
      TabOrder = 2
      OnClick = btnCopyClick
    end
    object chkAutoConn: TCheckBox
      Left = 11
      Top = 8
      Width = 78
      Height = 17
      Caption = #33258#21160#37325#36830
      TabOrder = 3
      OnClick = chkAutoConnClick
    end
  end
  object Timer1: TTimer
    Interval = 5000
    Left = 232
    Top = 32
  end
  object IdIPWatch1: TIdIPWatch
    Active = False
    HistoryFilename = 'iphist.dat'
    Left = 184
    Top = 48
  end
end
