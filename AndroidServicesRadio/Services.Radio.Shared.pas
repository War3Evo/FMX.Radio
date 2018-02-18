{
  Author : Ersan YAKIT
           ersanyakit@yahoo.com.tr
           www.ersanyakit.com
}

unit Services.Radio.Shared;

interface

const
  strLoading:String='LOADING';
  strUnknown:String='UNKNOWN';
  strCompleted:String='COMPLETED';

type
    TStatusProc        = procedure(pszData : string;Progress:Integer);
    TBroadcastInfoProc = procedure(pszBroadcastName,pszBitRate:string);
    TBroadcastMetaProc = procedure(pszData : string);

implementation

end.
