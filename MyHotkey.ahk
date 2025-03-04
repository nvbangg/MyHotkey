; MyHotkey
#Requires AutoHotkey v2.0

;---------Tổng hợp phím tắt-------------
; CapsLock+V: Dán nội dung clipboard trước đó
; CapsLock+F (format): Dán với định dạng (tên cho file code)
; CapsLock+T (translate): Chuyển đổi dịch trang web
; CapsLock+Down: Bật/tắt điều khiển chuột bằng phím mũi tên
; CapsLock+RAlt: Bật/tắt chức năng click chuột
; Phím mũi tên: Di chuyển chuột (khi bật chế độ)
; RAlt: Click chuột trái (khi bật chế độ)
; RCtrl: Click chuột phải (khi bật chế độ)

;---------About-------------------------
#SingleInstance Force

; Khai báo biến cho cài đặt
global mouseControlEnabled := false    ; Điều khiển chuột bằng phím mũi tên
global mouseClickEnabled := false      ; Sử dụng Alt phải và Ctrl phải để click
global alwaysNumLockEnabled := false   ; Luôn bật phím Numlock

; Tạo menu Settings và các mục con
settingsMenu := Menu()
settingsMenu.Add("Chế độ di chuyển chuột", ToggleMouseControlMenu)
settingsMenu.Add("Chế độ click chuột", ToggleMouseClickMenu)
settingsMenu.Add("Luôn bật Numlock", ToggleAlwaysNumLock)

; Thêm mục vào menu khay
A_TrayMenu.Add("Settings", (*) => settingsMenu.Show())
A_TrayMenu.Add("About", ShowAbout)
A_TrayMenu.Add("Shortcuts", ShowTips)

; Thông tin tooltip trên khay hệ thống
A_IconTip := "MyHotkey`nCapsLock+V: Paste Clipboard`nCapsLock+F: Format paste`nCapsLock+T: Translate (Chrome)`nCapsLock+Down: Mouse control"

; Kiểm tra và kích hoạt Numlock nếu cần khi khởi động
CheckNumlockStatus()

; Hàm kiểm tra trạng thái Numlock
CheckNumlockStatus() {
    if (alwaysNumLockEnabled && !GetKeyState("NumLock", "T")) {
        SetNumLockState "AlwaysOn"
        ToolTip("Đã BẬT Numlock tự động", 10, 10)
        SetTimer () => ToolTip(), -2000
    }
}

; Hàm bật/tắt chế độ Luôn bật Numlock
ToggleAlwaysNumLock(*) {
    global alwaysNumLockEnabled
    alwaysNumLockEnabled := !alwaysNumLockEnabled
    
    if (alwaysNumLockEnabled) {
        SetNumLockState "AlwaysOn"
        settingsMenu.Check("Luôn bật Numlock")
        ToolTip("Numlock sẽ luôn được BẬT", 10, 10)
    } else {
        SetNumLockState "Default"
        settingsMenu.Uncheck("Luôn bật Numlock")
        ToolTip("Chế độ Numlock tự động: TẮT", 10, 10)
    }
    
    SetTimer () => ToolTip(), -2000
}

; Hàm bật/tắt chế độ di chuyển chuột từ menu
ToggleMouseControlMenu(*) {
    global mouseControlEnabled
    mouseControlEnabled := !mouseControlEnabled
    
    if (mouseControlEnabled) {
        settingsMenu.Check("Chế độ di chuyển chuột")
        ToolTip("Điều khiển chuột bằng phím mũi tên: BẬT", 10, 10)
    } else {
        settingsMenu.Uncheck("Chế độ di chuyển chuột")
        ToolTip("Điều khiển chuột bằng phím mũi tên: TẮT", 10, 10)
    }
    
    SetTimer () => ToolTip(), -2000
}

; Hàm bật/tắt chế độ click chuột từ menu
ToggleMouseClickMenu(*) {
    global mouseClickEnabled
    mouseClickEnabled := !mouseClickEnabled
    
    if (mouseClickEnabled) {
        settingsMenu.Check("Chế độ click chuột")
        ToolTip("Click chuột bằng phím: BẬT`nRAlt: Click trái`nRCtrl: Click phải", 10, 10)
    } else {
        settingsMenu.Uncheck("Chế độ click chuột")
        ToolTip("Click chuột bằng phím: TẮT", 10, 10)
    }
    
    SetTimer () => ToolTip(), -3000
}

