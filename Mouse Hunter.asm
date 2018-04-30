    .MODEL SMALL
    .STACK 64
    .DATA
        ;=================Monster================
        MonsterPos   DW 10,10
        MonsterWidth DW 7
        ;==============Monster Move==============
        TimeToMove          DW 1000
        Xdiff               DW 0
        HorizontalDirection DB 0
        Ydiff               DW 0
        VerticalDirection   DB 0
        ;==================Coin==================
        CoinPos   DW 5,7
        CoinWidth DW 9
        CoinExist DB 0
        CoinX     DW 179,277,41,58,283,40,69,187,123,190,226,106,66,76,73,168,234,237,129,112,211,66,218,193,110,184,47,245,211,87,241,263,107,222,94,62,75,149,287,214,283,98,58 ,73 ,105,197, 74,273, 49,207, 97,139,132,240,64,100,284,289, 70,178,59
        CoinY     DW 139,86,91,78,129,162,68,148, 43,50,166,112,139,98,89,172, 60,151,146,84 ,167,95,151, 76,31,119,152,85,122,139,100,72,146,78,165,81,177, 52,124,116,136,41,60,100, 91,77 ,127, 82,122, 68,133,105, 70,149,99, 51,108, 49,169,156,91
        ;==================Messages==================
        ENDGAMEMESSAGE   DB 'Press any key to Restart Game$'
        ENDGAMEMESSAGE2  DB 'ESC to Back to Main Menu$'
        LossingMessage   DB 'You Lose$'
        WinningMessage   DB 'You Win$ '
        GameTitle        DB 'MOUSE HUNTER $'
        EasyMessage      DB 'Easy$'
        MediumMessage    DB 'Medium$'
        HardMessage      DB 'Hard$'
        SCOREMESSAGE     DB 'You scored $'

        DrawingColor DB 0
        Level        DB 1 
        AA           DB 1
        SCORE        DB 0


        .code
