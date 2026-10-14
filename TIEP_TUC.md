# TIẾP TỤC — Phong_ADung

**Cập nhật lần cuối:** 2026-10-14 16:30
**Phiên bản hiện tại:** **v22.100.20** (đã release GitHub + sync ổ Z)
**File chính:** `viet_drama_V22.99_stable_folder.py` (LF, 0 dòng CRLF, UTF-8 no BOM)
**Nhánh:** main — commit `1b94404`

---

## 1. Vừa xong trong phiên này (v22.100.20) — NGÔN NGỮ CHO SLINK

### Vấn đề phát hiện trên bài THẬT
Bài anh đăng hôm nay lên Slink (`682455`, `682375`) có **nội dung tiếng Việt nhưng bị gắn nhãn `en`**:

```
title = {"en": "Chiếc Xe Đen Trên Con Đường Đất"}     <- sai, phải là "vi"
```

Nguyên nhân: `publish_slink` gửi `title` / `content` dạng **CHUỖI THƯỜNG**.
fableon gặp chuỗi thì **luôn nhét vào key `en`**, bất kể nội dung viết bằng ngôn ngữ nào.
`seo_title` / `seo_description` thì gửi `{locale: text}` **chỉ 1 key** → theme render
`<title>` và `og:title` từ key `en` nên nếu chỉ có `{vi:...}` thì các thẻ đó **rỗng**.

### Cách vá
Thêm helper `slink_localized_value(text, locale)` (module-level, cạnh `slink_localized`):

```python
def slink_localized_value(text, locale) -> dict:
    out = {"en": text}                 # LUON kem 'en' lam fallback
    if locale and locale != "en":
        out[locale] = text
    return out
```

Đã áp vào **4 field** trong `publish_slink`:
- `title`  → `slink_localized_value(title_text, locale)`
- `content` (intro) → `slink_localized_value("<p>...</p>", locale)`
- `seo_title` → `slink_localized_value(seo_title, locale)`
- `seo_description` → `slink_localized_value(seo_desc, locale)`

Thêm hằng `SLINK_LOCALES = ("en", "vi", "zh", "ko")` (fableon chỉ có 4 slot ngôn ngữ).

`_slink_locale()` giữ nguyên mapping: `Vietnamese→vi`, `Chinese→zh`, `Korean→ko`,
**mọi ngôn ngữ khác → `en`** (fableon không có slot riêng cho Nhật/Hàn/Tây Ban Nha...).
→ 16 ngôn ngữ của tool vẫn chạy đủ, 3 ngôn ngữ có slot riêng thì ghi đúng slot.

**Khi TẮT ngôn ngữ** (`language_enabled=False`) → locale = `en` → payload y hệt trước đây.
Không phá hành vi cũ.

---

## 2. Đã verify (test THẬT trên site, không mock)

| Hạng mục | Kết quả |
|---|---|
| `py_compile` | COMPILE_OK |
| Import module | OK — `slink_localized_value`, `SLINK_LOCALES` có mặt |
| Payload dựng ra (locale `vi`) | `title` = `{"en": "...", "vi": "..."}`, `content`/`seo_*` tương tự |
| 16 ngôn ngữ → locale | Vietnamese→vi, Chinese→zh, Korean→ko, còn lại→en ✅ |
| TẮT ngôn ngữ → payload | y hệt bản cũ (chỉ `{"en": ...}`) ✅ |
| **POST thật lên fableon** (bài test `684823`) | **201**, server lưu đúng `{"en": "...", "vi": "..."}` cho cả 4 field ✅ |
| `title_en` (cột phụ) | vẫn được server tự điền ✅ |
| Xoá bài test | `DELETE` → 200, `GET` lại → **404** (đã xoá thật) ✅ |
| Site sạch | còn đúng **5 bài** (2 bài anh đăng + 3 bài gốc) |
| Config thật `~/.video_story_publisher_V22.99.json` | **KHÔNG bị ghi đè** (mtime 11:56, release chạy 16:27) |
| File chính + `version.json` | LF, 0 dòng CRLF |
| Backup bản gốc | `_backup_old/...v22.100.19_20261014_1626.py` (lấy từ `git show HEAD`) |
| Sync ổ Z | **18/18 MD5 khớp** |

---

## 3. Còn lại / chưa trả lời

- **Nhánh Slink chưa có `active_publish_link()` riêng** — hiện dựa vào `slink_existing_slugs()`,
  nên **chạy lại cùng folder có thể đăng trùng**. Anh chưa trả lời có muốn vá không.
- **Chưa test đăng thật qua GUI với video thật** (pipeline đã test E2E bằng script, chưa bấm nút trong GUI).
- **2 bài cũ hôm nay (682455, 682375) vẫn gắn nhãn `en`** — đã đăng trước khi vá.
  Nếu muốn đúng, phải sửa tay trong CMS (`PUT /api/posts/{id}` với dict `{en,vi}`) hoặc đăng lại.
- Câu hỏi treo cũ: có gộp option `single` không — chưa trả lời.
- Câu hỏi treo cũ: đổi tool sang xuất 1200x630 (thumbnail FB) không — chưa trả lời.
- 35 series test rác trên Adsconex chưa dọn (API không có route xoá → xoá tay trong CMS).

---

## 4. Bối cảnh cần nhớ

- **Tool này KHÔNG import module nội bộ** — single-file (trừ `updater`).
- API key Slink **chỉ đọc từ ô nhập trong GUI**, KHÔNG đọc `.env`.
- **fableon CHỈ hiểu `{{nextpage}}`**; `<!--nextpage-->` bị server coi là HTML comment và xoá sạch.
  → `publish_slink` KHÔNG lấy theo `cfg["pagebreak_mode"]`, LUÔN dùng `{{nextpage}}`.
- `published_slink_link` KHÔNG đoán link — lấy từ response (`/{slug}`).
- fableon API base `https://fableon.treeiq.biz/api`, site id `724`, category `266`, host `fableon.treeiq.biz`.
- **Đăng bài lên fableon là TẠO THẬT ngay** — muốn dò schema phải dùng payload THIẾU field bắt buộc để ăn 422.
- **KHÔNG BAO GIỜ in giá trị credential** (token Slink, mật khẩu site...) — chỉ nêu TÊN.
- Trước khi rời tool: ghi file này → commit/push → sync Z.
- Python: `C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe`

---

## 5. Lệnh hay dùng

```bash
cd "C:/Users/Admin/Desktop/Phong_ADung"
# release (tự ghi version.json + APP_VERSION + commit + push)
"C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe" release.py <version> "<mô tả>"
# sync ổ Z
"C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe" sync_z.py
# backup bản gốc từ git (KHÔNG copy file đang sửa)
git show HEAD:viet_drama_V22.99_stable_folder.py > "_backup_old/viet_drama_V22.99_stable_folder_v<ver>_<ts>.py"
```
