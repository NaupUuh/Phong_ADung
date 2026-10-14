# TIẾP TỤC — Phong_ADung

**Cập nhật lần cuối:** 2026-10-14 21:56
**Phiên bản hiện tại:** **v22.100.22** (đã release GitHub + push + sync ổ Z)
**File chính:** `viet_drama_V22.99_stable_folder.py` (LF, 0 dòng CRLF, UTF-8 no BOM)
**Nhánh:** main — commit `7919a8b`

---

## 1. Vừa xong trong phiên này (v22.100.22) — NÚT PLAY TRẮNG DÙNG PNG THẬT

### Bối cảnh
v22.100.21 đã thêm kiểu `white` nhưng **vẽ bằng PIL** (vòng trắng mờ alpha 95 +
tam giác) vì không tìm được file PNG ưng ý. Anh gửi ảnh nút play tham chiếu
(`img_c1a7ffded6c0.jpg`) rồi **gửi tiếp file PNG trong suốt thật**
(`img_6b3ac371b2c4.png`) và nói: *"E dùng file này cho a, đã xoá background"*.

### Phát hiện quan trọng: 2 ảnh anh gửi KHÁC NHAU về bản chất
| | `img_c1a7ffded6c0.jpg` (cũ) | `img_6b3ac371b2c4.png` (mới) |
|---|---|---|
| Định dạng | JPEG, **bàn cờ bake sẵn** (ô 22px, 233/252) | **PNG alpha thật** |
| Đĩa | **vòng ĐEN mờ** alpha ≈ 0.14–0.19, xuyên nền | **xám đặc #B0B0B0 (176)**, alpha 255, viền cứng |
| Shadow | không | **không** |
| Tam giác | trắng đặc, **bo góc** | trắng đặc, **NHỌN** |
| Đường kính | ~66% khung | **100% khung** |

→ Kết luận: file PNG mới là **asset thiết kế thật** (đĩa xám đặc + tam giác trắng
nhọn, không shadow). Bản JPEG cũ chỉ là bản render mờ.

### Số đo chính xác từ PNG (221×221 sau crop)
- Đĩa: **D = 220px**, tâm (278, 223) trong ảnh gốc 558×447; bbox crop `(168,113)-(389,334)`
- Màu đĩa: **#B0B0B0 = 176,176,176**; màu tam giác: **255,255,255**
- Viền: cứng, chuyển alpha 255→0 trong ~2px (không glow)
- Tam giác: **88×99px** → `th/D = 0.450`, `tw/D = 0.400`, `tw/th = 0.889`
- Lệch phải: **+0.048D**; lệch dọc: 0.0
- Diện tích tam giác = 13.6% diện tích đĩa

### Cách làm (thay bản PIL cũ)
Nhúng **chính file PNG anh gửi** vào code dạng **base64** để tool vẫn là 1 file `.py`:

```python
_WHITE_PLAY_B64 = ( "iVBORw0KGgo..."  # PNG 221x221, che do LA, 11352 B
                    ... )
_WHITE_PLAY_CACHE = None

def _white_play_asset():
    """Giai ma + cache anh nut play trang (RGBA). Chi doc 1 lan duy nhat."""
    global _WHITE_PLAY_CACHE
    if _WHITE_PLAY_CACHE is None:
        import io
        _WHITE_PLAY_CACHE = Image.open(
            io.BytesIO(base64.b64decode(_WHITE_PLAY_B64))).convert("RGBA")
    return _WHITE_PLAY_CACHE

def _draw_white_play_badge(base, scale, shadow=True):
    # art = _white_play_asset(); resize LANCZOS theo scale; alpha_composite giua anh
```

**Vì sao base64 mà không phải file rời:** tool là single-file, `updater.py` chỉ tải
các file trong danh sách cố định (không kéo theo thư mục `assets/`) → nhúng base64
thì máy khác bấm "Cập nhật" là có ngay, không lo thiếu file.