;----------------------------------------------------------------------------------------------------------------
MAIN    PROC FAR
        MOV AX,@DATA
        MOV DS,AX

        ;اول حاجة بدخل الفيديو مود عشان هبدأ ارسم
        mov ah, 0
        mov al, 13h
        int 10h

        Call MainMenu ;بنادى عليها عشان تعرض اسم اللعبة و بعدين اختار الصعوبه بتاعتها عشان ابدأ العب

        ;=================GameStartup================|
        StartGame:                                  ;|
        ;ببدأ بأنى امسح الشاشة عشان كنت بختار الصعوبة قبل كده;|
        MOV AH, 06h    ; Scroll up function         ;|
        XOR AL, AL     ; Clear entire screen        ;|
        MOV CX, 000h  ; Upper left corner           ;|اول نقظة على الشمال للخلفية الزرقاء
        MOV DX, 184FH  ; lower right corner         ;|اخر نقطة على اليمين للخلفية الزرقاء
        MOV BH, 1                                   ;|اللون بتاع الخلفية هيبقى ازرق
        INT 10H                                     ;|
                                                    ;|
        ;بظهر الماوس عشان اللعبة عبارة عن شخص بيصطاد الماوس;|
        mov ax,1                                    ;|
        int 33h                                     ;|
        ;بحط الماوس فى المكان اللى هيبدأ منه اللعب      ;|
        mov cx,320                                  ;|
        mov dx,120                                  ;|
        mov ax,4                                    ;|
        int 33h                                     ;|
        ;بحط الوحش فى المكان اللى هيبدأ يتحرك منه      ;|
        mov bx,10                                   ;|
        mov MonsterPos,bx                           ;|
        mov MonsterPos+2,bx                         ;|
        ;ده متغير عشان اعرف فى قطعة نقدية ولا موجودة   ;|
        mov bx,0                                    ;|
        mov CoinExist,bl                            ;|
        ;ببدأ المتغير اللى بيحسب الرقم القياسى للاعب بصفر و بفضل ازوده كل مره ياخد فيها قطعة نقدية;|
        mov Score,bl                                ;|
        ;============================================|
        GameLoop:
        ;عشان يشوف المكان بتاع الماوس فين و ابدأ اشوف هو خد القطعة النقدية و ازود الرقم القياسى ولا خبط فى الوحش ويكون خسر اللعبة
        call GetMousePos
        ;ببدأ اشوف النقطة اللى الماوس واقف عندها خبطت فى الوحش ولا لا لو خبطت هيخسر لو لا هيكمل اللعبة عادى
        ;Check for X
        mov bx,MonsterPos+2 ; باخد فيها ال الاكس بتاعه نفطة المركز
        add bx,MonsterWidth ; و هزود عليها نص العرض بتاع الوحش و كده جبت اكبر اكس فى الوحش
        cmp cx,bx ;لو كانت الاكس بتاعه الماوس اكبر من اكبر اكس فى جسم الوحش ساعتها هيكون الماوس لسه مخبطش الوحش
        JA NoCrash
        ;لو كانت الاكس بتاعه الماوس اصغر من اكبر اكس فى الوحش ساعتها فى فرصة يكون الوحش مسك الماوس
        sub bx,MonsterWidth ;كده برجع خطوه للمركز بتاع الوحش
        sub bx,MonsterWidth ;و كده برجع خطوه كمان عشان اوصل لاخر اكس على الشمال من الوحش
        cmp cx,bx ; بنشوف الاكس بتاعه الماوس لو اقل من اقل اكس فى الوحش فكده هو الوحش ممسكش الماوس
        JB NoCrash
        mov bx,MonsterPos ; بعد ما خلصنا نبص على الاكس نبص على الواى بتاعه مركز الوحش
        sub bx,MonsterWidth  ; لما برجع خطوة فى الواى بنص العرض بتاع الوحش بجيب اعلى واى فى الوحش
        cmp dx,bx ;و بشوف اعلى واى دى اللى فى الوحش و بشوف الماوس بالنسبالها لو الماوس اقل منها يبقى الماوس فوق الوحش و كده يبقى الوحش ممسكوش
        JB NoCrash
        add bx,MonsterWidth ;وبعدين بنزل خطوتين لتحت عشان لاكتر واى تحت
        add bx,MonsterWidth
        cmp dx,bx ; بقارن اكتر واى تحت بالواى بتاعه الماوس اللى جبتاها فوق و بشوف لو الواى بتاعه الماوس كانت اكبر من الواى بتاعه الوحش يبقى الماوس تحت و الوحش فوق و كده الوحش ممكسش الماوس
        JA NoCrash
        ; لو عديت من كل الشروط ديه و فضلت مكمل معنى كده انه الماوس جوه الوحش و كده الوحش مسك الماوس و ساعتها هنزل على الكود اللى بيخلص اللعبة
        jmp Crash

        NoCrash:

        ; بمسح الوحش القديم علشان ابدأ ارسمه فى مكانه الجديد عشان هو بيتحرك و لازم يتمسح الاول عشان يظهر فى المكان الجديد
        mov DrawingColor,1 ; نعمل لون الرسم دلوقتى ازرف بلون الخلفية عشان نمسح الوحش
        call DrawMonster   ; رسم الوحش

        ; المتغير ده بيبقى فيه فاضل قد ايه لحد ما الوحش يتحرك مكانه عشان لو مكانش فى وقت بين كل حركة و التانية هنلاقى ان الوحش بيتحرك بسرعه جدا
        dec TimeToMove ; بنقص اللفات اللى فاضلة عشان الوحش يتحرك
        cmp TimeToMove,0 ; فلو المتغير ده بصفر يبقى كده المفروض الوحش يبدأ يتحرك
        JA After


        ;Monster is moving كده الوحش هيتحرك بس منعرفش هو هيتحرك فين بالظبط فبنحسب اقصر مسافة و بعدين بنحركه من مكانه
        ;====================================
            ;هنا بنشوف احنا فى انهى مرحلة من الصعوبه عشان سرعه حركة الوحش بتتحدد على اساس صعوبة المرحلة
            ;و المتغير ده بعد ما وصل لصفر لازم ارجعه لفيمه عشان يبدأ يعد من الاول
            cmp Level,1
            JNE LEVEL23
                ;لو فى المرحلة الاولى يبفى فاضل 20 لفة لحد ما يبدأ الوحش بتحرك تانى و هو كده بطئ
                mov TimeToMove,20
                jmp AfterSelectLevel
            LEVEL23:
                cmp Level,2
                JNE Level3
                    ;لو فى المرحلة الثانية يبفى فاضل 15 لفة و يبدأ الوحش يتحرك تانى و ديه حركة متوسطه
                    mov TimeToMove,15
                    jmp AfterSelectLevel
                Level3:
                    ; لو المرحلة الثالثة و ديه اصعب مرحلة بيكون فاضل 8 لفات عشان الوحش يتحرك تانى
                    mov TimeToMove,8

            ;بعد ما اشوف فاضل قد ايه على الحركة الجاية ببدأ اشوف الحركة بتاعه الوحش هتكون فى انهى اتجاه
             AfterSelectLevel:
            cmp cx,MonsterPos+2 ;بنقارن الاكس بتاعه الماوس بالاكس بتاعه مركز الوحش عشان نشوف مين على اليمين و مين على الشمال عشان هنجيب فرق الاكسات و نعرف مين فيهم اكبر
            JA MouseRightMonsterLeft
            ;كده الوحش على اليمين و الماوس على الشمال
                mov bx,MonsterPos+2 ; ناخد الاكس بتاعه الوحش
                mov Xdiff,bx ; نحطها فى المتغير بتاع فرق الاكسات
                sub Xdiff,cx ; و بطرح منها الاكس بتاعه الماوس
                mov bl,1
                mov HorizontalDirection,bl ; كده حركة الوحش هتتخط فى المتغير 1 عشان كده الحركة للشمال
                ; ونبدأ نشوف الواى بعد ما شوفنا الاكس
                jmp CheckForY

            MouseRightMonsterLeft:
                ;كده الماوس على اليمين و الوحش على الشمال
                mov Xdiff,cx ; نحط فى المتغير بتاع فرق الاكسات الاكس بتاعه الماوس
                mov bx,MonsterPos+2
                sub Xdiff,bx ; نطرح منها الاكس بتاعه الوحش
                mov bl,0
                mov HorizontalDirection,bl ; المتغير بتاع اتجاه الحركة يبقى بصفر عشان حركة الوحش هتبقى من الشمال لليمين

            ; نبدأ نشوف الوايات عشان نقارنهم بالاكسات و نشوف الوحش هيتحرك فى اتجاه افقى ولا راسى
            CheckForY:
            cmp dx,MonsterPos ; نقارن الواى بتاعه الماوس بالواى بتاعه الوحش
            JA MouseDownMonsterUp
            ;لو الماوس فوق و الوحش تحت
                mov bx,MonsterPos
                mov Ydiff,bx ; المتغير بتاع الفرق بين الوايات هحط فيه الواى بتاعه الوحش
                sub Ydiff,dx ; واطرح منها الواى بتاعه الماوس
                mov bl,0
                mov VerticalDirection,bl ; متغير الحركة هيبقى بصفر عشان حركة الوحش هتبقى من تحت لفوق
                jmp StartMovingMonster  ; ونبدأ نحرك الوحش بعد ما حسبنا فرق الاكسات والوايات

            MouseDownMonsterUp:
                ; لو الماوس تحت و الوحش فوق
                mov Ydiff,dx ; متغير فرق الوايات هحط فيه الواى بتاعه الماوس
                mov bx,MonsterPos
                sub Ydiff,bx ; نطرح من متغير الفرق فى الوايات الواى بتاعه الوحش
                mov bl,1
                mov VerticalDirection,bl ; متغير الحركة هيبقى ب 1 و اتجاهها منفوق لتحت

        StartMovingMonster:
            ; بعد الحسابات بتاعه فرف الاكسات و الوايات بين الوحش و الماوس بنشوف انهى اقصر و الوحش هيمشى فيه
            mov bx,Xdiff
            cmp bx,Ydiff ; نقارن فرق الاكسات و الوايات مع بعض
            JA MoveHorizontally
                ; لو فرق الوايات اكبر يبقى الوحش هيتحرك رأسى
                ;Vertically
                mov bl,0
                cmp VerticalDirection,bl ; بعد كده بشوف هتحرك من فوق لتحت ولا من تحت لفوق
                JNE MoveMonsterDown
                ; لو المتغير بتاع اتجاه الحركة الرأسية بصفر تبقى الحركة من تحت لفوق
                ;MOVE MONSTER UP
                mov bx,1
                sub MonsterPos,bx ;بطرح من الواى بتاعه الوحش واحد و ابدأ ارسم
                ; و بعدين نبدأ نرسم الوحش فى المكان الجديد على طول
                jmp After
                MoveMonsterDown:
                mov bx,1
                add MonsterPos,bx ; بزود واحد على الاكس بتاعه الوحش
                ; نبدأ نرسم الوحش فى المكان الجديد
                jmp After

          MoveHorizontally:
                ; لو الفرق فى الاكسات اكبر يبفى الوحش هيتحرك افقى
                ;Horizontally
                mov bl,0
                cmp HorizontalDirection,bl ; بشوف متغير اتجاه الحركة الافقى من يمين للشمال ولا من الشمال لليمين
                JNE MoveMonsterLeft
                ; متغير اتجاه الحركة الافقى لو بصفر يبقى الحركة من الشمال لليمين
                ;MOVE MONSTER Right
                mov bx,1
                add MonsterPos+2,bx
                ; نبدأ نرسم الوحش فى المكان الجديد
                jmp After
                MoveMonsterLeft:
                mov bx,1
                sub MonsterPos+2,bx ;بنطرح واحد من الاكس بتاعه الوحش
                ; نبدأ نرسم الوحش فى المكان الجديد
                jmp After


       ;====================================

        After:
        mov DrawingColor,0Fh ; نعمل لون الرسم بالابيض
        call DrawMonster ; نبدأ نرسم الوحش بلونه
        
        call GetMousePos

        cmp CoinExist,0 ; المتغير بيعرفنى فى قطعه نقدية موحودة فى ارض اللعب ولا لا فلو مش موجوده ابدأ احط واحده جديده لو هى موجوده بشوف الماوس خدها ولا لا
        JNE ThereIsCoin
            ; لو مفيش قطعه نقدية موحوده يبقى احنا نحط واحده جديده
            mov CoinExist,1 ;بحط فى المتغير بتاع فى قطعه نقدية ولا لا 1 عشان كده فى قطعه نقدية فى ارض اللعبة
            call GenerateCoin ;عشان نختار مكان القطعه النقدية الجديد بطريقه عشوائية من مجموعه الارقام المسجلة فوق
        ThereIsCoin:
                ; لو فى قطعه نقدية فى ارض اللعبة
                ;Draw Coin in Position
                mov DrawingColor,14 ; لون الرسم الى الاصفر
                call DrawCoin       ; و نبدأ رسم القطعه النقدية

                ; بشوف النقطه اللى بيشاور عليها الماوس لو البيكسل دى ايه
                mov AH,0Dh
                mov BH,0
                int 10h
                ; لو لون البيكسل دى لون القطعه المعدنية يبفى الماوس خدها و هيكون الرفم القياسى يزيد بواحد
                cmp al,14
                JNE CHECKMONSTERCOIN

                inc SCORE  ; نزود الرقم القياسى بواحد
                mov CoinExist,0 ; نحط المتغير بتاع وجود قطعه نقدية بصفر عشان مبقاش فى قطعه نقدية دلوقتى

                ; نخفى الماوس الاول عشان نفدر نمسح القطعه النقدية اللى تحته و بعدين نرجع نظهره تانى
                    mov ax,2
                    int 33h

                ; نمسح القطعه النقدية اللى الماوس خدها
                mov DrawingColor,1 ; نحط لون الرسم بلون الخلفية الازرق
                call DrawCoin   ; نرسم القطعه النقدية بلون الخلفية

                ;نظهر الماوس تانى بعد ما مسحنا القطعه النقدية
                    mov ax,1
                    int 33h

            CHECKMONSTERCOIN:
        ; عشان نبطأ اللفة شوية عشان ميحصلش فليكرر
        ;Loop to pause Monster
        mov cx,100  ; عدد اللفات 100 لفة
          PAUSE:
            Loop PAUSE

        cmp SCORE,10 ;لو الرقم القياسى بيساوى 10 يبقى كده اللعبة خلصت واللاعب كسب
        JE Win

        ;GetKeyPressed Don't wait
        ; كل لوب بشوف لو اللاعب داس على زر عشان يخرج من اللعبة لو مداسش هكمل عادى
        mov ah,1
        int 16h

        cmp al,27 ; لو الزر كان زر الخروج اللعبة هتقفل
        JNE GameLoop
          ; للخروج من اللعبة
          MOV AH,4CH
          INT 21H

        ;======================================================
        Win:
            ; لو اللاعب جمع 10 قطعات نقدية و كسب واللعبة خلصت
            ; نشيل الماوس عشان نطبع الرسالة
             mov ax,2;Hide Mouse
             int 33h

            ;بنحرك مؤشر الكتابة للمكان المطلوب
            mov ah,2
            mov dx,080Fh ; الاكس 15 والواى 8
            int 10h
            ;بنطبع الرسالة ان اللاعب كسب
            mov ah, 9
            mov dx, offset WinningMessage
            int 21h
            ;بنحرك المؤشر للمكان المطلوب
            ;Move Cursor to Position
            mov ah,2
            mov dx,0A0Dh ; الاكس 14 والواى 10
            int 10h
            ;بنطبع الرقم القياسى للاعب
            ;Print Message
            mov ah, 9
            mov dx, offset SCOREMESSAGE
            int 21h
            ; ولان اللاعب كسب فالرقم القياسى 10
            ; بنطبع 1
            mov ah,2
            mov dl,31h
            int 21h
            ; نبطع 0
            mov ah,2
            mov dl,30h
            int 21h

            jmp DetectChoice

        Crash:
             ;نشيل الماوس
             mov ax,2
             int 33h
            ;نحرك مؤشر الماوس للمكان المطلوب
            mov ah,2
            mov dx,080Fh
            int 10h
            ;طباعه الرسالة المطلوبه
            mov ah, 9
            mov dx, offset LossingMessage
            int 21h

            ;نحرك المؤشر للمكان المطلوب
            mov ah,2
            mov dx,0A0Dh
            int 10h
            ;نطبع للرقم القياسى للاعب
            mov ah, 9
            mov dx, offset SCOREMESSAGE
            int 21h
            ; نطبع الرقم
            mov ah,2
            mov dl,SCORE
            add dl,30h
            int 21h


         DetectChoice:

             ;نحرك مؤشر الكتابة للمكان المطلوب
                mov ah,2
                mov dx,0C06h  ;الاكس 6 الواى 12
                int 10h
            ;طباعه الرسالة
                mov ah, 9
                mov dx, offset ENDGAMEMESSAGE
                int 21h

              ;نحرك مؤشر الكتابة للمكان المطلوب
                mov ah,2
                mov dx,0E08h
                int 10h
            ;طباعه الرسالة
                mov ah, 9
                mov dx, offset ENDGAMEMESSAGE2
                int 21h


            ;الانتظار حتى يرد اللاعب على الرسالة سواء كان يريد اللعب مره اخرى او العودة للقائمة الرئيسية
                mov ah,0
                int 16h

             ;اذا داس على زر الخروج هسيرجع الى القائمة الرئيسية
              cmp al,27
              JNE Restart
                ; لو الزر كان زر الخروج يرجع الى القائمة الرئيسية
                 Call MainMenu

              Restart:
                ; لو الزر مكانش زر الخروج يبقى هيعيد اللعبة
                    jmp StartGame


        hlt
