unit Services.Radio.Service;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Android.Service,
  System.Notification,     // for TJService
  Androidapi.Helpers,      // for StringToJString
  AndroidApi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os,
  Services.Radio,
  DateUtils;


type
  TDM = class(TAndroidService)
    procedure AndroidServiceCreate(Sender: TObject);
    procedure AndroidServiceDestroy(Sender: TObject);
    function AndroidServiceStartCommand(const Sender: TObject;
      const Intent: JIntent; Flags, StartId: Integer): Integer;
  private
    { Private declarations }
    NotificationCenter1: TCustomNotificationCenter; // was TNotificationCenter;
    FRadyo: TRTLRadio;
    procedure LaunchNotification;
  public
    { Public declarations }
  end;

var
  DM: TDM;
  MetaData, InfoData: String;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Androidapi.JNI.App,
  Androidapi.JNI.JavaTypes;
{
procedure StatusProc(pszData : string;Progress:Integer);
var
  MyNotification: TNotification;
begin
  MyNotification := TDM.NotificationCenter1.CreateNotification;
  try
    MyNotification.Name := 'StatusProc';
    MyNotification.Title := 'Status Information';
    MyNotification.AlertBody := Format('%s: %s',['Status:', pszData]);
    TDM.NotificationCenter1.PresentNotification(MyNotification);
  finally
    MyNotification.Free;
  end;
end; }

procedure BroadcastInfoProc(pszBroadcastName,pszBitRate:string);
var
  MyNotification: TNotification;
begin
  InfoData := Format('FUNC:%s:BROADCAST=%s:BITRATE=%s',['BroadcastInfoProc',pszBroadcastName,pszBitRate]);
  MyNotification := DM.NotificationCenter1.CreateNotification;
  try
    MyNotification.Name := 'BroadcastInfoProc';
    MyNotification.Title := 'Broadcast Information';
    MyNotification.AlertBody := Format('FUNC:%s:BROADCAST=%s:BITRATE=%s',['BroadcastInfoProc',pszBroadcastName,pszBitRate]);
    DM.NotificationCenter1.PresentNotification(MyNotification);
  finally
    MyNotification.Free;
  end;
end;


procedure BroadcastMetaProc(pszData : string);
var
  MyNotification: TNotification;
begin
  MetaData := Format('FUNC:%s:%s',['BroadcastMetaProc',pszData]);
  MyNotification := DM.NotificationCenter1.CreateNotification;
  try
    MyNotification.Name := 'BroadcastMetaProc';
    MyNotification.Title := 'Broadcast Information';
    MyNotification.AlertBody := Format('FUNC:%s:%s',['BroadcastMetaProc',pszData]);
    DM.NotificationCenter1.PresentNotification(MyNotification);
  finally
    MyNotification.Free;
  end;
end;

procedure TDM.AndroidServiceCreate(Sender: TObject);
begin
  MetaData := '';
  InfoData := '';
  FRadyo := TRTLRadio.Create;
  //FRadyo.SetStatusProc(StatusProc);
  FRadyo.SetBroadcastInfoProc(BroadcastInfoProc);
  FRadyo.SetBroadcastMetaProc(BroadcastMetaProc);
  FRadyo.SetOwner(Self);
  //FRadyo.SetStreamURL('http://s6.nexuscast.com/tunein/cactiradio.pls');
end;

procedure TDM.AndroidServiceDestroy(Sender: TObject);
begin
  if Assigned(FRadyo)
    then begin
           FRadyo.Destroy;
    end;
end;

function TDM.AndroidServiceStartCommand(const Sender: TObject;
  const Intent: JIntent; Flags, StartId: Integer): Integer;
var
  MyNotification: TNotification;
begin
  // recieve commands
  if Assigned(Intent) then
  begin
    if Intent.getAction.equalsIgnoreCase(StringToJString('StopIntent')) = true then
    begin
      JavaService.stopSelf;
      Result := TJService.JavaClass.START_NOT_STICKY; // don't reload service
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('StartIntent')) = true then
    begin
      FRadyo.SetStreamURL(JStringToString(Intent.getData.toString));
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('GetMetaData')) = true then
    begin
      // notification MetaData
      {if MetaData <> '' then
      begin
        MyNotification := NotificationCenter1.CreateNotification;
        try
          MyNotification.Name := 'MetaData';
          MyNotification.Title := 'Broadcast Information';
          MyNotification.AlertBody := MetaData;
          NotificationCenter1.PresentNotification(MyNotification);
        finally
          MyNotification.Free;
        end;
      end; }
      LaunchNotification;
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('GetInfoData')) = true then
    begin
      // notification InfoData
      if InfoData <> '' then
      begin
        MyNotification := NotificationCenter1.CreateNotification;
        try
          MyNotification.Name := 'InfoData';
          MyNotification.Title := 'Broadcast Information';
          MyNotification.AlertBody := InfoData;
          NotificationCenter1.PresentNotification(MyNotification);
        finally
          MyNotification.Free;
        end;
      end;
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('PlayRadio')) = true then
    begin
      if Assigned(FRadyo)
        then begin
                FRadyo.Play;
        end;
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('PauseRadio')) = true then
    begin
      if Assigned(FRadyo)
        then begin
                FRadyo.Pause;
        end;
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else Result := TJService.JavaClass.START_STICKY;
  end
  else Result := TJService.JavaClass.START_STICKY;
end;

{
procedure TDM.LaunchNotification;
var
  MyNotification: TNotification;
begin
    if(NotificationCenter1.Supported) then
    begin
       MyNotification := NotificationCenter1.CreateNotification;
       try
         MyNotification.Name := 'ServiceNotification';
         MyNotification.Title := 'Android Service Notification';
         MyNotification.AlertBody := 'My Notification works using GetMetaData LOL!';
         MyNotification.FireDate := Now;
         NotificationCenter1.PresentNotification(MyNotification);
       finally
         MyNotification.Free;
       end;
    end;
end; }

procedure TDM.LaunchNotification;
var
  Intent: JIntent;
begin
  Intent := TJIntent.Create;
  //Intent.setClassName(TAndroidHelper.Activity.getBaseContext,
    //TAndroidHelper.StringToJString('com.embarcadero.services.plaStreamer'));
  Intent.setType(StringToJString('text/pas'));
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.putExtra(TJIntent.JavaClass.EXTRA_TEXT, StringToJString('Wow This is an Intent And May work! GetMetaData'));
  //if TAndroidHelper.Activity.getPackageManager.queryIntentActivities(Intent, TJPackageManager.JavaClass.MATCH_DEFAULT_ONLY).size > 0 Then
  TAndroidHelper.Activity.startActivity(Intent);
end;

end.
