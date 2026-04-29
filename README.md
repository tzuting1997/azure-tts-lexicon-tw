# azure-tts-lexicon-tw

![ci](https://github.com/mcw519/azure-tts-lexicon-tw/actions/workflows/ci.yaml/badge.svg)

適用於 Azure Text to Speech 服務的中文自訂詞典。

Azure TTS 的發音已經相當自然，但在中文多音字、專有名詞或特定語境上，仍然可能出現讀音不準的情況。這個 repo 提供一份可直接透過 SSML 引用的自訂詞典，用來補強預設發音規則。

Azure TTS 支援在 SSML 中透過詞典 URL 載入自訂 lexicon。因為該檔案必須能從公網存取，直接放在 GitHub 上通常是最省事的做法，也方便後續持續維護與分享。

## 使用方式

詞典檔案連結：

```text
https://raw.githubusercontent.com/mcw519/azure-tts-lexicon-tw/main/lexicon.xml
```

在 SSML 中引用詞典：

```xml
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis"
          xmlns:mstts="http://www.w3.org/2001/mstts"
          xml:lang="en-US">
    <voice name="zh-CN-XiaoxiaoNeural">
        <lexicon uri="https://raw.githubusercontent.com/mcw519/azure-tts-lexicon-tw/main/lexicon.xml"/>
        等一會兒，朱重八！
    </voice>
</speak>
```

Azure 官方文件可參考：
https://learn.microsoft.com/zh-tw/azure/ai-services/speech-service/speech-synthesis-markup-structure#add-a-lexicon

## 維護與貢獻

如果你發現某些詞在 Azure TTS 中的發音不正確，可以透過 issue 回報，或直接提交 PR。

主要需要調整的檔案是 [lexicon.xml](lexicon.xml)。格式不算複雜，直接參考現有詞條通常就能理解寫法。

如果你想維護自己的版本，也可以 fork 這個 repo，再把 SSML 裡的詞典連結改成你自己的路徑：

```text
https://raw.githubusercontent.com/<你的 GitHub 使用者名稱>/azure-tts-lexicon-tw/main/lexicon.xml
```

補充：目前詞典內容仍以 Azure lexicon 規格與現有拼音標註方式為主，新增詞條時請盡量保持既有格式一致。

