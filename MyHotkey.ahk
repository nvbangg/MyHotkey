; MyHotkey
#Requires AutoHotkey v2.0

;---------Tổng hợp phím tắt-------------
; Alt+V: Dán nội dung clipboard trước đó
; Ctrl+Alt+V: Dán với định dạng (tên cho file code)
; Alt+T: Chuyển đổi dịch trang web

;---------About-------------------------
#SingleInstance Force
A_TrayMenu.Add("About", ShowAbout) ; Thêm mục "About" vào menu khay
A_TrayMenu.Add("Shortcuts", ShowTips) ; Thêm mục "Shortcuts" vào menu khay
A_IconTip := "MyHotkey`nAlt+V: Paste Clipboard`nCtrl+Alt+V: Format paste`nAlt+T: Translate (Chrome)" ; Thông tin tooltip trên khay hệ thống

ShowAbout(*) {
    result := MsgBox("MyHotkey`n`nVersion: 1.0`nDate: 03/03/2025`n`nCreated by: facebook.com/nvbangg`nVisit creator's page?", "About MyHotkey", "YesNo")
    if (result = "Yes")
        Run("https://facebook.com/nvbangg")
}

ShowTips(*) {
    tipsText := "--------PHÍM TẮT--------`n"
    tipsText .= "Alt+V: Dán nội dung clipboard trước đó`n"
    tipsText .= "Ctrl+Alt+V: Dán với định dạng (tên cho file code)`n"
    tipsText .= "Alt+T: Chuyển đổi dịch trang web`n`n"
    
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

; Alt+V: Dán nội dung clipboard trước đó
!v:: {
    if clipboardHistory.Length >= 2 {
        oldClip := ClipboardAll()
        A_Clipboard := clipboardHistory[2]
        ClipWait(0.3)
        Send("^v")
        Sleep(50)
        A_Clipboard := oldClip
    }
}

; Ctrl+Alt+V: Dán với định dạng (tên cho file code)
^!v:: {
    if clipboardHistory.Length >= 2 {
        oldClip := ClipboardAll()
        A_Clipboard := clipboardHistory[2] . "_" . RemoveAccents(clipboardHistory[1]) . "."
        ClipWait(0.3)
        Send("^v")
        Sleep(50)
        A_Clipboard := oldClip
    }
}

;---------CHROME------------------

; Chỉ hoạt động trong Chrome
#HotIf WinActive("ahk_exe chrome.exe")

; Alt+T: Chuyển đổi dịch trang web
!t:: {
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