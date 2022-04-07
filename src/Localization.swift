func gettext(_ s: String) -> String {
    let language = NSLocale.preferredLanguages.first ?? "en"
    if language == "ja-JP" {
        // (git ls-files | grep swift) | xargs cat | grep gettext | grep -v func | sed 's/.*gettext("\([^"]*\)").*/case "\1":/g' | sort | uniq | pbcopy
        switch s {
        case "About": return "About"
        case "Back": return "戻る"
        case "Bedrock to Java": return "統合版 から Java版に"
        case "Cancel": return "キャンセル"
        case "Choose a zip file of Java Edition world data": return "Java版のデータをzip圧縮したファイルを選択してください"
        case "Choose an mcworld file": return "mcworld ファイルを選択してください"
        case "Completed": return "完了"
        case "Export": return "書き出し"
        case "Failed": return "失敗"
        case "Java to Bedrock": return "Java版 から 統合版に"
        case "Select conversion mode": return "変換モードを選んでください"
        case "Select": return "ファイルを選ぶ"
        case "Xbox360 to Bedrock": return "Xbox360版 から 統合版に"
        case "Xbox360 to Java": return "Xbox360版 から Java版に"
        default:
            return s
        }
    } else {
        return s
    }
}
