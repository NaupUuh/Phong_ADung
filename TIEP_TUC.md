# TIẾP TỤC — Phong_ADung (v22.100.12)

Cập nhật: 2026-10-07

## TRẠNG THÁI
- Đã vá 3 lỗi + thêm chia nhỏ request cho Adsconex. File chính:
  `viet_drama_V22.99_stable_folder.py` (LF-only, py_compile OK).
- 5 bài 502 tồn đọng đã đăng lại đủ 10 chương/bài (mỗi bài 1 series).

## NGUYÊN NHÂN GỐC 502 `origin_bad_gateway` (đã chốt — QUAN TRỌNG)
502 khi đăng Adsconex **KHÔNG phải do token, KHÔNG do payload bẩn**.
Origin site (dramanest.gigglelo.com) bị **timeout ~10–11 giây** khi request quá lớn:
- POST /posts content **> ~50KB** → Cloudflare 502 `origin_bad_gateway` sau ~11s.
- Cùng content đó **<= ~40KB** → 201 trong 2–9s.
- Tất định: cùng payload 78KB đăng OK ngày 06/10, nay 502 lặp lại y hệt mọi lần.
- Bisect: 1..7 chương (40KB) OK; 1..8 (47KB) 502; 7..8 / 5..8 / 1..6 / từng chương đều OK
  ⇒ ngưỡng theo **TỔNG dung lượng content**, không theo chương cụ thể.

## ĐÃ VÁ (v22.100.12)
1. **Chia nhỏ request** (`_adsconex_send_all` + `adsconex_split_chunks`) — vá chính cho 502.
   - content > `adsconex_max_chars_per_request` (mặc định **36000**) → cắt tại ranh giới
     `<p>CHAPTER N - ...</p>`, gửi nhiều lần.
   - **BẮT BUỘC** truyền `series_id` cho phần 2 trở đi (`adsconex_series_id_for_slug`).
     Không có series_id thì **mỗi POST tạo 1 series mới → chương bị tách** (đã bị thật).
   - Nghỉ giữa các phần: `adsconex_chunk_gap_seconds` (mặc định 3s).
   - Mọi phần OK → gộp `posts` trả về như 1 lần gửi; phần nào lỗi → trả payload GỐC để lưu đăng lại.
2. **Nút "Đăng lại bài lỗi" bỏ sót bài 502** — `find_pending_adsconex` trước chỉ nhặt 401/403.
   Nay nhặt cả `401/403/429/500/502/503/504/520-524/network`.
3. **Chống đăng trùng** — `adsconex_existing_slugs()` đối chiếu slug payload với `/series` trên site,
   bỏ qua bài đã có (ghi `republish_skipped_already_live.txt`). Bắt quả thật: 2/7 bài lưu
   `http_status=502` nhưng series **ĐÃ có trên site** (502 lỗi giả — origin đã tạo bài nhưng
   response bị cắt). Đăng lại mù sẽ sinh bài trùng.
4. **Nút "Lấy link site"** ra `https://https://...` khi config đã có scheme → đã sửa.
5. **`NameError: free variable 'e'`** khi cập nhật thất bại (`_update_work`, `_update_apply`):
   lambda trong `self.after(0, lambda: ...)` đọc biến `e` của `except` — đã hết scope khi Tk chạy.
   Sửa: gán `_err = str(e)` trước. Trước đây lỗi thật bị che bằng NameError.

## ĐÃ XỬ LÝ XONG TRÊN SITE
- 5 bài 502 trong `Z:\...\3 vu oan\ch đăng 4\Story Outputs` đã đăng lại đủ 10 chương/bài, mỗi bài 1 series.
- 5 bài này lúc đăng lần đầu (bản cũ) bị tách 2–3 series → đã gộp về 1 series bằng `PUT /posts/{id}`
  (đổi `series_id` + nối lại `next_chapter`/`prev_chapter`).

## VIỆC CÒN LẠI (cần xoá tay trong CMS — API không có route xoá/sửa series)
- **18 series test** tên `ZZPROBE ...` (id: 7241, 7249–7252, 7257–7259, 7261–7262, 7264–7265, 7267, 7271–7273, 7286, 7291).
- **6 series rỗng** (đã chuyển hết chương sang series chính): id 7275, 7277, 7279, 7280, 7282, 7283.

## NGUYÊN NHÂN GỐC 403 blogbio_verify_failed (bản cũ — giữ để tham chiếu)
Tool cũ hardcode **host chết `usjusticereport.cfx.bz`**. Host này chết thật:
- GET `/` → 200 (site tĩnh còn sống) NHƯNG mọi `/api/*` → **403 `blogbio_verify_failed`** với MỌI token.
- Cùng token đó bắn vào `dramanest.gigglelo.com` → **200**.
→ Máy chạy config trống/mặc định → trỏ host chết → 403 toàn bộ. Đã bỏ hẳn host chết khỏi cả 2 tool.

## LỆNH HAY DÙNG
```bash
cd C:/TOOLS UPDATE CUỐI/Phong_ADung/Phong_ADung
PY=C:/Users/Admin/AppData/Local/Programs/Python/Python313/python.exe
$PY -m py_compile viet_drama_V22.99_stable_folder.py   # kiem cu phap
$PY release.py 22.100.12 "mo ta thay doi"               # phat hanh
$PY sync_z.py                                           # copy len Z + doi chieu MD5
```

## BÀI HỌC
- **502 `origin_bad_gateway` = request quá lớn, KHÔNG phải token/payload.** Origin timeout ~10–11s.
  Ngưỡng nằm ở **tổng dung lượng content**, không theo số chương. An toàn: ~36KB/request.
- **`POST /api/posts` mode=chapter KHÔNG tự gộp theo `permalink`.** Mỗi POST không có `series_id`
  sẽ **tạo series mới**. Muốn gộp nhiều request vào 1 series **phải truyền `series_id`**.
- **Sửa bài qua `PUT /api/posts/{ID số}`** (slug trả 405). Ràng buộc: `next_chapter`/`prev_chapter`
  phải cùng series. Gộp series: gỡ link tạm (`next_chapter=null`) → đổi `series_id` → nối lại link.
  KHÔNG có route xoá (DELETE → 405).
- `GET /api/series` = đèn báo token sạch + dùng đối chiếu chống đăng trùng.
- Test tool thật: `POST {"title":""}` → 422 (không tạo bài).
- File `.bat` cho máy khác: **ASCII-only + CRLF + `pause`** (LF + tiếng Việt → tự tắt).
- Tool gửi header Chrome đầy đủ để qua Cloudflare (urllib trần bị `Error 1010`).
- Đọc/ghi file tool bằng `newline=""` (giữ LF; git blob cũng LF).

## 2026-10-07 (moi) - Fix Mo_An.vbs
- LOI: 'Microsoft VBScript compilation error: Expected end of statement' tai dong 20
  khi double-click Mo_An.vbs.
- NGUYEN NHAN: VBScript KHONG co escape \" nhu C/JS. Muon 1 dau " trong chuoi phai
  viet "" (gap doi).
  SAI : sh.Run """ & bat & """ hidden", 0, False
  DUNG: sh.Run """" & bat & """", 0, False
- DA TEST: cscript //nologo -> exit 0, goi dung .bat (tao marker). Da push GitHub.
- Neu gap lai loi nay o may khac: chay updater.py hoac chep de Mo_An.vbs ban moi.
