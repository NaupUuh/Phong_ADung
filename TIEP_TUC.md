# TIẾP TỤC — Phong_ADung

**Cập nhật lần cuối:** 2026-10-14 12:00
**Phiên bản hiện tại:** **v22.100.19** (đã release GitHub + sync ổ Z)
**File chính:** `viet_drama_V22.99_stable_folder.py` (LF, 0 dòng CRLF, UTF-8 no BOM)
**Nhánh:** main — commit `22e90b4`

---

## 1. Vừa xong trong phiên này (v22.100.19)

### (a) Chuyển khối "Ngôn ngữ truyện" lên mục 1 "Đầu vào"
- **Trước:** nằm trong tab **SmartTraffic** (grid row 8).
- **Nay:** nằm trong khối **`1. Đầu vào: video, kịch bản hoặc cả hai`** (`source` frame, `row=5`),
  LabelFrame tiêu đề: `Ngôn ngữ truyện (áp cho mọi web/net đã chọn)`.
- Gồm: checkbutton `language_enabled` + combobox `language` (16 thứ tiếng) + `language_hint` + `language_note`.
- **Phạm vi áp dụng = TOÀN CỤC cho mọi net** (SmartTraffic / Adsconex / Slink). Không phụ thuộc `net_provider`,
  vì mọi call site dùng chung `effective_language(self.cfg)`.
- **Mặc định TẮT** → chạy y như cũ (tiếng Anh).
- Gỡ hẳn khối cũ khỏi tab SmartTraffic (chỉ còn comment đánh dấu vị trí cũ).
- `_refresh_language_state()` đã cập nhật lại text `language_note` cho khớp vị trí mới
  (ghi rõ "Áp cho MỌI net đang chọn").

### (b) Tách nút "⬆ Cập nhật" ra góc phải trên, ĐỘC LẬP
- **Trước:** nằm trong frame `actions` (cạnh "Chẩn đoán máy").
- **Nay:** `corner = ttk.Frame(self)` pack **ngay đầu `_build()`**, `self.update_btn.pack(side="right")`.
- Nằm **ngoài** LabelFrame "Tiến độ toàn bộ" → không bị ẩn/hiện theo nút "Thu gọn".
- Verify: `update_btn.master.master is app` → True.

---

## 2. Đã verify (test thật, không mock)

| Hạng mục | Kết quả |
|---|---|
| `py_compile` | COMPILE_OK |
| Import module | OK |
| GUI mở thật (`App()`) | OK — 8 tab: Kịch bản & Prompt, Vilao AI, SmartTraffic, Adsconex, Slink, Image hosting, FFmpeg, Hướng dẫn |
| Khối ngôn ngữ nằm trong `1. Đầu vào` | ✅ LabelFrame "Ngôn ngữ truyện (áp cho mọi web/net đã chọn)" |
| Nút Cập nhật ở góc phải trên, độc lập | ✅ `master.master is app`, `side=right` |
| Không còn khối ngôn ngữ lặp trong tab SmartTraffic | ✅ |
| Ngôn ngữ áp cho cả 3 net | ✅ Korean cho SmartTraffic / Adsconex / Slink — cùng `effective_language` |
| TẮT ngôn ngữ | ✅ trả về `English` |
| Screenshot đối chiếu layout | ✅ khớp yêu cầu |
| Config thật `~/.video_story_publisher_V22.99.json` | MD5 `744ab410…`, mtime 11:42 — **KHÔNG bị tool/test ghi đè** |
| Backup bản cũ | `_backup_old/viet_drama_V22.99_stable_folder_v22.100.18_20261014_1155.py` (md5 `52b95f9c`, lấy từ `git show HEAD`) |
| GitHub | commit `22e90b4`; blob `version.json` sha `ea25e82b` khớp local |
| Ổ Z | **17/17 MD5 KHỚP** |
| Line ending file chính | LF, 0 CRLF |

---

## 3. Việc còn lại (chưa làm)

- [ ] **Nhánh Slink chưa có `active_publish_link()` riêng** — hiện dựa vào `slink_existing_slugs()`.
      Rủi ro: chạy lại cùng folder có thể đăng trùng. *(Đã hỏi anh, chưa trả lời.)*
