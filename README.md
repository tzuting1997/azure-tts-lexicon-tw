# azure-tts-lexicon-tw

![ci](https://github.com/mcw519/azure-tts-lexicon-tw/actions/workflows/ci.yaml/badge.svg)

這個分支目前提供一份給 Azure Text to Speech 英文語音使用的自訂詞典範例，目標 locale 是 `en-US`。

Azure TTS 預設發音通常已經不錯，但縮寫、品牌名、人名、產品名，或大小寫敏感的字詞，還是很容易出現不符合需求的讀法。這份 repo 提供一份可直接透過 SSML 引用的 custom lexicon，讓你在 Azure Speech 端覆蓋預設發音。

目前這份英文 lexicon 採用 Azure 官方支援的 PLS 1.0 格式，`xml:lang="en-US"` 並搭配 `alphabet="ipa"`。對英文詞典來說，`ipa` 比較直觀，也比較接近 Azure Learn 文件的主要範例；縮寫或多詞片語則優先使用 `alias`，避免直接對片語硬寫 phoneme。

## 使用方式

請先把 [lexicon.xml](lexicon.xml) 放到可公開存取的 URL，例如 GitHub Raw 或 Azure Blob Storage，然後在 SSML 裡引用：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
       xmlns:mstts="http://www.w3.org/2001/mstts"
       xml:lang="en-US">
    <voice name="en-US-AvaNeural">
        <lexicon uri="https://raw.githubusercontent.com/<your-account>/<your-repo>/<your-branch>/lexicon.xml"/>
        BTW, I've added the SKU to OpenAI FAQ notes for Benigni.
    </voice>
</speak>
```

Azure 官方文件：
https://learn.microsoft.com/en-us/azure/ai-services/speech-service/speech-synthesis-markup-pronunciation#custom-lexicon

## 目前詞典內容

這份範例目前包含幾類常見條目：

1. 縮寫展開，例如 `BTW`、`FAQ`、`SKU`、`OpenAI`。
2. 單字或名稱發音，例如 `GitHub`、`Benigni`、`I've`。

注意：Azure custom lexicon 的 `lexeme` 是區分大小寫的，所以 `GitHub` 和 `github` 會被視為不同詞條。

## Azure 使用注意

詞典是否生效，關鍵在於 Azure 最後收到的請求是不是包含 `<lexicon uri="..."/>` 的 SSML。

也就是說：

1. 詞典檔案必須能從公網存取。
2. 你實際送到 Azure TTS 的內容必須是 SSML，而不是純文字。
3. SSML 內必須真的有 `<lexicon uri="..."/>`。
4. 自訂 lexicon 以 URI 為快取 key，更新同一個 URL 後，Azure 端最多可能需要約 15 分鐘才會刷新。

另外一個常見限制是：custom lexicon 比較適合單一實體、縮寫或專有名詞。如果你要控制一整段片語的讀法，通常先拆成 `alias`，或直接在 SSML 內用 `sub` / `phoneme` 會更穩。

## 驗證流程

這個 repo 目前有兩層驗證：

1. 本地 quick check：檢查 XML 是否完整、根節點與 namespace 是否正確、`xml:lang` / `alphabet` 是否符合 repo 設定，以及每個 `lexeme` 是否至少包含 `grapheme` 加上 `alias` 或 `phoneme`。
2. CI 正式驗證：GitHub Actions 會跑 Azure Samples 提供的 `CustomLexiconValidation` 工具，這一層更接近 Azure Speech 真正接受的格式。

本地 quick check：

```bash
./scripts/validate-lexicon.sh
```

因為目前詞典使用 `alphabet="ipa"`，本地檢查也會額外擋掉包含空白的 IPA phoneme，避免像 SAPI phone set 那樣的空白分隔寫法混進來。

## 維護建議

主要維護的檔案是 [lexicon.xml](lexicon.xml)。新增詞條時，可以優先用以下原則：

1. 縮寫、產品代號、多詞片語，先考慮用 `alias`。
2. 單字、人名、品牌名，確定讀音後再用 `phoneme`。
3. 若使用 `ipa`，`phoneme` 內容不要有空白。
4. 如果某個詞有大小寫差異，就分開建立 lexeme。

如果你要改成自己的公開 URL，可以把 SSML 中的 lexicon 連結換成：

```text
https://raw.githubusercontent.com/<your-account>/<your-repo>/<your-branch>/lexicon.xml
```

