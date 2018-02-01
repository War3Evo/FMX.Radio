{
  Author : Ersan YAKIT
           ersanyakit@yahoo.com.tr
           www.ersanyakit.com
}

unit Services.Radio;

{$WARNINGS OFF}
{$HINTS OFF}

interface
uses Services.Radio.Shared;
     //FMX.Types,
     //FMX.Forms;

type
  TRTLCustomRadio = class(TObject)
    procedure InitRadio(iHandle:Pointer);virtual;abstract;
    procedure UnloadRadio;virtual;abstract;
    function  Play:Boolean;virtual;abstract;
    procedure Pause;virtual;abstract;
    procedure SetStreamURL(AUrl : string);virtual;abstract;

    procedure SetStatusProc(AProc:TStatusProc);virtual;abstract;
    procedure SetBroadcastInfoProc(AProc:TBroadcastInfoProc);virtual;abstract;
    procedure SetBroadcastMetaProc(AProc:TBroadcastMetaProc);virtual;abstract;

  end;


  TRTLRadio = class(TRTLCustomRadio)
  private
    FPlatformRadio: TRTLCustomRadio;
    FOwner : Pointer;   //was TFmxObject

    procedure InitRadio(iHandle:Pointer);override;
    procedure UnloadRadio;override;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetOwner(iHandle:Pointer);

    function  Play:Boolean;override;
    procedure Pause;override;
    procedure SetStreamURL(AUrl : string);override;

    procedure SetStatusProc(AProc:TStatusProc);override;
    procedure SetBroadcastInfoProc(AProc:TBroadcastInfoProc);override;
    procedure SetBroadcastMetaProc(AProc:TBroadcastMetaProc);override;
  end;

implementation

uses
{$IFDEF ANDROID}
  Services.Radio.Android;
{$ENDIF}
{$IFDEF MSWINDOWS}
  FMX.Radio.Windows;
{$ENDIF}

{ TFMXRadio }

constructor TRTLRadio.Create;
begin
  inherited;
  FPlatformRadio := TRTLPlatformRadio.Create;
end;

procedure TRTLRadio.SetOwner(iHandle:Pointer);     //was TFmxObject    iHandle:THandle
begin
  FOwner := iHandle;
  //InitRadio(Tform(FOwner).handle);
  InitRadio(FOwner);
end;

destructor TRTLRadio.Destroy;
begin
  UnloadRadio;
  FPlatformRadio.Free;
  inherited;
end;

function TRTLRadio.Play:Boolean;
begin
   Result := FPlatformRadio.Play;
end;

procedure TRTLRadio.Pause;
begin
   FPlatformRadio.Pause;
end;

procedure TRTLRadio.SetStreamURL(AUrl : string);
begin
   FPlatformRadio.SetStreamURL(AUrl);
end;

procedure TRTLRadio.SetStatusProc(AProc:TStatusProc);
begin
  if Assigned(AProc)
    then begin
            FPlatformRadio.SetStatusProc(AProc);
         end;
end;

procedure TRTLRadio.SetBroadcastInfoProc(AProc:TBroadcastInfoProc);
begin
  if Assigned(AProc)
    then begin
            FPlatformRadio.SetBroadcastInfoProc(AProc);
         end;
end;

procedure TRTLRadio.SetBroadcastMetaProc(AProc:TBroadcastMetaProc);
begin
  if Assigned(AProc)
    then begin
            FPlatformRadio.SetBroadcastMetaProc(AProc);
         end;
end;

procedure TRTLRadio.InitRadio(iHandle:Pointer);
begin
  FPlatformRadio.InitRadio(iHandle);
end;

procedure TRTLRadio.UnloadRadio;
begin
  FPlatformRadio.UnloadRadio;
end;

end.


