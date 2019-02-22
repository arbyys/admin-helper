#include <Vis2>
#include <Notify>

;           _____  __  __ _____ _   _      _    _ ______ _      _____  ______ _____  
;     /\   |  __ \|  \/  |_   _| \ | |    | |  | |  ____| |    |  __ \|  ____|  __ \ 
;    /  \  | |  | | \  / | | | |  \| |    | |__| | |__  | |    | |__) | |__  | |__) |
;   / /\ \ | |  | | |\/| | | | | . ` |    |  __  |  __| | |    |  ___/|  __| |  _  / 
;  / ____ \| |__| | |  | |_| |_| |\  |    | |  | | |____| |____| |    | |____| | \ \ 
; /_/    \_\_____/|_|  |_|_____|_| \_|    |_|  |_|______|______|_|    |______|_|  \_\
;
; by Arbys
                                                                                  

;============================;
;        [ PROMĚNNÉ ]        ;
;============================;

a := new Vis2.Graphics.Subtitle(windowTitle)
max = 21
y = ""
chatinput := false
secondwin := false
secondwin2 := false
secondwin3 := false
leftobj = false
action = 0
posh = 0
pose := [-1, -1, -1, -1, -1]
akce_id := []
akce_odmeny := []
akce_nazev = ""

;============================;
;       [ NASTAVENÍ ]        ;
;============================;

IniRead, iup, settings.ini, ButtonsB, Up
IniRead, ileft, settings.ini, ButtonsB, Left 
IniRead, iright, settings.ini, ButtonsB, Right
IniRead, idown, settings.ini, ButtonsB, Down
IniRead, filter, settings.ini, Cmdreader, filter
IniRead, chatlogpath, settings.ini, About, chatlogpath
IniRead, name, settings.ini, About, name
IniRead, version, data.ini, Version, version

;============================;
;       [ PO STARTU ]        ;
;============================;

; Jestli script běží s admin právy
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"
   ExitApp
}

; Auto-updater
whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
whr.Open("GET", "https://raw.githubusercontent.com/czArbys/admin-helper/master/version.txt", true)
whr.Send()
whr.WaitForResponse()
res := whr.ResponseText
StringReplace, res, res, `n,, All

if (!(version == res))
{
	MsgBox, 4,, K dispozici je nová verze Admin Helperu. Chcete updatovat?
	IfMsgBox Yes
	{
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", "https://raw.githubusercontent.com/czArbys/admin-helper/master/new.ahk", true)
		whr.Send()
		whr.WaitForResponse()
		newscript := whr.ResponseText
		sec := "lib/new.ahk"
		WriteFile(newscript, sec)
		Sleep, 1000
		FileCopy, lib/new.ahk, Main.ahk, 1
		IniWrite, %res%, data.ini, Version, version
		MsgBox, Úspěšně updatováno na verzi %res%!
		Reload
	}
}

; Nastavení chatlogu
if (chatlogpath == 0)
{

	MsgBox, 4,, Je toto cesta k vašemu chatlog.txt ?`n`nC:\Users\%A_UserName%\Documents\GTA San Andreas User Files\SAMP\chatlog.txt
	IfMsgBox Yes
	{
		IniWrite, C:\Users\%A_UserName%\Documents\GTA San Andreas User Files\SAMP\chatlog.txt, settings.ini, About, chatlogpath
		chatlogpath := "C:\Users\%A_UserName%\Documents\GTA San Andreas User Files\SAMP\chatlog.txt"
	}
	else
	{
		MsgBox Vyberte prosím cestu k vašemu chatlog.txt
		FileSelectFile, SelectedFile, 3, , Vyberte cestu k chatlog.txt, Text Documents (*.txt; *.doc)
		if SelectedFile =
		{
			MsgBox, Nevybral jste cestu, program se ukončí.
			ExitApp
		}
		else
		{
			IniWrite, %SelectedFile%, settings.ini, About, chatlogpath
			chatlogpath := "C:\Users\%A_UserName%\Documents\GTA San Andreas User Files\SAMP\chatlog.txt"
		}
	}
	

}

