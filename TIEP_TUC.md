# TIẾP TỤC — Phong_ADung (Video Story Publisher)

**Cập nhật lần cuối:** 2026-10-14
**Phiên bản hiện tại:** v22.100.18
**File chính:** `viet_drama_V22.99_stable_folder.py` (single-file, LF, ~8.6k dòng)

---

## VIỆC VỪA LÀM XONG (v22.100.18 — 2026-10-14)

### 1. Thêm net provider `Slink` (đăng lên fableon.treeiq.biz)
- Net mới trong combobox **"Net đăng bài"**: `("SmartTraffic", "Adsconex", "Slink")`.
- Tab GUI mới **`Slink`** (sau tab Adsconex): API token (masked + nút Edit Key),
  base URL, site host, site ID, Category ID (+ nút "Lấy danh sách"), trạng thái bài,
  nút "Kiểm tra token" / "Mở API token" / "Mở site", nhóm "Thử lại khi net lỗi tạm thời".
- Pipeline: `_slink_headers` / `_slink_locale` / `_slink_send` (retry lỗi tạm thời)
  / `publish_slink` (POST `/api/posts/chapter`) / `republish_pending_slink`.
- Helper module-level: `published_slink_link`, `slink_localized`, `build_slink_chapters`,
  `slink_pending_path`, `slink_write_pending`, `slink_clear_pending`, `slink_existing_slugs`,
  `find_pending_slink`.
- Nút **"Đăng lại bài lỗi"** giờ chạy theo net đang chọn (Adsconex **hoặc** Slink).
- Key config mới: `slink_api_key`, `slink_base_url`, `slink_site_host`, `slink_site_id`,
  `slink_category`, `slink_status`, `slink_retry_count`, `slink_retry_delay`.

### 2. Thêm chức năng NGÔN NGỮ (port từ Phong_DHue v23.6)
- Trước đây ADung **CHƯA có**: chỉ có key `language` chết, không UI, không dùng ở đâu.
- Đã port: `LANGUAGE_OPTIONS` (16 ngôn ngữ), `LANGUAGE_KEYS`, `LANGUAGE_LABELS`,
  `language_label`, `language_prompt_name`, `effective_language`, `language_instruction`,
  `strip_language_rules`, `filename_phrases_for_language`, `fallback_hashtags_for_language`,
  `_is_default_phrase_list`, `CAPTION_CTA`, `FIRST_PERSON_MARKERS`, `NO_SPACE_LANGUAGES`.
- UI: tab **SmartTraffic** → khối **"Ngôn ngữ truyện"** (checkbutton + combobox +
  hint + ghi chú). **Mặc định TẮT = tiếng Anh y như trước.**
- Áp ngôn ngữ vào: `_writer_json_call`, `_write_chapter_batch`, `_write_one_chapter`,
  `_story_metadata`, caption Facebook, hashtag fallback, tên file video, `run()` log.

---

## 🔴 BÀI HỌC QUAN TRỌNG (đừng quên)

1. **`FIXED_PRODUCTION_SETTINGS` ghi đè lựa chọn người dùng.**
   Bản cũ ghim `"language": "English"` → `apply_fixed_production_settings()` sẽ ghi đè
   mọi lựa chọn → ngôn ngữ KHÔNG BAO GIỜ có tác dụng. **Đã gỡ.** Nếu thêm option mới
   mà người dùng phải chọn được → **KHÔNG** nhét vào `FIXED_PRODUCTION_SETTINGS`.

2. **fableon CHỈ hiểu `{{nextpage}}`.**
   Marker `<!--nextpage-->` (dùng cho SmartTraffic) bị server coi là HTML comment
   và **xoá sạch** → mất phân trang. `publish_slink` **luôn** dùng `{{nextpage}}`,
   KHÔNG lấy theo `cfg["pagebreak_mode"]`. (Đã đo thật: `plain+htmlcomment` →
   content lưu `<p>one</p>\n\n\n\n<p>two</p>` — marker biến mất.)

3. **`GET /api/posts/{id}/chapter/{n}` trả `data.post` + `data.chapters`.**
   `GET /api/posts/{id}/chapters` **KHÔNG** trả `content` (chỉ id/number/title/view_count).
   Muốn đọc nội dung 1 chương → dùng `/chapter/{n}` và đọc `data.chapters[0].content`.

