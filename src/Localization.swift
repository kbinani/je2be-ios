func gettext(_ s: String) -> String {
    let language = NSLocale.preferredLanguages.first ?? "en"
    switch language {
    case "ja-JP":
        switch s {
        case "About je2be": return "je2be について"
        case "Back": return "戻る"
        case "Bedrock to Java": return "統合版 から Java版に"
        case "Can't access file": return "ファイルにアクセスできません"
        case "Cancel": return "キャンセル"
        case "Cancelled": return "キャンセルされました"
        case "Choose a zip file of Java Edition world data": return "Java版のデータをzip圧縮したファイルを選択してください"
        case "Choose an mcworld file": return "mcworld ファイルを選択してください"
        case "Completed": return "完了"
        case "Do you really want to cancel?": return "本当に処理を中断しますか?"
        case "Error": return "エラー"
        case "Export": return "書き出し"
        case "Failed": return "変換に失敗しました"
        case "IO error": return "IO エラー"
        case "Internal error of converter": return "変換処理の内部エラー"
        case "Java to Bedrock": return "Java版 から 統合版に"
        case "Multiple level.dat found in the zip file": return "複数の level.dat ファイルが zip に含まれています"
        case "No": return "いいえ"
        case "Select": return "ファイルを選ぶ"
        case "Select conversion mode": return "変換モードを選んでください"
        case "The mcworld file is corrupt": return "mcworld ファイルが破損しています"
        case "The zip file is corrupt": return "zip ファイルが破損しています"
        case "Uncaught C++ exception": return "C++ の例外が発生しました"
        case "Uncaught general exception": return "例外が発生しました"
        case "Unknown error": return "不明なエラー"
        case "Unzip error": return "zip の解凍エラー"
        case "Xbox360 to Bedrock": return "Xbox360版 から 統合版に"
        case "Xbox360 to Java": return "Xbox360版 から Java版に"
        case "Yes": return "はい"
        case "level.dat not found in the zip file": return "level.dat ファイルが zip に含まれていません"
        default:
            return s
        }
    default:
        return s
    }
}
