{

This is a datapump for interbase, I use it for pump data from
foxpro and paradox files.

I want K2Pump to be an open source project so
your comments, suggestions and changes to the code are welcome.

If you don´t want to contribute with the project, feel free to do
whatever you want with the code.

christian

mailto: k2pump@sig2k.com.ar
http://sig2k.com.ar

Enjoy It.

Note:
I took the idea (and some lines of code) from a datapump for postgree from
Sergio Kessler
Email : sergio@perio.unlp.edu.ar
www   : http://perio.unlp.edu.ar/~sergio

##############
Edited in 13/02/2020 by Maicon Saraiva
www http://www.sismais.com
Changes: Increase new features, bug's fixes and improvements 
}

unit Main;

interface

uses
  Bde, SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DB, FileCtrl, DBTables, Gauges, ExtCtrls, Windows,
  IBCustomDataSet, IBQuery, IBDatabase, ComCtrls, IBTable, IBSQL,
  CheckLst;

type rCampos = record
       Nombre: string;
       NewDataBaseNombre : string; //The Destination database do'nt need any especial caracter this property is for this
       Defect: variant;
       Nulo: boolean;
     end;

type
  TFrmMain = class(TForm)
    Table: TTable;
    Database1: TIBDatabase;
    Transact: TIBTransaction;
    CBDatabase: TComboBox;
    Label1: TLabel;
    LBTable: TCheckListBox;
    Progress: TGauge;
    BtnExport: TButton;
    CreateTableCheckBox: TCheckBox;
    chkPumpData: TCheckBox;
    CheckBox1: TCheckBox;
    Label4: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    Label5: TLabel;
    RadioGroup1: TRadioGroup;
    Edit1: TEdit;
    Label6: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Edit3: TEdit;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    AutFillNum: TCheckBox;
    AutFillNon: TCheckBox;
    TCampos: TIBQuery;
    TCamposNOMBRE: TIBStringField;
    TCamposTIPO: TSmallintField;
    TCamposNULO: TSmallintField;
    CheckBox5: TCheckBox;
    Query1: TIBQuery;
    MemoErrorLog: TMemo;
    Label7: TLabel;
    btnCheckAll: TButton;
    btnLocDataBase: TButton;
    OpenDialog1: TOpenDialog;
    MemoInstructions: TMemo;
    btnPreview: TButton;
    procedure FormCreate(Sender: TObject);
    procedure CBDatabaseChange(Sender: TObject);
    procedure BtnExportClick(Sender: TObject);
    function  CreateScript: string;
    function  IndexScript: string;
    procedure Database1DialectDowngradeWarning(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure btnCheckAllClick(Sender: TObject);
    procedure btnLocDataBaseClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    tbl : TFileName;
    function MakeValidDataBaseObjectName(aName : String):String;
    function Get_aCamposIndexBy_NewDataBaseNombre(aCampos : array of rCampos;
      sFieldName : String):Integer;
  end;

var
  FrmMain: TFrmMain;

implementation

uses Utils, uFrmPreView;
{$R *.DFM}

procedure TFrmMain.FormCreate(Sender: TObject);
var sPath : String;
begin
  Session.GetDatabaseNames(CBDatabase.Items);
  //With this aplicattion, that's distribuited a copy of a bkank Firebird database
  //On start i check if exists, then isuggested it for migration
  sPath :=  ExtractFilePath(Application.ExeName);
  if FileExists(sPath+'DB_NOTABLE.FDB') then
  begin
    if not FileExists(sPath+'DB_NOTABLE_NEW.FDB') then
    begin
      CopyFile(PChar(sPath+'DB_NOTABLE.FDB'),PChar(sPath+'DB_NOTABLE_NEW.FDB'),False);
      Application.MessageBox(PChar(Format('To help you, was created a copy of included database: '+SLineBreak+
          ' %s '+SLineBreak+
          'To: '+SLineBreak+
          '%s '+SLineBreak+
          'If you like, use it in conversion.',
          [sPath+'DB_NOTABLE.FDB_NEW.FDB', sPath+'DB_NOTABLE_NEW.FDB'])
          ),'Information',MB_OK + MB_ICONINFORMATION) ;
    end;
    if FileExists(sPath+'DB_NOTABLE_NEW.FDB') then
      Edit3.Text := sPath + 'DB_NOTABLE_NEW.FDB'; //Change it to Database name edit.
  end;
end;

procedure TFrmMain.CBDatabaseChange(Sender: TObject);
begin
  Session.GetTableNames( CBDatabase.Items[CBDatabase.ItemIndex], '',
                         True, False, LBTable.Items);
  LBTable.Sorted := True;
  BtnExport.Enabled := LBTable.Items.Count > 0;
end;

procedure TFrmMain.BtnExportClick(Sender: TObject);
var
  Err: boolean;
  i, rec : longint;
  indexTable : integer;
  strSql, StrSq2: string;
  TimeStart: Double;
  aCampos: array of rCampos;
  BoolY, BoolN: string;
  sDestinationFieldName : String;
  aCamposIndex : Integer;
begin

  if Length(Edit3.Text)=0 then
    begin
      MessageDlg('Set the BDE Alias (Origin).', mtError, [mbOK], 0);
      Exit;
    end;

  Table.DatabaseName := CBDatabase.Items[CBDatabase.ItemIndex];
  Database1.DataBaseName := Edit3.Text;
  Database1.Params.Clear;
  if Length(Edit1.Text)>0 then
    Database1.Params.Add('user_name='+Edit1.Text);
  if Length(Edit2.Text)>0 then
    Database1.Params.Add('password='+Edit2.Text);
  Database1.LoginPrompt := (Length(Edit1.Text)=0) or (Length(Edit2.Text)=0);
  Database1.Connected := True;

// standard formats for interbase
  ShortDateFormat := 'mm/dd/yyyy';
  LongTimeFormat := 'hh:mm:ss';
  DecimalSeparator := '.';
// value for boolean fields
  BoolY := 'S';
  BoolN := 'N';

  Memo1.Clear;

  TimeStart := Time;

  for indexTable:= 0 to LBTable.Items.Count-1 do
    begin
      if LBTable.Checked[indexTable] then
        try
          Table.TableName := LBTable.Items[indexTable];
          Table.Open;

          Memo1.Lines.Add(#13#10+TimeToStr(Time)+' Processing table ' + Table.TableName);

          tbl := Table.TableName;
          Delete(tbl, Pos('.', tbl), length(tbl));

          Progress.MinValue := 0;
          if Table.RecordCount = 0 then
            Progress.MaxValue := 1
          else
            Progress.MaxValue := Table.RecordCount;
          Progress.Progress := 0;
          Progress.Show;

          Err := False;

          if CreateTableCheckBox.Checked then
            try
              strSql := CreateScript;
              if Length(strsql)=0 then raise exception.Create('');
              Query1.SQL.Text := strSql;
              Transact.StartTransaction;
              Query1.ExecSQL;
              Transact.Commit;
              Memo1.Lines.Add(TimeToStr(Time)+' Table '+tbl+' created ok');
            except
              on E: exception do begin
                Memo1.Lines.Add(TimeToStr(Time)+' Error creating table '+tbl);
                if Transact.InTransaction then
                  Transact.Rollback;
                E.Message := E.Message+#13'SQL'#13+strSql;
                raise;
              end;
            end;

          if chkPumpData.Checked then
            try
              TCampos.Close;
              TCampos.ParamByName('TABLA').Value := UpperCase(tbl);
              TCampos.Open;

              StrSql := '';
              StrSq2 := '';
              SetLength(aCampos,0);
              while not TCampos.Eof do
              begin

                if Length(StrSql) > 0 then
                begin
                  StrSql := StrSql+',';
                  StrSq2 := StrSq2+',';
                end;
                i := Length(aCampos);
                SetLength(aCampos,i+1);
                aCampos[i].Nombre := Trim(TCamposNOMBRE.Value);
                aCampos[i].NewDataBaseNombre := MakeValidDataBaseObjectName(aCampos[i].Nombre);
                aCampos[i].Nulo   := TCamposNULO.Value <> 1;
                case TCamposTIPO.Value of
                  14, 37, 40: aCampos[i].Defect := ' ';
                  12: aCampos[i].Defect := StrToDate('01/01/1900');
                  13: aCampos[i].Defect := StrToTime('12:00');
                  35: aCampos[i].Defect := StrToDate('01/01/1900');
                else
                  aCampos[i].Defect := 0;
                end;

                StrSql := StrSql+aCampos[i].NewDataBaseNombre;
                StrSq2 := StrSq2+':'+aCampos[i].NewDataBaseNombre;

                TCampos.Next;
              end;
              Transact.Commit;

              if Length(StrSql)=0 then
                raise Exception.Create('no hay ningun campo que coincida el nombre');

              Query1.SQL.Text := 'INSERT INTO '+tbl+' ('+StrSql+') VALUES('+StrSq2+')';
              Query1.Prepare;

              rec := 0;
              Table.First;
              while not Table.Eof do begin

                for i := 0 to Table.Fields.Count-1 do
                begin
                  //Remove invalid caracters for field names in Firebird/Interbase database
                  sDestinationFieldName := MakeValidDataBaseObjectName( Table.Fields[i].FieldName );
                  //Find the field in new database (based on apropriated nombre) ?
                  aCamposIndex := Get_aCamposIndexBy_NewDataBaseNombre(aCampos,sDestinationFieldName);

                  //Found correspondent field?
                  if aCamposIndex <> -1 then
                    if (Table.Fields[I].DataType = ftBoolean) then
                    begin
                        if Table.Fields[I].IsNull then
                          Query1.Params.ParamByName(aCampos[aCamposIndex].NewDataBaseNombre).Value := 'N'
                        else
                          if Table.Fields[I].Value then
                            Query1.Params.ParamByName(aCampos[aCamposIndex].NewDataBaseNombre).Value := 'S'
                          else
                            Query1.Params.ParamByName(aCampos[aCamposIndex].NewDataBaseNombre).Value := 'N'
                     end
                     else
                      if (Table.Fields[I].IsNull) then
                      begin
                          if aCampos[i].Nulo then
                            Query1.Params.ParamByName(aCampos[aCamposIndex].NewDataBaseNombre).Clear
                          else
                            Query1.Params.ParamByName(aCampos[aCamposIndex].NewDataBaseNombre).Text := aCampos[i].Defect
                       end
                       else
                         Query1.Params.ParamByName(aCampos[aCamposIndex].NewDataBaseNombre).Text := Table.Fields[I].AsString;
                 end;
                Table.Next;
                Query1.ExecSQL;

                rec := rec + 1;
                Progress.Progress := rec;
                Application.ProcessMessages;
                if CheckBox5.Checked and (rec mod 10000 = 0) then begin
                  Transact.Commit;
                  Transact.StartTransaction;
                  Memo1.Lines.Add(TimeToStr(Time)+' '+IntToStr(rec)+' records pumped');
                  Update;
                end;
              end;

              Query1.Unprepare;
              Transact.Commit;
              Memo1.Lines.Add(TimeToStr(Time)+' Table '+tbl+' data pumped ok');
            except
              on E: Exception do begin
                if Query1.Prepared then Query1.Unprepare;
                if Transact.InTransaction then Transact.Commit;
                Memo1.Lines.Add(TimeToStr(Time)+' Table '+tbl+' error pumping data');
                E.Message := E.Message+#13'SQL'#13+Query1.Sql.Text;
                raise;
              end;
            end;

          if CheckBox1.Checked and not Err then
            try
              Transact.StartTransaction;
              strSql := IndexScript;
              Query1.SQL.Text := strSql;
              Query1.ExecSQL;
              Transact.Commit;
              Memo1.Lines.Add(TimeToStr(Time)+' Table '+tbl+' Secondary indexes created ok');
            except
              on E: Exception do begin
                Memo1.Lines.Add(TimeToStr(Time)+' Table '+tbl+' Error creating secondary indexes');
                if Transact.InTransaction then
                  Transact.Rollback;
                E.Message := E.Message+#13'SQL'#13+strSql;
                raise;
              end;
            end;
        except
          on E: Exception do
          begin
            Application.MessageBox(PChar(E.Message),'Conversion error:',MB_OK + MB_ICONERROR);
            MemoErrorLog.Lines.Add(E.Message);
          end;
        end;
        Table.Close;
   end;
   Database1.Connected := False;
   Memo1.Lines.Add(#13#10+TimeToStr(Time)+' Done in '+TimeToStr(Time-TimeStart));

end;

function TFrmMain.CreateScript: string;
var
  curProp: CURProps;
  pfldDes, pCurFld: pFLDDesc;
  // pfldDes is a pointer to a list of field descriptors.
  // It must be allocated with (iFields * sizeof(FLDDesc))
  // where iFields is a field in the structure curProps
  // from DbiGetCursorProps
  // pCurFld is a pointer the description of one field in the list.
  MemSize: Integer;
  FieldList: string;

  i, k: integer;
  err: boolean;
  sqlDataType, primaryKey, strSql: string;
  name: string;
begin
  //remove especial caracter e accents from table name
  tbl := MakeValidDataBaseObjectName(tbl);
  strSql := 'CREATE TABLE ' + tbl + ' ( ';

  primaryKey := '';
  err := False;

  Check(DbiGetCursorProps(Table.Handle, curProp));

  // Get enough memory for one field desc times the # of fields
  MemSize := curProp.iFields * SizeOf(FLDDesc);
  pfldDes := AllocMem(MemSize);
  try
    pCurFld := pfldDes;
    Check(DbiGetFieldDescs(Table.Handle, pfldDes));
    I := 0;
    FieldList := '';
    while (i < curProp.iFields) do begin
      sqlDataType := '';

      case pCurFld.iFldType of
        fldZSTRING:    if CheckBox3.Checked then
                         sqlDataType := 'VARCHAR(' + IntToStr( Table.Fields[i].DataSize-1)+')'
                       else
                         sqlDataType := 'CHAR(' + IntToStr( Table.Fields[i].DataSize-1)+')';
        fldINT16:      sqlDataType := 'SMALLINT';
        fldstAUTOINC,
        fldINT32:      sqlDataType := 'INTEGER';
        fldBCD,
        fldFLOAT:      if pCurFld.iUnits1 > 1 then
                         if pCurFld.iUnits2 = 0 then
                           begin
                             if pCurFld.iUnits1 < 5 then
                               sqlDataType := 'SMALLINT'
                             else if pCurFld.iUnits1 < 10 then
                               sqlDataType := 'INTEGER'
                             else
                               if Database1.SQLDialect = 3 then
                                 sqlDataType := 'NUMERIC(18,0)'
                               else
                                 sqlDataType := 'DOUBLE PRECISION';
                           end
                         else
                           begin
                             if pCurFld.iUnits1 > 15 then
                               k := 18
                             else
                               k := pCurFld.iUnits1 - 1;
                             sqlDataType := 'NUMERIC('+IntToStr(k)+','+IntToStr(pCurFld.iUnits2)+')'
                           end
                       else
                         sqlDataType := 'FLOAT';
        fldTIME:       if Database1.SQLDialect = 3 then
                         sqlDataType := 'TIME'
                       else
                         sqlDataType := 'TIMESTAMP';
        fldDATE:       if Database1.SQLDialect = 3 then
                         sqlDataType := 'DATE'
                       else
                         sqlDataType := 'TIMESTAMP';
        fldTIMESTAMP:  sqlDataType := 'TIMESTAMP';
        fldBOOL:       sqlDataType := 'CHAR(1)';
        fldstMEMO,
        fldBLOB:       sqlDataType := 'BLOB';
      else
        showMessage('Tipo de dado do campo desconhecido.');
        err := True;
      end;

      if Length(sqlDataType) > 0 then
        begin
          // the following makes the field compatible with dialect 1
          name := MakeValidDatabaseObjectName(pCurFld.szName);

          if pCurFld.iFldType = fldBOOL then
            sqlDataType := sqlDataType + ' NOT NULL'
          else
            begin

              if Table.FieldByName(pCurFld.szName).DefaultExpression <> '' then
                sqlDataType := sqlDataType + ' DEFAULT=' + Table.FieldByName(pCurFld.szName).DefaultExpression;

              if CheckBox4.Checked or Table.FieldByName(pCurFld.szName).Required or Table.FieldByName(pCurFld.szName).IsIndexField then
                sqlDataType := sqlDataType + ' NOT NULL';

              if Table.FieldByName(pCurFld.szName).IsIndexField then
                primaryKey := primaryKey + name + ', ';

            end;

          strSql := strSql + name;
          strSql := strSql + ' ' + sqlDataType;
        end;

      if i < curProp.iFields-1 then strSql := strSql + ', ';

      inc(pCurFld);
      inc(i);
    end;
  finally
    FreeMem(pfldDes, MemSize);
  end;

  // here we remove the last ',' of the primary key
  delete( primaryKey, length(primaryKey)-1, 2);
  // remove especial caracter and acentued
  if primaryKey <> '' then
     strSql := strSql + ', PRIMARY KEY (' + primaryKey + ') ';

  strSql := strSql +  ');';

  result := strSql;

  if err then result := '';

end;

function TFrmMain.IndexScript: string;
var
  i, j: integer;
  iFields, strSql: string;
begin
  Table.IndexDefs.Update;
  for i := 0 to Table.IndexDefs.Count-1 do
    begin
      if ixPrimary in Table.IndexDefs[i].Options then continue;
      if ixExpression in Table.IndexDefs[i].Options then continue;

      strSql := 'CREATE ';

      if ixUnique in Table.IndexDefs[i].Options then
        strSql := strSql + 'UNIQUE ';

      if ixDescending in Table.IndexDefs[i].Options then
        strSql := strSql + 'DESC ';

      strSql := strSql + 'INDEX ' + tbl + '_' + Table.IndexDefs[i].Name + ' ON ' + tbl + '( ';
      iFields := Table.IndexDefs[i].Fields;
      j := pos( ';', iFields);
      while j > 0 do
        begin
          delete( iFields, j, 1);
          insert( ',', iFields, j);
          j := pos( ';', iFields);
        end;
        strSql := strSql + iFields + ');';
    end;
    result := strSql;
end;

procedure TFrmMain.Database1DialectDowngradeWarning(Sender: TObject);
begin
  RadioGroup1.ItemIndex := 0;
end;

procedure TFrmMain.RadioGroup1Click(Sender: TObject);
begin
  if RadioGroup1.ItemIndex = 1 then
    Database1.SQLDialect := 3
  else
    Database1.SQLDialect := 1;
end;

procedure TFrmMain.btnCheckAllClick(Sender: TObject);
var I: Integer;
  bCheck : Boolean;
begin
  bCheck := btnCheckAll.Caption = 'Check All';
  for i:=0 to LBTable.Items.Count-1 do
    LBTable.Checked[i] := bCheck;


  //if check all, convert buttom to Uncheck All
  if bCheck then
    btnCheckAll.Caption := 'Uncheck All'
  else
    btnCheckAll.Caption := 'Check All';


end;

procedure TFrmMain.btnLocDataBaseClick(Sender: TObject);
begin
  OpenDialog1.Filter := 'Interbase database file (*.gdb)|*.gdb|Firebird database file (*.fdb)|*.fdb';
  OpenDialog1.Title := 'Open Interbase or Firebird database file';
  OpenDialog1.DefaultExt := 'fdb';
  if OpenDialog1.Execute then
    Edit3.Text := OpenDialog1.FileName;
end;

procedure TFrmMain.btnPreviewClick(Sender: TObject);
var i, selectedIndex : Integer;
  DataSource : TDataSource;
begin
  selectedIndex := -1;
  for i:=0 to LBTable.Items.Count-1 do
    if LBTable.Selected[i] then
    begin
      selectedIndex := i;
      Break;
    end;

  if selectedIndex = -1 then
    MessageBox(Self.Handle,'Please select (no necessary Check) an item.','No item selected', 0)
  else
  begin
    Table.Close;
    Table.DatabaseName := CBDatabase.Items[CBDatabase.ItemIndex];
    Table.TableName := LBTable.Items[selectedIndex];
    Table.Open;

    DataSource := TDataSource.Create(nil);
    try
      DataSource.DataSet := Table;
      frmPreview := TfrmPreview.Create(Self);
      frmPreview.lblTableName.Caption := LBTable.Items[selectedIndex];
      frmPreview.DBGrid1.DataSource   := DataSource;
      frmPreview.ShowModal;
    finally
      FreeAndNil(frmPreview);
      DataSource.Free;
    end;
  end;
end;

function TFrmMain.MakeValidDataBaseObjectName(aName: String): String;
var sNewName:String;
begin
  {This function get the apropriated database object name for Interbase/Firebird
  destination. (Table Name, Field Name, etc.
  The premisse is remove all non accepted caracters.}
  sNewName := UpperCase( Trim(aName) );
  sNewName := StringReplace(sNewName,'/','_',[rfReplaceAll]);
  sNewName := StringReplace(sNewName,' ','_',[rfReplaceAll]);
  sNewName := UpperCase(ReplaceAccentedCharacter(sNewName));
  sNewName := RemoveEspecialCaracter(sNewName);
  sNewName := StringReplace(sNewName,'.','_',[rfReplaceAll]);
  sNewName := StringReplace(sNewName,'__','_',[rfReplaceAll]); //if have two underline, remove one

  Result := sNewName;
end;

function TFrmMain.Get_aCamposIndexBy_NewDataBaseNombre(
  aCampos: array of rCampos; sFieldName:String): Integer;
var I, iFieldsCount : Integer;
begin
  Result := -1;
  iFieldsCount := Length(aCampos);
  for I:=0 to iFieldsCount-1 do
    if aCampos[I].NewDataBaseNombre = sFieldName then
    begin
      Result := I; //Found
      Break;
    end;
end;

end.