; Nastavení jména
if (name == 0)
{
	InputBox, UserInput, Jméno, Zadejte své jméno v SA:MP., , 300, 150
	if ErrorLevel
	{
		MsgBox, Nevybral jste jméno, program se ukončí.
		ExitApp
	}
	else
	{
		IniWrite, %UserInput%, settings.ini, About, name
		MsgBox Vše nastaveno! Můžete začít používat AdminHelper!
	}
}

; "Check" se bude opakovat každých 200ms
#Persistent
SetTimer, Check, 200
return

;============================;
;         [ FUNKCE ]         ;
;============================;

CheckWin() ; Test, zda je aktivní GTA:SA okno
{
   WinGetTitle, Title, A

   if (Title == "GTA:SA:MP")
   {
      return true
   }
   else
   {   
      return false
   }
}

WriteFile(_Data,_FileName)
{
	RunWait, %COMSPEC% /c type null > %_FileName% ,,Hide
	FileAppend, %_Data%, %_FileName%, UTF-8
}
GetId(s) ; ID ze zprávy
{
   RegExMatch(s, ".*\(([\d]{1,3})\).*", out)
   Return out1
   
}

GetIdRace(s) ; ID ze zprávy o závodě
{
   RegExMatch(s, ".*\w\(([\d]{1,3})\).*", out)
   Return out1

}

GetPos(s) ; Pozice ze zprávy o závodě
{
	RegExMatch(s, ".*\s\((\d{1})\)", out)
	Return out1
}

FormatChatlog(k, f) ; Poslední řádek chatlogu
{

   Loop Read, %f%

      i := Mod(A_Index,k), L%i% := A_LoopReadLine

   Loop % k

      i := Mod(i+1,k), L .= L%i% "`n"

   StringReplace, L, L, `r,, All
   StringReplace, L, L, `n,, All

   Return L

}

FilterList(l) ; Filtrace listu
{
	ail := ""
	Loop % l.Length()
	{
		if (!(l[A_Index] == -1))
		{
			ail .= l[A_Index] . " "
		}

	}
	return ail
}

;============================;
;          [ MENU ]          ;
;============================;