ShowAbout(*) {
    result := MsgBox("MyHotkey`n`nVersion: 1.0`nDate: 03/03/2025`n`nCreated by: facebook.com/nvbangg`nVisit creator's page?", "About MyHotkey", "YesNo")
    if (result = "Yes")
        Run("https://facebook.com/nvbangg")
}

ShowTips(*) {
    tipsText := "--------PHÍM TẮT--------`n"
    tipsText .= "CapsLock+V: Dán nội dung clipboard trước đó`n"
    tipsText .= "CapsLock+F: Dán với định dạng (tên cho file code)`n"
    tipsText .= "CapsLock+T: Chuyển đổi dịch trang web`n"
    tipsText .= "CapsLock+Down: Bật/tắt điều khiển chuột bằng phím mũi tên`n"
    tipsText .= "CapsLock+RAlt: Bật/tắt chức năng click chuột`n"
    tipsText .= "Phím mũi tên: Di chuyển chuột (khi bật chế độ)`n"
    tipsText .= "RAlt: Click chuột trái (khi bật chế độ)`n"
    tipsText .= "RCtrl: Click chuột phải (khi bật chế độ)`n"
    
    MsgBox(tipsText, "Shortcuts - MyHotkey", "Ok")
}

;---------CLIPBOARD MANAGER-------------

; Lưu trữ 2 mục clipboard gần nhất
clipboardHistory := []

; Khởi tạo map chuyển đổi dấu toàn cục
global accentMap := Map(
    "à", "a", "á", "a", "ả", "a", "ã", "a", "ạ", "a", "â", "a", "ầ", "a", "ấ", "a", "ẩ", "a", "ẫ", "a", "ậ", "a", "ă", "a", "ằ", "a", "ắ", "a", "ẳ", "a", "ẵ", "a", "ặ", "a",
    "è", "e", "é", "e", "ẻ", "e", "ẽ", "e", "ẹ", "e", "ê", "e", "ề", "e", "ế", "e", "ể", "e", "ễ", "e", "ệ", "e",
    "ì", "i", "í", "i", "ỉ", "i", "ĩ", "i", "ị", "i",
    "ò", "o", "ó", "o", "ỏ", "o", "õ", "o", "ọ", "o", "ô", "o", "ồ", "o", "ố", "o", "ổ", "o", "ỗ", "o", "ộ", "o", "ơ", "o", "ờ", "o", "ớ", "o", "ở", "o", "ỡ", "o", "ợ", "o",
    "ù", "u", "ú", "u", "ủ", "u", "ũ", "u", "ụ", "u", "ư", "u", "ừ", "u", "ứ", "u", "ử", "u", "ữ", "u", "ự", "u",
    "ỳ", "y", "ý", "y", "ỷ", "y", "ỹ", "y", "ỵ", "y", "đ", "d",
    "À", "A", "Á", "A", "Ả", "A", "Ã", "A", "Ạ", "A", "Â", "A", "Ầ", "A", "Ấ", "A", "Ẩ", "A", "Ẫ", "A", "Ậ", "A", "Ă", "A", "Ằ", "A", "Ắ", "A", "Ẳ", "A", "Ẵ", "A", "Ặ", "A",
    "È", "E", "É", "E", "Ẻ", "E", "Ẽ", "E", "Ẹ", "E", "Ê", "E", "Ề", "E", "Ế", "E", "Ể", "E", "Ễ", "E", "Ệ", "E",
    "Ì", "I", "Í", "I", "Ỉ", "I", "Ĩ", "I", "Ị", "I",
    "Ò", "O", "Ó", "O", "Ỏ", "O", "Õ", "O", "Ọ", "O", "Ô", "O", "Ồ", "O", "Ố", "O", "Ổ", "O", "Ỗ", "O", "Ộ", "O", "Ơ", "O", "Ờ", "O", "Ớ", "O", "Ở", "O", "Ỡ", "O", "Ợ", "O",
    "Ù", "U", "Ú", "U", "Ủ", "U", "Ũ", "U", "Ụ", "U", "Ư", "U", "Ừ", "U", "Ứ", "U", "Ử", "U", "Ữ", "U", "Ự", "U",
    "Ỳ", "Y", "Ý", "Y", "Ỷ", "Y", "Ỹ", "Y", "Ỵ", "Y", "Đ", "D"
)

