program cancel;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, LResources
  { you can add units after this };

{$IFDEF WINDOWS}{$R cancel.rc}{$ENDIF}

begin
  {$I cancel.lrs}
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