!;::

	DllCall("ShowCursor","Uint",0)
	
	;Smazání menu
	if (w0.isVisible() == 1)
	{
		wr := Vis2.Graphics.Subtitle.Render("", "xCenter y55% w800 h350 c0099FF")
		Loop
		{
			if (A_Index > max)
			{
				break
			}
			
			w%A_index%.Destroy()
		}
		wauthor.Destroy()
		wversion.Destroy()
		w0.Destroy()
		wr.Destroy()
	}
	
	;Vykreslení menu
	else
	{
		w0 := Vis2.Graphics.Subtitle.Render("", "xCenter y55% w800 h350 c0099FF")
		w1 := Vis2.Graphics.Subtitle.Render("ADMIN HELPER", "xCenter y55% w800 c0066CC", "xCenter y10% cffffff s4%")
		wauthor := Vis2.Graphics.Subtitle.Render("by Arbys", "x1290 y57.7% cNone", "xCenter cffffff s1.8%")
		wversion := Vis2.Graphics.Subtitle.Render("v" . version . "", "x560 y57.7% cNone", "xCenter cffffff s1.8%")
		if(iup == "T")
		{
			w2 := Vis2.Graphics.Subtitle.Render("⮝", "xCenter cNone y60%", "c00d800 s8%")
		}
		else
		{
			w2 := Vis2.Graphics.Subtitle.Render("⮝", "xCenter cNone y60%", "ccc0000 s8%")
		}
		w3 := Vis2.Graphics.Subtitle.Render("KONTROLA CHATU", "xCenter cNone y66.5%", "c000000 s2%")
		if(ileft == "T")
		{
			w4 := Vis2.Graphics.Subtitle.Render("⮜", "x560 cNone y70%", "c00d800 s8%")
		}
		else
		{
			w4 := Vis2.Graphics.Subtitle.Render("⮜", "x560 cNone y70%", "ccc0000 s8%")
		}
		w5 := Vis2.Graphics.Subtitle.Render("UPZORONĚNÍ NA REPORTY", "x1055 cNone y72.5%", "c000000 s2%")
		if(iright == "T")
		{
			w6 := Vis2.Graphics.Subtitle.Render("⮞", "x1260 atopright cNone y70%", "c00d800 s8%")
		}
		else
		{
			w6 := Vis2.Graphics.Subtitle.Render("⮞", "x1260 atopright cNone y70%", "ccc0000 s8%")
		}
		w7 := Vis2.Graphics.Subtitle.Render("NESMAZÁNÍ OBJ / PICKUPŮ", "x630 cNone y72.5%", "c000000 s2%")
		if(idown == "T")
		{
			w8 := Vis2.Graphics.Subtitle.Render("⮟", "xCenter cNone y80%", "c00d800 s8%")
		}
		else
		{
			w8 := Vis2.Graphics.Subtitle.Render("⮟", "xCenter cNone y80%", "ccc0000 s8%")
		}
		w9 := Vis2.Graphics.Subtitle.Render("FILTRACE CMDREADER", "xCenter cNone y79%", "c000000 s2%")
		w10 := Vis2.Graphics.Subtitle.Render("VPN TEST", "xCenter c333333 w800 h3% y87.4%", "cffffff xCenter y20% s2%")
		w11 := Vis2.Graphics.Subtitle.Render("MAX RYCHLOSTI", "xCenter cNone w800 h3% y87.4%", "cffffff xLeft y20% s2%")
		w12 := Vis2.Graphics.Subtitle.Render("NASTAVENÍ FILTRACE", "xCenter cNone w800 h3% y87.4%", "cffffff xRight y20% s2%")
		w13 := Vis2.Graphics.Subtitle.Render("[ NUM 2 ]", "xCenter c333333 w800 h2.5% y90%", "cdaa520 xCenter y20% s1.5%")
		w14 := Vis2.Graphics.Subtitle.Render("[ NUM 1 ]", "xCenter cNone w800 h2.5% y90%", "cdaa520 xLeft y20% s1.5%")
		w15 := Vis2.Graphics.Subtitle.Render("[ NUM 3 ]", "xCenter cNone w800 h2.5% y90%", "cdaa520 xRight y20% s1.5%")
		
		w16 := Vis2.Graphics.Subtitle.Render("HARMONOGRAM", "xCenter c333333 w800 h3% y92.4%", "cffffff xCenter y20% s2%")
		w17 := Vis2.Graphics.Subtitle.Render("HROMADNÁ VÝHRA AKCE", "xCenter cNone w800 h3% y92.4%", "cffffff xLeft y20% s2%")
		w18 := Vis2.Graphics.Subtitle.Render("VÝSLEDKY FILTRACE", "xCenter cNone w800 h3% y92.4%", "cffffff xRight y20% s2%")
		w19 := Vis2.Graphics.Subtitle.Render("[ NUM 5 ]", "xCenter c333333 w800 h2.5% y95%", "cdaa520 xCenter y20% s1.5%")
		w20 := Vis2.Graphics.Subtitle.Render("[ NUM 4 ]", "xCenter cNone w800 h2.5% y95%", "cdaa520 xLeft y20% s1.5%")
		w21 := Vis2.Graphics.Subtitle.Render("[ NUM 6 ]", "xCenter cNone w800 h2.5% y95%", "cdaa520 xRight y20% s1.5%")
	}
return

;============================;
;         [ BINDY ]          ;
;============================;

;Ukončení aplikace
!Del::
ExitApp
return

