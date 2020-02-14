unit uFrmPreview;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, DBGrids, ExtCtrls;

type
  TfrmPreview = class(TForm)
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    Label1: TLabel;
    lblTableName: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPreview: TfrmPreview;

implementation

{$R *.dfm}

end.
