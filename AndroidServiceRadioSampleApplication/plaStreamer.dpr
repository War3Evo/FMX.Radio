program plaStreamer;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  DW.Androidapi.JNI.LocalBroadcastManager in '..\..\KastriFree\API\DW.Androidapi.JNI.LocalBroadcastManager.pas',
  DW.MultiReceiver.Android in '..\..\KastriFree\Core\DW.MultiReceiver.Android.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TDM, DM);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