; Theo dõi sự thay đổi của clipboard
OnClipboardChange(ClipChanged)

ClipChanged(Type) {
    if Type = 1 {  ; Chỉ theo dõi khi nội dung là văn bản
        try {
            clipboardHistory.InsertAt(1, A_Clipboard)
            if clipboardHistory.Length > 2
                clipboardHistory.Pop()  ; Giữ mảng luôn chỉ có 2 phần tử
        }
    }
}

; Hàm chuyển đổi chuỗi không dấu
RemoveAccents(str) {
    result := ""
    Loop Parse, str
        result .= accentMap.Has(A_LoopField) ? accentMap[A_LoopField] : A_LoopField
    return result
}

; CapsLock+V: Dán nội dung clipboard trước đó
CapsLock & v:: {
    if clipboardHistory.Length >= 2 {
        oldClip := ClipboardAll()
        A_Clipboard := clipboardHistory[2]
        ClipWait(0.3)
        Send("^v")
        Sleep(50)
        A_Clipboard := oldClip
    }
}

; CapsLock+F: Dán với định dạng (tên cho file code)
CapsLock & f:: {
    if clipboardHistory.Length >= 2 {
        oldClip := ClipboardAll()
        A_Clipboard := clipboardHistory[2] . "_" . RemoveAccents(clipboardHistory[1]) . "."
        ClipWait(0.3)
        Send("^v")
        Sleep(50)
        A_Clipboard := oldClip
    }
}

; Chỉ hoạt động trong Chrome
#HotIf WinActive("ahk_exe chrome.exe")

; CapsLock+T: Chuyển đổi dịch trang web
CapsLock & t:: {
    ; Tạm thời chặn đầu vào người dùng
    BlockInput("On")
    
    ; Nhấp chuột phải
    MouseClick("Right")
    Sleep(50)   ; Delay 50ms

    Send("t")    ; Nhấn T
    Sleep(50)

    Send("{Enter}")  ; Nhấn Enter
    Sleep(50) 

    ; Click chuột trái
    MouseClick("Left")   
    
    ; Khôi phục đầu vào người dùng
    BlockInput("Off")
}
#HotIf  ; Kết thúc điều kiện

;--------TOUCHPAD CONTROL--------
; Biến để theo dõi trạng thái kích hoạt
mouseControlEnabled := false    ; Điều khiển chuột bằng phím mũi tên
mouseClickEnabled := false      ; Sử dụng Alt phải và Ctrl phải để click
mouseSpeed := 10                ; Tốc độ di chuyển cho nhấn nhanh 
mouseSpeedFast := 20            ; Tốc độ di chuyển ban đầu khi nhấn giữ
mouseMaxSpeed := 100            ; Tốc độ di chuyển tối đa khi nhấn giữ lâu
holdThreshold := 400            ; Ngưỡng thời gian để xác định nhấn giữ (ms)

; Biến theo dõi phím đang được nhấn giữ
arrowKeyHeld := ""              ; Lưu phím mũi tên đang được nhấn giữ
holdStartTime := 0              ; Thời điểm bắt đầu nhấn giữ

; Bật/tắt điều khiển chuột bằng CapsLock + Down (bao gồm cả chức năng click)
CapsLock & Down::ToggleMouseControl()

; Bật/tắt tính năng click chuột bằng CapsLock + Alt phải
CapsLock & RAlt::ToggleMouseClick()

; Hàm bật/tắt chức năng điều khiển chuột bằng phím mũi tên và cả click chuột
ToggleMouseControl() {
    global mouseControlEnabled, mouseClickEnabled
    
    mouseControlEnabled := !mouseControlEnabled
    
    if (mouseControlEnabled) {
        mouseClickEnabled := true  ; Luôn đồng bộ với trạng thái điều khiển chuột
        settingsMenu.Check("Chế độ di chuyển chuột")
        settingsMenu.Check("Chế độ click chuột")
        ToolTip("Đã BẬT đầy đủ chức năng:`n- Điều khiển chuột bằng phím mũi tên`n- Click chuột bằng RAlt (trái) và RCtrl (phải)", 10, 10)
    }
    else {
        mouseClickEnabled := false
        settingsMenu.Uncheck("Chế độ di chuyển chuột")
        settingsMenu.Uncheck("Chế độ click chuột")
        ToolTip("Đã TẮT tất cả chức năng điều khiển chuột", 10, 10)
    }
    
    SetTimer () => ToolTip(), -3000
}