**Vì sao lưu chế độ `LA`:** ảnh chỉ có 2 màu xám/trắng → LA (grayscale + alpha)
nén còn 11.4 KB (base64 15.1 KB) thay vì RGBA 15.6 KB. **Roundtrip 0 sai** (đã verify).

### Đã sửa những chỗ nào
| # | Vị trí | Thay đổi |
|---|---|---|
| 1 | `_WHITE_PLAY_B64` + `_white_play_asset()` + `_draw_white_play_badge()` | thay bản vẽ PIL bằng asset PNG thật (base64) |
| 2 | docstring `draw_youtube_badge` | mô tả `white` = "dia xam dac #B0B0B0 + tam giac trang nhon" |
| 3 | nhãn GUI tab Image hosting | "vòng tròn trắng mờ" → "vòng tròn xám" |

Phần đọc config (`_youtube_badge_settings`, `preview_youtube_badge`, combobox)
**giữ nguyên** từ v22.100.21 — vẫn nhận `play`/`logo`/`white`.

---

## 2. Đã verify (test THẬT)

| Hạng mục | Kết quả |
|---|---|
| `py_compile` | OK |
| File chính | LF, **0 dòng CRLF** |
| **Pixel-exact vs ảnh anh gửi** | **alpha giống hệt từng pixel** (`array_equal`=True), chỉ khác RGB ở vùng alpha=0 (không hiển thị) ✅ |
| Hình học tái tạo | th/D=0.448, tw/D=0.398, lệch phải +0.048D — khớp ảnh gốc ✅ |
| `make_social_thumbnail` | `play` / `logo` / `white` đều ra 290×290 OK |
| Hiển thị 4 nền × 3 scale | nút rõ trên nền tối/trắng/nâu/xanh, **không mất hút trên nền trắng** ✅ |
| Viền | sạch, không răng cưa (vision xác nhận ở cả scale 20%) |
| Style lạ (`xyz`, `""`) | fallback `play`, không crash |
| `white`/`WHITE`/`  White  `/`trang` | đều nhận |
| Config thật `~/.video_story_publisher_V22.99.json` | **KHÔNG bị ghi đè** (mtime 11:56:44) |
| Backup bản gốc | `_backup_old/...v22.100.21_20261014_2154.py` (từ `git show HEAD`) |
| Sync ổ Z | **20/20 MD5 khớp** |
| `git status` sau release | sạch, đã push (`origin/main` = `7919a8b`) |

---

## 3. Còn lại / chưa trả lời

- **Chưa bấm nút "Xem trước logo" trong GUI** (đã test qua đúng hàm
  `make_social_thumbnail` mà GUI gọi; chưa thao tác chuột trong GUI).
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
  (**asset PNG thật**: đĩa xám #B0B0B0 + tam giác trắng nhọn). Scale = % chiều rộng,
  kẹp **10..60%**.
- **Asset `white` nằm trong `_WHITE_PLAY_B64`** (base64, chế độ LA, 221×221). Muốn đổi
  ảnh: crop sát alpha>0 → lưu PNG LA `optimize=True, compress_level=9` → base64 →
  thay chuỗi trong `_WHITE_PLAY_B64`. Nhớ **xoá `_WHITE_PLAY_CACHE`** khi đổi.
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

---

## 6. Đổi ảnh nút play `white` (khi anh gửi file mới)

```python
import base64, io, numpy as np
from PIL import Image
im = Image.open(SRC).convert("RGBA")
a = np.asarray(im); ys, xs = np.nonzero(a[:,:,3] > 0)
asset = im.crop((int(xs.min()), int(ys.min()), int(xs.max())+1, int(ys.max())+1))
buf = io.BytesIO(); asset.convert("LA").save(buf, format="PNG", optimize=True, compress_level=9)
b64 = base64.b64encode(buf.getvalue()).decode()
# chia 96 ky tu/dong, thay vao _WHITE_PLAY_B64, roi dat _WHITE_PLAY_CACHE = None
```
