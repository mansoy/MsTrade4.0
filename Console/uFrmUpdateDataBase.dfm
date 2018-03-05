object FrmUpdateDataBase: TFrmUpdateDataBase
  Left = 0
  Top = 0
  Caption = #20462#22797#34920#29366#24577
  ClientHeight = 369
  ClientWidth = 796
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 796
    Height = 49
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 200
      Top = 18
      Width = 48
      Height = 13
      Caption = #35746#21333#32534#21495
    end
    object RadioGroup1: TRadioGroup
      Left = 1
      Top = 1
      Width = 185
      Height = 47
      Align = alLeft
      Caption = #20219#21153#31867#22411
      Columns = 3
      ItemIndex = 0
      Items.Strings = (
        #21457#36135
        #20998#20179
        #26816#24211)
      TabOrder = 0
      OnClick = RadioGroup1Click
    end
    object edtOrderNo: TEdit
      Left = 254
      Top = 15
      Width = 225
      Height = 21
      TabOrder = 1
    end
    object btnQuery: TButton
      Left = 500
      Top = 13
      Width = 75
      Height = 25
      Caption = #26597#35810
      TabOrder = 2
      OnClick = btnQueryClick
    end
    object btnPost: TButton
      Left = 581
      Top = 13
      Width = 75
      Height = 25
      Caption = #25552#20132
      TabOrder = 3
      OnClick = btnPostClick
    end
  end
  object cxGrid1: TcxGrid
    Left = 0
    Top = 49
    Width = 796
    Height = 320
    Align = alClient
    TabOrder = 1
    LevelTabs.Style = 10
    RootLevelOptions.DetailTabsPosition = dtpTop
    object TvFH: TcxGridBandedTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsData.Deleting = False
      OptionsData.Inserting = False
      OptionsView.CellEndEllipsis = True
      OptionsView.GroupByBox = False
      OptionsView.HeaderHeight = 35
      OptionsView.BandHeaders = False
      Bands = <
        item
        end>
      object TvFHRowId: TcxGridBandedColumn
        Caption = 'ID'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Filtering = False
        Options.Focusing = False
        Width = 50
        Position.BandIndex = 0
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object TvFHOrderNo: TcxGridBandedColumn
        Caption = #35746#21333#32534#21495
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Filtering = False
        Options.Focusing = False
        Width = 140
        Position.BandIndex = 0
        Position.ColIndex = 1
        Position.RowIndex = 0
      end
      object TvFHAccount: TcxGridBandedColumn
        Caption = 'QQ'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Filtering = False
        Options.Focusing = False
        Width = 70
        Position.BandIndex = 0
        Position.ColIndex = 2
        Position.RowIndex = 0
      end
      object TvFHRoleName: TcxGridBandedColumn
        Caption = #21457#36135#35282#33394
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Filtering = False
        Options.Focusing = False
        Width = 70
        Position.BandIndex = 0
        Position.ColIndex = 3
        Position.RowIndex = 0
      end
      object TvFHSaleNum: TcxGridBandedColumn
        Caption = #21457#36135#13#10#25968#37327
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Filtering = False
        Options.Focusing = False
        Width = 50
        Position.BandIndex = 0
        Position.ColIndex = 4
        Position.RowIndex = 0
      end
      object TvFHKcNum: TcxGridBandedColumn
        Caption = #24211#23384#13#10#25968#37327
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Filtering = False
        Options.Focusing = False
        Width = 50
        Position.BandIndex = 0
        Position.ColIndex = 5
        Position.RowIndex = 0
      end
      object TvFHSyNum: TcxGridBandedColumn
        Caption = #21097#20313#13#10#25968#37327
        HeaderAlignmentHorz = taCenter
        Options.Filtering = False
        Width = 50
        Position.BandIndex = 0
        Position.ColIndex = 6
        Position.RowIndex = 0
      end
      object TvFHState: TcxGridBandedColumn
        Caption = #29366#24577
        RepositoryItem = cxEditRepository1ImageComboBoxItem1
        HeaderAlignmentHorz = taCenter
        Options.Filtering = False
        Position.BandIndex = 0
        Position.ColIndex = 7
        Position.RowIndex = 0
      end
      object TvFHCatchReason: TcxGridBandedColumn
        Caption = #24322#24120#21407#22240
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Filtering = False
        Options.Focusing = False
        Width = 150
        Position.BandIndex = 0
        Position.ColIndex = 8
        Position.RowIndex = 0
      end
      object TvFHDBItem: TcxGridBandedColumn
        DataBinding.ValueType = 'LargeInt'
        VisibleForCustomization = False
        Position.BandIndex = 0
        Position.ColIndex = 9
        Position.RowIndex = 0
      end
    end
    object TvFC: TcxGridBandedTableView
      Navigator.Buttons.CustomButtons = <>
      DataController.Summary.DefaultGroupSummaryItems = <>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      OptionsView.GroupByBox = False
      OptionsView.HeaderHeight = 35
      Bands = <
        item
          Caption = #22522#26412#20449#24687
        end
        item
          Caption = #20027#21495
        end
        item
          Caption = #23376#21495
        end
        item
          Caption = #20854#20182#20449#24687
        end>
      object TvFcRowId: TcxGridBandedColumn
        Caption = 'ID'
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 40
        Position.BandIndex = 0
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object TvFcOrderNo: TcxGridBandedColumn
        Caption = #35746#21333#32534#21495
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 100
        Position.BandIndex = 0
        Position.ColIndex = 1
        Position.RowIndex = 0
      end
      object TvFcGroupNo: TcxGridBandedColumn
        Caption = #32452#32534#21495
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 100
        Position.BandIndex = 0
        Position.ColIndex = 2
        Position.RowIndex = 0
      end
      object TvFcOutAccount: TcxGridBandedColumn
        Caption = #36134#21495
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 70
        Position.BandIndex = 1
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object TvFcOutRoleName: TcxGridBandedColumn
        Caption = #35282#33394
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Position.BandIndex = 1
        Position.ColIndex = 1
        Position.RowIndex = 0
      end
      object TvFcOutRoleKc: TcxGridBandedColumn
        Caption = #24211#23384#13#10#25968#37327
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 45
        Position.BandIndex = 1
        Position.ColIndex = 2
        Position.RowIndex = 0
      end
      object TvFcOutSyNum: TcxGridBandedColumn
        Caption = #21097#20313#13#10#25968#37327
        PropertiesClassName = 'TcxSpinEditProperties'
        Properties.AssignedValues.MaxValue = True
        Properties.MinValue = -1.000000000000000000
        HeaderAlignmentHorz = taCenter
        Width = 50
        Position.BandIndex = 1
        Position.ColIndex = 3
        Position.RowIndex = 0
      end
      object TvFcInAccount: TcxGridBandedColumn
        Caption = #36134#21495
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 70
        Position.BandIndex = 2
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object TvFcInRoleName: TcxGridBandedColumn
        Caption = #35282#33394
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Position.BandIndex = 2
        Position.ColIndex = 1
        Position.RowIndex = 0
      end
      object TvFcDBItem: TcxGridBandedColumn
        Visible = False
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Position.BandIndex = 3
        Position.ColIndex = 2
        Position.RowIndex = 0
      end
      object TvFcInRoleKc: TcxGridBandedColumn
        Caption = #24211#23384#13#10#25968#37327
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 45
        Position.BandIndex = 2
        Position.ColIndex = 2
        Position.RowIndex = 0
      end
      object TvFcInSyNum: TcxGridBandedColumn
        Caption = #21097#20313#13#10#25968#37327
        PropertiesClassName = 'TcxSpinEditProperties'
        Properties.AssignedValues.MaxValue = True
        Properties.MinValue = -1.000000000000000000
        HeaderAlignmentHorz = taCenter
        Width = 50
        Position.BandIndex = 2
        Position.ColIndex = 3
        Position.RowIndex = 0
      end
      object TvFcOutNum: TcxGridBandedColumn
        Caption = #20986#36135#13#10#25968#37327
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 45
        Position.BandIndex = 0
        Position.ColIndex = 3
        Position.RowIndex = 0
      end
      object TvFcOrderState: TcxGridBandedColumn
        Caption = #29366#24577
        RepositoryItem = cxEditRepository1ImageComboBoxItem1
        HeaderAlignmentHorz = taCenter
        Width = 60
        Position.BandIndex = 3
        Position.ColIndex = 0
        Position.RowIndex = 0
      end
      object TvFcCatchReason: TcxGridBandedColumn
        Caption = #24322#24120#21407#22240
        HeaderAlignmentHorz = taCenter
        Options.Editing = False
        Options.Focusing = False
        Width = 120
        Position.BandIndex = 3
        Position.ColIndex = 1
        Position.RowIndex = 0
      end
    end
    object LvFH: TcxGridLevel
      Caption = #21457#36135
      GridView = TvFH
    end
    object LvFK: TcxGridLevel
      Caption = #20998#24211
      GridView = TvFC
    end
    object LvPK: TcxGridLevel
      Caption = #26816#24211
    end
  end
  object cxEditRepository1: TcxEditRepository
    Left = 112
    Top = 160
    object cxEditRepository1ImageComboBoxItem1: TcxEditRepositoryImageComboBoxItem
      Properties.Items = <
        item
          Description = #25104#21151
          ImageIndex = 0
          Value = 0
        end
        item
          Description = #22833#36133'('#23545#26041')'
          Value = 55
        end
        item
          Description = #23601#32490
          Value = 10
        end
        item
          Description = #38431#21015#20013
          Value = 15
        end
        item
          Description = #22788#29702#20013
          Value = 20
        end
        item
          Description = #22833#36133'('#33258#24049')'
          Value = 50
        end>
    end
  end
end