;Bindy pokud je menu aktivní
#If w0.isVisible() == 1
Up::
	if(iup == "T")
	{
		IniWrite, F, settings.ini, ButtonsB, Up
		iup := "F"
		w2.Destroy()
		w2 := Vis2.Graphics.Subtitle.Render("⮝", "xCenter cNone y60%", "ccc0000 s8%")
		Notify("Info", "Kontrola chatu byla vypnuta!", 4)
		
	}
	else
	{
		IniWrite, T, settings.ini, ButtonsB, Up
		iup := "T"
		w2.Destroy()
		w2 := Vis2.Graphics.Subtitle.Render("⮝", "xCenter cNone y60%", "c00d800 s8%")
		Notify("Info", "Kontrola chatu byla zapnuta!", 4)
	}
	SoundPlay *-1
return
Right::
	if(iright == "T")
	{
		IniWrite, F, settings.ini, ButtonsB, Right
		iright := "F"
		w6.Destroy()
		w6 := Vis2.Graphics.Subtitle.Render("⮞", "x1260 atopright cNone y70%", "ccc0000 s8%")
		Notify("Info", "Funkce upozornění na reporty byla vypnuta!", 4)
	}
	else
	{
		IniWrite, T, settings.ini, ButtonsB, Right
		iright := "T"
		w6.Destroy()
		w6 := Vis2.Graphics.Subtitle.Render("⮞", "x1260 atopright cNone y70%", "c00d800 s8%")
		Notify("Info", "Funkce upozornění na reporty byla zapnuta!", 4)
	}
	SoundPlay *-1
return
Left::
	if(ileft == "T")
	{
		IniWrite, F, settings.ini, ButtonsB, Left
		ileft := "F"
		w4.Destroy()
		w4 := Vis2.Graphics.Subtitle.Render("⮜", "x560 cNone y70%", "ccc0000 s8%")
		Notify("Info", "Kontrola nesmazání objektů / pickupů byla vypnuta!", 4)
	}
	else
	{
		IniWrite, T, settings.ini, ButtonsB, Left
		ileft := "T"
		w4.Destroy()
		w4 := Vis2.Graphics.Subtitle.Render("⮜", "x560 cNone y70%", "c00d800 s8%")
		Notify("Info", "Kontrola nesmazání objektů / pickupů byla zapnuta!", 4)
	}
	SoundPlay *-1
return
Down::
	if(idown == "T")
	{
		IniWrite, F, settings.ini, ButtonsB, Down
		idown := "F"
		w8.Destroy()
		w8 := Vis2.Graphics.Subtitle.Render("⮟", "xCenter cNone y80%", "ccc0000 s8%")
		Notify("Info", "Filtrace cmdreaderu byla vypnuta!", 4)
	}
	else
	{
		IniWrite, T, settings.ini, ButtonsB, Down
		IniWrite, -, data.ini, CmdreaderData, ids
		idown := "T"
		w8.Destroy()
		w8 := Vis2.Graphics.Subtitle.Render("⮟", "xCenter cNone y80%", "c00d800 s8%")
		Notify("Info", "Filtrace cmdreaderu byla zapnuta!", 4)
	}
	SoundPlay *-1
