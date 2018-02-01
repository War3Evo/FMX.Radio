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
  Services.Radio;

type
  TDM = class(TAndroidService)
    procedure AndroidServiceCreate(Sender: TObject);
    procedure AndroidServiceDestroy(Sender: TObject);
    function AndroidServiceStartCommand(const Sender: TObject;
      const Intent: JIntent; Flags, StartId: Integer): Integer;
  private
    { Private declarations }
    FRadyo: TRTLRadio;
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Androidapi.JNI.App,
  Androidapi.JNI.JavaTypes;

procedure TDM.AndroidServiceCreate(Sender: TObject);
begin
  FRadyo := TRTLRadio.Create;
  FRadyo.SetOwner(Self);
  FRadyo.SetStreamURL('http://s6.nexuscast.com/tunein/cactiradio.pls');
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
begin
  // recieve commands
  if Assigned(Intent) then
  begin
    if Intent.getAction.equalsIgnoreCase(StringToJString('StopIntent')) then
    begin
      JavaService.stopSelf;
      Result := TJService.JavaClass.START_NOT_STICKY; // don't reload service
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('StartIntent')) then
    begin
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('PlayRadio')) then
    begin
      if Assigned(FRadyo)
        then begin
                FRadyo.Play;
        end;
      Result := TJService.JavaClass.START_STICKY; // rerun service if it stops
    end
    else if Intent.getAction.equalsIgnoreCase(StringToJString('PauseRadio')) then
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

end.
