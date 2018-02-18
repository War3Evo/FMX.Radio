program AndroidRadioService;

uses
  System.Android.ServiceApplication,
  Services.Radio.Service in 'Services.Radio.Service.pas' {DM: TAndroidService},
  Services.Radio.Android in 'Services.Radio.Android.pas',
  Services.Radio.Bass in 'Services.Radio.Bass.pas',
  Services.Radio.BassAac in 'Services.Radio.BassAac.pas',
  Services.Radio in 'Services.Radio.pas',
  Services.Radio.Shared in 'Services.Radio.Shared.pas',
  DW.Androidapi.JNI.LocalBroadcastManager in '..\..\KastriFree\API\DW.Androidapi.JNI.LocalBroadcastManager.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
