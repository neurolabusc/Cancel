program cancel;

uses
  Forms,
  main in 'main.pas' {Form1},
  utils in 'utils.pas';

{$R delphi.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
