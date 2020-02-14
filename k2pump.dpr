program k2pump;

uses
  Forms,
  Main in 'MAIN.PAS' {FrmMain},
  Utils in 'Utils.pas',
  uFrmPreview in 'uFrmPreview.pas' {frmPreview};

{$R *.RES}

begin
  Application.Title := 'Pump for Interbase and Firebird';
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
