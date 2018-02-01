{
  Author : Ersan YAKIT
           ersanyakit@yahoo.com.tr
           www.ersanyakit.com
}

unit Services.Radio.Android;

interface
{$WARNINGS OFF}
{$HINTS OFF}
{$IFDEF ANDROID}
uses
  Services.Radio.Bass,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  Services.Radio,
  //FMX.Types,
  Services.Radio.Shared,
  //FMX.Forms,
  //FMX.Platform.Android,
  Androidapi.JNI.Os,
  Androidapi.JNI.Net,
  Androidapi.JNIBridge,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.Media,
  Androidapi.JNI.Provider,
  Androidapi.Helpers,
  Androidapi.JNI.App;
  //FMX.Platform,
  //FMX.PhoneDialer;

type
  TRTLPlatformRadio = class(TRTLCustomRadio)
  private
    FStreamURL            : string;
    FActiveChannel        : HSTREAM;
    FStatusProc           : TStatusProc;
    FBroadcastInfoProc    : TBroadcastInfoProc;
    FBroadcastMetaProc    : TBroadcastMetaProc;
    FPause                : Boolean;

    procedure DoMeta();
  public
    function  Play:Boolean;override;
    procedure Pause;override;
    procedure SetStreamURL(AUrl : string); override;
    procedure InitRadio(iHandle:Pointer);override;
    procedure UnloadRadio;override;

    procedure SetStatusProc(AProc:TStatusProc);override;
    procedure SetBroadcastInfoProc(AProc:TBroadcastInfoProc);override;
    procedure SetBroadcastMetaProc(AProc:TBroadcastMetaProc);override;
  end;

{$ENDIF}

implementation
{ TFMXPlatformRadio }
{$IFDEF ANDROID}
var
  ARadio : TRTLPlatformRadio;

procedure MetaSync(handle: HSYNC; channel, data: DWORD; user: Pointer);cdecl;
begin
  if Assigned(ARadio)
    then begin
            ARadio.DoMeta();
         end;
end;

procedure TRTLPlatformRadio.DoMeta();
var
  meta: MarshaledAString;
  line: string;
  p: Integer;
begin
  meta := BASS_ChannelGetTags(FActiveChannel, BASS_TAG_META);
  if (meta <> nil) then
  begin
    line:=UTF8Decode(meta);
    p := Pos('StreamTitle=', line);
    if (p = 0) then
      Exit;
    p := p + 13;

    if Assigned(FBroadcastMetaProc)
      then begin
               FBroadcastMetaProc(Copy(meta, p, Pos(';', line) - p - 1));
           end;
  end;
end;

function TRTLPlatformRadio.Play:Boolean;
var
  szBroadcastName    : string;
  szBroadcastBitRate :string;
  icy                : MarshaledAString;
  ResultCode         : Integer;
  len, Progress      : DWORD;
begin
  FPause := false;
  Result := false;
  ResultCode := 0;
  BASS_StreamFree(FActiveChannel);
  Progress := 0;

  FActiveChannel := BASS_StreamCreateURL(PChar(FStreamURL),
                                         0,
                                         BASS_STREAM_BLOCK or
                                         BASS_STREAM_STATUS or
                                         BASS_STREAM_AUTOFREE or
                                         BASS_UNICODE,
                                         nil,
                                         nil);
  if FActiveChannel = 0 then
  begin
    ResultCode := Bass_ErrorGetCode;
    Result := false;
    Exit;
  end;
  begin
    // Progress
    repeat
      len := BASS_StreamGetFilePosition(FActiveChannel, BASS_FILEPOS_END);
      if (len = DW_Error)
        then begin
                break;
             end;
      //Application.ProcessMessages; // Need to find an alternative to this rather than using VCL or FMX
      if FPause then break;    // to break repeat if needed by application instead of 'Application.ProcessMessages' for now

      Progress := BASS_StreamGetFilePosition(FActiveChannel, BASS_FILEPOS_BUFFER) * 100 div len;

      if Assigned(FStatusProc)
        then begin
                FStatusProc(strLoading,Progress);
             end;
    until (Progress > 75) or (BASS_StreamGetFilePosition(FActiveChannel, BASS_FILEPOS_CONNECTED) = 0);


    icy := BASS_ChannelGetTags(FActiveChannel, BASS_TAG_ICY);
    if (icy = nil) then
      icy := BASS_ChannelGetTags(FActiveChannel, BASS_TAG_HTTP);

    szBroadcastName := strUnknown;
    szBroadcastBitRate := strUnknown;

    if (icy <> nil)
    then begin
            while (icy^ <> #0) do
            begin
              if (Copy(icy, 1, 9) = 'icy-name:')
                then begin
                        szBroadcastName := Copy(icy, 10, MaxInt);
                     end
              else if (Copy(icy, 1, 7) = 'icy-br:')
                then begin
                        szBroadcastBitRate := 'bitrate: ' + Copy(icy, 8, MaxInt);
                     end;
              icy := icy + Length(icy) + 1;
            end;

           if Assigned(FBroadcastInfoProc)
            then begin
                     FBroadcastInfoProc(szBroadcastName,szBroadcastBitRate);
                 end;
         end;

    DoMeta();
    BASS_ChannelSetSync(FActiveChannel, BASS_SYNC_META, 0, @MetaSync, nil);
    BASS_ChannelPlay(FActiveChannel, FALSE);
    if Assigned(FStatusProc)
       then begin
             FStatusProc(strCompleted,100);
       end;
    Result := True;
  end;
end;

procedure TRTLPlatformRadio.Pause;
begin
  if FActiveChannel<>0
    then begin
          BASS_ChannelStop(FActiveChannel);
         end;
  FPause := true;
end;

procedure TRTLPlatformRadio.SetStreamURL(AUrl : string);
begin
    FStreamURL := AUrl;
end;

procedure TRTLPlatformRadio.SetStatusProc(AProc:TStatusProc);
begin
  if Assigned(FStatusProc)
  then begin
    FStatusProc := AProc;
  end;
end;

procedure TRTLPlatformRadio.SetBroadcastInfoProc(AProc:TBroadcastInfoProc);
begin
  if Assigned(FBroadcastInfoProc)
  then begin
    FBroadcastInfoProc := AProc;
  end;
end;

procedure TRTLPlatformRadio.SetBroadcastMetaProc(AProc:TBroadcastMetaProc);
begin
  if Assigned(FBroadcastMetaProc)
  then begin
    FBroadcastMetaProc := AProc;
  end;
end;

procedure TRTLPlatformRadio.InitRadio(iHandle:Pointer);
begin
    FActiveChannel := 0;
    FStatusProc:=Nil;
    ARadio := Self;

  if BASS_Init(-1,
               44100,
               0,
               iHandle,
               nil)
  then begin
          BASS_PluginLoad(PChar(BASS_FOLDER + 'libbass_aac.so'), 0 or BASS_UNICODE);
          BASS_SetConfig(BASS_CONFIG_NET_PLAYLIST, 1);
          BASS_SetConfig(BASS_CONFIG_NET_PREBUF, 0);
       end;
end;

procedure TRTLPlatformRadio.UnloadRadio;
begin
  if FActiveChannel<>0
    then begin
           BASS_StreamFree(FActiveChannel);
         end;
end;



{$ENDIF}
end.

