unit Services.Radio.Service;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Android.Service,
  System.Notification,     // for TJService
  Androidapi.JNI.Support,
  Androidapi.Helpers,      // for StringToJString
  AndroidApi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Os,
  Services.Radio,
  DW.Androidapi.JNI.LocalBroadcastManager, // for TJLocalBroadcastManager
  DateUtils;


type
  TDM = class(TAndroidService)
    procedure AndroidServiceCreate(Sender: TObject);
    procedure AndroidServiceDestroy(Sender: TObject);
    function AndroidServiceStartCommand(const Sender: TObject;
      const Intent: JIntent; Flags, StartId: Integer): Integer;
  private
    { Private declarations }
    //NotificationCenter1: TCustomNotificationCenter; // was TNotificationCenter;
    FRadyo: TRTLRadio;
    procedure DoMessage(const AMsg: string);
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

const
  cServiceMessageAction = 'com.embarcadero.services.plaStreamer'; // Your Main Application
  cServiceMessageParamMessage = 'message';


procedure StatusProc(pszData : string;Progress:Integer);
begin
  DM.DoMessage(Format('%s:%s:%d',['STATUS', pszData, Progress]));
end;

procedure BroadcastInfoProc(pszBroadcastName,pszBitRate:string);
begin
  DM.DoMessage(Format('FUNC:%s:BROADCAST=%s:BITRATE=%s',['BroadcastInfoProc',pszBroadcastName,pszBitRate]));
end;


procedure BroadcastMetaProc(pszData : string);
begin
  DM.DoMessage(Format('FUNC:%s:%s',['BroadcastMetaProc',pszData]));
end;

procedure TDM.AndroidServiceCreate(Sender: TObject);
begin
  MetaData := '';
  InfoData := '';
  FRadyo := TRTLRadio.Create;
  FRadyo.SetStatusProc(StatusProc);
  FRadyo.SetBroadcastInfoProc(BroadcastInfoProc);
  FRadyo.SetBroadcastMetaProc(BroadcastMetaProc);
  FRadyo.SetOwner(Self);
  //FRadyo.SetStreamURL('http://s6.nexuscast.com/tunein/cactiradio.pls');  //sets at StartIntent
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
  MyNotification: JNotification;
  NotificationBuilder: JNotificationCompat_Builder;
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
    else if Intent.getAction.equalsIgnoreCase(StringToJString('PlayRadio')) = true then
    begin
      if Assigned(FRadyo)
        then begin
                NotificationBuilder := TJNotificationCompat_Builder.JavaClass.init(TAndroidHelper.Context);
                NotificationBuilder := NotificationBuilder.setSmallIcon(TAndroidHelper.Context.getApplicationInfo.icon);
                NotificationBuilder := NotificationBuilder.setContentTitle(StrToJCharSequence(TAndroidHelper.ApplicationTitle));
                NotificationBuilder := NotificationBuilder.setContentText(StrToJCharSequence('Foreground Service Started'));
                MyNotification := NotificationBuilder.build;
                JavaService.startForeground(666,MyNotification);

                FRadyo.Play;
        end;
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('PauseRadio')) = true then
    begin
      if Assigned(FRadyo)
        then begin
                NotificationBuilder := TJNotificationCompat_Builder.JavaClass.init(TAndroidHelper.Context);
                NotificationBuilder := NotificationBuilder.setSmallIcon(TAndroidHelper.Context.getApplicationInfo.icon);
                NotificationBuilder := NotificationBuilder.setContentTitle(StrToJCharSequence(TAndroidHelper.ApplicationTitle));
                NotificationBuilder := NotificationBuilder.setContentText(StrToJCharSequence('Foreground Service Stopped'));
                MyNotification := NotificationBuilder.build;
                JavaService.stopForeground(true);

                FRadyo.Pause;
        end;
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else Result := TJService.JavaClass.START_STICKY;
  end
  else Result := TJService.JavaClass.START_STICKY;
end;

{
function GetLogTime: string;
begin
  Result := FormatDateTime('mm-dd hh:nn:ss.zzz', Now);
end; }

procedure TDM.DoMessage(const AMsg: string);
var
  LIntent: JIntent;
begin
  // Sends a local broadcast that the app can receive. This *should* be thread-safe since it does not access any outside references
  LIntent := TJIntent.JavaClass.init(StringToJString(cServiceMessageAction));
  //LIntent.putExtra(StringToJString(cServiceMessageParamMessage), StringToJString(GetLogTime + ':' + AMsg));
  LIntent.putExtra(StringToJString(cServiceMessageParamMessage), StringToJString(AMsg));
  TJLocalBroadcastManager.JavaClass.getInstance(TAndroidHelper.Context).sendBroadcast(LIntent);
end;

end.