MAIN    ENDP
;======================================================
MainMenu PROC
            ; بداية نمسح الشاشة عشان نبدأ نختار المرحلة من الصعوبة اللى اللاعب هيلعب بيها
            ;Fill Background with Background Color
            MOV AH, 06h    ; Scroll up function         ;|
            XOR AL, AL     ; Clear entire screen        ;|
            MOV CX, 000h  ; Upper left corner           ;| اول نقطه على الشمال فوق
            MOV DX, 184FH  ; lower right corner         ;| اخر نقطة على اليمين تحت
            MOV BH, 0                                   ;| لون الخلفية اسود
            INT 10H

            ; تحريك المؤشر للكتابة للمكان المطلوب لطباعه اسم اللعبة
            mov ah,2
            mov dx,040Dh
            int 10h
            ;طباعه اسم اللعبة
            mov ah, 9
            mov dx, offset GameTitle
            int 21h
            ; طباعه رمز بجانب اسم اللعبة
            mov ah,2
            mov dl,1h
            int 21h
            ; رسم خطين فوق و تحت اسم اللعبة
            mov al,1 ;Pixel color
            mov ah,0ch ;Draw Pixel Command
            mov cx,100    ; نقطة البداية فى الاكس
            mov dx,25     ; نقطة البداية فى الواى
            TitleRect:
                    ; رسم النقطة فى الخط فوق عنوان اللعبة
                    int 10h
                    add dx,20
                    ; رسم النقطة فى الخط تحت عنوان اللعبة
                    int 10h
                    sub dx,20
                    ; الانتقال الى الاكس القادمة
                    inc cx
                    cmp cx,220
                    JBE TitleRect
            ;########################
            ;Move Cursor to Position
            ; انتقال المؤشر الى المكان المطلوب
            mov ah,2
            mov dx,0B11h
            int 10h
            ;طباعه المرحلة الاولى
            mov ah, 9
            mov dx, offset EasyMessage
            int 21h
            ;########################
            ;انتقال مؤشر الكتابة الى المكان المطلوب
            mov ah,2
            mov dx,0D11h
            int 10h
            ;طباعه اسم المرحلة الثانية
            mov ah, 9
            mov dx, offset MediumMessage
            int 21h
            ;########################
            ;انتقال مؤشر الكتابة الى المكان المطلوب
            mov ah,2
            mov dx,0F11h
            int 10h
            ;طباعه اسم المرحلة الاخيرة
            mov ah, 9
            mov dx, offset HardMessage
            int 21h

            ;اانتفال المؤشر للمكان المطلوب
            mov ah,2
            mov dx,0B0Fh
            int 10h
            ; بدأ الاختيار من المرحلة الاولى و التغيير فيما بعد
            mov cl,1
            mov Level,cl
            ; نرسم سهم ازرق بجانب المرحلة المختارة
            Call DrawBlueArrow

            USERINPUT:
            ; الانتظار حتى يدخل الاعب اختياره
            ;Wait for key Press
            mov ah,0
            int 16h

            cmp ah,80 ; اذا كان الاعب داس السهم الى اسفل
            JNE CHECKESC
            ;check if current level 1
            ;لو كانت المرحلة المختارة حاليا هى الاولى
                cmp Level,1
                JNE CHECKAGAIN
                    ;Level 2 is chosen
                    ; المرحلة الثانية هى المرحلة المختارة
                    mov bl,2
                    mov Level,bl

                    ;انتقال مؤشر الكتابة الى المكان المطلوب
                    mov ah,2
                    mov dx,0B0Fh
                    int 10h
                    ; رسم سهم اسود مكان السهم السابق
                    call DrawBlackArrow

                    ;انتقال مؤشر الكتابة الى المكان المطلوب
                    mov ah,2
                    mov dx,0D0Fh
                    int 10h
                    ; رسم سهم جديد فى مكان المرحلة الجديدة المختارة
                    call DRAWBLUEARROW
                    jmp USERINPUT

              CHECKAGAIN:
                cmp Level,2 ; لو كانت المرحلة المختارة سابقا هى المرحلة الثانية
                JNE LEVEL1CHOSEN
                    ;Level 3 Chosen
                    ; المرحلة المختارة الجديدة هى المرحلة الثالثة
                        mov bl,3
                        mov Level,bl

                        ;انتقال المؤشر للكتابة الى المكان الجديد
                        mov ah,2
                        mov dx,0D0Fh
                        int 10h
                        ; رسم سهم اسود مكان السهم الازرق القديم للمرحلة الثانية
                        call DrawBlackArrow

                        ;انتقال مؤشر الكتابة الى المكان المطلوب
                        mov ah,2
                        mov dx,0F0Fh
                        int 10h
                        ; رسم السهم الازرق فى المكان الجديد للمرحلة المختارة الثالثة
                        call DRAWBLUEARROW
                        jmp USERINPUT
                LEVEL1CHOSEN:
                        ; لو كانت المرحلة الثالثة هى المختارة سابقا فالمرحلة المختارة حاليا هى الاولى
                        mov Level,1

                        ;الانتقال الى مكان الطباعه المطلوب
                        mov ah,2
                        mov dx,0F0Fh
                        int 10h
                        ; رسم سهم اسود مكان السهم فى المرحلة السابقة و هى الثالثة
                        call DrawBlackArrow

                        ;الانتقال مؤشر الكتابة الى المكان المطلوب
                        mov ah,2
                        mov dx,0B0Fh
                        int 10h
                        ; طباعه سهم ازرق فى المكان الجديد للمرحلة الجديدة المختارة و هى المرحلة الاولى
                        call DRAWBLUEARROW
                        jmp USERINPUT
            CHECKESC:
                cmp al,27 ;اذا كان الزر المختار هو زر الخروج
                  JNE CHECKENTER
                  ; الخروج من اللعبة
                  MOV AH,4CH
                  INT 21H

            CHECKENTER:
                cmp al,13 ; اذا كان الزر هو زر الادخال
                JNE USERINPUT

                ; الخروج من الفانكشن و البدأ باللعب

        ret
