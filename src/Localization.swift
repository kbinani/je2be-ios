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
        case "Choose a bin file of Xbox 360 Edition data to start conversion": return "Xbox360版のデータ, bin ファイルを選択"
        case "Choose a zip file of Java Edition world data to start conversion": return "Java版のデータをzip圧縮したファイルを選択"
        case "Choose an mcworld file to start conversion": return "mcworld ファイルを選択"
        case "Completed": return "完了"
        case "Configure player UUID (Optional)": return "プレイヤーUUIDの設定 (省略可)"
        case "Do you really want to cancel?": return "本当に処理を中断しますか?"
        case "Error": return "エラー"
        case "Export": return "書き出し"
        case "Failed": return "変換に失敗しました"
        case "IO error": return "IO エラー"
        case "Internal error of converter": return "変換処理の内部エラー"
        case "Invalid UUID format": return "UUIDのフォーマットが不正です"
        case "It is also possible to start conversion without setting the UUID": return "UUIDを設定せずこのまま変換を始めることも可能です"
        case "Java to Bedrock": return "Java版 から 統合版に"
        case "Multiple level.dat found in the zip file": return "複数の level.dat ファイルが zip に含まれています"
        case "No": return "いいえ"
        case "Player UUID is not set. Open the Settings app to configure": return "プレイヤーUUIDが設定されていません。設定アプリで設定してください"
        case "Select": return "ファイルを選んで変換開始"
        case "Select conversion mode": return "変換モードを選択"
        case "The mcworld file is corrupt": return "mcworld ファイルが破損しています"
        case "The zip file is corrupt": return "zip ファイルが破損しています"
        case "Uncaught C++ exception": return "C++ の例外が発生しました"
        case "Uncaught general exception": return "例外が発生しました"
        case "Unknown error": return "不明なエラー"
        case "Unzip error": return "zip の解凍エラー"
        case "Use the UUID for conversion": return "このUUIDを変換に使用する"
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