- [ ] **Chưa bấm đăng thật qua GUI với video thật** cho nhánh Slink (pipeline đã test E2E bằng script).
- [ ] **Câu hỏi treo:** đổi tool sang xuất thumbnail 1200x630 cho Facebook? *(chưa trả lời)*
- [ ] **Câu hỏi treo:** gộp option `single` (chia chapter) không? *(chưa trả lời)*
- [ ] **Câu hỏi treo:** dọn file tạm trong `Temp/`? *(chưa trả lời)*
- [ ] **35 series test rác** trên Adsconex chưa dọn (API không có route xoá → xoá tay trong CMS).

---

## 4. Bối cảnh quan trọng (đừng quên)

- **KHÔNG import module nội bộ** — tool drama là **single-file** (trừ `updater`).
- **API key tool drama CHỈ đọc từ ô nhập trong GUI**, KHÔNG đọc `.env`.
- **Không bao giờ in/lặp lại giá trị credential** (token, API key, mật khẩu) — chỉ nêu TÊN.
- **`FIXED_PRODUCTION_SETTINGS` KHÔNG được chứa key `language`** — hàm này `cfg.update()` đè mọi key
  mỗi lần chạy, sẽ vô hiệu hoá lựa chọn ngôn ngữ của user. (Key `language` vẫn phải còn trong
  `DEFAULT_CONFIG` để tránh KeyError máy mới.)
- **Marker phân trang fableon (Slink):** CHỈ hiểu `{{nextpage}}`. Marker `<!--nextpage-->` bị server
  coi là HTML comment và **xoá sạch**. → `publish_slink` ghim cứng `{{nextpage}}`, KHÔNG lấy theo
  `pagebreak_mode`.
- **`publish_result.json` do CALLER ghi** (GUI/`run()`), không phải `publish_slink` — không phải bug.
- **Option mặc định phải giữ:** logo YouTube = TẮT; chapter = `batch`; ngôn ngữ = TẮT.
- **Giữ tên biến `filename_phrase_editor`**; 3 cột tab "Kịch bản & Prompt" chia đều.
- **Giới hạn tên file: 219 ký tự.**
- **Quy trình release:** sửa code → `python release.py <ver> "<mô tả>"` (script tự ghi `APP_VERSION`
  + `version.json`) → `python sync_z.py`. **ĐỪNG sửa `APP_VERSION` bằng tay** trước khi chạy release.py
  (sẽ lệch version và fail).
- **Backup trước khi sửa:** `cp file _backup_old/..._v<ver>_<ngày>.py` — nhưng nếu đã sửa rồi mới copy
  thì backup là bản ĐÃ SỬA; phải lấy bản gốc bằng `git show HEAD:<file> > backup`.
- **Môi trường:** Windows, Python 3.13 tại
  `C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe`.
- **Ổ Z:** `Z:/HQData-2/TOOLS TỔNG HỢP/TOOLS UPDATE CUỐI/Phong_ADung/`.

---

## 5. Cách chạy nhanh để kiểm tra layout

```bash
PY="C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe"
cd "C:/Users/Admin/Desktop/Phong_ADung"
"$PY" -m py_compile viet_drama_V22.99_stable_folder.py && echo COMPILE_OK
"$PY" viet_drama_V22.99_stable_folder.py     # mở GUI thật
```

Test tự động không mở GUI:
```python
import importlib.util, sys, os
os.environ["VIDEO_STORY_PUBLISHER_SKIP_WIZARD"] = "1"
os.environ["VIDEO_STORY_PUBLISHER_NO_UPDATE"] = "1"
spec = importlib.util.spec_from_file_location("adung", r"C:\Users\Admin\Desktop\Phong_ADung\viet_drama_V22.99_stable_folder.py")
m = importlib.util.module_from_spec(spec); sys.modules["adung"] = m; spec.loader.exec_module(m)
app = m.App()
print(app.update_btn.master.master is app)          # True = nút Cập nhật độc lập
print(app.language_combo.winfo_class())             # TCombobox
print(m.effective_language({**app.cfg, "language_enabled": True, "language": "Korean"}))
app.destroy()
```