MainMenu ENDP
;======================================================
DrawMonster PROC
    pusha
        mov cx,MonsterPos+2 ; الاكس مركز الوحش
        sub cx,MonsterWidth ; طرح نصف العرض من المركز عشان نجيب الاكس اللى على الشمال فى الوحش
        mov dx,MonsterPos   ; الواى لمركز الوحش
        sub dx,MonsterWidth ; بطرح نص الطول من المركز عشان نجيب اعلى نقطة فى الوحش
        mov al,DrawingColor ;Pixel color ; بنرسم بلون الرسم المتحدد قبل كده
        mov ah,0ch
        ; رسم الخطين الافقيين
        horizontal:
            ; رسم النقطة فى الخط اللى فوق
            int 10h
            add dx,MonsterWidth
            add dx,MonsterWidth
            int 10h
            ; رسم النقطه فى الخط اللى تحت
            sub dx,MonsterWidth
            sub dx,MonsterWidth
            mov bx,MonsterPos+2
            add bx,MonsterWidth ; اخر نقطة هى نقطة المركز فى الاكس زائد نص العرض
            inc cx      ; التحرك افقيا فى الاكس للنقطة اللى بعدها
            cmp cx,bx
        jnz horizontal

        int 10h
        ; رسم الخطين الافقيين المتوازيين

        mov cx,MonsterPos+2 ; الاكس مركز الوحش
        sub cx,MonsterWidth ; طرح نصف العرض من المركز عشان نجيب الاكس اللى على الشمال فى الوحش
        mov dx,MonsterPos   ; الواى لمركز الوحش
        sub dx,MonsterWidth ; بطرح نص الطول من المركز عشان نجيب اعلى نقطة فى الوحش

        vertical:
            ; رسم النقطة الابتدائية
            int 10h
            inc dx
            add cx,MonsterWidth
            add cx,MonsterWidth
            ; رسم النقطة فى الخط الموازى الاخر
            int 10h
            sub cx,MonsterWidth
            sub cx,MonsterWidth
            mov bx,MonsterPos
            add bx,MonsterWidth
            cmp dx,bx ; اخر نقطة فى الواى هى المركز زائد نص الطول
        jnz vertical

        int 10h
        ; عشان نبدأ نرسم العنين بتاعه الوحش
        mov cx,MonsterPos+2 ; النقطة الابتدائية للاكس هى مركز الوحش
        mov dx,MonsterPos   ; النقطة الابتدائية للواى هى مركز الوحش
        sub cx,3  ; برجع 3 خطوات لورا فى الاكس
        sub dx,5  ; بنرجع 5 خطوات لورا فى الواى عشان العين فى الجزء اللى فوق من الوش
        ; بيصم شكل العيت للوحش
        mov bx,3 ; بنعمل اللفة 3 مرات
        DrawEyes:
            int 10h
            ; بنرسم النقطة
            inc dx
            ;و ننزل نرسم النقطة اللى تحتها
            int 10h
            inc dx
            ; ونروح كمان على النقطة اللى تحت تحتها
            int 10h
            sub dx,2
            ; و بعدين نرجع للواى الاصلية
            add cx,4
            int 10h
            ; و نبدأ نعيد نفس الكلام بس للعين التانية
            inc dx
            int 10h
            inc dx
            int 10h
            sub dx,2
            sub cx,4

            inc cx
            dec bx
            JNZ DrawEyes


        mov cx,MonsterPos+2 ; النقطة الابتدائية للاكس هى مركز الوحش
        mov dx,MonsterPos   ; النقطة الابتدائية للواى هى مركز الوحش
        sub cx,4
        add dx,1

        mov bx,9
        ;بيرسم فم الوحش
        ;بنرسم كذا خط افقى ورا بعض
        DRAWMOUTHV:
                ;بنرسم اول نقطة
                int 10h
                inc dx
                ;والنقطة اللى تحتها
                int 10h
                inc dx
                ;و النقطة اللى تحت تحتها
                int 10h
                inc dx
                ;و النقطة اللى تحتهم
                int 10h
                ;و بنرجع تانى على اول نقطة فى الواى
                sub dx,3
                ; و بعدين نزوج الاكس
                inc cx
                dec bx

          JNZ DRAWMOUTHV

   popa
            ret
