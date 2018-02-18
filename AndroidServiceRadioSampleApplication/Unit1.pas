unit Unit1;

interface

uses
  System.StartupCopy, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Gestures,
  FMX.TabControl, FMX.ScrollBox, FMX.Memo, System.Math.Vectors, FMX.Ani,
  FMX.Controls3D, FMX.Objects3D, FMX.MaterialSources, FMX.Viewport3D,
  System.Notification, System.Android.Service, FMX.Platform, System.Messaging,
  DW.MultiReceiver.Android,
  Androidapi.JNI.GraphicsContentViewText, // for JIntent
  Androidapi.JNI.JavaTypes, FMX.Layers3D;//, FireDAC.UI.Intf, FireDAC.FMXUI.Wait,
  //FireDAC.Stan.Intf, FireDAC.Comp.UI; // for JIntent //, FMX.Types3D;

type
  TMessageReceivedEvent = procedure(Sender: TObject; const Msg: string) of object;

  /// <summary>
  ///   Acts as a receiver of local broadcasts sent by the service
  /// </summary>
  TServiceMessageReceiver = class(TMultiReceiver)
  private
    FOnMessageReceived: TMessageReceivedEvent;
    procedure DoMessageReceived(const AMsg: string);
  protected
    procedure Receive(context: JContext; intent: JIntent); override;
    procedure ConfigureActions; override;
  public
    property OnMessageReceived: TMessageReceivedEvent read FOnMessageReceived write FOnMessageReceived;
  end;

  TForm1 = class(TForm)
    Viewport3D2: TViewport3D;
    Viewport3D1: TViewport3D;
    Memo1: TMemo;
    Plane2: TPlane;
    FloatAnimation1: TFloatAnimation;
    PlaneMusicPlayPause: TPlane;
    FloatAnimation2: TFloatAnimation;
    TextureMusicPlayIcon: TTextureMaterialSource;
    TextureMaterialMusicPause: TTextureMaterialSource;
    TextureMaterialSource1: TTextureMaterialSource;
    GestureManager1: TGestureManager;
    GridPanelLayout1: TGridPanelLayout;
    TextureMaterialSource2: TTextureMaterialSource;
    TextLayer3D1: TTextLayer3D;
    TextureMaterialSource3: TTextureMaterialSource;
    procedure FormCreate(Sender: TObject);
    procedure PlaneMusicPlayPauseClick(Sender: TObject);
    procedure FloatAnimation2Process(Sender: TObject);
    procedure FloatAnimation2Finish(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Viewport3D2Click(Sender: TObject);
  private
    { Private declarations }
    FReceiver: TServiceMessageReceiver;
    procedure ServiceMessageHandler(Sender: TObject; const AMsg: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  PlayMusic : Boolean;
  PlayMusicButtonAnimationLock : Boolean;
  LoadingMusic : Boolean = false;
  FirstTime : Boolean = true;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiPh.fmx ANDROID}
{$R *.LgXhdpiTb.fmx ANDROID}

uses
//  System.Android.Service;
  Androidapi.Helpers,
  Androidapi.JNI.App,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,   // required by JBundle
  FMX.Platform.Android;  // required by MainActivity

const
  cServiceName = 'com.embarcadero.services.AndroidRadioService';
  cServiceMessageAction = 'com.embarcadero.services.plaStreamer'; //'com.delphiworlds.action.servicemessage';
  cServiceMessageParamMessage = 'message';

{ TServiceMessageReceiver }

procedure TServiceMessageReceiver.ConfigureActions;
begin
  // Adds the appropriate action to the intent filter so that messages are received
  IntentFilter.addAction(StringToJString(cServiceMessageAction));
end;

procedure TServiceMessageReceiver.DoMessageReceived(const AMsg: string);
begin
  if Assigned(FOnMessageReceived) then
    FOnMessageReceived(Self, AMsg);
end;

procedure TServiceMessageReceiver.Receive(context: JContext; intent: JIntent);
begin
  // Retrieves the message from the intent
  DoMessageReceived(JStringToString(intent.getStringExtra(StringToJString(cServiceMessageParamMessage))));
end;

{ Process Message }

procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
   ListOfStrings.DelimitedText   := Str;
end;

procedure TForm1.ServiceMessageHandler(Sender: TObject; const AMsg: string);
var
   OutPutList: TStringList;
begin
   OutPutList := TStringList.Create;
   try
     Split(':', AMsg, OutPutList);
     if(OutPutList.Strings[0] = 'STATUS') then
      begin
       if(OutPutList.Strings[1] = 'COMPLETED') then
        begin
          //Memo1.Lines.Add('META DATA COMPLETED');
          FloatAnimation2.AnimationType := TAnimationType.&In;
          FloatAnimation2.StartValue := 0;
          FloatAnimation2.StopValue := 360;
          FloatAnimation2.Duration := 1.5;
          FloatAnimation2.Interpolation := TInterpolationType.Exponential;
          FloatAnimation2.PropertyName := 'RotationAngle.Y';
          FloatAnimation2.Enabled := false;
          LoadingMusic := false;
          PlaneMusicPlayPause.MaterialSource := TextureMaterialMusicPause;
        end
        else
        begin
          FloatAnimation2.AnimationType := TAnimationType.&In;
          FloatAnimation2.StartValue := 0;
          FloatAnimation2.StopValue := 360;
          FloatAnimation2.Duration := 1.5;
          FloatAnimation2.Interpolation := TInterpolationType.Exponential;
          FloatAnimation2.PropertyName := 'RotationAngle.Y';
          FloatAnimation2.Enabled := true;
          LoadingMusic := true;
          PlaneMusicPlayPause.MaterialSource := TextureMaterialSource3;
        end;
      end
     else if(OutPutList.Strings[0] = 'FUNC') then
     begin
       if(OutPutList.Strings[1] = 'BroadcastInfoProc') then
       begin
         //Memo1.Lines.Add(OutPutList.Strings[2]);
         //Memo1.Lines.Add(OutPutList.Strings[3]);
       end
       else if(OutPutList.Strings[1] = 'BroadcastMetaProc') then
       begin
         Memo1.Lines.Add(OutPutList.Strings[2]);
       end;
     end;
   finally
     OutPutList.Free;
   end;

  //Memo1.Lines.Add(AMsg);
end;

procedure TForm1.Viewport3D2Click(Sender: TObject);
begin
  //memo1.Lines.Add('clicked viewport');
end;

{ MAIN FORM }

procedure TForm1.FloatAnimation2Process(Sender: TObject);
var
  LIntent: JIntent;
begin
  if LoadingMusic = true then exit;

  if (PlayMusicButtonAnimationLock = false) and (PlaneMusicPlayPause.RotationAngle.Y >= 180) then
  begin
    if PlaneMusicPlayPause.MaterialSource = TextureMusicPlayIcon then
      begin
        PlaneMusicPlayPause.MaterialSource := TextureMaterialMusicPause;
        PlayMusicButtonAnimationLock := true;
        PlayMusic := true;
        FloatAnimation1.Enabled := true;
        LIntent := TJIntent.Create;
        LIntent.setClassName(TAndroidHelper.Context.getPackageName(),
          TAndroidHelper.StringToJString(cServiceName));
        LIntent.setAction(StringToJString('PlayRadio'));
        TAndroidHelper.Activity.startService(LIntent);
      end
    else
      begin
        PlaneMusicPlayPause.MaterialSource := TextureMusicPlayIcon;
        PlayMusicButtonAnimationLock := true;
        PlayMusic := false;
        FloatAnimation1.Enabled := false;
        LIntent := TJIntent.Create;
        LIntent.setClassName(TAndroidHelper.Context.getPackageName(),
          TAndroidHelper.StringToJString(cServiceName));
        LIntent.setAction(StringToJString('PauseRadio'));
        TAndroidHelper.Activity.startService(LIntent);
      end;
  end;
end;

procedure TForm1.FloatAnimation2Finish(Sender: TObject);
begin
    FloatAnimation2.Enabled := false;
    PlayMusicButtonAnimationLock := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  LIntent: JIntent;
  Data: Jnet_Uri;
begin
  FReceiver := TServiceMessageReceiver.Create(True);
  FReceiver.OnMessageReceived := ServiceMessageHandler;

  LIntent := TJIntent.Create;
  LIntent.setClassName(TAndroidHelper.Activity.getBaseContext,
    TAndroidHelper.StringToJString(cServiceName));
  Data := TJnet_Uri.JavaClass.parse(StringToJString('http://s6.nexuscast.com/tunein/cactiradio.pls'));
  LIntent.setData(Data);
  LIntent.setAction(StringToJString('StartIntent'));
  TAndroidHelper.Activity.startService(LIntent);
  PlayMusic := false;
  PlayMusicButtonAnimationLock := false;
  Viewport3D2.Enabled := true;
  PlaneMusicPlayPause.HitTest := true;
  PlaneMusicPlayPause.BringToFront;

  TextLayer3D1.Opacity := 1;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FReceiver.Free;
  inherited;
end;

procedure TForm1.PlaneMusicPlayPauseClick(Sender: TObject);
begin
  FloatAnimation2.Enabled := true;
  if PlayMusic = false then
    begin
      memo1.Lines.Add('Loading PLA Streaming Audio...');
      if FirstTime = true then memo1.Lines.Add('P.S. First Time loading can take a little time, so please press wait if android asks.');
      memo1.Lines.Add('');
      FirstTime := false;
    end;
end;

end.
