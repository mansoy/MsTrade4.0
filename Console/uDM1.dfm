object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 294
  Width = 259
  object cdsConn: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'ConnID'
        DataType = ftInteger
      end
      item
        Name = 'GroupName'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'OrderNo'
        DataType = ftString
        Size = 50
      end
      item
        Name = 'GameArea'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'GameSvr'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'Account'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'SendMachineState'
        DataType = ftInteger
      end
      item
        Name = 'LogText'
        DataType = ftString
        Size = 200
      end
      item
        Name = 'Interval'
        DataType = ftLongWord
      end
      item
        Name = 'Json'
        DataType = ftMemo
      end
      item
        Name = 'TaskState'
        DataType = ftInteger
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 40
    Top = 25
  end
  object dsConn: TDataSource
    DataSet = cdsConn
    Left = 131
    Top = 25
  end
  object cdsConnDetail: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'ConnID'
        DataType = ftInteger
      end
      item
        Name = 'Num'
        DataType = ftInteger
      end
      item
        Name = 'LogText'
        DataType = ftString
        Size = 200
      end
      item
        Name = 'Role'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'Stock'
        DataType = ftInteger
      end
      item
        Name = 'RowID'
        DataType = ftInteger
      end
      item
        Name = 'State'
        DataType = ftInteger
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 40
    Top = 73
  end
  object dsConnDetail: TDataSource
    DataSet = cdsConnDetail
    Left = 131
    Top = 73
  end
  object cdsOrder: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'TaskType'
        DataType = ftInteger
      end
      item
        Name = 'OrderNo'
        DataType = ftString
        Size = 50
      end
      item
        Name = 'GameArea'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'GameSvr'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'Account'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'PassWord'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'ConsoleID'
        DataType = ftString
        Size = 32
      end
      item
        Name = 'ReceiptRole'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'ReceiptRoleLevel'
        DataType = ftInteger
      end
      item
        Name = 'SafeWay'
        DataType = ftInteger
      end
      item
        Name = 'CheckLevel'
        DataType = ftBoolean
      end
      item
        Name = 'SaleNum'
        DataType = ftInteger
      end
      item
        Name = 'Json'
        DataType = ftMemo
      end
      item
        Name = 'IsDoing'
        DataType = ftBoolean
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 40
    Top = 177
  end
  object dsOrder: TDataSource
    DataSet = cdsOrder
    Left = 131
    Top = 177
  end
  object cdsOrderDetail: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'RowID'
        DataType = ftInteger
      end
      item
        Name = 'RoleID'
        DataType = ftInteger
      end
      item
        Name = 'RoleName'
        DataType = ftString
        Size = 20
      end
      item
        Name = 'SendNum'
        DataType = ftInteger
      end
      item
        Name = 'EachNum'
        DataType = ftInteger
      end
      item
        Name = 'Stock'
        DataType = ftInteger
      end
      item
        Name = 'IsMain'
        DataType = ftBoolean
      end
      item
        Name = 'Account'
        DataType = ftString
        Size = 20
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 40
    Top = 121
  end
  object dsOrderDetail: TDataSource
    DataSet = cdsOrderDetail
    Left = 131
    Top = 121
  end
end