DrawMonster ENDP
;======================================================
 ; الحصول على احداثيات الماوس
GetMousePos PROC

        mov ax,3
        int 33h
        SHR cx,1  ; بيقسم القيمة بتاعة الاكس بتاعه الموس علي 2 عشان هي بتيجي بضعف قيمتها

    ret
GetMousePos endp
;======================================================
  ;يرسم سهم اسود في مكان الكتابة
DRAWBLACKARROW PROC

            mov ah, 0eh           ;0eh = 14
            mov al,16
            xor bx, bx           ; رقم الصفحة
            mov bl, 0            ;لون الاسود
            int 10h
    ret
DRAWBLACKARROW ENDP
;======================================================
; يرسم سهم ازرق فى مكان مؤشر الكتابة
DRAWBLUEARROW PROC

            mov ah, 0eh           ;0eh = 14
            mov al,16
            xor bx, bx           ; رقم الصفحة
            mov bl, 1            ;لون ازرق
            int 10h

    ret
DRAWBLUEARROW ENDP
;======================================================
; اختيار مكان القطعة النقدية الجديدة باستخدام طريقة عشوائية
GenerateCoin PROC
        pusha

        ; الحصول على الوقت الحالى
        mov ah,2CH
        int 21h
        ; بتسجيل الثوانى من الوقت فى المخزن دى اكس
        mov dl,dh
        mov dh,0
        ; اخذ قيمة الاكس العشوائية
        mov bx,offset coinX
        add bx,dx
        mov cx,[bx]
        mov CoinPos+2,cx ; تسجيل القيمة المختارة فى المتغير لمكان القطعة النقدية
        ; اخد قيمة الواى العشوائية
        mov bx,offset coinY
        add bx,dx
        mov cx,[bx]
        mov CoinPos,cx ; تسجيل القيمة المختارة فى المتغير لمكان القطعة النقدية

       popa
    ret