return
Numpad1::
if (CheckWin())
{
	wr := Vis2.Graphics.Subtitle.Render("", "xCenter y55% w800 h350 c0099FF")
	Loop
	{
		if (A_Index > max)
		{
			break
		}
		
		w%A_index%.Destroy()
	}
	wauthor.Destroy()
	wversion.Destroy()
	w0.Destroy()
	wr.Destroy()
	SplashImage, lib/img2.png, b ZW1500 ZH1000 W1500 H1000
	DllCall("ShowCursor","Uint",0)
	sub4 := Vis2.Graphics.Subtitle.Render("ESC = zavřít", "x2% p1% c222222 y7%", "ccc0000 s2.5%")
	secondwin2 := true
}
else
{
	MsgBox Musíte mít zaplé GTA:SA!
}
return
Numpad2::
if (CheckWin())
{
	wr := Vis2.Graphics.Subtitle.Render("", "xCenter y55% w800 h350 c0099FF")
	Loop
	{
		if (A_Index > max)
		{
			break
		}
		
		w%A_index%.Destroy()
	}
	wauthor.Destroy()
	wversion.Destroy()
	w0.Destroy()
	wr.Destroy()
	SendInput t^a/ [ Zadej IP adresu pro VPN test | 'ENTER' = potvrdit; 'DELETE' = ukončit ] :{space}
	chatinput := true
	action = 2
}
else
{
	MsgBox Musíte mít zaplé GTA:SA!
}
return
Numpad3::
if (CheckWin())
{
	wr := Vis2.Graphics.Subtitle.Render("", "xCenter y55% w800 h350 c0099FF")
	Loop
	{
		if (A_Index > max)
		{
			break
		}
		
		w%A_index%.Destroy()
	}
	wauthor.Destroy()
	wversion.Destroy()
	w0.Destroy()
	wr.Destroy()
	SendInput t^a/ [ Zadej slovo, co chceš v cmdreader filtrovat | 'ENTER' = potvrdit; 'DELETE' = ukončit ] : %filter%
	chatinput := true
	action = 3
}
else
{
	MsgBox Musíte mít zaplé GTA:SA!
}
return
Numpad4::
if (CheckWin())
{
	wr := Vis2.Graphics.Subtitle.Render("", "xCenter y55% w800 h350 c0099FF")
	Loop
	{
		if (A_Index > max)
		{
			break
		}
		
		w%A_index%.Destroy()
	}
	wauthor.Destroy()
	wversion.Destroy()
	w0.Destroy()
	wr.Destroy()
	int := FilterList(pose)
	SendInput t^a/ [ Zadej ID výherců, oddělená mezerou | 'ENTER' = potvrdit; 'DELETE' = ukončit ] : %int%
	chatinput := true
	action := 4
}
else
{
	MsgBox Musíte mít zaplé GTA:SA!
}
return
Numpad5::
	wr := Vis2.Graphics.Subtitle.Render("", "xCenter y55% w800 h350 c0099FF")
	Loop
	{
		if (A_Index > max)
		{
			break
		}
		
		w%A_index%.Destroy()
	}
	wauthor.Destroy()
	wversion.Destroy()
	w0.Destroy()
	wr.Destroy()
	SplashImage, lib/img.png, b ZW1500 ZH1000 W1500 H1000
	DllCall("ShowCursor","Uint",0)
	sub4 := Vis2.Graphics.Subtitle.Render("ESC = zavřít", "x2% p1% c222222 y7%", "ccc0000 s2.5%")
	secondwin2 := true
return
Numpad6::
	wr := Vis2.Graphics.Subtitle.Render("", "xCenter y55% w800 h350 c0099FF")
	Loop
	{
		if (A_Index > max)
		{
			break
		}
		
		w%A_index%.Destroy()
	}
	wauthor.Destroy()
	wversion.Destroy()
	w0.Destroy()
	wr.Destroy()
	
	IniRead, filter, settings.ini, Cmdreader, filter
	IniRead, ids, data.ini, CmdreaderData, ids
	sub1 := Vis2.Graphics.Subtitle.Render("", "xCenter y65% w800 h300 c333333")
	sub2 := Vis2.Graphics.Subtitle.Render("Výsledky filtrace slova '" . filter . "':", "xCenter cNone y70%", "c00d800 s3%")
	sub3 := Vis2.Graphics.Subtitle.Render("" . ids . "", "xCenter cNone y75%", "c00d800 s2%")
	sub4 := Vis2.Graphics.Subtitle.Render("ESC = zavřít", "x560 cNone y65.5%", "ccc0000 s2%")
	secondwin := true
	
return

;Bindy pokud je aktivní jiné okno
#If secondwin == true
Esc::
	Loop, 4
	{
		sub%A_index%.Destroy()
	}
	secondwin := false
