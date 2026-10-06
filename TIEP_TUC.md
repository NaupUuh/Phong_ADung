# TIẾP TỤC — Phong_ADung (v22.100.10)

Cập nhật: 2026-10-06

## TRẠNG THÁI
- Đã release public **v22.100.10** (commit `bb36287`, push 2026-10-06T17:02:36Z).
- Sync Z xong: `Z:\HQData-2\TOOLS TỔNG HỢP\TOOLS UPDATE CUỐI\Phong_ADung` (13/13 MD5 khớp).
- File chính: `viet_drama_V22.99_stable_folder.py` (CRLF 6877 / LF-only 0). py_compile OK.

## NGUYÊN NHÂN GỐC LỖI 403 blogbio_verify_failed (đã chốt)
Tool có **host chết `usjusticereport.cfx.bz`** làm mặc định. Host này CHẾT THẬT:
- GET `/` → 200 (site tĩnh còn sống) NHƯNG mọi endpoint `/api/*` → **403 `blogbio_verify_failed` / `verify_status:502`** với MỌI token (kể cả token đúng).
- Cùng token đó bắn vào `dramanest.gigglelo.com` → **200**.
→ Máy nào chạy với config trống/mặc định → trỏ vào host chết → 403 toàn bộ, y hệt lỗi máy `Admin`.

**Cách ly bằng chứng:** cùng 1 token, 2 host: `dramanest.gigglelo.com` GET 200 / POST 422; `usjusticereport.cfx.bz` GET 403 / POST 403.
Token rác → 403 `blogbio_verify_failed`. Token đúng + host chết → **cũng 403 y hệt**. ⇒ Lỗi này là **host/tầng verify**, không phân biệt được token sai hay host chết nếu chỉ nhìn 403.

## ĐÃ VÁ
1. **Bỏ hẳn host chết** `usjusticereport.cfx.bz` (11 chỗ ADung / 12 chỗ DHue) → `dramanest.gigglelo.com`.
   Chỉ dùng host điền trong tool (`adsconex_base_url` / `adsconex_site_host`).
2. **Vá 401/403:** token bị từ chối → **LƯU payload** (`adsconex_write_pending`) để đăng lại, kèm thông báo rõ nguyên nhân.
   Trước đây 42 bài 403 **mất trắng** (không tạo trên site, không lưu payload).
   An toàn: đã kiểm chứng bài 403 KHÔNG hề được tạo (404) → đăng lại không sinh trùng.
3. Cập nhật `_api_docs_adsconex.txt` sang host mới.

## VIỆC CÒN LẠI
- [ ] **Máy `Admin` (máy lỗi):** bấm "⬆ Cập nhật" trong tool, HOẶC sửa tab Adsconex:
      - API base URL = `https://dramanest.gigglelo.com/api`
      - Site host     = `dramanest.gigglelo.com`
      → rồi bấm **"Kiểm tra token"** (phải ra OK) → bấm **"Đăng lại bài lỗi"** để cứu các bài đã lưu.
- [ ] Nếu máy Admin vẫn 403 sau khi đổi host → lúc đó mới nghi token (bấm "Kiểm tra token").
- [ ] Bài rác test (~14 series) chưa dọn — API không có route xoá (DELETE → 405), phải xoá tay trong CMS.
- [ ] Token dramanest đang dùng: [KHÔNG IN RA]. SHA256 đầu `a1b18c6d...`.

## LỆNH HAY DÙNG
```bash
cd C:/Users/Admin/Desktop/Phong_ADung
PY=C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe
$PY -m py_compile viet_drama_V22.99_stable_folder.py   # kiem cu phap
$PY release.py 22.100.10 "mo ta thay doi"               # phat hanh
$PY sync_z.py                                           # copy len Z + doi chieu MD5
```

## BÀI HỌC
- **Đừng tin GET 200 của 1 host là token OK.** Phải test **cùng token trên đúng host tool đang dùng**.
- Lỗi `blogbio_verify_failed` KHÔNG nói được là token sai hay host chết → phải thử token trên host đã biết tốt.
- Test tool thật chỉ dùng `POST {"title":""}` → 422 (không tạo bài). Đèn báo token sạch = `GET /api/categories`.
- File `.bat` cho máy khác: **ASCII-only + CRLF + `pause`** (LF + tiếng Việt → tự tắt).
- Tool gửi header Chrome đầy đủ để qua Cloudflare (urllib trần bị `Error 1010`).
- Đọc/ghi file tool bằng `newline=""` (CRLF, không được đổi sang LF).