GenerateCoin ENDP
;======================================================
; رسم القطعه النقدية فى مكانها المسجل فى المتغير الخاص بمكان العملة النقدية
DrawCoin PROC
       pusha

        mov cx,CoinPos+2 ; الاكس مركز الوحش
        mov dx,CoinPos   ; الواى لمركز الوحش
        mov al,DrawingColor ;Pixel color ; بنرسم بلون الرسم المتحدد قبل كده
        mov ah,0ch ;Draw Pixel Command

        mov si,CoinWidth ; قيمة البداية هى نصف العرض للقطعه المعدنية و من ثم نطرح منها 2 كل مرة و بالتالى نحصل على هرم كلما ارتفعنا فى الواى
        lal:
            ; لحساب نصف القطر نقسم على 2 و نرجع بالرقم ده من المركز عشان نوصل لاول نقطه نبدأ نرسم منها الخط الافقى
            mov di,si
            SHR di,1
            ; بداية بالاكس المركز
            mov cx,CoinPos+2
            sub cx,di ;نطرخ منها الرقم اللى حسبناه فوق اللى هو نص طول الخط الافقى
            ;عشان نجيب النهاية
            mov bx,CoinPos+2 ;نجيب الاكس بتاعه مركز الوحش
            add bx,di        ;بزود عليها الرقم اللى هو نص طول الخط الافقى
            ; نبدأ نرسم الخط الافقى من البداية للنهاية اللى حسبناهم
            DrawHori:
                int 10h
                inc cx ; بروح على الاكس اللى بعدها لحد ما اوصل لاخر اكس انا حسباها فوق

                cmp cx,bx
                JBE DrawHori

            inc dx ;و بعدين هروح على النقطة اللى فوقيها اللى علىيها الدور بس بطول خط افقى اقل

        sub si,2
        cmp si,1
        JA lal
         ;نعمل نفس الكلام تانى بس للجزء اللى تحت من العملة النقدية
        mov dx,CoinPos ; ناخد الواى بتاعه المركز

        mov si,CoinWidth ; طول اكبر خط افقى اللى هو البداية
        laal:
            ;نقسمها على الاتنين عشان نجيب نص طول الخط الافقى
            mov di,si
            SHR di,1
            ;نبدأ بالاكس من المركز بتاع الوحش
            mov cx,CoinPos+2
            sub cx,di ;نطرح من الاكس الرقم اللى حسبناه
            ; دية هتبقى نهاية الخط الافقى فى الاكس عشان اعرف هقف امتى
            mov bx,CoinPos+2 ; مركز الوحش فى الاكس
            add bx,di ; بزود على نص طول الخط الافقى اللى برسمه
            ; كده هبدأ ارسم الخط الافقى الجديد
            DrawHorii:
                int 10h
                inc cx ;اروح على الاكس اللى بعدها

                cmp cx,bx
                JBE DrawHorii

            dec dx ; وبعدين بعد ما اخلص الخط الافقى ابدأ اروح على الواى اللى بعدها لحد ما اوصل لاخر واى

        sub si,2
        cmp si,1
        JA laal


      popa

    ret
DrawCoin ENDP
;======================================================
        END MAIN
;----------------------------------------------------------------------------------------------------------------