return

;Bindy pokud je aktivní jiné okno
#If secondwin2 == true
Esc::
	SplashImage, Off
	sub4.Destroy()
	secondwin2 := false
	Sleep, 100
	DllCall("ShowCursor","Uint",0)
return
w::
a::
s::
d::
space::
ctrl::
alt::
shift::
enter::
t::
lbutton::
rbutton::
return

;Bindy pokud je aktivní jiné okno
#If secondwin3 == true
Delete::
	Loop, 7
	{
		akce_%A_index%.Destroy()
	}
	secondwin3 := false
return

Enter::
	Loop, 7
	{
			akce_%A_index%.Destroy()
	}
	Loop
	{
		if (A_Index > akce_id.MaxIndex())
		{
			break
		}
			
		s := "/vyhralakcigm " . akce_id[A_index] . " " . akce_odmeny[A_index] . " " . akce_nazev . " | " . A_Index . ". místo"
		SendInput t^a%s%{Enter}
	}
	secondwin3 := false
return

;Bindy pokud je aktivní input v chatu
#If chatinput == true
Delete::
	SendInput ^a{BackSpace}{Esc}
	chatinput := false
return
Enter::
	oCB := ClipboardAll
	Send, ^a
    Send, ^c
    Send {Del}
    Send {Esc}
    ClipWait,1
	RegExMatch(clipboard, ".*\]\s\:\s(.*)", out)
	if (action == 1)
	{
		chatinput := false

	}
	else if (action == 2)
	{
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		whr.Open("GET", "http://proxy.mind-media.com/block/proxycheck.php?ip=" . out1 . "", true)
		whr.Send()
		whr.WaitForResponse()
		res := whr.ResponseText
		if (res == "Y")
		{
			Notify("Info", "Ip adresa " . out1 . " je VPN!", 4)
		}
		else
		{
			Notify("Info", "Ip adresa " . out1 . " není VPN!", 4)
			
		}
		SoundPlay *-1
		chatinput := false
	}
	else if (action == 3)
	{
		IniWrite, %out1%, settings.ini, Cmdreader, filter
		Notify("Info", "Nyní je nastaveno pro filtraci v cmdreaderu slovo " . out1 . "", 4)
		filter := out1
		SoundPlay *-1
		chatinput := false
		
	}
	else if (action == 4)
	{
		akce_id := StrSplit(out1, A_Space)
		Loop,
		{
			if (A_Index > akce_id.MaxIndex())
			{
				break
			}
			
			if (akce_id[A_Index] == -1)
			{
				akce_id.RemoveAt(A_Index)
			}
		}
		SendInput t^a/ [ Zadej název akce | 'ENTER' = potvrdit; 'DELETE' = ukončit ] :{space}
		action := 41
	}
	else if (action == 41)
	{
		akce_nazev := out1
		SendInput t^a/ [ Zadej částku pro 1. místo | 'ENTER' = potvrdit; 'DELETE' = ukončit ] :{space}
		action := 42
	}
	else if (action == 42)
	{
		akce_odmeny[1] := out1
		Loop
		{
			if (A_Index > akce_id.MaxIndex())
			{
				break
			}
			
			if (A_Index != 1)
			{
				akce_odmeny[A_Index] := akce_odmeny[A_Index-1] - 50000
			}
		}
		inte := FilterList(akce_odmeny)
		SendInput t^a/ [ Zadej částky pro ostatní, oddělené mezerou | 'ENTER' = potvrdit; 'DELETE' = ukončit ] : %inte%{BackSpace}
		action := 43
	}
	else if (action == 43)
	{
		loca = 70
		Loop
		{
			if (A_Index > akce_id.MaxIndex())
			{
				break
			}
			akce_%A_Index% := Vis2.Graphics.Subtitle.Render("/vyhralakcigm " . akce_id[A_index] . " " . akce_odmeny[A_index] . " " . akce_nazev . " | " . A_Index . ". místo", "xCenter c333333 w800 y" . loca . "%", "c00d800 xCenter y10% s2.3%")
		loca += 3
		}
		akce_6 := Vis2.Graphics.Subtitle.Render("DELETE = storno", "xCenter cWhite p0.5% y62%", "ccc0000 s2%")
		akce_7 := Vis2.Graphics.Subtitle.Render("ENTER = potvrdit", "xCenter cWhite p0.5% y66%", "ccc0000 s2%")
		chatinput := false
		secondwin3 := true
	}
    ClipBoard := oCB