; Hàm bật/tắt chức năng click chuột bằng Alt phải và Ctrl phải
ToggleMouseClick() {
    global mouseClickEnabled
    mouseClickEnabled := !mouseClickEnabled
    
    if mouseClickEnabled {
        settingsMenu.Check("Chế độ click chuột")
        ToolTip("Click chuột bằng phím: BẬT`nRAlt: Click trái`nRCtrl: Click phải", 10, 10)
    }
    else {
        settingsMenu.Uncheck("Chế độ click chuột")
        ToolTip("Click chuột bằng phím: TẮT", 10, 10)
    }
    
    SetTimer () => ToolTip(), -3000
}

; Hàm di chuyển chuột với tốc độ tăng dần theo thời gian nhấn giữ
ContinuousMove() {
    global arrowKeyHeld, holdStartTime, mouseSpeedFast, mouseMaxSpeed
    
    if (arrowKeyHeld = "")
        return
    
    ; Tính toán tốc độ dựa trên thời gian đã nhấn giữ
    holdDuration := A_TickCount - holdStartTime
    speedFactor := Min(1, holdDuration / 2000)  ; Tăng dần tốc độ trong 2 giây
    currentSpeed := mouseSpeedFast + (mouseMaxSpeed - mouseSpeedFast) * speedFactor
    
    ; Di chuyển chuột theo hướng được nhấn giữ
    Switch arrowKeyHeld {
        Case "Up": MouseMove(0, -currentSpeed, , "R")
        Case "Down": MouseMove(0, currentSpeed, , "R")
        Case "Left": MouseMove(-currentSpeed, 0, , "R")
        Case "Right": MouseMove(currentSpeed, 0, , "R")
    }
}

; Các phím điều khiển chuột (chỉ hoạt động khi tính năng điều khiển chuột được kích hoạt)
#HotIf mouseControlEnabled
; Xử lý khi nhấn xuống các phím mũi tên
Up::KeyDown("Up")
Down::KeyDown("Down")
Left::KeyDown("Left")
Right::KeyDown("Right")

; Xử lý khi nhả phím mũi tên
Up Up::KeyUp()
Down Up::KeyUp()
Left Up::KeyUp()
Right Up::KeyUp()

; Hàm xử lý khi nhấn phím mũi tên
KeyDown(key) {
    global arrowKeyHeld, holdStartTime, mouseSpeed, holdThreshold
    
    ; Di chuyển chuột một khoảng nhỏ ngay lập tức
    Switch key {
        Case "Up": MouseMove(0, -mouseSpeed, , "R")
        Case "Down": MouseMove(0, mouseSpeed, , "R")
        Case "Left": MouseMove(-mouseSpeed, 0, , "R")
        Case "Right": MouseMove(mouseSpeed, 0, , "R")
    }
    
    ; Bắt đầu theo dõi nhấn giữ
    arrowKeyHeld := key
    holdStartTime := A_TickCount
    
    ; Đặt timer để kiểm tra nhấn giữ sau ngưỡng thời gian
    SetTimer CheckHold, -holdThreshold
}

; Hàm xử lý khi nhả phím mũi tên
KeyUp() {
    global arrowKeyHeld
    arrowKeyHeld := ""
    SetTimer ContinuousMove, 0  ; Dừng timer di chuyển liên tục
}

; Hàm kiểm tra xem phím có đang được nhấn giữ không
CheckHold() {
    global arrowKeyHeld
    
    if (arrowKeyHeld != "") {
        ; Nếu phím vẫn được giữ sau ngưỡng thời gian, bắt đầu di chuyển liên tục
        SetTimer ContinuousMove, 16  ; Khoảng 60 FPS
    }
}
#HotIf

; Các phím click chuột (chỉ hoạt động khi tính năng click chuột được kích hoạt)
#HotIf mouseClickEnabled
RAlt::Click()                   ; Alt phải = Click chuột trái
RCtrl::Click("Right")           ; Ctrl phải = Click chuột phải
#HotIf