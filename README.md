# azure-tts-lexicon-tw

![ci](https://github.com/mcw519/azure-tts-lexicon-tw/actions/workflows/ci.yaml/badge.svg)

適用於 LiveKit 搭配 Azure Text to Speech 服務的中文自訂詞典。

Azure TTS 的發音已經相當自然，但在中文多音字、專有名詞或特定語境上，仍然可能出現讀音不準的情況。這個 repo 提供一份可直接透過 SSML 引用的自訂詞典，用來補強預設發音規則。

這份 lexicon 的實際使用場景是 LiveKit 的 Azure Speech TTS。雖然上層是 LiveKit Agents/plugin，但真正解析 `lexicon.xml` 的仍然是 Azure Speech，所以詞典格式、locale、alphabet 與驗證規則都還是以 Azure 官方 custom lexicon 規格為準。

Azure TTS 支援在 SSML 中透過詞典 URL 載入自訂 lexicon。因為該檔案必須能從公網存取，直接放在 GitHub 上通常是最省事的做法，也方便後續持續維護與分享。

這份詞典目前採用 Azure 官方支援的 PLS 1.0 格式，`xml:lang="zh-TW"` 並搭配 `alphabet="x-microsoft-sapi"`。對於英文縮寫、品牌名或含空白的混合詞組，優先使用 `alias -> phoneme` 的兩段式寫法，避免直接把英文音素塞進 `zh-TW` 詞典中。

## 使用方式

詞典檔案連結：

```text
https://raw.githubusercontent.com/mcw519/azure-tts-lexicon-tw/main/lexicon.xml
```

在 SSML 中引用詞典：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:mstts="http://www.w3.org/2001/mstts"
       xml:lang="zh-TW">
    <voice name="zh-TW-HsiaoChenNeural">
        <lexicon uri="https://raw.githubusercontent.com/mcw519/azure-tts-lexicon-tw/main/lexicon.xml"/>
        這款產品有維他命 B1，LiveKit 的整合也已經完成。
    </voice>
</speak>
```

Azure 官方文件可參考：
https://learn.microsoft.com/zh-tw/azure/ai-services/speech-service/speech-synthesis-markup-pronunciation#custom-lexicon

## LiveKit 使用注意

如果你是透過 LiveKit 的 Azure Speech TTS plugin 使用這份詞典，關鍵不是「LiveKit 有沒有載入這個 XML」，而是「Azure 最後收到的內容是不是包含 `<lexicon uri="..."/>` 的 SSML」。

也就是說：

1. 這份 lexicon 必須放在 Azure 可公開存取的 URL。
2. 送到 Azure TTS 的 SSML 內必須真的包含 `<lexicon uri="..."/>`。
3. 如果 LiveKit 這一層最後送出去的只是純文字，而不是帶有 `lexicon` 標籤的 SSML，這份詞典就不會生效。

LiveKit 官方文件也有寫到 Azure Speech TTS plugin 支援 SSML 發音控制，因此這個 repo 的設計前提就是讓 Azure 端透過 SSML 來引用這份詞典，而不是讓 LiveKit 直接解析 lexicon 檔本身。

## 驗證流程

這個 repo 已經有兩層驗證：

1. 本地 quick check：先檢查 XML 是否完整、根節點是否還是 PLS 1.0、`xml:lang` 和 `alphabet` 是否被改壞、以及每個 `lexeme` 是否至少有 `grapheme` 和 `alias/phoneme`。
2. CI 正式驗證：push 或 PR 時，GitHub Actions 會執行 Azure Samples 提供的 `CustomLexiconValidation` 工具。這一層比較接近 Azure Speech 真正會接受的規格。

本地 quick check：

```bash
./scripts/validate-lexicon.sh
```

補充：本地腳本主要是擋結構性錯誤，像是 XML 壞掉、必要欄位漏掉、root metadata 被改錯。音素是否合法、某些條目是否違反 Azure lexicon 細節規則，仍以 CI 內的 Azure 官方 validator 為準。

再補一個實務坑：Azure Learn 文件對 custom lexicon 的 `alphabet` 明確寫 `x-microsoft-sapi`，但 Azure Samples 提供的 `CustomLexiconValidation` 工具目前仍只接受 `sapi` 這個 enum 值。這個 repo 的做法是保留原始 [lexicon.xml](lexicon.xml) 與官方文件一致，在 CI 裡另外產生一份暫存檔，把 `x-microsoft-sapi` 正規化成 `sapi` 後再丟給 validator，避免為了遷就舊工具而改壞正式詞典格式。

## 維護與貢獻

如果你發現某些詞在 Azure TTS 中的發音不正確，可以透過 issue 回報，或直接提交 PR。

主要需要調整的檔案是 [lexicon.xml](lexicon.xml)。格式不算複雜，直接參考現有詞條通常就能理解寫法。

如果你想維護自己的版本，也可以 fork 這個 repo，再把 SSML 裡的詞典連結改成你自己的路徑：

```text
https://raw.githubusercontent.com/<你的 GitHub 使用者名稱>/azure-tts-lexicon-tw/main/lexicon.xml
```

補充：目前詞典內容仍以 Azure lexicon 規格與現有拼音標註方式為主，新增詞條時請盡量保持既有格式一致。

