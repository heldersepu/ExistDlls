{**
Program will check that on a given directory
for every "???.PAS" file there is a "???.DLL" 
the same for the "???I.PAS" & "f_???.PAS" files
If NOPAUSE found as a parameter it will bypass the:
  'Press ENTER to continue . . .'
**}

program ExistDlls;
{$APPTYPE CONSOLE}
uses
  SysUtils,
  ColorUtils in 'ColorUtils.pas';

var
  ErrorFile,
  strLOG: String;
  dPath : String = '';
  myFile: TextFile;
  I: Integer;
  doPause: Boolean = True;

//Concatenate the strings in Comma separated format (a, B, c)
Function addStr(strError, strName: String): String;
begin
  if strError = '' then
    addStr := strName
  else
    addStr := strError + ', ' + strName;
end;

//Checks that all the .PAS files have a .DLL file
//Returns the given strError + the new ones
Function checkFiles(strPath, strErrorFile: String): String;
  var SR: TSearchRec;
begin
  if FindFirst(strPath,$20,Sr) = 0 then
  Repeat
    if Not fileExists(dPath + StringReplace(SR.Name ,'.PAS','.DLL',[rfReplaceAll, rfIgnoreCase])) then
      strErrorFile := addStr(strErrorFile, SR.Name);
  Until (FindNext(Sr) <> 0);
  FindClose(SR);
  checkFiles := strErrorFile;
end;

Procedure ShowHelp;
begin
  writeln(' ');
  writeln('Displays a list of PAS files that have no DLL in a directory.');
  writeln(' checks that for all "???.PAS" file there is a "???.DLL" ');
  writeln(' same "???I.PAS" and "f_???.PAS" files');
  writeln(' ');
  writeln(' EXISTDLLS [drive:][path] [/NOPAUSE]') ;
  writeln(' ');
  writeln('   /NOPAUSE    Suppresses pause after the output in case of errors,');
  writeln('               default is to stop and wait for Enter key. ');
  writeln(' ');
  writeln('If no directory is provided will check current.');
  writeln(' ');
end;

begin
  //Read the folder from the command Line
  if (ParamCount > 0) then
  begin
    if (Pos(ParamStr(1), '/?') > 0) then
      ShowHelp
    else
    begin
    dPath := ParamStr(1);    //Get first parameter
    //Check parameters for "NoPause"
    for I := 1 to ParamCount do
    begin
      doPause := (Pos(UpperCase(ParamStr(I)), '/NOPAUSE -NOPAUSE') = 0);
      if not doPause then
      begin
        if I = 1 then dPath := GetCurrentDir; //Get Current folder
        break;
      end;
    end;
    end;
  end
  else
    dPath := GetCurrentDir; //Get Current folder

  if (dPath <> '') then
  begin
    //Add a "\" at the end of the folder name
    if (dPath[Length(dPath)] <> '\') then
      dPath := dPath + '\';


    strLOG := dPath + 'ERROR.LOG';
    ErrorFile := '';

    //Delete the Error log file
    if fileExists(strLOG) then
      DeleteFile(strLOG);

    //Check all ???.PAS files
    ErrorFile := checkFiles(dPath + '???.PAS'  ,ErrorFile);
    ErrorFile := checkFiles(dPath + '???I.PAS' ,ErrorFile);
    ErrorFile := checkFiles(dPath + 'f_???.PAS',ErrorFile);

    //If error Found DO output
    if ErrorFile <> '' then
    begin
      //Save errors to LOG file
      AssignFile(myFile, strLOG);
      ReWrite(myFile);
      writeln(myFile, dPath);
      writeln(myFile, ErrorFile);
      CloseFile(myFile);

      //Console Output
      writeln(' ');
      ColorWrite('    -***** ',14); ColorWrite('ERRORS FOUND ',12); ColorWrite('*****-',14,True);
      ColorWrite('  No DLL was created for the following files ',11,True);
      ColorWrite('   ' + ErrorFile,12,True);
      ColorWrite('  Log file: ' + strLOG,14,True);
      writeln(' ');
      if dopause then
      begin
        writeln('Press ENTER to continue . . .');
        readln;
      end;
    end;
  end;
end.

