-- Note from War3Evo --

   Works for Delphi 10.2.2 Tokyo for Firemonkey Android!

   There is a developmental branch that I'm currently working on a method that will allow the service to communicate back to the main form/app.  Once I complete it, I'll move it to the master copy.
   
-- End of Note from War3Evo --

# AndroidServicesRadio

Because its required so that the sound doesn't clip if you put your application into the background in android.

I converted the FMX.Radio so that you could use it as a Android Service.  For some reason, you can't use any FMX (Firemonkey) source code in a Android Service.

The Youtube video https://www.youtube.com/watch?v=0mD3WLK8FYc is very helpful in understanding how to put a Android Service into your project.

In order to change the StreamURL, you'll currently need to change it in the Services.Radio.Service.pas

Overall, this is example code that you can change freely at will.  Just remember to remove the Android Service from your main project, Build the AndroidServicesRadio, then Add the AndroidServicesRadio as a Android Service back into your main project, and add its source files.

1. Make sure you setup your Deployment in your "main project" for the android BASS audio library
2. Build the AndroidServicesRadio project
3. Add the AndroidServicesRadio as a Android Service to your project by right clicking on Android - Android SDK 24.3.3 32 bit and clicking on 'Add Android Service...'
4. Add the Source Files Services.Radio.Android.pas, Services.Radio.Bass.pas, Services.Radio.BassAac.pas, Services.Radio.pas, Services.Radio.Service.pas, Services.Radio.Shared.pas to your project.
5. Add this sourcecode into your main project:

<pre>
uses
  System.StartupCopy, System.Android.Service;

implementation

uses
  Androidapi.Helpers,
  Androidapi.JNI.App,
  Androidapi.JNI.GraphicsContentViewText, // for JIntent
  Androidapi.JNI.JavaTypes;  // for JIntent

procedure TForm1.FormCreate(Sender: TObject);
var
  LIntent: JIntent;
begin
  LIntent := TJIntent.Create;
  LIntent.setClassName(TAndroidHelper.Activity.getBaseContext,
    TAndroidHelper.StringToJString('com.embarcadero.services.AndroidRadioService'));
  LIntent.setAction(StringToJString('StartIntent'));
  TAndroidHelper.Activity.startService(LIntent);
end;



6. To pause the radio add this code somewhere in your project:
var
  LIntent: JIntent;

        LIntent := TJIntent.Create;
        LIntent.setClassName(TAndroidHelper.Context.getPackageName(),
          TAndroidHelper.StringToJString('com.embarcadero.services.AndroidRadioService'));
        LIntent.setAction(StringToJString('PauseRadio'));
        TAndroidHelper.Activity.startService(LIntent);



7. To play the radio add this code somewhere in your project:
var
  LIntent: JIntent;

        LIntent := TJIntent.Create;
        LIntent.setClassName(TAndroidHelper.Context.getPackageName(),
          TAndroidHelper.StringToJString('com.embarcadero.services.AndroidRadioService'));
        LIntent.setAction(StringToJString('PlayRadio'));
        TAndroidHelper.Activity.startService(LIntent);


</pre>

# FMX.Radio
Delphi Tokyo 10.2.2 Firemonkey Radio Player
Stream data from HTTP and FTP servers (inc. Shoutcast, Icecast & Icecast2), with IDN and proxy server support and adjustable buffering 

#FMX.Radio.Windows
<pre>
1. Download bass24.zip from http://www.un4seen.com (direct link http://uk.un4seen.com/files/bass24.zip ).
2. Extract the archive somewhere, copy extracted bass.dll to your project output directory.
</pre>

#FMX.Radio.Android
<pre>
Download Latest Bass from http://www.un4seen.com/forum/?topic=13225


Project -> Deployment -> Add Files

1 : Library->Android->armeabi  (Currently usable almost all androids)
	a : libbass.so
	b : libbass_aac.so	
	c : libbassflac.so
	Remote Path : library\lib\armeabi\

OR : Library->Android->x86
	a : libbass.so
	b : libbass_aac.so	
	c : libbassflac.so
	Remote Path : library\lib\x86\

OR : Library->Android->armeabi-v7a (Only usable in the newest androids)
	a : libbass.so
	b : libbass_aac.so	
	c : libbassflac.so
	Remote Path : library\lib\armeabi-v7a\


Make sure library files remote path name, must be added in the Deployment window.
</pre>


#FMX.Radio.IOS

#Bass Audio Library
BASS is an audio library for use in software on several platforms. Its purpose is to provide developers with powerful and efficient sample, stream (MP3, MP2, MP1, OGG, WAV, AIFF, custom generated, and more via OS codecs and add-ons), MOD music (XM, IT, S3M, MOD, MTM, UMX), MO3 music (MP3/OGG compressed MODs), and recording functions. All in a compact DLL that won't bloat your distribution.

#Android
http://www.un4seen.com/forum/?topic=13225

#IOS
http://www.un4seen.com/forum/?topic=10910

#WinCE
http://www.un4seen.com/forum/?topic=9534

#ARMLINUX
http://www.un4seen.com/forum/?topic=13804