4. **`publish_slink` KHÔNG tự ghi `publish_result.json`.**
   Giống hệt Adsconex/SmartTraffic: caller (`run()` khi auto_publish, hoặc
   `App.publish_current`) mới ghi file đó. Đây là thiết kế, không phải bug.

5. **`paragraphize` escape HTML** → phải chèn marker SAU khi paragraphize
   (nếu không `{{nextpage}}` bị đổi thành `&lt;!--...--&gt;`).

---

## ĐÃ TEST THẬT (2026-10-14)

| Hạng mục | Kết quả |
|---|---|
| `py_compile` + import module | OK |
| GUI khởi tạo | OK — 8 tab: Kịch bản & Prompt, Vilao AI, SmartTraffic, Adsconex, **Slink**, Image hosting, FFmpeg, Hướng dẫn |
| Combobox ngôn ngữ | 16 giá trị, mặc định TẮT |
| Checkbox ngôn ngữ bật/tắt | combo readonly/disabled + hint đổi đúng |
| Ô "Câu chèn trong tên file" tự đổi theo ngôn ngữ | OK (chỉ khi còn bản mặc định) |
| `publish_slink` E2E thật lên fableon | 201 → 2 chapter lưu đúng → xoá 200 |
| Marker `{{nextpage}}` lưu trên server | OK (còn nguyên trong content) |
| Retry: base URL sai → lưu pending → sửa URL → đăng lại OK | OK, pending tự xoá sau khi thành công |
| Token Slink GET /posts | 200 |
| Mặc định cũ không đổi (`effective_language` = English khi TẮT) | OK |
| Config thật MD5 | `8d3536e3337123f88ea6a4387454c8dd` — KHÔNG đổi |

**Đã dọn sạch bài test** — site fableon còn đúng 3 bài gốc
(`the-baby-in-the-dumpster`, `the-bluebird-file`, `i-found-my-4-year-old-locked-in-the-laundry-room`).

---

## VIỆC CÒN LẠI / CHƯA LÀM

- **Chưa test đăng bài thật bằng GUI** (bấm nút Publish trong tool với 1 video thật).
  Phần pipeline đã test E2E bằng script, nhưng chưa qua GUI.
- **Chưa test `republish_failed_posts` từ GUI** với folder lỗi thật.
- **Bug đã biết (chưa vá):** nhánh `net_provider=Adsconex` thiếu `active_publish_link()`
  → có thể đăng trùng. Slink cũng chưa có hàm tương đương — hiện dựa vào
  `slink_existing_slugs()` + `_adsconex_has_published()`.
- **502 máy Admin** — bằng chứng do ORIGIN site, không phải tool.
- 35 series test rác trên Adsconex chưa dọn (API không có route xoá → xoá tay trong CMS).

---

## LỆNH THƯỜNG DÙNG

```bash
# Compile check
"C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe" -m py_compile \
  "C:/Users/Admin/Desktop/Phong_ADung/viet_drama_V22.99_stable_folder.py"

# Phát hành bản mới
cd "C:/Users/Admin/Desktop/Phong_ADung"
python release.py 22.100.19 "Mô tả thay đổi"

# Sync lên ổ Z (kèm đối chiếu MD5)
python sync_z.py
```

---

## BỐI CẢNH

- **Backup bản cũ:** `_backup_old/viet_drama_V22.99_stable_folder_v22.100.17_20261014_1052.py`
- **Nguồn port ngôn ngữ:** `C:/Users/Admin/Desktop/Phong_DHue/viet_drama_V23.6_dashboard_thumbnail.py` (v23.6.19)
- **Config thật:** `~/.video_story_publisher_V22.99.json` (74 key) — **KHÔNG được ghi đè**
- **Ổ Z:** `Z:/HQData-2/TOOLS TỔNG HỢP/TOOLS UPDATE CUỐI/Phong_ADung/`
- **fableon CMS:** site id `724`, category `266`, API base `https://fableon.treeiq.biz/api`,
  auth Bearer `id|secret`, tài liệu đầy đủ ở `C:/Users/Admin/Desktop/fableon_API_va_viet_chapter.md`
