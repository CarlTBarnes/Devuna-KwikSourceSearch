

   MEMBER('KssKeyGen.clw')                                 ! This is a MEMBER module

!region Notices
! ================================================================================
! Notice : Copyright (C) 2017, Devuna
!          Distributed under the MIT License (https://opensource.org/licenses/MIT)
!
!    This file is part of Devuna-KwikSourceSearch (https://github.com/Devuna/Devuna-KwikSourceSearch)
!
!    Devuna-KwikSourceSearch is free software: you can redistribute it and/or modify
!    it under the terms of the MIT License as published by
!    the Open Source Initiative.
!
!    Devuna-KwikSourceSearch is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    MIT License for more details.
!
!    You should have received a copy of the MIT License
!    along with Devuna-KwikSourceSearch.  If not, see <https://opensource.org/licenses/MIT>.
! ================================================================================
!endregion Notices 

   INCLUDE('ABTOOLBA.INC'),ONCE
   INCLUDE('ABWINDOW.INC'),ONCE

!!! <summary>
!!! Generated from procedure template - Window
!!! </summary>
Main PROCEDURE 

!region Notices
! ================================================================================
! Notice : Copyright (C) 2017, Devuna
!          Distributed under the MIT License (https://opensource.org/licenses/MIT)
!
!    This file is part of Devuna-KwikSourceSearch (https://github.com/Devuna/Devuna-KwikSourceSearch)
!
!    Devuna-KwikSourceSearch is free software: you can redistribute it and/or modify
!    it under the terms of the MIT License as published by
!    the Open Source Initiative.
!
!    Devuna-KwikSourceSearch is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
!    MIT License for more details.
!
!    You should have received a copy of the MIT License
!    along with Devuna-KwikSourceSearch.  If not, see <https://opensource.org/licenses/MIT>.
! ================================================================================
!endregion Notices 
Registrant           CSTRING(29)                           ! 
sLicense      STRING(72)
BinaryLicense STRING(36)
bLicense      BYTE,DIM(36),OVER(BinaryLicense)
pType         ULONG
pData         ULONG
sMask         STRING('<048h,0DCh,09Ch,060h,026h,08Ah,011h,0E1h,03Dh,06Ch,005h,0B1h,09Bh,071h,04Ah,0E1h,048h,0DCh,09Ch,060h,026h,08Ah,011h,0E1h,03Dh,06Ch,005h,0B1h,09Bh,071h,04Ah,0E1h,048h,0DCh,09Ch,060h>')
bMask         BYTE,DIM(36),OVER(sMask)
lDate         LONG
sDate         STRING(4),OVER(lDate)
crc           LONG
sCrc          STRING(4),OVER(crc) 
Window               WINDOW('KSS Key Generator'),AT(,,179,78),FONT('Segoe UI',10),DOUBLE,ICON('kss.ico'),GRAY,SYSTEM,IMM
                       PROMPT('Registrant'),AT(5,5),USE(?Registrant:Prompt)
                       ENTRY(@s28),AT(45,5,128,10),USE(Registrant)
                       PROMPT('Key'),AT(5,20),USE(?sLicense:Prompt)
                       TEXT,AT(45,20,128,34),USE(sLicense),READONLY,SKIP
                       BUTTON('&Generate'),AT(78,59,45,14),USE(?cmdGenerate),DEFAULT
                       BUTTON('Cl&ose'),AT(129,59,45,14),USE(?cmdClose)
                     END

ThisWindow           CLASS(WindowManager)
Init                   PROCEDURE(),BYTE,PROC,DERIVED
Kill                   PROCEDURE(),BYTE,PROC,DERIVED
TakeAccepted           PROCEDURE(),BYTE,PROC,DERIVED
                     END

Toolbar              ToolbarClass


  CODE
  GlobalResponse = ThisWindow.Run()                        ! Opens the window and starts an Accept Loop

!---------------------------------------------------------------------------
DefineListboxStyle ROUTINE
!|
!| This routine create all the styles to be shared in this window
!| It`s called after the window open
!|
!---------------------------------------------------------------------------

ThisWindow.Init PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  GlobalErrors.SetProcedureName('Main')
  SELF.Request = GlobalRequest                             ! Store the incoming request
  ReturnValue = PARENT.Init()
  IF ReturnValue THEN RETURN ReturnValue.
  SELF.FirstField = ?Registrant:Prompt
  SELF.VCRRequest &= VCRRequest
  SELF.Errors &= GlobalErrors                              ! Set this windows ErrorManager to the global ErrorManager
  SELF.AddItem(Toolbar)
  CLEAR(GlobalRequest)                                     ! Clear GlobalRequest after storing locally
  CLEAR(GlobalResponse)
  SELF.Open(Window)                                        ! Open window
  Do DefineListboxStyle
  INIMgr.Fetch('Main',Window)                              ! Restore window settings from non-volatile store
  SELF.SetAlerts()
  RETURN ReturnValue


ThisWindow.Kill PROCEDURE

ReturnValue          BYTE,AUTO

  CODE
  ReturnValue = PARENT.Kill()
  IF ReturnValue THEN RETURN ReturnValue.
  IF SELF.Opened
    INIMgr.Update('Main',Window)                           ! Save window data to non-volatile store
  END
  GlobalErrors.SetProcedureName
  RETURN ReturnValue


ThisWindow.TakeAccepted PROCEDURE

ReturnValue          BYTE,AUTO

i                    LONG
j                    LONG
hiNibble             BYTE
loNibble             BYTE
Looped BYTE
  CODE
  LOOP                                                     ! This method receive all EVENT:Accepted's
    IF Looped
      RETURN Level:Notify
    ELSE
      Looped = 1
    END
  ReturnValue = PARENT.TakeAccepted()
    CASE ACCEPTED()
    OF ?cmdGenerate
      ThisWindow.Update()
      lDate = DATE(MONTH(TODAY()),DAY(TODAY()),YEAR(TODAY())+100)
      BinaryLicense = sDate & Registrant & ALL(' ',28-LEN(Registrant))
      crc = kcr_crc32(ADDRESS(BinaryLicense),32,0)
      BinaryLicense = sDate & Registrant & ALL(' ',28-LEN(Registrant)) & sCrc
      LOOP i = 1 TO 36
           bLicense[i] = BXOR(bLicense[i],bMask[i])
           hiNibble = BSHIFT(BAND(bLicense[i],0F0h),-4)
           loNibble = BAND(bLicense[i],0Fh)
           j = ((i-1) * 2) + 1
           CASE hiNibble
             OF 0
                sLicense[j] = '0'
             OF 1
                sLicense[j] = '1'
             OF 2
                sLicense[j] = '2'
             OF 3
                sLicense[j] = '3'
             OF 4
                sLicense[j] = '4'
             OF 5
                sLicense[j] = '5'
             OF 6
                sLicense[j] = '6'
             OF 7
                sLicense[j] = '7'
             OF 8
                sLicense[j] = '8'
             OF 9
                sLicense[j] = '9'
             OF 10
                sLicense[j] = 'A'
             OF 11
                sLicense[j] = 'B'
             OF 12
                sLicense[j] = 'C'
             OF 13
                sLicense[j] = 'D'
             OF 14
                sLicense[j] = 'E'
             OF 15
                sLicense[j] = 'F'
           END     
           CASE loNibble
             OF 0
                sLicense[j+1] = '0'
             OF 1
                sLicense[j+1] = '1'
             OF 2
                sLicense[j+1] = '2'
             OF 3
                sLicense[j+1] = '3'
             OF 4
                sLicense[j+1] = '4'
             OF 5
                sLicense[j+1] = '5'
             OF 6
                sLicense[j+1] = '6'
             OF 7
                sLicense[j+1] = '7'
             OF 8
                sLicense[j+1] = '8'
             OF 9
                sLicense[j+1] = '9'
             OF 10
                sLicense[j+1] = 'A'
             OF 11
                sLicense[j+1] = 'B'
             OF 12
                sLicense[j+1] = 'C'
             OF 13
                sLicense[j+1] = 'D'
             OF 14
                sLicense[j+1] = 'E'
             OF 15
                sLicense[j+1] = 'F'
           END     
      END  
      DISPLAY(sLicense)
      SETCLIPBOARD(sLicense)
    OF ?cmdClose
      ThisWindow.Update()
      POST(EVENT:CloseWindow)
    END
    RETURN ReturnValue
  END
  ReturnValue = Level:Fatal
  RETURN ReturnValue

