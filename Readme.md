-- Note from War3Evo --

   Works for Delphi 10.2.2 Tokyo for Firemonkey Android!
   Don't ask me about getting it working for iphone unless you just want to send me a iphone to work with!
   
-- End of Note from War3Evo --

# AndroidServicesRadio
This sample application is on Google Play: https://play.google.com/store/apps/details?id=com.embarcadero.plaStreamer&hl=en and I have included full source code.

INSTRUCTIONS: To make life simple, I created a Project Group called UseThisProjectGroup to combine both the plaStreamer project and the AndroidRadioService project in the AndroidServiceRadioSampleApplication folder.  You'll need to have both projects up so you can build the AndroidRadioService, then add it to your plaStreamer project by right clicking on Android underneath "Target Platforms" and choosing "Add Android Service..." then find the AndroidServicesRadio folder and add it.  You'll also need to add the *.pas files from the AndroidServicesRadio folder.  You'll also need to make sure you have DW.Androidapi.JNI.LocalBroadcastManager.pas and DW.MultiReceiver.Android.pas and DW.GlobalDefines.inc included in your plaStreamer project. Double click on plaStreamer project in the Project Manager on the right side of your screen.  It should make it bold.  Then click the menu "Project" then find and click "Deployment".  Make sure that you do have all the required libbass files.  If your using my project files, it should have them already listed.  Make sure the remote path for the libbass*.* files are like... library\lib\armeabi-v7a\ library\lib\armeabi\ library\lib\x86\ ... if not.. double or triple click on the remote path and change them!  Everything should run fine.  Its on Google Play!   Have any issues let me know! 

Requires source code from: https://github.com/War3Evo/KastriFree which allows the service to "talk back" to the main thread application.

Just put KastriFree folder next to the FMXradio folder, not inside it! Example:
<pre>
folder1
-- FMXradio
-- KastriFree
</pre>

Notes and other helpful information:

Check out the sourcecode from https://github.com/DelphiWorlds/KastriFree/blob/master/Demos/AndroidLocation/Application/LA.MainFrm.pas to understand how to make your main thread recieve the messages from the service.

I converted the FMX.Radio so that you could use it as a Android Service.  For some reason, you can't use any FMX (Firemonkey) source code in a Android Service.

The Youtube video https://www.youtube.com/watch?v=0mD3WLK8FYc is very helpful in understanding how to put a Android Service into your project.

In order to change the StreamURL, see procedure TForm1.FormCreate(Sender: TObject); in unit1.pas of the AndroidServiceRadioSampleApplication folder.

## OTHER INFORMATION from previous FMX.Radio that is helpful

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