return
^a::
SendInput ^a
chatinput := false
return

;============================;
;         [ CHATLOG ]        ;
;============================;

;Hlavní funkce, která kontroluje chatlog.txt
Check:
x := % FormatChatlog(2, chatlogpath)
if (ileft == "T")
{
	if (!(WinExist("GTA:SA:MP")) && leftobj == true)
	{
		Notify("Upozornění", "Pozor, možná sis na serveru zapomněl smazat objekty!", 6)
		SoundPlay *-1
		leftobj := false
    }
	if (!(WinExist("GTA:SA:MP")) && leftpickup == true)
	{
		Notify("Upozornění", "Pozor, možná sis na serveru zapomněl smazat pickupy!", 6)
		SoundPlay *-1
		leftpickup := false
    }
}

if (!(x == y))
{
	if (iup == "T")
	{
		if ((RegExMatch(x, "(.)\1{25,}")) != 0)
		{
		  if ((RegExMatch(x, "\+Gang|\-Firma|\[\/\/]|\[=]|;Gang|Audio stream|rádius|*CB")) == 0)
		  {
			 idh := % GetId(x)
			 Notify("Mute", "Hráč s id " . idh . " možná spamuje!", 4)
			 SoundPlay *-1
		  }
		}

		else if ((RegExMatch(x, "http|:\/\/")) != 0)
		{
		  if ((RegExMatch(x, "\+Gang|\-Firma|\[\/\/]|\[=]|;Gang|Audio stream|rádius")) == 0)
		  {
			 idh := % GetId(x)
			 Notify("/spam", "Hráč s id " . idh . " možná píše URL do chatu!", 4)
			 SoundPlay *-1
		  }
		}
	}
	
	if (idown == "T")
	{
		if InStr(x, "cmdtext:")
		{
			if InStr(x, filter)
			{
				idh := % GetId(x)
				IniRead, ids, data.ini, CmdreaderData, ids
				IniWrite, %ids% ID: %idh% - , data.ini, CmdreaderData, ids
			}
		}
	}

	if (iright == "T")
	{
		if InStr(x, "nahlásil hráče:")
		{
			SoundPlay *-1
			Notify("Upozornění", "Přišel nový report za porušení pravidel!", 4)
		}
		else if InStr(x, "nahlásil cheatera:")
		{
			SoundPlay *-1
			Notify("Upozornění", "Přišel nový report za cheaty!", 4)
		}
	}
	
	if InStr(x, "Administrátor " . name . " načetl objekty")
	{
		leftobj := true
	}
	
	else if InStr(x, "Administrátor " . name . " odstranil své objekty")
	{
		leftobj := false
	}
	
	else if InStr(x, "Administrátor " . name . " odstranil všechny svoje pickupy")
	{
		leftpickup := false
	}
	
	else if InStr(x, "Administrátor " . name . " načetl pickupy")
	{
		leftpickup := true
	}
	
	else if InStr(x, "vyhrál závod v čase")
	{
		idh := % GetId(x)
		pose[1] := idh

	}
	
	else if InStr(x, "prohrál závod s časem")
	{
		idh := % GetIdRace(x)
		posh := % GetPos(x)
		if posh between 2 and 5
		{
			pose[posh] := idh
		}
	}
   y := x
}
return

;============================
; SEM SI LZE DÁT SVOJE BINDY:
