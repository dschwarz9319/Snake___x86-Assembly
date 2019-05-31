INCLUDE Irvine32.inc
INCLUDELIB Irvine32.lib

.data
g_array BYTE 35 DUP(16 DUP(0))

;Declaration for Snake
firstDot DWORD 35,00h
secondDot DWORD 35,00h
thirdDot DWORD 35,00h
fourthDot DWORD 35,00h
fifthDot DWORD 35,00h
;Declaration for Cherry
cherry DWORD 42, 00h
;Player Health
healthMessage DB "Health: ", 0dh, 0Ah, 00h
health DWORD 3, 00h

;Score
score DWORD 0, 00h

;Endgame message
endgame DB "Game Over :( Score: ", 0dh, 0Ah, 00h

;Cherry Flag
cherryFlag DWORD 0, 00h

;vertical boundaries
verto DWORD 124, 00h
;horizontal boundries
horo DWORD 45, 00h
;8 bit variable used to keep track of y coordinate
vertCounter DB 0d
;8 bit variable used to keep track of x coordinate
horiCounter DB 0d

twoVertCounter DB 0d
twoHoriCounter DB 0d

threeVertCounter DB 0d
threeHoriCounter DB 0d

fourVertCounter DB 0d
fourHoriCounter DB 0d

fiveVertCounter DB 0d
fiveHoriCounter DB 0d

;newline
newline DB 0Dh, 0Ah, 00h
;empty space between boundaries
space BYTE "                                      ", 00h
;empty space before boundaries
firstSpace BYTE "             ", 00h
eaxXCord DWORD ?
ebxYCord DWORD ?
cherryXCord DWORD ?
cherryYCord DWORD ?
;Arena Boundaries
xRangeLow DWORD 14
xRangeHigh DWORD 20
yRangeLow DWORD 10
yRangeHigh DWORD 17


.code


access2DArray PROC USES EDX ESI, array:DWORD, x:DWORD, y:DWORD, a_width:DWORD
       MOV EAX, a_width
       MUL y
       ADD EAX, x
       ADD EAX, array
       MOV ESI, EAX
       MOV EAX, 0
       MOV AL, [ESI]
       RET
access2DArray ENDP
 
write2DArray PROC USES EAX EDX, val:BYTE, array:DWORD, x:DWORD, y:DWORD, a_width:DWORD
       MOV EAX, a_width
       MUL y
       ADD EAX, x
       MOV DL, val
       ADD EAX, array
       MOV [EAX], DL
       RET
write2DArray ENDP



main PROC
;Draws outline for arena
SnakeLocation:
MOV DL, 33
MOV DH, 10

MOV horiCounter, 33
MOV twoHoriCounter, 33
MOV threeHoriCounter, 33
MOV fourHoriCounter, 33
MOV fiveHoriCounter, 33

MOV vertCounter, 10
MOV twoVertCounter, 10
MOV threeVertCounter, 10
MOV fourVertCounter, 10
MOV fiveVertCounter, 10

WindowSetup:
MOVZX EAX, DL
PUSH EAX
MOVZX EBX, DH
PUSH EBX

MOV dl, 13
MOV dh, 0
CALL Gotoxy

PrePrintTopLine:
MOV ECX, 40
MOV EAX, 0

PrintTopLine:
MOV EAX, horo
CALL WriteChar
INC EAX
LOOP PrintTopLine
MOV EDX, OFFSET newline
CALL WriteString

PrePrintRows:
MOV ECX, 19
MOV EAX, 0

PrintRows:
MOV EDX, OFFSET firstSpace
CALL WriteString
MOV EAX, verto
CALL WriteChar
MOV EDX, OFFSET space
CALL WriteString
MOV EAX, verto
CALL WriteChar
MOV EDX, OFFSET newline
CALL WriteString
INC EAX
LOOP PrintRows

PrePrintBottomLine:
MOV ECX, 40
MOV EAX, 0

MOV EDX, OFFSET firstSpace
CALL WriteString

PrintBottomLine:
MOV EAX, horo
CALL WriteChar
INC EAX
LOOP PrintBottomLine
MOV EDX, OFFSET newline
CALL WriteString

MOV EDX, OFFSET healthMessage
CALL WriteString
MOV EAX, health
CALL WriteInt

CMP cherryFlag, 0
JE GenerateCherry

Popping:
POP EBX
MOV ebxYcord, EBX
MOV DH, BYTE PTR ebxYCord
POP EAX
MOV eaxXCord, EAX
MOV DL, BYTE PTR eaxXCord


;Displays first "*" in middle of screen
CALL GotoXY
MOV EAX, firstDot
CALL WriteChar
.IF score > 0
MOV DL, twoHoriCounter
MOV DH, twoVertCounter
CALL GotoXY
MOV EAX, firstDot
CALL WriteChar
MOV DL, horiCounter
MOV DH, vertCounter
.ENDIF

.IF score > 1
MOV DL, threeHoriCounter
MOV DH, threeVertCounter
CALL GotoXY
MOV EAX, firstDot
CALL WriteChar
MOV DL, horiCounter
MOV DH, vertCounter
.ENDIF

.IF score > 2
MOV DL, fourHoriCounter
MOV DH, fourVertCounter
CALL GotoXY
MOV EAX, firstDot
CALL WriteChar
MOV DL, horiCounter
MOV DH, vertCounter
.ENDIF

.IF score > 3
MOV DL, fiveHoriCounter
MOV DH, fiveVertCounter
CALL GotoXY
MOV EAX, firstDot
CALL WriteChar
MOV DL, horiCounter
MOV DH, vertCounter
.ENDIF



;Displays Cherry
MOV DL, BYTE PTR cherryXCord 
MOV DH, BYTE PTR cherryYCord
CALL GotoXy
MOV EAX, cherry
CALL WriteChar

Trails:
	;checks player health
	CMP health, 0
	JE GameOver
	;allows for pause in user input
	MOV EAX, 50
	CALL Delay
	;accepts user input
	CALL ReadChar
	JZ Trails


	;checks if "d" key was pressed
	CMP AL, 100
	JE MoveRight
	;checks if "a" key was pressed
	CMP Al, 97
	JE MoveLeft
	;checks is "d" key was pressed
	CMP AL, 115
	JE LineDown
	;checks if "w" key was pressed
	CMP AL, 119
	JE LineUp


LineDown:
	CMP vertCounter, 18
	JG Damage


MOV AL, fourVertCounter
MOV fiveVertCounter, AL

MOV AL, threeVertCounter
MOV fourVertCounter, AL

MOV AL, twoVertCounter
MOV threeVertCounter, AL

MOV AL, vertCounter
MOV twoVertCounter, AL

INC vertCounter 

;x coordinate
MOV dl, horiCounter
;y coordinate
MOV dh, vertCounter
CALL Gotoxy
MOV EAX, firstDot
CALL WriteChar

MOVZX EAX, horiCounter
CMP EAX, cherryXcord
JE FromUp

JMP WindowSetup

FromDown:
MOVZX EBX, vertCounter
.IF EBX == cherryYcord
MOV AL, fourVertCounter
MOV fiveVertCounter, AL

MOV AL, threeVertCounter
MOV fourVertCounter, AL

MOV AL, twoVertCounter
MOV threeVertCounter, AL

MOV AL, vertCounter
MOV twoVertCounter, AL
JMP GotCherry
.ENDIF
JMP WindowSetup

FromUp:
MOVZX EBX, vertCounter
.IF EBX == cherryYcord
MOV AL, fourVertCounter
MOV fiveVertCounter, AL

MOV AL, threeVertCounter
MOV fourVertCounter, AL

MOV AL, twoVertCounter
MOV threeVertCounter, AL

MOV AL, vertCounter
MOV twoVertCounter, AL
JMP GotCherry
.ENDIF
JMP WindowSetup

FromRight:
MOVZX EBX, vertCounter
.IF EBX == cherryYcord
MOV AL, fourHoriCounter
MOV fiveHoriCounter, AL

MOV AL, threeHoriCounter
MOV fourHoriCounter, AL

MOV AL, twoHoriCounter
MOV threeHoriCounter, AL

