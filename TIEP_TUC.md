# TIẾP TỤC — Phong_ADung

**Cập nhật lần cuối:** 2026-10-14 17:22
**Phiên bản hiện tại:** **v22.100.21** (đã release GitHub + sync ổ Z)
**File chính:** `viet_drama_V22.99_stable_folder.py` (LF, 0 dòng CRLF, UTF-8 no BOM)
**Nhánh:** main — commit `088a57d`

---

## 1. Vừa xong trong phiên này (v22.100.21) — NÚT PLAY TRẮNG

Anh gửi ảnh thumbnail Facebook có nút play **trắng** và yêu cầu: *"Phần logo youtube
thêm cho a nút play trắng như này, tự tìm rồi down về cho a"*.

### Kết quả đo từ ảnh tham chiếu
Nút trong ảnh = **vòng tròn trắng MỜ + tam giác trắng ĐẶC** (kiểu overlay play của
Facebook), **KHÔNG** phải nút play đỏ YouTube đang có.

- Ảnh 320×313, thumbnail ở x≈54..150; nút ở tâm **(100,166)**, đường kính **~20px**
  trên thumbnail rộng ~96px → **≈ 21%** chiều rộng ảnh.
- Đo hướng tâm: nền quanh nút `lum≈66` → vòng mờ `lum≈70..76` (sáng hơn nền
  ~5-10 đơn vị) → giữa `lum≈49..63`. Tức vòng **hơi sáng hơn nền**, không phải
  trắng đặc.
- Tam giác: `th=10px, tw=9px` → **tw/th ≈ 0.90**; `th/D ≈ 0.45..0.50`.

### Cách làm
**Không tải file PNG ngoài** (mọi nguồn tải về đều lệch kiểu hoặc vướng license).
Vẽ bằng PIL, thêm **kiểu thứ 3** `white` bên cạnh `play` / `logo`:

```python
def _draw_white_play_badge(base, scale, shadow=True):
    # ve o 4x roi LANCZOS thu nho -> khong rang cua
    # vong: fill (255,255,255,95) + vien mong outline alpha 130
    # tam giac: th = S*0.33, tw = th*0.90, lech phai S*0.025
```

Trong `draw_youtube_badge()`: thêm nhánh `is_white` (nhận cả `white` và `trang`)
→ gọi `_draw_white_play_badge`. Khi `style="white"` thì **bỏ qua** hình chữ nhật
đỏ, dùng đường kính = `scale × cạnh ngắn`.

### 4 chỗ đã sửa
| # | Vị trí | Thay đổi |
|---|---|---|
| 1 | `draw_youtube_badge` (module-level) | thêm `_draw_white_play_badge()` + nhánh `is_white` |
| 2 | `StoryPipeline._youtube_badge_settings` | `("play","logo")` → `("play","logo","white")` |
| 3 | `App.preview_youtube_badge` | cùng danh sách trên (nút "Xem trước logo") |
| 4 | GUI tab Image hosting | Combobox `values=("play","logo","white")` + nhãn mô tả kiểu `white` |

---

## 2. Đã verify (test THẬT)

| Hạng mục | Kết quả |
|---|---|
| `py_compile` | COMPILE_OK |
| File chính | LF, **0 dòng CRLF** |
| `make_social_thumbnail(badge_style="white")` | chạy OK, ảnh 290×290 ra đúng nút trắng |
| Soi ảnh bằng vision | **"vòng tròn trắng mờ + tam giác trắng đặc, rất giống nút play overlay Facebook"** ✅ |
| Kiểu cũ `play` / `logo` | vẫn chạy y như trước (8068B / 9011B) ✅ |
| Style lạ (`xyz`) | fallback về `play`, không crash ✅ |
| Scale biên 0.05 / 0.95 | không crash ✅ |
| `_youtube_badge_settings` | `white`/`WHITE`/`  white  ` → `white`; `bogus` → `play`; TẮT → `('',0.0)` ✅ |
| Bóng đổ trên nền sáng | nhờ shadow vẫn thấy được nút (nền trắng nhạt là ca xấu nhất) |
| Config thật `~/.video_story_publisher_V22.99.json` | **KHÔNG bị ghi đè** (mtime 11:56) |
| Backup bản gốc | `_backup_old/...v22.100.20_20261014_1719.py` (từ `git show HEAD`) |
| Sync ổ Z | **19/19 MD5 khớp** |

---

## 3. Còn lại / chưa trả lời

- **Chưa bấm nút "Xem trước logo" trong GUI** để xem thực tế (đã test bằng script
  qua đúng hàm `make_social_thumbnail`; GUI chỉ gọi lại hàm đó).
- **Nhánh Slink chưa có `active_publish_link()` riêng** — chạy lại cùng folder có
  thể đăng trùng. Anh chưa trả lời có muốn vá không.
- **Chưa test đăng thật qua GUI với video thật** (pipeline đã test E2E bằng script).
- **2 bài Slink cũ (682455, 682375) vẫn gắn nhãn `en`** — đăng trước khi vá v22.100.20.
- Câu hỏi treo cũ: có gộp option `single` không — chưa trả lời.
- Câu hỏi treo cũ: đổi tool sang xuất 1200×630 (thumbnail FB) không — chưa trả lời.
- 35 series test rác trên Adsconex chưa dọn (API không có route xoá → xoá tay trong CMS).

---

## 4. Bối cảnh cần nhớ

- **Tool này KHÔNG import module nội bộ** — single-file (trừ `updater`).
- **Logo YouTube trên ảnh bìa:** mặc định **TẮT**; CHỈ vẽ lên ảnh bìa **website 290×290**,
  ảnh bìa Facebook **KHÔNG** bị ảnh hưởng (`make_social_thumbnail` cho FB gọi không badge).
- 3 kiểu: `play` (ô đỏ bo góc + tam giác), `logo` (ô đỏ + chữ "YouTube"), `white`
  (vòng trắng mờ + tam giác trắng). Scale = % chiều rộng, kẹp **10..60%**.
- API key Slink **chỉ đọc từ ô nhập trong GUI**, KHÔNG đọc `.env`.
- **fableon CHỈ hiểu `{{nextpage}}`**; `<!--nextpage-->` bị server xoá sạch.
- `published_slink_link` KHÔNG đoán link — lấy từ response (`/{slug}`).
- fableon API base `https://fableon.treeiq.biz/api`, site id `724`, category `266`.
- **Đăng bài lên fableon là TẠO THẬT ngay** — dò schema phải dùng payload THIẾU field.
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