MOV AL, horiCounter
MOV twoHoriCounter, AL
JMP GotCherry
.ENDIF
JMP WindowSetup

FromLeft:
MOVZX EBX, vertCounter
.IF EBX == cherryYcord
MOV AL, fourHoriCounter
MOV fiveHoriCounter, AL

MOV AL, threeHoriCounter
MOV fourHoriCounter, AL

MOV AL, twoHoriCounter
MOV threeHoriCounter, AL

MOV AL, horiCounter
MOV twoHoriCounter, AL
JMP GotCherry
.ENDIF
JMP WindowSetup

;Function simply writes a "*" at the end of the cursor
MoveRight:
CMP horiCounter, 50
JG Damage

MOV AL, fourHoriCounter
MOV fiveHoriCounter, AL

MOV AL, threeHoriCounter
MOV fourHoriCounter, AL

MOV AL, twoHoriCounter
MOV threeHoriCounter, AL

MOV AL, horiCounter
MOV twoHoriCounter, AL

INC horiCounter 


;x coordinate
MOV dl, horiCounter
;y coordinate
MOV dh, vertCounter
CALL Gotoxy
MOV EAX, firstDot
CALL WriteChar

MOVZX EAX, horiCounter
CMP EAX, cherryXcord
JE FromLeft

JMP WindowSetup

;Function writes "*" two spaces left of where the cursor is
MoveLeft:
CMP horiCounter, 15
JL Damage

MOV AL, fourHoriCounter
MOV fiveHoriCounter, AL

MOV AL, threeHoriCounter
MOV fourHoriCounter, AL

MOV AL, twoHoriCounter
MOV threeHoriCounter, AL

MOV AL, horiCounter
MOV twoHoriCounter, AL

DEC horiCounter 


;x coordinate
MOV dl, horiCounter
;y coordinate
MOV dh, vertCounter
CALL Gotoxy
MOV EAX, firstDot
CALL WriteChar

MOVZX EAX, horiCounter
CMP EAX, cherryXcord
JE FromRight

JMP WindowSetup

;Funtion displays "*" one line above the cursor
LineUp:
CMP vertCounter, 2
	JL Damage
;Subracts the y coordinate by 1 so as not to rewrite
;"*" in the same space
MOV AL, fourVertCounter
MOV fiveVertCounter, AL

MOV AL, threeVertCounter
MOV fourVertCounter, AL

MOV AL, twoVertCounter
MOV threeVertCounter, AL

MOV AL, vertCounter
MOV twoVertCounter, AL


DEC VertCounter 

;x coordinate
MOV dl, horiCounter
;y coordinate
MOV dh, vertCounter
CALL Gotoxy
MOV EAX, firstDot
CALL WriteChar

MOVZX EAX, horiCounter
CMP EAX, cherryXcord
JE FromDown

JMP WindowSetup

Damage:
DEC health
JMP WindowSetup

GenerateCherry:
CALL Randomize

XRandomizer:
MOV EAX, 0
MOV EAX, xRangeHigh
SUB EAX, xRangeLow
INC EAX
CALL RandomRange
ADD EAX, xRangeLow
MOV cherryXCord, 0
MOV cherryXCord, EAX
MOV DL, BYTE PTR cherryXCord 

YRandomizer:
MOV EBX, 0
MOV EBX, yRangeHigh
SUB EBX, yRangeLow
INC EBX
CALL RandomRange
ADD EBX, yRangeLow
MOV cherryYCord, 0
MOV cherryYCord, EAX
MOV DH, BYTE PTR cherryYCord

CALL Gotoxy
MOV EAX, cherry
CALL WriteChar

INC cherryFlag
JMP Popping

GotCherry:
INC score 
DEC cherryFlag
JMP WindowSetup


GameOver:
MOV DL, 0
MOV DH, 21
CALL GotoXY
MOV EDX, OFFSET endgame
CALL WriteString
MOV EAX, score
CALL WriteInt
MOV EDX, OFFSET newline
CALL WriteString


CALL WaitMsg
INVOKE ExitProcess, 0
main ENDP
END main